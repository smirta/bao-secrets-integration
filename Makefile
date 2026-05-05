.PHONY: help install lint test test-all clean docs

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	@echo "Installing Python dependencies..."
	pip install -r requirements.txt
	@echo "Installing Ansible collections..."
	ansible-galaxy install -r requirements.yml
	@echo "Dependencies installed successfully!"

lint: ## Run linting checks
	@echo "Running yamllint..."
	yamllint .
	@echo "Running ansible-lint..."
	ansible-lint roles/openbao_secrets_integration
	@echo "Linting complete!"

test: ## Run default molecule test
	@echo "Running Molecule tests (default scenario)..."
	cd roles/openbao_secrets_integration && molecule test
	@echo "Tests complete!"

test-all: ## Run all molecule scenarios
	@echo "Running all Molecule test scenarios..."
	cd roles/openbao_secrets_integration && \
		molecule test -s default && \
		molecule test -s userpass-auth && \
		molecule test -s approle-auth && \
		molecule test -s rotation
	@echo "All tests complete!"

test-integration: ## Run integration tests
	@echo "Running integration tests..."
	@echo "Make sure OpenBao is running on localhost:8200"
	ansible-playbook tests/integration-test.yml
	@echo "Integration tests complete!"

test-scenario: ## Run specific molecule scenario (usage: make test-scenario SCENARIO=userpass-auth)
	@if [ -z "$(SCENARIO)" ]; then \
		echo "Error: Please specify SCENARIO (e.g., make test-scenario SCENARIO=userpass-auth)"; \
		exit 1; \
	fi
	@echo "Running Molecule test scenario: $(SCENARIO)..."
	cd roles/openbao_secrets_integration && molecule test -s $(SCENARIO)

verify: ## Run verifier only (no destroy)
	@echo "Running verification..."
	cd roles/openbao_secrets_integration && molecule verify
	@echo "Verification complete!"

converge: ## Run converge only (no destroy, useful for debugging)
	@echo "Running converge..."
	cd roles/openbao_secrets_integration && molecule converge
	@echo "Converge complete!"

destroy: ## Destroy molecule test environment
	@echo "Destroying test environment..."
	cd roles/openbao_secrets_integration && molecule destroy
	@echo "Environment destroyed!"

clean: ## Clean up test artifacts and caches
	@echo "Cleaning up..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	cd roles/openbao_secrets_integration && molecule destroy 2>/dev/null || true
	@echo "Cleanup complete!"

format: ## Format YAML files (requires prettier)
	@echo "Formatting YAML files..."
	@which prettier > /dev/null 2>&1 || (echo "Error: prettier not found. Install with: npm install -g prettier" && exit 1)
	prettier --write "**/*.{yml,yaml}"
	@echo "Formatting complete!"

docs: ## Generate documentation
	@echo "Generating documentation..."
	@echo "Documentation is in README.md and CONTRIBUTING.md"
	@echo "View with: cat README.md"

dev-openbao: ## Start OpenBao dev server in Docker
	@echo "Starting OpenBao dev server..."
	@docker run -d --name openbao-dev \
		-p 8200:8200 \
		-e VAULT_DEV_ROOT_TOKEN_ID=test-root-token \
		-e VAULT_ADDR=http://0.0.0.0:8200 \
		openbao/openbao:latest bao server -dev -dev-listen-address=0.0.0.0:8200
	@echo "OpenBao dev server started!"
	@echo "  Address: http://localhost:8200"
	@echo "  Token: test-root-token"
	@echo "Stop with: make stop-openbao"

stop-openbao: ## Stop OpenBao dev server
	@echo "Stopping OpenBao dev server..."
	@docker stop openbao-dev 2>/dev/null || true
	@docker rm openbao-dev 2>/dev/null || true
	@echo "OpenBao dev server stopped!"

ci: lint test-all ## Run full CI pipeline locally
	@echo "CI pipeline complete!"

release: ## Create a release (requires VERSION=x.y.z)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: Please specify VERSION (e.g., make release VERSION=1.0.0)"; \
		exit 1; \
	fi
	@echo "Creating release $(VERSION)..."
	@echo "1. Running tests..."
	@make test-all
	@echo "2. Updating version references..."
	@echo "3. Creating git tag..."
	git tag -a "v$(VERSION)" -m "Release version $(VERSION)"
	@echo "Release $(VERSION) created!"
	@echo "Push with: git push origin v$(VERSION)"
