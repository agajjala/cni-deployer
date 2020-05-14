%: usage

.PHONY: usage
usage:
	@echo "Usage:"
	@echo "make template - Creates Helm templates for defined manifest files"
	@echo "make clean   - Deletes the generated helm templates"

.PHONY: setup
setup:
	pip install -q --upgrade pip
	pip install -q -r requirements.txt

.PHONY: template
template: clean
	@echo "Linting HELM Charts..."
	helm lint --strict Applications/*
	@echo "Generating HELM Templates..."
	python3 src/helm_template_generator.py

.PHONY: test
test:
	@echo "Linting HELM Charts..."
	helm lint --strict Applications/*
	@echo "Running UT's..."
	python3 -m pytest --cov=src src

.PHONY: clean
clean:
	rm -rf Manifests/Output
