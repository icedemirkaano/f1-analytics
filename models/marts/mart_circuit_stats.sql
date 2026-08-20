with bitirenler as (

    select
        circuit_name,
        circuit_country,
        grid_position,
        position_order
    from {{ ref('mart_race_results') }}
    where season_year between 2003 and 2024
      and is_classified

),

korelasyon as (

    select
        circuit_name,
        corr(grid_position, position_order) as grid_finish_korelasyon,
        count(*)                            as bitiren_kayit
    from bitirenler
    group by 1

),

tum_kayitlar as (

    select
        circuit_name,
        circuit_country,
        count(*)                                                   as toplam_katilim,
        count(distinct race_id)                                    as yaris_sayisi,
        countif(is_dnf)                                            as dnf_sayisi,
        countif(status_group = 'dnf_incident')                     as kaza_sayisi,
        countif(status_group = 'dnf_mechanical')                   as mekanik_sayisi,
        avg(abs(grid_delta))                                       as ort_mutlak_pozisyon_degisimi
    from {{ ref('mart_race_results') }}
    where season_year between 2003 and 2024
    group by 1, 2

),

pole_istatistik as (

    select
        circuit_name,
        count(*)                as pole_sayisi,
        countif(is_win)         as pole_galibiyet,
        countif(is_podium)      as pole_podyum
    from {{ ref('mart_race_results') }}
    where season_year between 2003 and 2024
      and is_pole
    group by 1

)

select
    t.circuit_name,
    t.circuit_country,
    t.yaris_sayisi,
    t.toplam_katilim,

    round(k.grid_finish_korelasyon, 4)                          as grid_finish_korelasyon,
    round(pow(k.grid_finish_korelasyon, 2) * 100, 1)            as aciklanan_varyans_pct,

    round(t.dnf_sayisi     / t.toplam_katilim * 100, 1)         as dnf_orani,
    round(t.kaza_sayisi    / t.toplam_katilim * 100, 1)         as kaza_orani,
    round(t.mekanik_sayisi / t.toplam_katilim * 100, 1)         as mekanik_orani,
    round(t.ort_mutlak_pozisyon_degisimi, 2)                    as ort_pozisyon_degisimi,

    p.pole_sayisi,
    round(safe_divide(p.pole_galibiyet, p.pole_sayisi) * 100, 1) as pole_galibiyet_orani,
    round(safe_divide(p.pole_podyum,   p.pole_sayisi) * 100, 1)  as pole_podyum_orani

from tum_kayitlar t
join korelasyon      k using (circuit_name)
left join pole_istatistik p using (circuit_name)
where t.toplam_katilim >= 100