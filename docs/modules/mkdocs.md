# mkdocs

Serve the [mkdocs](https://www.mkdocs.org/) site of the consumer project from a pre-provisioned Python virtual environment at `~/.venvs/docs`.

## Tasks

| Task | Description |
|------|-------------|
| `mkdocs:start` | Run `mkdocs serve` bound to `localhost:{{.MKDOCS_PORT}}` |

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `MKDOCS_PORT` | `8001` | Port for `mkdocs serve` |
| `PYTHON_VENVS_BASEDIR` | `~/.venvs/` | Base directory for the Python virtual environments |
| `PYTHON_VENV_DIR_DOCS` | `{{.PYTHON_VENVS_BASEDIR}}/docs` | Full path to the docs virtual environment |

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
