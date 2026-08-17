select
    resultId                                 as result_id,
    raceId                                   as race_id,
    driverId                                 as driver_id,
    constructorId                            as constructor_id,
    statusId                                 as status_id,

    grid                                     as grid_position,
    positionOrder                            as position_order,
    safe_cast(position as int64)             as finish_position,
    positionText                             as position_text,
    points                                   as points,
    laps                                     as laps_completed,

    safe_cast(milliseconds as int64)         as race_ms,
    safe_cast(fastestLap as int64)           as fastest_lap_number,
    safe_cast(rank as int64)                 as fastest_lap_rank,
    safe_cast(fastestLapSpeed as float64)    as fastest_lap_kph,
    {{ lap_time_to_ms("fastestLapTime") }}   as fastest_lap_ms,

    positionOrder <= 3                       as podium_flag,
    safe_cast(position as int64) is not null as classified_flag
from {{ source('raw_f1', 'results') }}