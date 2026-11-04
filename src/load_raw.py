import pathlib
import duckdb

RAW_DIR = pathlib.Path("data/raw")
DB_PATH = "data/olist.duckdb"

def main():
    files = sorted(RAW_DIR.glob("*.csv"))
    if not files:
        raise SystemExit("No CSV files found in data/raw")

    con = duckdb.connect(DB_PATH)
    for f in files:
        name = f.stem.replace("olist_", "").replace("_dataset", "")
        con.execute(
            f"CREATE OR REPLACE TABLE raw_{name} AS "
            f"SELECT * FROM read_csv_auto('{f.as_posix()}')"
        )
        n = con.execute(f"SELECT count(*) FROM raw_{name}").fetchone()[0]
        print(f"raw_{name}: {n} rows")
    con.close()

if __name__ == "__main__":
    main()