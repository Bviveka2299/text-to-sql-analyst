select *
from {{ ref('stg_order_payments') }}
where coalesce(payment_value >= 0, false)
