.PHONY: all clean setup lint format bump-version test \
		license-check license-headers

PROJECT_PKG ?= github
COMMIT_VERSION ?= $(shell bash -c 'read -p "Semantic bump (\"major\", \"minor\" or \"patch\") or new version (eg. \"0.1.3\"): " bmp; echo $${bmp}')

all:
	make clean
	make setup || exit 1
	make lint || exit 1
	make test || exit 1

clean:
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov
	rm -f .coverage

--check-git-status:
	@status=$$(git status --porcelain); \
		if [ -n "$${status}" ]; \
		then \
			echo "ERROR:\n  GIT status is not clean.\
			\n  Commit or discard your changes before using this script."; \
			exit 1; \
		fi

--shell-check:
	@for f in ./**/*.sh; do \
		[ -e "$f" ] && uv run --frozen shellcheck ./**/*.sh; \
		break; \
	done

lint:
	uv run --frozen ruff format ./ --check
	uv run --frozen ruff check ./
	make -- --shell-check

format:
	uv run --frozen ruff format ./
	uv run --frozen ruff check --fix ./

bump-version:
	@make -- --check-git-status
	@old_version=$$(uv version --frozen --dry-run --short); echo "Current version: $${old_version}"; \
		bmp_vrs=$(COMMIT_VERSION); \
		case $${bmp_vrs} in \
			major|minor|patch) echo "Version bumping: $${bmp_vrs}"; uv version --bump $${bmp_vrs}; ;; \
			*) echo "New version provided: $${bmp_vrs}"; uv version "$${bmp_vrs}"; ;; \
		esac; \
		new_version=$$(uv version --dry-run --short); \
		if [ "$${new_version}" = "$${old_version}" ]; then \
			echo "$${old_version} version update did not change the version number."; \
			exit 0; \
		else \
			uv sync; \
			uv run git commit pyproject.toml uv.lock -m ":bookmark: Bumping version from v$${old_version} to v$${new_version}"; \
			git tag -a "v$${new_version}" -m ":bookmark: Bumping version from v$${old_version} to v$${new_version}"; \
			echo "\nNew version: $${new_version}"; \
		fi

test:
	@echo "There are no tests defined in this project."

--license-export:
	@echo "Exporting the requirements ..."
	uv export --frozen --output-file requirements.txt.tmp --quiet
	uv run --frozen liccheck -s pyproject.toml -r requirements.txt.tmp -R license-report.txt.tmp
	rm requirements.txt.tmp
	uv run --frozen python scripts/convert-license-report.py -f license-report.txt.tmp -co "license-report.csv" -ro "thirdparty.rst"
	rm license-report.txt.tmp

license-headers:
	uv run --frozen licenseheaders -t .license.tmpl -d ${PROJECT_PKG} -cy
	uv run --frozen licenseheaders -t .license.tmpl -d scripts -cy
	@echo "Successfully modified headers."

--license-headers-check:
	@make -- --check-git-status
	make license-headers
	@make -- --check-git-status
	@echo "All files have the correct license headers."

license-check:
	make -- --license-headers-check
	@echo "Exporting the requirements ..."
	uv export --frozen --output-file requirements.txt.tmp --quiet
	@echo "Checking for license conflicts ..."
	@uv run --frozen liccheck -s pyproject.toml -r requirements.txt.tmp --level cautious \
		&& rm requirements.txt.tmp \
		&& echo "There were no license conflicts!" \
		|| ( \
			rm requirements.txt.tmp \
			&& echo "Some license conflicts were found and need to be fixed (see above)." \
			&& exit 1\
			)

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

--setup-license:
	@echo "Adding license headers to all files ..."; make license-headers
	@git_status=$$(git status --porcelain); \
		if [ -n "$${git_status}" ]; \
		then \
			git add ./*; \
			uv run pre-commit run --all-files || true; \
			git add ./*; \
			uv run git commit -m ":page_facing_up: Add license headers"; \
		fi
	@echo "Checking if license headers are correct ..."; make -- --license-headers-check || exit 1

setup:
	@make -- --check-git-status || exit 1
	@make -- --setup-uv || exit 1; make -- --setup-license || exit 1
	@echo "Checking pre-commits ..."; uv run --frozen pre-commit run --all-files || exit 1
	@echo "\nSetup completed successfully!\n"
