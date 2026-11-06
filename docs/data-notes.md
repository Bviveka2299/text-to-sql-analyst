# Olist Data Notes

## 1. Tables and grain
- raw_orders: one row per order (99,441 rows). Has a status and five timestamps tracing the order's life (purchase, approved, carrier, delivered, estimated).
- raw_customers: TODO (99,441 rows)
- raw_order_items: TODO (112,650 rows)
- raw_order_payments: one row per payment, not per order (103,886 rows)
- raw_order_reviews: TODO (99,224 rows)
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
- Delivered orders with null delivery dates: TODO
- Product categories missing from the translation table: TODO

## 4. Implications for modeling
- Aggregate payments to one row per order before joining, to avoid double counting.
- Use the real customer ID as the customer key: TODO
- DuckDB read the date columns as TIMESTAMP, so no date conversion is needed.