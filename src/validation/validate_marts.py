import sys
import duckdb
import pandera as pa
from pandera import Column, Check, DataFrameSchema

STATUSES = ["delivered", "shipped", "canceled", "unavailable",
            "invoiced", "processing", "created", "approved"]

fct_orders_schema = DataFrameSchema(
    {
        "order_id": Column(str, unique=True, nullable=False),
        "customer_unique_id": Column(str, nullable=False),
        "order_status": Column(str, Check.isin(STATUSES)),
        "n_items": Column(int, Check.ge(0), coerce=True),
        "total_payment_value": Column(float, Check.ge(0), nullable=True, coerce=True),
        "review_score": Column(float, Check.in_range(1, 5), nullable=True, coerce=True),
        "delivery_days": Column(float, Check.ge(0), nullable=True, coerce=True),
    },
    strict=False,
)

dim_customers_schema = DataFrameSchema(
    {
        "customer_unique_id": Column(str, unique=True, nullable=False),
        "n_orders": Column(int, Check.ge(1), coerce=True),
    },
    strict=False,
)

CHECKS = [
    ("fct_orders", fct_orders_schema),
    ("dim_customers", dim_customers_schema),
]

def main():
    con = duckdb.connect(sys.argv[1] if len(sys.argv) > 1 else "data/olist.duckdb", read_only=True)
    failed = False
    for table, schema in CHECKS:
        df = con.sql(f"SELECT * FROM {table}").df()
        try:
            schema.validate(df, lazy=True)
            print(f"OK    {table}: {len(df)} rows validated")
        except pa.errors.SchemaErrors as err:
            failed = True
            print(f"FAIL  {table}: {len(err.failure_cases)} failing values")
            print(err.failure_cases[["column", "check", "failure_case"]].head(20))
    con.close()
    sys.exit(1 if failed else 0)

if __name__ == "__main__":
    main()
