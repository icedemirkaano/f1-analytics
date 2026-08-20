select
    -- anahtarlar
    f.result_id,
    f.race_id,
    f.driver_id,
    f.constructor_id,

    -- boyutlar (filtreler icin)
    f.season_year,
    f.round_number,
    f.race_name,
    f.race_date,
    c.circuit_name,
    c.country                       as circuit_country,
    d.driver_name,
    con.constructor_name,
    f.era_name,
    f.era_id,
    f.weather_condition,
    f.status_group,

    -- olcumler
    f.grid_position,
    f.position_order,
    f.finish_position,
    f.points,
    f.grid_delta,
    f.team_form_5_pos,
    f.driver_form_5_pos,
    f.form_race_count,
    f.quali_gap_teammate_ms,
    f.teammate_finish_gap,
    f.precip_total_mm,
    f.temperature_c,

    -- bayraklar
    f.is_podium,
    f.is_win,
    f.is_pole,
    f.is_dnf,
    f.is_classified,
    f.pit_lane_start,
    f.is_era_first_season,

    -- dashboard icin hazir gruplamalar
    case
        when f.grid_position <= 3  then '1-3'
        when f.grid_position <= 6  then '4-6'
        when f.grid_position <= 10 then '7-10'
        else '11+'
    end as grid_grubu,

    case
        when f.team_form_5_pos is null    then 'veri yok'
        when f.team_form_5_pos <= 6       then 'cok iyi (1-6)'
        when f.team_form_5_pos <= 10      then 'iyi (6-10)'
        when f.team_form_5_pos <= 14      then 'orta (10-14)'
        else 'zayif (14+)'
    end as form_grubu,

    -- baseline kurali (grid <= 3 ise podyum tahmini)
    f.grid_position <= 3 as baseline_tahmin

from {{ ref('int_pre_race_features') }} f
join {{ ref('stg_circuits') }}     c   using (circuit_id)
join {{ ref('stg_drivers') }}      d   using (driver_id)
join {{ ref('stg_constructors') }} con using (constructor_id)