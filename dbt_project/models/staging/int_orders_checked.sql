with numbered as (
    select
        *,
        row_number() over (
            partition by order_id
            order by purchased_at, customer_id
        ) as rn
    from {{ ref('stg_orders') }}
),

customers as (
    select customer_id as matched_customer_id
    from {{ ref('stg_customers') }}
)

select
    n.*,
    n.rn > 1                              as is_duplicate,
    c.matched_customer_id is null         as is_orphan_customer,
    coalesce(n.order_status not in (
        'delivered', 'shipped', 'canceled', 'unavailable',
        'invoiced', 'processing', 'created', 'approved'
    ), true)                              as is_invalid_status,
    coalesce(n.delivered_to_customer_at < n.purchased_at, false)
                                          as is_delivered_before_purchase
from numbered n
left join customers c on n.customer_id = c.matched_customer_id
