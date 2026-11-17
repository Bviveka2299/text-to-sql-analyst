{{ config(severity='warn') }}

select order_id
from {{ ref('stg_orders') }}
where order_status = 'delivered'
  and delivered_to_customer_at is null
