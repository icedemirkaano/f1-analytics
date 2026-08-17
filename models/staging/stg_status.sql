select
    s.statusId  as status_id,
    s.status    as status_text,
    case
        when s.status = 'Finished'                    then 'finished'
        when s.status like '+%Lap%'                   then 'finished_lapped'
        when s.status in ('Accident', 'Collision', 'Collision damage',
                          'Spun off', 'Damage')       then 'dnf_incident'
        when s.status in ('Disqualified', 'Did not qualify', 'Did not prequalify',
                          'Withdrew', 'Not classified', 'Retired',
                          'Injury', 'Illness')        then 'dnf_other'
        else 'dnf_mechanical'
    end as status_group
from {{ source('raw_f1', 'status') }} as s