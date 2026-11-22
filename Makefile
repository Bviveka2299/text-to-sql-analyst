.PHONY: setup test load dbt validate build

setup:
	pip install -r requirements.txt

test:
	pytest

load:
	python src/load_raw.py

dbt:
	cd dbt_project && dbt seed --profiles-dir . && dbt run --profiles-dir . && dbt test --profiles-dir .

validate:
	python src/validation/validate_marts.py

build: load dbt validate
