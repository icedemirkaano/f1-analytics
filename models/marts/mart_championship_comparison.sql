with surucu_sezon as (

    select
        m.season_year,
        m.driver_id,
        d.driver_name,
        sum(m.points_original)              as puan_orijinal,
        sum(m.points_modern)                as puan_modern,
        countif(m.finish_position = 1)      as galibiyet,
        countif(m.finish_position <= 3)     as podyum,
        countif(m.finish_position <= 10)    as ilk10_bitis,
        count(*)                            as katilim
    from {{ ref('int_results_modern_points') }} m
    join {{ ref('stg_drivers') }} d using (driver_id)
    group by 1, 2, 3

),

siralamalar as (

    select
        *,
        rank() over (partition by season_year order by puan_orijinal desc) as sira_orijinal,
        rank() over (partition by season_year order by puan_modern desc)   as sira_modern
    from surucu_sezon
    where puan_orijinal > 0 or puan_modern > 0

)

select
    season_year,
    driver_id,
    driver_name,
    katilim,
    galibiyet,
    podyum,
    ilk10_bitis,
    puan_orijinal,
    puan_modern,
    sira_orijinal,
    sira_modern,
    sira_orijinal - sira_modern                       as sira_kazanci,
    sira_orijinal = 1                                 as gercek_sampiyon,
    sira_modern = 1                                   as modern_sampiyon,
    (sira_orijinal = 1) != (sira_modern = 1)          as sampiyonluk_degisti
from siralamalar
where sira_orijinal <= 10 or sira_modern <= 10