{{ config(
    materialized = 'incremental',
    unique_key = "CONCAT_WS('-', address, tag_name, start_date)",
    incremental_strategy = 'delete+insert',
) }}

WITH display AS (

    SELECT
        DISTINCT tx_hash,
        block_timestamp,
        decoded_flat :displayName :: STRING AS tag_name,
        _inserted_timestamp
    FROM
        {{ source(
            'avalanche_silver',
            'decoded_logs'
        ) }}
    WHERE
        contract_address ILIKE '0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d'
        AND event_name = 'RegistrationApproved'

{% if is_incremental() %}
AND _inserted_timestamp > (
    SELECT
        MAX(_inserted_timestamp)
    FROM
        {{ this }}
)
{% endif %}
),
register AS (
    SELECT
        DISTINCT tx_hash,
        block_timestamp,
        decoded_flat: adminAddress :: STRING AS address
    FROM
        {{ source(
            'avalanche_silver',
            'decoded_logs'
        ) }}
    WHERE
        contract_address ILIKE '0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d'
        AND event_name ILIKE 'RegistrationRequested'

{% if is_incremental() %}
AND _inserted_timestamp > (
    SELECT
        MAX(_inserted_timestamp)
    FROM
        {{ this }}
)
{% endif %}
),
base_table AS (
    SELECT
        'avalanche' AS blockchain,
        'flipside' AS creator,
        b.address,
        A.tag_name,
        'chainlink oracle' AS tag_type,
        A.block_timestamp :: DATE AS start_date,
        NULL AS end_date,
        A._inserted_timestamp,
        CURRENT_TIMESTAMP AS tag_created_at
    FROM
        display A
        JOIN register b
        ON A.tx_hash = b.tx_hash
    WHERE
        address IS NOT NULL
        AND tag_name IS NOT NULL
)
SELECT
    *,
    sysdate() as inserted_timestamp,
    sysdate() as modified_timestamp,
    {{ dbt_utils.generate_surrogate_key(['address','tag_name','start_date']) }} AS tags_chainlink_oracle_avalanche_id,
    '{{ invocation_id }}' as _invocation_id
FROM
    base_table qualify(ROW_NUMBER() over(PARTITION BY address, tag_name
ORDER BY
    start_date DESC)) = 1
