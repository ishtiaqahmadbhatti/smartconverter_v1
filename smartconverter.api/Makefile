# TechMindsForge FastAPI Makefile

.PHONY: help install dev test lint format clean run docker-build docker-run

# Default target
help:
	@echo "TechMindsForge FastAPI - Available Commands:"
	@echo ""
	@echo "Setup:"
	@echo "  install     Install dependencies"
	@echo "  dev         Setup development environment"
	@echo ""
	@echo "Development:"
	@echo "  run         Run the application"
	@echo "  test        Run tests"
	@echo "  lint        Run linting checks"
	@echo "  format      Format code"
	@echo ""
	@echo "Docker:"
	@echo "  docker-build    Build Docker image"
	@echo "  docker-run      Run with Docker Compose"
	@echo ""
	@echo "Utilities:"
	@echo "  clean       Clean temporary files"
	@echo "  help        Show this help message"

# Setup commands
install:
	pip install -r requirements.txt

dev:
	python scripts/setup_dev.py

# Development commands
run:
	python -m app.main

test:
	python scripts/run_tests.py

lint:
	flake8 app/ tests/
	black --check app/ tests/
	isort --check-only app/ tests/

format:
	black app/ tests/
	isort app/ tests/

# Docker commands
docker-build:
	docker build -t smart-convert-api .

docker-run:
	docker-compose up --build

# Utility commands
clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf build/
	rm -rf dist/
	rm -rf .coverage
	rm -rf htmlcov/
	rm -rf .pytest_cache/
