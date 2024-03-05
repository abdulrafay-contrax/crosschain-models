{{ config (
    materialized = "view",
    post_hook = fsc_utils.if_data_call_function_v2(
        func = 'udf_bulk_rest_api_v2',
        target = "{{this.schema}}.{{this.identifier}}",
        params = {
            "external_table": "ASSET_METADATA_API/COINGECKO",
            "sql_limit": "10",
            "producer_batch_size": "10",
            "worker_batch_size": "10",
            "sm_secret_name": "prod/coingecko/rest",
            "sql_source": "{{this.identifier}}"
        }
    ),
    tags = ['streamline_asset_metadata_realtime']
) }}

WITH calls AS (

    SELECT
        '{service}/api/v3/coins/list?include_platform=true&x_cg_pro_api_key={Authentication}' AS api_url
)
SELECT
    DATE_PART('EPOCH', SYSDATE())::INTEGER AS partition_key,
    ARRAY_CONSTRUCT(
        partition_key,
        ARRAY_CONSTRUCT(
            'GET',
            api_url,
            PARSE_JSON('{}'),
            PARSE_JSON('{}'),
            ''
        ) 
    ) AS request
FROM
    calls
    -- needs to run 10-15 min prior to prices workflows (asset metadata referenced in history + realtime models)