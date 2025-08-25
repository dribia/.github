# Github

*GitHub configurations for Dribia organization.*

**Author** Dribia Data Research <code@dribia.com>

[![Lint](https://github.com/dribia/github-config/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/dribia/github-config/actions/workflows/lint.yml?query=branch%3Amain)
[![License](https://github.com/dribia/github-config/actions/workflows/license.yml/badge.svg?branch=main)](https://github.com/dribia/github-config/actions/workflows/license.yml?query=branch%3Amain)
[![Version](https://storage.googleapis.com/badges-acfad1c6946ef2ce/github-config/main/version.svg)](https://github.com/dribia/github-config/tree/main)

---

## Main functionalities

Describe here the main functionalities of your project.

## Start developing

Following the next few steps you can set up **Github** locally to start working on it:

* Clone the repository using `git clone git@github.com:dribia/github-config.git`
* `cd` into the cloned `github-config` folder.
* Run the provided setup command with `make setup`, which will:
    * Install `github` and its dependencies in a virtual environment and commit the resulting `uv.lock` file.
    * Install the configured pre-commits.

### Makefile

This project contains a Makefile that centralize all the useful commands necessary to set up a new
project, check linting of run tests.

### Versioning

Our projects must follow [semantic versioning.](https://semver.org/)
The command `make bump-version` can help you bump your project's version.
For instance:

```shell
make bump-version
# Semantic bump ("major", "minor" or "patch") or new version (eg. "0.1.3"): minor
```

will bump your project's version's second digit (e.g. from `0.1.0` to `0.2.0`).

The requested input accepts the same arguments as uv's `uv version`
[command](https://docs.astral.sh/uv/reference/cli/#uv-version).

This will modify the version informed in your `pyproject.toml` file,
commit this file with a standard commit message and, tag the commit
with the corresponding version number.

Remember you need to specifically push your tags with:

```shell
git push origin --tags
```

### Code linting

This project provides tools to lint your code, which will help you discover bugs and have your codebase clean.

First, you should **always have pre-commits activated**.
If you've done the setup with the `make setup` command you're good to go.
Otherwise, run `uv run pre-commit install` to install the pre-commit hooks.

Then, there is also a `make lint` command that runs the required linting operations.
This is part of the CI pipeline, so **you must make sure this script runs without problems!**

### Licensing

Before starting this project you should have agreed with Dribia the license option
to choose. If you did so, and correctly informed the option when scaffolding the project,
you should have the correct LICENSE file. If not, you should modify it accordingly.

#### License headers

As a part of the project licensing, every source code file written by Dribia should have an
informative header about the license agreement.

The following command automatically puts these headers to every source code file:

```shell
make license-headers
```

#### License check

As a part of our agreement with clients, we might have to provide a report telling which third-party
libraries our project is using, and if their license allows us to use them.
Also, there are some copyleft libraries which is better not to use in our projects.

The following command allows us to check if the third-party libraries we are using have a
true open source license so that we can effectively use them. It also checks if the headers
are correctly placed in the code files:

```shell
make license-check
```

There is a white and black list system for licenses we want to accept and avoid
that is configured in the `[tool.liccheck]` section of the `pyproject.toml` file,
in the `authorized_licenses` and `unauthorized_licenses` respectively.

There is also the option to put a specific library to the white list whichever its license
is, by putting it in the `[tool.liccheck.authorized_packages]` section of the same file.
Of course, this cannot be called a best practice!

> [!NOTE]
> Note that this check is a part of the CI pipeline for the `main` branch,
> so you should make sure that license headers and license compliance are OK before pushing to `main`.
