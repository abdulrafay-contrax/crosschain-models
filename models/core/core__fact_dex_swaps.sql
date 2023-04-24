{{ config(
    materialized = 'view',
    persist_docs ={ "relation": true,
    "columns": true }
) }}

WITH base AS (

    SELECT
        'ethereum' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        sender AS trader,
        token_in,
        amount_in_unadj AS amount_in_raw,
        token_out,
        amount_out_unadj AS amount_out_raw,
        _log_id
    FROM
        {{ source(
            'ethereum_silver_dex',
            'complete_dex_swaps'
        ) }}
    UNION ALL
    SELECT
        'optimism' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        sender AS trader,
        token_in,
        amount_in_unadj AS amount_in_raw,
        token_out,
        amount_out_unadj AS amount_out_raw,
        _log_id
    FROM
        {{ source(
            'optimism_silver_dex',
            'complete_dex_swaps'
        ) }}
    UNION ALL
    SELECT
        'avalanche' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        sender AS trader,
        token_in,
        amount_in_unadj AS amount_in_raw,
        token_out,
        amount_out_unadj AS amount_out_raw,
        _log_id
    FROM
        {{ source(
            'avalanche_silver_dex',
            'complete_dex_swaps'
        ) }}
    UNION ALL
    SELECT
        'osmosis' AS blockchain,
        'osmosis' platform,
        block_id AS block_number,
        block_timestamp,
        tx_id AS tx_hash,
        trader AS trader,
        from_currency AS token_in,
        from_amount AS amount_in,
        to_currency AS token_out,
        to_amount amount_out,
        CONCAT(
            tx_id,
            '-',
            _BODY_INDEX
        ) AS _log_id
    FROM
        {{ source(
            'osmosis_silver',
            'swaps'
        ) }}
)
SELECT
    blockchain,
    platform,
    block_number,
    block_timestamp,
    tx_hash,
    trader,
    token_in,
    amount_in_raw,
    token_out,
    amount_out_raw,
    _log_id
FROM
    base
