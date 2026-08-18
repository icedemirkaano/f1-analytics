select
    s.statusId  as status_id,
    s.status    as status_text,
    case
        when s.status = 'Finished'                              then 'finished'
        when s.status like '+%Lap%'                             then 'finished_lapped'

        when s.status in ('Accident', 'Collision', 'Collision damage',
                          'Spun off', 'Damage', 'Fatal accident',
                          'Debris')                             then 'dnf_incident'

        when s.status in ('Did not qualify', 'Did not prequalify', 'Withdrew',
                          'Not classified', 'Disqualified', 'Retired',
                          'Injury', 'Illness', 'Injured', 'Physical',
                          'Driver unwell', 'Eye injury', '107% Rule',
                          'Excluded', 'Underweight', 'Safety',
                          'Safety concerns', 'Not restarted',
                          'Safety belt', 'Driver Seat', 'Seat')  then 'dnf_other'

        when s.status in ('Out of fuel', 'Fuel', 'Refuelling', 'Fuel rig',
                          'Puncture', 'Tyre puncture', 'Tyre',
                          'Wheel nut', 'Stalled')                then 'dnf_team_or_external'

        when s.status in ('Engine', 'Gearbox', 'Suspension', 'Transmission',
                          'Electrical', 'Brakes', 'Clutch', 'Fuel system',
                          'Turbo', 'Hydraulics', 'Overheating', 'Ignition',
                          'Oil leak', 'Throttle', 'Halfshaft', 'Wheel',
                          'Oil pressure', 'Fuel pump', 'Differential',
                          'Handling', 'Fuel leak', 'Steering', 'Radiator',
                          'Power Unit', 'Wheel bearing', 'Injection',
                          'Fuel pressure', 'Water leak', 'Alternator',
                          'Exhaust', 'Mechanical', 'Chassis', 'Magneto',
                          'Driveshaft', 'Axle', 'Heat shield fire', 'Battery',
                          'Power loss', 'Distributor', 'Oil pump', 'Oil pipe',
                          'Broken wing', 'Electronics', 'Rear wing',
                          'Vibrations', 'Water pressure', 'Water pump',
                          'Supercharger', 'ERS', 'Front wing', 'Technical',
                          'Pneumatics', 'Undertray', 'Spark plugs',
                          'Water pipe', 'Wheel rim', 'Fuel pipe', 'Fire',
                          'Drivetrain', 'Track rod', 'Oil line',
                          'Engine misfire', 'Cooling system', 'Brake duct',
                          'Launch control', 'Crankshaft', 'CV joint',
                          'Engine fire')                         then 'dnf_mechanical'

        else 'dnf_unclassified'
    end as status_group
from {{ source('raw_f1', 'status') }} as s