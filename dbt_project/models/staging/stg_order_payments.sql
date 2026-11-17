select
    order_id || '-' || cast(payment_sequential as varchar) as payment_key,
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
from {{ source('raw', 'raw_order_payments') }}
