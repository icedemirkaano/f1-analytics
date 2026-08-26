-- models/staging/stg_status.sql
--
-- DEGISIKLIK NOTU (bu iterasyon):
-- Onceki surumde 'Did not qualify', 'Did not prequalify', 'Withdrew' ve
-- '107% Rule' degerleri dnf_other icinde toplaniyordu. Bu 1.613 kayit
-- yarisa HIC BASLAMAMIS surucülere ait. Bitirememek ile hic baslamamak
-- farkli seyler oldugu icin bunlar ayri bir 'dns' kategorisine alindi.
--
-- Etkisi: 1980'lerde DNF orani %61,5'ten %54,5'e iniyor. Modern donemde
-- fark 1 puanin altinda. Yani "guvenilirlik devrimi" anlatisi degismiyor,
-- sadece eski donemlerin sisirilmis olcumu duzeliyor.

select
    s.statusId  as status_id,
    s.status    as status_text,

    case
        ------------------------------------------------------------------
        -- YARISI BITIRENLER
        ------------------------------------------------------------------
        when s.status = 'Finished'                              then 'finished'
        when s.status like '+%Lap%'                             then 'finished_lapped'

        ------------------------------------------------------------------
        -- YARISA HIC BASLAMAYANLAR  (YENI KATEGORI)
        -- Bu kayitlar DNF sayilmamali: arac bozulmadi, kaza olmadi,
        -- surucu zaten gride cikmadi. 1980'lerin on eleme doneminde
        -- cok sayida takim yarisa katilmaya calisip eleniyordu.
        ------------------------------------------------------------------
        when s.status in ('Did not qualify',
                          'Did not prequalify',
                          'Withdrew',
                          '107% Rule')                          then 'dns'

        ------------------------------------------------------------------
        -- KAZA KAYNAKLI TERK
        ------------------------------------------------------------------
        when s.status in ('Accident', 'Collision', 'Collision damage',
                          'Spun off', 'Damage', 'Fatal accident',
                          'Debris')                             then 'dnf_incident'

        ------------------------------------------------------------------
        -- MEKANIK ARIZA
        ------------------------------------------------------------------
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
                          'Engine fire')                        then 'dnf_mechanical'

        ------------------------------------------------------------------
        -- TAKIM VEYA DIS ETKEN
        ------------------------------------------------------------------
        when s.status in ('Out of fuel', 'Fuel', 'Refuelling', 'Fuel rig',
                          'Puncture', 'Tyre puncture', 'Tyre',
                          'Wheel nut', 'Stalled')               then 'dnf_team_or_external'

        ------------------------------------------------------------------
        -- DIGER TERK SEBEPLERI
        -- Yarisa basladi ama siniflandirilmadi. Icerik karisik:
        -- idari (Disqualified, Excluded), belirsiz (Retired, Not classified)
        -- ve surucu kaynakli (Injury, Illness) durumlar.
        ------------------------------------------------------------------
        when s.status in ('Not classified', 'Disqualified', 'Retired',
                          'Excluded', 'Underweight', 'Not restarted',
                          'Injury', 'Illness', 'Injured', 'Physical',
                          'Driver unwell', 'Eye injury',
                          'Safety', 'Safety concerns',
                          'Safety belt', 'Driver Seat', 'Seat')  then 'dnf_other'

        else 'dnf_unclassified'
    end as status_group,

    -- Yarisi fiilen basladi mi? Alt analizlerde payda olarak kullanilir.
    case
        when s.status in ('Did not qualify', 'Did not prequalify',
                          'Withdrew', '107% Rule')              then false
        else true
    end as did_start

from {{ source('raw_f1', 'status') }} as s