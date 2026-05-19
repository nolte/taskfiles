# mkdocs

Serve the [mkdocs](https://www.mkdocs.org/) site of the consumer project from a pre-provisioned Python virtual environment at `~/.venvs/docs`.

## Prerequisites

* Python virtual environment at `~/.venvs/docs` that holds the consumer's mkdocs stack. The [nolte/workstation](https://github.com/nolte/workstation) playbook provisions it; or, point `PYTHON_VENVS_BASEDIR` at a different location.
* The consumer's `mkdocs.yml` lives in the working directory the `task` runs from (`USER_WORKING_DIR`).

## Tasks

| Task | Description |
|------|-------------|
| `mkdocs:start` | Run `mkdocs serve` bound to `localhost:{{.MKDOCS_PORT}}`. |

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `MKDOCS_PORT` | `8001` | Port for `mkdocs serve`. |
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

Then run `task mkdocs:start` from the directory that holds the consumer's `mkdocs.yml`.

## Troubleshooting

* `mkdocs: command not found`: the docs venv is missing or empty. Verify `~/.venvs/docs/bin/activate` exists and that the venv holds the `mkdocs` package.
* Address already in use: another `mkdocs serve` is already bound to the default port. Override `MKDOCS_PORT` as shown in the preceding example.
