# kind

Control a local [kind](https://kind.sigs.k8s.io/) development cluster.

## Prerequisites

* `kind` binary on the `PATH`.
* `docker` (or a compatible container runtime) running, since `kind` provisions the cluster as containers.

## Tasks

| Task | Description |
|------|-------------|
| `kind:start` | Create the cluster (`kind create cluster`). |
| `kind:destroy` | Delete the cluster (`kind delete cluster`). |
| `kind:recreate` | Delete and create the cluster again (calls `destroy` then `start`). |

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `KIND_CREATE_EXTRA_ARGS` | `""` | Extra arguments passed to `kind create` (for example `--config kind-config.yaml`). |

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

Then run `task kind:start`, `task kind:destroy`, or `task kind:recreate` from the consumer's working directory.

## Troubleshooting

* `kind:recreate` isn't idempotent for a missing cluster: `destroy` exits non-zero when nothing is there to delete. Use `kind:start` directly for fresh provisioning.
* Custom node images or networking go through `KIND_CREATE_EXTRA_ARGS`. The module doesn't own the `kind` config file; it lives in the consumer repository.
