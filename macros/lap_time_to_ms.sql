{% macro lap_time_to_ms(col) %}
case
  when {{ col }} is null or {{ col }} = '' then null
  when strpos({{ col }}, ':') > 0 then
    safe_cast(split({{ col }}, ':')[offset(0)] as int64) * 60000
    + cast(round(safe_cast(split({{ col }}, ':')[offset(1)] as float64) * 1000) as int64)
  else cast(round(safe_cast({{ col }} as float64) * 1000) as int64)
end
{% endmacro %}