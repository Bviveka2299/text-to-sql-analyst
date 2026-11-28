select
    i.order_item_key,
    i.order_id,
    i.order_item_id,
    i.product_id,
    i.seller_id,
    c.customer_unique_id,
    o.purchased_at,
    i.shipping_limit_at,
    i.price,
    i.freight_value
from {{ ref('stg_order_items') }} i
join {{ ref('stg_orders_valid') }} o using (order_id)
join {{ ref('stg_customers') }} c using (customer_id)
