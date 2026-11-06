import duckdb

con = duckdb.connect("data/olist.duckdb", read_only=True)
tables = [r[0] for r in con.execute("SHOW TABLES").fetchall()]

for t in sorted(tables):
    n = con.execute(f"SELECT count(*) FROM {t}").fetchone()[0]
    print(f"\n=== {t} ({n} rows) ===")
    cols = con.execute(f"DESCRIBE {t}").fetchall()
    for name, dtype, *_ in cols:
        nulls = con.execute(f'SELECT count(*) FROM {t} WHERE "{name}" IS NULL').fetchone()[0]
        flag = f"  <-- {nulls} nulls" if nulls else ""
        print(f"  {name:40} {dtype:12}{flag}")
