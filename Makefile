setup:
	pip install -r requirements.txt

test:
	pytest

load:
	python src/load_raw.py