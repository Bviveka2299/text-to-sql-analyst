select product_category_name, product_category_name_english
from {{ source('raw', 'raw_product_category_name_translation') }}
union all
select product_category_name, product_category_name_english
from {{ ref('missing_category_translations') }}
