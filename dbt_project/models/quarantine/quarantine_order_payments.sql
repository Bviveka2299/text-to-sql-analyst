{{ config(materialized='table') }}

select
    payment_key,
    order_id,
    payment_value,
    'negative_or_null_payment' as failed_checks,
    current_timestamp          as quarantined_at
from {{ ref('stg_order_payments') }}
where not coalesce(payment_value >= 0, false)
