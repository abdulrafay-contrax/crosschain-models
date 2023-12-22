{{ config (
    materialized = "incremental",
    unique_key = "uid",
    cluster_by = "run_time::date",
    post_hook = "ALTER TABLE {{ this }} ADD SEARCH OPTIMIZATION on equality(uid)",
    tags = ['streamline_prices_complete']
) }}

SELECT
    id,
    run_time,
    metadata,
    data,
    error,
    id || '-' || run_time::VARCHAR as uid
FROM

{{ source( "bronze_streamline", "asset_prices_coin_gecko_api") }}

 
QUALIFY(ROW_NUMBER() OVER (PARTITION BY uid
ORDER BY
    run_time DESC)) = 1
