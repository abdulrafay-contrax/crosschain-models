{% macro run_get_coin_market_cap_hourly_ohlc() %}
    {% set sql %}
        call streamline.get_coin_market_cap_hourly_ohlc();
    {% endset %}

    {% do run_query(sql) %}
{% endmacro %}