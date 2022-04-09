SHELL := /bin/bash
POETRY_VERSION=1.1.12

test:
	mkdir test-results
	python -m pytest --cov --junitxml=test-results/junit.xml tests/
	python -m coverage report
	python -m coverage html  # open htmlcov/index.html in a browser

groom:
	isort kafkaescli/ tests/
	black kafkaescli/ tests/


install-poetry:
	POETRY_VERSION=$(POETRY_VERSION) curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

make build:
	poetry build

install:
	poetry install

pip-install:
	poetry export --dev --without-hashes -f requirements.txt -o requirements.txt
	pip install -r requirements.txt

docker-build: build
	@docker build -t kafkaescli: .

docker-run:
	docker run -it --rm --name kafkaescli kafkaescli

pipeline-test: install-poetry pip-install test

pipeline-release.%: install-poetry pip-install groom build
	poetry version $* && git commit -am "bump patch version: $$(poetry version -s)"

pipeline-release-minor: install-poetry pip-install groom build
	poetry version minor
	git commit -am "bump minor version: $$(poetry version -s)"

pipeline-release-major: install-poetry pip-install groom build
	poetry version major
	git commit -am "bump major version: $$(poetry version -s)"

pipeline-build-docs:
	cd docs/ && make html