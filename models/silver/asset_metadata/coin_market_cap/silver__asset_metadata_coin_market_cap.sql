{{ config(
    materialized = 'incremental',
    unique_key = "CONCAT_WS('-', id, coalesce(token_address,''))",
    incremental_strategy = 'delete+insert'
) }}

SELECT
    id,
    NAME,
    symbol,
    VALUE :platform :token_address :: STRING AS token_address,
    VALUE :platform :name :: STRING AS platform,
    _inserted_timestamp,
    sysdate() as inserted_timestamp,
    sysdate() as modified_timestamp,
    {{ dbt_utils.generate_surrogate_key(['id','token_address']) }} as asset_metadata_coin_market_cap_id,
    '{{ invocation_id }}' as _invocation_id
FROM
    {{ ref('bronze__asset_metadata_coin_market_cap') }}

{% if is_incremental() %}
WHERE
    _inserted_date >= (
        SELECT
            MAX(
                _inserted_timestamp :: DATE
            )
        FROM
            {{ this }}
    )
    AND _inserted_timestamp > (
        SELECT
            MAX(_inserted_timestamp)
        FROM
            {{ this }}
    )
{% endif %}

qualify(ROW_NUMBER() over (PARTITION BY id, token_address
ORDER BY
    _inserted_timestamp DESC)) = 1