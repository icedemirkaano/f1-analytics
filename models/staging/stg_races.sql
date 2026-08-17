select
    raceId                      as race_id,
    year                        as season_year,
    round                       as round_number,
    circuitId                   as circuit_id,
    name                        as race_name,
    date                        as race_date,
    safe_cast(time as time)     as race_time_utc
from {{ source('raw_f1', 'races') }}