with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select customer_id, customer_unique_id
    from {{ ref('stg_customers') }}
),

items as (
    select
        order_id,
        count(*)           as n_items,
        sum(price)         as items_value,
        sum(freight_value) as freight_value
    from {{ ref('stg_order_items') }}
    group by 1
),

payments as (
    select
        order_id,
        count(*)                    as n_payments,
        sum(payment_value)          as total_payment_value,
        max(payment_installments)   as max_installments
    from {{ ref('stg_order_payments') }}
    group by 1
),

latest_review as (
    select order_id, review_score
    from (
        select
            order_id,
            review_score,
            row_number() over (
                partition by order_id
                order by review_answered_at desc, review_created_at desc, review_id
            ) as rn
        from {{ ref('stg_order_reviews') }}
    )
    where rn = 1
)

select
    o.order_id,
    c.customer_unique_id,
    o.order_status,
    o.purchased_at,
    o.approved_at,
    o.delivered_to_carrier_at,
    o.delivered_to_customer_at,
    o.estimated_delivery_at,
    coalesce(i.n_items, 0)        as n_items,
    i.items_value,
    i.freight_value,
    p.n_payments,
    p.total_payment_value,
    p.max_installments,
    r.review_score,
    date_diff('day', o.purchased_at, o.delivered_to_customer_at)              as delivery_days,
    date_diff('day', o.estimated_delivery_at, o.delivered_to_customer_at)     as delivery_delay_days,
    case
        when o.delivered_to_customer_at is null then null
        else o.delivered_to_customer_at > o.estimated_delivery_at
    end                                                                        as is_late
from orders o
join customers c using (customer_id)
left join items i using (order_id)
left join payments p using (order_id)
left join latest_review r using (order_id)
