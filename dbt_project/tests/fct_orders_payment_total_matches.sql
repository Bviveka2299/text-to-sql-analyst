select *
from (
    select
        (select sum(total_payment_value) from {{ ref('fct_orders') }})        as fct_total,
        (select sum(payment_value) from {{ ref('stg_order_payments_valid') }})      as stg_total
)
where abs(fct_total - stg_total) > 0.01
