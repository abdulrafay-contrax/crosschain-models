{% macro udf_bulk_get_coin_gecko_asset_market_data_historical() %}
    CREATE
    OR REPLACE EXTERNAL FUNCTION streamline.udf_bulk_get_coin_gecko_asset_market_data_historical() returns text api_integration = aws_crosschain_api_dev AS {% if target.database == "CROSSCHAIN" -%}
        'https://q2il6n5mmg.execute-api.us-east-1.amazonaws.com/prod/bulk_get_coin_gecko_asset_market_data_historical'
    {% else %}
        'https://ubuxgfotp2.execute-api.us-east-1.amazonaws.com/dev/bulk_get_coin_gecko_asset_market_data_historical'
    {%- endif %}
{% endmacro %}