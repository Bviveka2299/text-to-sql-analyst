# ADR 002: Fix the grain of each mart and aggregate before joining

## Status
Accepted

## Context
Several raw tables have more than one row per order: payments (up to 29 per order), reviews (up to 3), and order items. Joining them directly to orders duplicates rows and inflates sums such as revenue per customer.

## Decision
- fct_orders has exactly one row per order. Items, payments, and reviews are aggregated to one row per order before joining, using left joins so orders without them are kept.
- fct_order_items has one row per item, keyed on order_id and order_item_id.
- dim_customers is keyed on customer_unique_id, because customer_id is unique per order.
- Reviews are reduced to the latest review per order.
- Geolocation is reduced to one row per zip prefix.

## Consequences
- Two reconciliation tests guard against fan-out: row count of fct_orders equals orders, and total payments in fct_orders equals the raw payment total.
- Review score is an after-the-fact value, so ML features must only use reviews available before the prediction date.