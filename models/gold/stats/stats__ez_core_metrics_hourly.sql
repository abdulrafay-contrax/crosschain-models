{{ config(
    materialized = 'view',
    persist_docs ={ "relation": true,
    "columns": true },
    meta ={ 'database_tags':{ 'table':{ 'PURPOSE': 'STATS, METRICS, CORE, HOURLY',
    } } }
) }}

SELECT
    'ethereum' AS blockchain,
    block_timestamp_hour,
    block_number_min,
    block_number_max,
    block_count,
    transaction_count,
    transaction_count_success,
    transaction_count_failed,
    unique_from_count AS unique_initiator_count,
    'ETH' AS fee_currency,
    total_fees,
    total_fees * p.price AS total_fees_usd,
    COALESCE (
        core_metrics_hourly_id,
        {{ dbt_utils.generate_surrogate_key(
            ['block_timestamp_hour']
        ) }}
    ) AS ez_core_metrics_hourly_id,
    COALESCE(
        inserted_timestamp,
        '2000-01-01'
    ) AS inserted_timestamp,
    COALESCE(
        modified_timestamp,
        '2000-01-01'
    ) AS modified_timestamp
FROM
    {{ ref('silver_metrics__core_hourly') }}
    s
    LEFT JOIN {{ ref('price__ez_hourly_token_prices') }}
    p
    ON s.block_timestamp_hour = p.hour
    AND p.token_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2' --WETH
    AND p.blockchain = 'ethereum' --use ethereum for L2s (better price coverage)
