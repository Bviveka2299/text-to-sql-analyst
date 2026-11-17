select
    review_id,
    order_id,
    review_score,
    review_creation_date    as review_created_at,
    review_answer_timestamp as review_answered_at
from {{ source('raw', 'raw_order_reviews') }}
