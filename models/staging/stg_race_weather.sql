select
    race_id,

    temperature_c,
    humidity_pct,
    wind_speed_kmh,

    precip_total_mm,
    precip_max_hourly_mm,
    precip_start_mm,
    weather_code_max,

    weather_condition,
    is_wet,

    time_source,
    local_hour_used,
    window_hours

from {{ source('raw_f1', 'race_weather') }}