{{ config(materialized='table') }}

select
    order_id,
    customer_id,
    order_status,
    purchased_at,
    delivered_to_customer_at,
    concat_ws(', ',
        case when is_duplicate                 then 'duplicate_order_id' end,
        case when is_orphan_customer           then 'orphan_customer_id' end,
        case when is_invalid_status            then 'invalid_status' end,
        case when is_delivered_before_purchase then 'delivered_before_purchase' end
    )                   as failed_checks,
    current_timestamp   as quarantined_at
from {{ ref('int_orders_checked') }}
where is_duplicate or is_orphan_customer
   or is_invalid_status or is_delivered_before_purchase
