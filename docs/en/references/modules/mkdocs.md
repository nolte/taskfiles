---
title: mkdocs
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-08-09
---

# mkdocs

Serve and strictly build the [mkdocs](https://www.mkdocs.org/) site of the
consumer project from a pre-provisioned Python virtual environment.

See [References → Common contract](../index.md#common-contract) for the
`USER_WORKING_DIR`, pin-strategy, override-syntax, and venv conventions
that apply across every module.

## Prerequisites

- A Python virtual environment at `~/.venvs/docs` that holds the consumer's
  mkdocs stack. The [`nolte/workstation`](https://github.com/nolte/workstation)
  playbook provisions it; point `PYTHON_VENVS_BASEDIR` at a different
  location otherwise.
- The consumer's `mkdocs.yml` lives in the working directory the `task`
  command runs from (`USER_WORKING_DIR`).

## Tasks

| Task | Description |
|------|-------------|
| `mkdocs:start` | Activate `PYTHON_VENV_DIR_DOCS` and run `mkdocs serve -a localhost:{{.MKDOCS_PORT}}`. |
| `mkdocs:build` | Activate `PYTHON_VENV_DIR_DOCS` and run `mkdocs build --strict {{.MKDOCS_BUILD_EXTRA_ARGS}}`; fails on any warning, so CI can verify the site is fully buildable. |

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `MKDOCS_PORT` | `8001` | Port for `mkdocs serve`. |
| `MKDOCS_BUILD_EXTRA_ARGS` | (empty) | Extra arguments appended to `mkdocs build --strict`. |
| `PYTHON_VENVS_BASEDIR` | `~/.venvs/` | Base directory for the Python virtual environments. |
| `PYTHON_VENV_DIR_DOCS` | `{{.PYTHON_VENVS_BASEDIR}}/docs` | Full path to the docs virtual environment. |

## Example

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  mkdocs:
    taskfile: "{{.TASK_COLLECTION_BASE}}/taskfile-include-mkdocs.yaml"
    vars:
      MKDOCS_PORT: 8080
```

Run `task mkdocs:start` from the directory that holds the consumer's
`mkdocs.yml`.

## Troubleshooting

- **`mkdocs: command not found`.** The docs venv is missing or empty.
  Confirm that `~/.venvs/docs/bin/activate` exists and that the venv holds
  the `mkdocs` package.
- **Port already in use.** Another `mkdocs serve` already holds the default
  port. Override `MKDOCS_PORT` as shown in the preceding example.
- **mkdocs serves a different site than expected.** The task uses
  `USER_WORKING_DIR`. Verify the directory the `task` command runs from
  has the consumer's `mkdocs.yml`.
