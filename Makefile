REGISTRY ?= ghcr.io/TU-ORG
IMAGE    ?= poc-teradata-onprem
TAG      ?= latest

# Formateo automático de código
format:
	pdm run ruff check . --fix
	pdm run ruff format .

# Verificación de calidad completa
quality: install
	pdm run ruff check .
	pdm run ruff format --check .
	pdm run pylint src
	pdm run mypy src
	pdm run pytest -q --maxfail=1 --disable-warnings --cov=src --cov-report=term-missing

# Preparar código antes del commit
pre-commit: format quality
	@echo "✅ Código listo para commit"

# Docker build
build:
	docker build -t $(REGISTRY)/$(IMAGE):$(TAG) .

# Docker push
push:
	docker push $(REGISTRY)/$(IMAGE):$(TAG)

# Instalar dependencias
install:
	pdm install --dev

# Ejecutar tests
test:
	pdm run pytest tests/ -v --cov=src --cov-report=term-missing

# Ejecutar contenedor localmente
run:
	docker run -d --name teradata-onprem -p 1025:1025 -p 1026:1026 $(REGISTRY)/$(IMAGE):$(TAG)

# Parar y remover contenedor
stop:
	docker stop teradata-onprem || true
	docker rm teradata-onprem || true

# Limpiar archivos temporales
clean:
	docker rmi $(REGISTRY)/$(IMAGE):$(TAG) || true
	find . -type d -name "__pycache__" -exec rm -rf {} + || true
	find . -type f -name "*.pyc" -delete || true