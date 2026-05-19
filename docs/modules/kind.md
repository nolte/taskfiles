# kind

Control a local [kind](https://kind.sigs.k8s.io/) development cluster.

## Tasks

| Task | Description |
|------|-------------|
| `kind:start` | Create the cluster (`kind create cluster`) |
| `kind:destroy` | Delete the cluster (`kind delete cluster`) |
| `kind:recreate` | Delete and create the cluster again |

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `KIND_CREATE_EXTRA_ARGS` | `""` | Extra arguments passed to `kind create` (for example `--config kind-config.yaml`) |

## Example

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  kind:
    taskfile: "{{.TASK_COLLECTION_BASE}}/taskfile-include-kind.yaml"
    vars:
      KIND_CREATE_EXTRA_ARGS: "--config kind-config.yaml"
```
