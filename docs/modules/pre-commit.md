# pre-commit

Run [pre-commit](https://pre-commit.com/) hooks from a pre-provisioned Python virtual environment at `~/.venvs/development`.

## Tasks

| Task | Description |
|------|-------------|
| `pre-commit:install` | Install the hooks into the current project (`pre-commit install`) |
| `pre-commit:start` | Run every hook over every file (`pre-commit run --all-files`) |

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `PYTHON_VENVS_BASEDIR` | `~/.venvs/` | Base directory for the Python virtual environments |
| `PYTHON_VENV_DIR_DEVELOPMENT` | `{{.PYTHON_VENVS_BASEDIR}}/development` | Full path to the development virtual environment |

## Example

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  pre-commit: "{{.TASK_COLLECTION_BASE}}/taskfile-include-pre-commit.yaml"
```
