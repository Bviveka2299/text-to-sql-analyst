select *
from (
    select
        (select count(*) from {{ ref('fct_orders') }})  as fct_rows,
        (select count(*) from {{ ref('stg_orders_valid') }})  as stg_rows
)
where fct_rows != stg_rows
