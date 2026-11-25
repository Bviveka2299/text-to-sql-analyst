import duckdb

DB = "data/olist_test.duckdb"   # never point this at the real database
assert "test" in DB

con = duckdb.connect(DB)
real_customer = "(SELECT customer_id FROM raw_customers LIMIT 1)"

# 1. Duplicate order: copy an existing row
con.execute("INSERT INTO raw_orders SELECT * FROM raw_orders LIMIT 1")

# 2. Orphan order: customer does not exist, and a delivered order has no delivery date
con.execute("""
INSERT INTO raw_orders BY NAME
SELECT 'bad_orphan' AS order_id, 'no_such_customer' AS customer_id,
       'delivered' AS order_status,
       TIMESTAMP '2018-01-01 10:00:00' AS order_purchase_timestamp,
       TIMESTAMP '2018-01-15 00:00:00' AS order_estimated_delivery_date
""")

# 3. Invalid status
con.execute(f"""
INSERT INTO raw_orders BY NAME
SELECT 'bad_status' AS order_id, {real_customer} AS customer_id,
       'banana' AS order_status,
       TIMESTAMP '2018-02-01 10:00:00' AS order_purchase_timestamp,
       TIMESTAMP '2018-02-15 00:00:00' AS order_estimated_delivery_date
""")

# 4. Delivered before it was purchased
con.execute(f"""
INSERT INTO raw_orders BY NAME
SELECT 'bad_dates' AS order_id, {real_customer} AS customer_id,
       'delivered' AS order_status,
       TIMESTAMP '2018-03-01 10:00:00' AS order_purchase_timestamp,
       TIMESTAMP '2018-03-02 10:00:00' AS order_delivered_carrier_date,
       TIMESTAMP '2018-02-01 10:00:00' AS order_delivered_customer_date,
       TIMESTAMP '2018-03-15 00:00:00' AS order_estimated_delivery_date
""")

# 5. Review score out of range (valid scores are 1-5)
con.execute("""
INSERT INTO raw_order_reviews BY NAME
SELECT 'bad_review_1' AS review_id, 'bad_dates' AS order_id, 9 AS review_score,
       TIMESTAMP '2018-03-20 10:00:00' AS review_creation_date,
       TIMESTAMP '2018-03-21 10:00:00' AS review_answer_timestamp
""")

# 6. Negative payment
con.execute("""
INSERT INTO raw_order_payments BY NAME
SELECT 'bad_status' AS order_id, 1 AS payment_sequential,
       'credit_card' AS payment_type, 1 AS payment_installments,
       -50.0 AS payment_value
""")

print("raw_orders rows:", con.execute("SELECT count(*) FROM raw_orders").fetchone()[0], "(expect 99445)")
con.close()
