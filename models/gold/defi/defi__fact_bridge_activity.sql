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
        blockchain AS source_chain,
        destination_chain,
        bridge_address,
        sender AS source_address,
        destination_chain_receiver AS destination_address,
        'out' AS direction,        
        token_address,
        amount_unadj AS amount_raw,
        COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
        COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
        ez_bridge_activity_id AS fact_bridge_activity_id
    FROM
        {{ source(
            'ethereum_defi',
            'ez_bridge_activity'
        ) }}
    UNION ALL
    SELECT
        'optimism' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        blockchain AS source_chain,
        destination_chain,
        bridge_address,
        sender AS source_address,
        destination_chain_receiver AS destination_address,        
        'out' AS direction,        
        token_address,
        amount_unadj AS amount_raw,
        COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
        COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
        ez_bridge_activity_id AS fact_bridge_activity_id
    FROM
        {{ source(
            'optimism_defi',
            'ez_bridge_activity'
        ) }}
    UNION ALL
    SELECT
        'avalanche' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        blockchain AS source_chain,
        destination_chain,
        bridge_address,
        sender AS source_address,
        destination_chain_receiver AS destination_address,        
        'out' AS direction,        
        token_address,
        amount_unadj AS amount_raw,
        COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
        COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
        ez_bridge_activity_id AS fact_bridge_activity_id
    FROM
        {{ source(
            'avalanche_defi',
            'ez_bridge_activity'
        ) }}
    UNION ALL
    SELECT
        'polygon' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        blockchain AS source_chain,
        destination_chain,
        bridge_address,
        sender AS source_address,
        destination_chain_receiver AS destination_address,        
        'out' AS direction,        
        token_address,
        amount_unadj AS amount_raw,
        COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
        COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
        ez_bridge_activity_id AS fact_bridge_activity_id
    FROM
        {{ source(
            'polygon_defi',
            'ez_bridge_activity'
        ) }}
    UNION ALL
    SELECT
        'bsc' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        blockchain AS source_chain,
        destination_chain,
        bridge_address,
        sender AS source_address,
        destination_chain_receiver AS destination_address,        
        'out' AS direction,        
        token_address,
        amount_unadj AS amount_raw,
        COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
        COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
        ez_bridge_activity_id AS fact_bridge_activity_id
    FROM
        {{ source(
            'bsc_defi',
            'ez_bridge_activity'
        ) }}
    UNION ALL
    SELECT
        'arbitrum' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        blockchain AS source_chain,
        destination_chain,
        bridge_address,
        sender AS source_address,
        destination_chain_receiver AS destination_address,        
        'out' AS direction,        
        token_address,
        amount_unadj AS amount_raw,
        COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
        COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
        ez_bridge_activity_id AS fact_bridge_activity_id
    FROM
        {{ source(
            'arbitrum_defi',
            'ez_bridge_activity'
        ) }}
    UNION ALL
    SELECT
        'base' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        blockchain AS source_chain,
        destination_chain,
        bridge_address,
        sender AS source_address,
        destination_chain_receiver AS destination_address,        
        'out' AS direction,        
        token_address,
        amount_unadj AS amount_raw,
        COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
        COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
        ez_bridge_activity_id AS fact_bridge_activity_id
    FROM
        {{ source(
            'base_defi',
            'ez_bridge_activity'
        ) }}
    UNION ALL
    SELECT
        'gnosis' AS blockchain,
        platform,
        block_number,
        block_timestamp,
        tx_hash,
        blockchain AS source_chain,
        destination_chain,
        bridge_address,
        sender AS source_address,
        destination_chain_receiver AS destination_address,        
        'out' AS direction,        
        token_address,
        amount_unadj AS amount_raw,
        COALESCE(inserted_timestamp,'2000-01-01') as inserted_timestamp,
        COALESCE(modified_timestamp,'2000-01-01') as modified_timestamp,
        ez_bridge_activity_id AS fact_bridge_activity_id
    FROM
        {{ source(
            'gnosis_defi',
            'ez_bridge_activity'
        ) }}
)
SELECT
    blockchain,
    platform,
    block_number,
    block_timestamp,
    tx_hash,
    source_chain,
    destination_chain,
    bridge_address,
    source_address,
    destination_address,        
    direction,        
    token_address,
    amount_raw,
    inserted_timestamp,
    modified_timestamp,
    fact_bridge_activity_id
FROM
    base
