# Olist Data Notes

## 1. Tables and grain
- raw_orders: 
    - one row per order (99,441 rows). Has a status and five timestamps tracing the order's life (purchase, approved, carrier, delivered, estimated).
    - has one row per order and that order_id is unique (99,441 of 99,441).
- raw_customers: TODO (99,441 rows)
- raw_order_items: 
    - one row per item in an order. Key is (order_id, order_item_id), unique across all 112,650 rows.
- raw_order_payments: one row per payment, not per order (103,886 rows)
- raw_order_reviews:
    - one row per review, not per order (99,224 rows). 98,126 orders have 1 review, 543 have 2, and 4 have 3
- raw_products: one row per product, `product_id` is unique (32,951 rows). 610 products have a null category.
- raw_sellers: one row per seller, `seller_id` is unique (3,095 rows).
- raw_geolocation: 
    - raw_geolocation: many points per zip prefix, not one row per prefix (1,000,163 rows, 19,015 distinct prefixes)
- raw_product_category_name_translation: TODO (71 rows)

## 2. Keys and joins
- orders -> customers via customer_id
- orders -> order_items via order_id
- orders -> payments via order_id
- customer_id vs customer_unique_id: 
customer_id is unique per order (99,441), while customer_unique_id identifies the real customer (96,096 distinct). Orders join to customers through customer_id.

## 3. Data quality issues
- About 3% of orders (about 2,900) have more than one payment row, up to 29 rows for one order.
- One order has no payment row (99,440 orders in payments vs 99,441 in orders).
- About 768 orders have no review, and 547 have more than one.
- Delivered orders with null delivery dates: 
    - 97% of orders are delivered. 8 delivered orders have no delivery date, and 6 canceled orders do have one.
    - All orders in the other statuses (shipped, unavailable, invoiced, processing, created, approved) have a null delivery date, which is expected.
- 8 orders have status delivered but no customer delivery date. 7 have a carrier date and 1 has neither. 6 of the 8 were purchased in June-July 2018, near the end of the dataset.
- 93,099 customers (96.9%) placed one order, and 2,997 (3.1%) placed two or more. The maximum is 17 orders for one customer.
- Two product categories are missing from the translation table: pc_gamer and portateis_cozinha_e_preparadores_de_alimentos. Some products also have a null category (count: 610)
- 610 products (1.9%) have a null category. 13 products belong to two categories missing from the translation table (pc_gamer, portateis_cozinha_e_preparadores_de_alimentos).

## 4. Implications for modeling
- Aggregate payments to one row per order before joining, to avoid double counting.
- Use the real customer ID as the customer key: TODO
- DuckDB read the date columns as TIMESTAMP, so no date conversion is needed.
- Aggregate order items to one row per order before joining with payments or reviews. Create a  surrogate key for tests.
- Reduce reviews to one row per order (latest review) before joining, and use a left join. For ML features, only use reviews available before the prediction date.
- Use delivered orders when defining customer purchases for the repurchase model.
- Delivery-delay features are null for undelivered orders, so handle them explicitly.
- Keep these orders. Leave delivery-delay features null for them. Add a dbt test with severity warn
- Use customer_unique_id as the customer key in dim_customers. About 3,345 orders come from repeat customers (about 3%), so the repurchase label will be heavily imbalanced.
- The repurchase label will be heavily imbalanced, and 90-day positives will be fewer still. Measure the positive rate for 90 and 180 days before choosing the target. Restrict to delivered orders. Use PR-AUC.
- Add a dbt seed with the two missing translations, and use COALESCE(..., 'unknown') for products with no category.
- Add a dbt seed for the two missing translations. Use COALESCE(english_name, 'unknown') so null-category products are kept and labeled unknown.
- Aggregate geolocation to one row per zip prefix (average latitude and longitude) before joining. Use a left join, and handle customers or sellers with no match.
