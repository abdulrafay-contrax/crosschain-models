{{ config(
    materialized = 'incremental',
    unique_key = ['token_address', 'platform'],
    incremental_strategy = 'delete+insert',
    cluster_by = ['_inserted_timestamp::DATE']
) }}

WITH base_assets AS (

    SELECT
        id,
        p.value :: STRING AS token_address,
        NAME,
        symbol,
        p.key :: STRING AS platform,
        _inserted_timestamp,
        SYSDATE() AS inserted_timestamp,
        SYSDATE() AS modified_timestamp,
        {{ dbt_utils.generate_surrogate_key(['token_address','platform']) }} AS asset_metadata_coin_gecko_id,
        '{{ invocation_id }}' AS _invocation_id
    FROM
        {{ ref('silver__all_asset_metadata_coingecko2') }} A,
        LATERAL FLATTEN(
            input => VALUE :platforms
        ) p

{% if is_incremental() %}
WHERE
    _inserted_timestamp > (
        SELECT
            MAX(_inserted_timestamp)
        FROM
            {{ this }}
    )
{% endif %}
)
SELECT
    id,
    token_address,
    NAME,
    symbol,
    platform,
    _inserted_timestamp,
    inserted_timestamp,
    modified_timestamp,
    asset_metadata_coin_gecko_id,
    _invocation_id
FROM
    base_assets
WHERE
    token_address IS NOT NULL
    AND LENGTH(token_address) > 0
    AND platform IS NOT NULL
    AND LENGTH(platform) > 0 qualify(ROW_NUMBER() over (PARTITION BY token_address, platform
ORDER BY
    _inserted_timestamp DESC)) = 1 -- specifically built for tokens with token_address (not native/gas tokens)
