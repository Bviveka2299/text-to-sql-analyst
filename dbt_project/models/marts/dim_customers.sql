with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        c.customer_unique_id,
        count(distinct o.order_id)  as n_orders,
        min(o.purchased_at)         as first_order_at,
        max(o.purchased_at)         as last_order_at
    from customers c
    join orders o using (customer_id)
    group by 1
),

latest_location as (
    select customer_unique_id, zip_code_prefix, city, state
    from (
        select
            c.customer_unique_id,
            c.zip_code_prefix,
            c.city,
            c.state,
            row_number() over (
                partition by c.customer_unique_id
                order by o.purchased_at desc
            ) as rn
        from customers c
        join orders o using (customer_id)
    )
    where rn = 1
)

select
    co.customer_unique_id,
    ll.zip_code_prefix,
    ll.city,
    ll.state,
    co.n_orders,
    co.first_order_at,
    co.last_order_at
from customer_orders co
join latest_location ll using (customer_unique_id)
