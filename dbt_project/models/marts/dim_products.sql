select
    product_id,
    category,
    name_length,
    description_length,
    photos_qty,
    weight_g,
    length_cm,
    height_cm,
    width_cm
from {{ ref('stg_products') }}
