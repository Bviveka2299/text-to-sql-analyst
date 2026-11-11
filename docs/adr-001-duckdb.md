# ADR 001: Use DuckDB as the warehouse

## Status
Accepted

## Context
The project needs a SQL warehouse for the Olist data (about 100K orders, 1M geolocation rows). It must run on a laptop with 8 GB of RAM, cost nothing, and work with dbt.

## Decision
Use DuckDB as a single local file (`data/olist.duckdb`) through the `dbt-duckdb` adapter.

## Consequences
- Free and open source (MIT license), with no server to run or maintain.
- Light enough for 8 GB of RAM.
- Only one process can write at a time, so close Python shells before running dbt.
- Not designed for many concurrent users. The same dbt models can later run on Snowflake for a comparison.