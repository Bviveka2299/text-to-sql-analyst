select *
from {{ ref('stg_order_reviews') }}
where coalesce(review_score between 1 and 5, false)
