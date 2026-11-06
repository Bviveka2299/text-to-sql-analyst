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
- raw_products: TODO (32,951 rows)
- raw_sellers: TODO (3,095 rows)
- raw_geolocation: TODO (1,000,163 rows)
- raw_product_category_name_translation: TODO (71 rows)

## 2. Keys and joins
- orders -> customers via customer_id
- orders -> order_items via order_id
- orders -> payments via order_id
- customer_id vs customer_unique_id: TODO (write the two distinct counts and which one is the real person)

## 3. Data quality issues
- About 3% of orders (about 2,900) have more than one payment row, up to 29 rows for one order.
- One order has no payment row (99,440 orders in payments vs 99,441 in orders).
- About 768 orders have no review, and 547 have more than one.
- Delivered orders with null delivery dates: 
    - 97% of orders are delivered. 8 delivered orders have no delivery date, and 6 canceled orders do have one.
    - All orders in the other statuses (shipped, unavailable, invoiced, processing, created, approved) have a null delivery date, which is expected.
- Product categories missing from the translation table: TODO

## 4. Implications for modeling
- Aggregate payments to one row per order before joining, to avoid double counting.
- Use the real customer ID as the customer key: TODO
- DuckDB read the date columns as TIMESTAMP, so no date conversion is needed.
- Aggregate order items to one row per order before joining with payments or reviews. Create a  surrogate key for tests.
- Reduce reviews to one row per order (latest review) before joining, and use a left join. For ML features, only use reviews available before the prediction date.
- Use delivered orders when defining customer purchases for the repurchase model.
- Delivery-delay features are null for undelivered orders, so handle them explicitly.