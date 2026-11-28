select
    order_id, customer_id, order_status, purchased_at, approved_at,
    delivered_to_carrier_at, delivered_to_customer_at, estimated_delivery_at
from {{ ref('int_orders_checked') }}
where not (is_duplicate or is_orphan_customer
           or is_invalid_status or is_delivered_before_purchase)
