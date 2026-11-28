{{ config(materialized='table') }}

select
    review_id,
    order_id,
    review_score,
    'review_score_out_of_range' as failed_checks,
    current_timestamp           as quarantined_at
from {{ ref('stg_order_reviews') }}
where not coalesce(review_score between 1 and 5, false)
