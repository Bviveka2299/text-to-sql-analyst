select
    zip_code_prefix,
    avg(lat)  as lat,
    avg(lng)  as lng,
    count(*)  as n_points
from {{ ref('stg_geolocation') }}
group by 1
