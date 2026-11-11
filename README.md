# Text-to-SQL Analyst

Data and ML platform on the Olist e-commerce dataset: a dbt data layer, a repurchase prediction model, and a guarded text-to-SQL agent.

## Tech stack
DuckDB, dbt, Pandera, Python, pytest, sqlglot

## Setup
1. Download the Olist dataset from Kaggle and unzip the 9 CSVs into `data/raw/`
2. `python3 -m venv .venv && source .venv/bin/activate`
3. `make setup`
4. `make load`

## Status
Week 1: raw data loaded and profiled (see `docs/data-notes.md`). Next: dbt staging models.