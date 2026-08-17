select
    qualifyId                       as qualify_id,
    raceId                          as race_id,
    driverId                        as driver_id,
    constructorId                   as constructor_id,
    position                        as quali_position,
    {{ lap_time_to_ms("q1") }}      as q1_ms,
    {{ lap_time_to_ms("q2") }}      as q2_ms,
    {{ lap_time_to_ms("q3") }}      as q3_ms,
    coalesce(
        {{ lap_time_to_ms("q3") }},
        {{ lap_time_to_ms("q2") }},
        {{ lap_time_to_ms("q1") }}
    )                               as best_quali_ms
from {{ source('raw_f1', 'qualifying') }}