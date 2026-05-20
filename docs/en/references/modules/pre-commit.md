---
title: pre-commit
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-05-20
---

# pre-commit

Run [pre-commit](https://pre-commit.com/) hooks from a pre-provisioned
Python virtual environment.

See [References → Common contract](../index.md#common-contract) for the
`USER_WORKING_DIR`, pin-strategy, override-syntax, and venv conventions
that apply across every module.

## Prerequisites

- A Python virtual environment at `~/.venvs/development` that holds the
  `pre-commit` package. The
  [`nolte/workstation`](https://github.com/nolte/workstation) playbook
  provisions it.
- The consumer repository has a `.pre-commit-config.yaml`.

## Tasks

| Task | Description |
|------|-------------|
| `pre-commit:install` | Activate the development venv and run `pre-commit install`. |
| `pre-commit:start` | Activate the development venv and run `pre-commit run --all-files`. |

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `PYTHON_VENVS_BASEDIR` | `~/.venvs/` | Base directory for the Python virtual environments. |
| `PYTHON_VENV_DIR_DEVELOPMENT` | `{{.PYTHON_VENVS_BASEDIR}}/development` | Full path to the development virtual environment. |

## Example

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  pre-commit: "{{.TASK_COLLECTION_BASE}}/taskfile-include-pre-commit.yaml"
```

Typical local workflow:

```bash
task pre-commit:install   # one-time, registers the git hook
task pre-commit:start     # on demand, runs every hook over every file
```

In CI, run `task pre-commit:start` directly. A fresh runner has no git
hook to install.

## Troubleshooting

- **`pre-commit: command not found`.** The development venv is missing or
  empty. Confirm that `~/.venvs/development/bin/activate` exists and that
  the venv holds the `pre-commit` package.
- **A hook fails on the first run.** `pre-commit` has to fetch and build
  the hook environment the first time. Re-run the same task; `pre-commit`
  caches hook environments under `~/.cache/pre-commit/`.
- **Hooks report no files.** Confirm the `task` command runs from the root
  of the consumer repository (`USER_WORKING_DIR`), not from a sub-directory
  that holds no tracked files.
