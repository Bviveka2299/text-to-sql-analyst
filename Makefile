.PHONY: setup load dbt validate test build

setup:
	pip install -r requirements.txt

load:
	python src/load_raw.py

dbt:
	cd dbt_project && dbt seed --profiles-dir . && dbt run --profiles-dir . && dbt test --profiles-dir .

validate:
	python src/validation/validate_marts.py

test:
	pytest

build: load dbt validate
