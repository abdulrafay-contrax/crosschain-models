{{ config(
    materialized = 'incremental',
    unique_key = "address",
    incremental_strategy = 'merge',
    merge_update_columns = ['creator'],
    merge_exclude_columns = ["inserted_timestamp"],
) }}

WITH buyers AS (

    SELECT
        DISTINCT 'ethereum' AS blockchain,
        'flipside' AS creator,
        nft_to_address AS address,
        'looksrare user' AS tag_name,
        'nft' AS tag_type,
        MIN(
            block_timestamp :: DATE
        ) AS start_date,
        NULL AS end_date,
        CURRENT_TIMESTAMP AS tag_created_at,
        MIN(_INSERTED_TIMESTAMP) AS ingested_at
    FROM
        {{ source(
            'ethereum_silver_nft',
            'looksrare_sales'
        ) }}

{% if is_incremental() %}
WHERE
    _INSERTED_TIMESTAMP > (
        SELECT
            MAX(ingested_at)
        FROM
            {{ this }}
    )
{% endif %}
GROUP BY
    nft_to_address
),
sellers AS (
    SELECT
        DISTINCT 'ethereum' AS blockchain,
        'flipside' AS creator,
        nft_from_address AS address,
        'looksrare user' AS tag_name,
        'nft' AS tag_type,
        MIN(
            block_timestamp :: DATE
        ) AS start_date,
        NULL AS end_date,
        CURRENT_TIMESTAMP AS tag_created_at,
        MIN(_INSERTED_TIMESTAMP) AS ingested_at
    FROM
        {{ source(
            'ethereum_silver_nft',
            'looksrare_sales'
        ) }}

{% if is_incremental() %}
WHERE
    _INSERTED_TIMESTAMP > (
        SELECT
            MAX(ingested_at)
        FROM
            {{ this }}
    )
{% endif %}
GROUP BY
    nft_from_address
),
union_table AS (
    SELECT
        *
    FROM
        buyers
    UNION
    SELECT
        *
    FROM
        sellers
),
final_table AS (
    SELECT
        *
    FROM
        union_table qualify(ROW_NUMBER() over(PARTITION BY address
    ORDER BY
        start_date ASC)) = 1
)
SELECT
    A.*,
    sysdate() as inserted_timestamp,
    sysdate() as modified_timestamp,
    {{ dbt_utils.generate_surrogate_key(['address']) }} AS tags_nft_looksrare_user_id,
    '{{ invocation_id }}' as _invocation_id  
FROM
    final_table A
