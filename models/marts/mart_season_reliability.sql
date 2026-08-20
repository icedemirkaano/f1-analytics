with sezon_kategori as (

    select
        season_year,
        era_id,
        era_name,
        is_era_first_season,
        count(*)                                                    as toplam_katilim,
        count(distinct race_id)                                     as yaris_sayisi,

        countif(status_group = 'finished')                          as finished,
        countif(status_group = 'finished_lapped')                   as finished_lapped,
        countif(status_group = 'dnf_mechanical')                    as dnf_mechanical,
        countif(status_group = 'dnf_incident')                      as dnf_incident,
        countif(status_group = 'dnf_other')                         as dnf_other,
        countif(status_group = 'dnf_team_or_external')              as dnf_team_or_external,
        countif(is_dnf)                                             as dnf_toplam

    from {{ ref('mart_race_results') }}
    group by 1, 2, 3, 4

)

select
    season_year,
    era_id,
    era_name,
    is_era_first_season,
    yaris_sayisi,
    toplam_katilim,

    round(dnf_toplam           / toplam_katilim * 100, 1) as dnf_orani,
    round(dnf_mechanical       / toplam_katilim * 100, 1) as mekanik_orani,
    round(dnf_incident         / toplam_katilim * 100, 1) as kaza_orani,
    round(dnf_other            / toplam_katilim * 100, 1) as diger_orani,
    round(dnf_team_or_external / toplam_katilim * 100, 1) as takim_hatasi_orani,
    round((finished + finished_lapped) / toplam_katilim * 100, 1) as bitirme_orani

from sezon_kategori