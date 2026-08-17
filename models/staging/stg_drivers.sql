select
    driverId                        as driver_id,
    driverRef                       as driver_ref,
    code                            as driver_code,
    forename                        as first_name,
    surname                         as last_name,
    concat(forename, ' ', surname)  as driver_name,
    dob                             as birth_date,
    nationality                     as nationality,
    safe_cast(number as int64)      as permanent_number
from {{ source('raw_f1', 'drivers') }}