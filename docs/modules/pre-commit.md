# pre-commit

Run [pre-commit](https://pre-commit.com/) hooks from a pre-provisioned Python virtual environment at `~/.venvs/development`.

## Prerequisites

* Python virtual environment at `~/.venvs/development` that holds the `pre-commit` package. The [nolte/workstation](https://github.com/nolte/workstation) playbook provisions it.
* The consumer repository has a `.pre-commit-config.yaml`.

## Tasks

| Task | Description |
|------|-------------|
| `pre-commit:install` | Install the hooks into the current project (`pre-commit install`). |
| `pre-commit:start` | Run every hook over every file (`pre-commit run --all-files`). |

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

In CI, run `task pre-commit:start` directly: there is no git hook to install.

## Troubleshooting

* `pre-commit: command not found`: the development venv is missing or empty. Verify `~/.venvs/development/bin/activate` exists and that the venv holds the `pre-commit` package.
* A hook fails on the first run because `pre-commit` hasn't fetched it yet. Re-run the same task; `pre-commit` caches hook environments under `~/.cache/pre-commit/`.
