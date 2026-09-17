with base as (

    select
        res.result_id,
        res.race_id,
        res.driver_id,
        res.constructor_id,
        ra.season_year,
        ra.round_number,
        ra.race_name,
        res.finish_position,
        res.position_order,
        res.points as points_original

    from {{ ref('stg_results') }} res
    join {{ ref('stg_races') }} ra using (race_id)
    where ra.season_year >= 1995

),

-- yarım puanlı yarışları tespit et
half_point_races as (

    select
        r.race_id
    from {{ ref('stg_races') }} r
    where (r.season_year = 2009 and r.race_name = 'Malaysian Grand Prix')
       or (r.season_year = 2021 and r.race_name = 'Belgian Grand Prix')

),

scored as (

    select
        b.*,

        h.race_id is not null as is_half_points,

        -- 2010-2018 puan sistemi, sadece sınıflandırılmış sürücüler
        case
            when b.finish_position is null then 0
            when b.finish_position = 1  then 25
            when b.finish_position = 2  then 18
            when b.finish_position = 3  then 15
            when b.finish_position = 4  then 12
            when b.finish_position = 5  then 10
            when b.finish_position = 6  then 8
            when b.finish_position = 7  then 6
            when b.finish_position = 8  then 4
            when b.finish_position = 9  then 2
            when b.finish_position = 10 then 1
            else 0
        end as points_modern_full

    from base b
    left join half_point_races h using (race_id)

)

select
    *,
    case
        when is_half_points then points_modern_full / 2
        else points_modern_full
    end as points_modern
from scored