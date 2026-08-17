select
    circuitId   as circuit_id,
    circuitRef  as circuit_ref,
    name        as circuit_name,
    location    as city,
    country     as country,
    lat         as latitude,
    lng         as longitude,
    alt         as altitude_m
from {{ source('raw_f1', 'circuits') }}