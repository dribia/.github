.PHONY: all clean setup lint test

all:
	make clean
	make setup || exit 1
	make lint || exit 1

clean:
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov
	rm -f .coverage

test:
	@echo "No tests defined."

--check-git-status:
	@status=$$(git status --porcelain); \
		if [ -n "$${status}" ]; \
		then \
			echo "ERROR:\n  GIT status is not clean.\
			\n  Commit or discard your changes before using this script."; \
			exit 1; \
		fi

lint:
	uv run pre-commit run --all-files

--setup-uv:
	@echo "Checking if uv is installed ..."; \
		uv_path=$$(command -v "uv"); \
		if [ -z "$${uv_path}" ]; \
		then \
			echo "ERROR: uv not found.\
			\n  You should have uv installed in order to setup this project.\
			\n  https://docs.astral.sh/uv/getting-started/installation/\n"; \
			exit 1; \
		fi
	@echo "Checking if uv.lock is up-to-date ..."; \
		if uv lock --check --quiet > /dev/null 2>&1 ; \
		then \
			echo "uv.lock is up-to-date"; \
            uv sync; \
  			uv run pre-commit install --install-hooks; \
		else \
  			echo "uv.lock is NOT up-to-date."; \
  			echo "Update uv.lock and commit it."; \
			uv sync; \
			uv run pre-commit install --install-hooks; \
			git add uv.lock; \
  			uv run pre-commit run --files uv.lock || true; \
  			uv run git commit .pre-commit-config.yaml uv.lock -m ":lock: Lock the project dependencies"; \
		fi

setup:
	@make -- --check-git-status || exit 1
	@make -- --setup-uv || exit 1
	@echo "Checking pre-commits ..."; uv run --frozen pre-commit run --all-files || exit 1
	@echo "\nSetup completed successfully!\n"; exit 0
