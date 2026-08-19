with base as (

    select
        res.result_id,
        res.race_id,
        res.driver_id,
        res.constructor_id,
        res.status_id,

        ra.season_year,
        ra.round_number,
        ra.race_date,
        ra.circuit_id,
        ra.race_name,

        res.grid_position       as grid_position_raw,
        res.position_order,
        res.finish_position,
        res.points,
        res.laps_completed,

        st.status_group,
        st.status_text

    from {{ ref('stg_results') }} res
    join {{ ref('stg_races') }}  ra using (race_id)
    join {{ ref('stg_status') }} st using (status_id)

),

-- 1. Pit lane düzeltmesi: grid 0 -> o yarıştaki max grid + 1
grid_fixed as (

    select
        *,
        max(grid_position_raw) over (partition by race_id) as race_max_grid,
        case
            when grid_position_raw = 0
                then max(grid_position_raw) over (partition by race_id) + 1
            else grid_position_raw
        end as grid_position,
        grid_position_raw = 0 as pit_lane_start
    from base

),

-- 2. Temel türetilmiş metrikler
derived as (

    select
        *,
        grid_position - position_order            as grid_delta,
        position_order <= 3                       as is_podium,
        position_order = 1                        as is_win,
        grid_position = 1                         as is_pole,
        status_group in ('dnf_mechanical', 'dnf_incident',
                         'dnf_other', 'dnf_team_or_external')  as is_dnf,
        status_group = 'dnf_mechanical'           as is_dnf_mechanical,
        finish_position is not null               as is_classified
    from grid_fixed

),

-- 3. Form metrikleri (sezon içi, genişleyen pencere, max 5 yarış)
form as (

    select
        *,

        -- takım formu: ortalama bitiş pozisyonu
        avg(position_order) over (
            partition by constructor_id, season_year
            order by round_number
            rows between 5 preceding and 1 preceding
        ) as team_form_5_pos,

        -- takım formu: ortalama ham puan
        avg(points) over (
            partition by constructor_id, season_year
            order by round_number
            rows between 5 preceding and 1 preceding
        ) as team_form_5_pts,

        -- sürücü formu: ortalama bitiş pozisyonu
        avg(position_order) over (
            partition by driver_id, season_year
            order by round_number
            rows between 5 preceding and 1 preceding
        ) as driver_form_5_pos,

        -- kaç yarışa dayanıyor
        count(*) over (
            partition by driver_id, season_year
            order by round_number
            rows between 5 preceding and 1 preceding
        ) as form_race_count,

        -- takımın son 10 yarıştaki DNF oranı
        avg(case when is_dnf then 1.0 else 0.0 end) over (
            partition by constructor_id, season_year
            order by round_number
            rows between 10 preceding and 1 preceding
        ) as team_dnf_rate_10

    from derived

),

-- 4. Sıralama turu ve takım arkadaşı karşılaştırması
teammate as (

    select
        f.*,

        q.quali_position,
        q.best_quali_ms,

        -- takım toplamları (diğer sürücüyü bulmak için)
        sum(q.best_quali_ms) over (
            partition by f.race_id, f.constructor_id
        ) as team_sum_quali_ms,

        count(q.best_quali_ms) over (
            partition by f.race_id, f.constructor_id
        ) as team_quali_count,

        sum(f.position_order) over (
            partition by f.race_id, f.constructor_id
        ) as team_sum_position,

        count(*) over (
            partition by f.race_id, f.constructor_id
        ) as teammates_in_race

    from form f
    left join {{ ref('stg_qualifying') }} q
        on  f.race_id   = q.race_id
        and f.driver_id = q.driver_id

),
-- 5. Hava durumu ve regülasyon dönemi
enriched as (

    select
        t.*,

        -- takım arkadaşına göre farklar
        -- takım arkadaşına göre quali farkı
        -- negatif = takım arkadaşından hızlı
        case
            when t.teammates_in_race = 2
             and t.team_quali_count  = 2
             and t.best_quali_ms is not null
                then t.best_quali_ms - (t.team_sum_quali_ms - t.best_quali_ms)
        end as quali_gap_teammate_ms,

        -- takım arkadaşına göre bitiş farkı
        -- negatif = takım arkadaşından önde bitirdi
        case
            when t.teammates_in_race = 2
                then t.position_order - (t.team_sum_position - t.position_order)
        end as teammate_finish_gap,

        w.weather_condition,
        w.precip_total_mm,
        w.temperature_c,
        w.is_wet,
        w.time_source as weather_time_source,

        e.era_id,
        e.era_name,
        e.engine_formula,
        e.is_era_first_season,
        e.is_anomalous_season

    from teammate t
    left join {{ ref('stg_race_weather') }} w using (race_id)
    left join {{ ref('regulation_eras') }}  e on t.season_year = e.season_year

)

select * from enriched