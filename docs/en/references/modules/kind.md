---
title: kind
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-05-20
---

# kind

Control a local [kind](https://kind.sigs.k8s.io/) development cluster.

See [References → Common contract](../index.md#common-contract) for the
`USER_WORKING_DIR`, pin-strategy, and override-syntax conventions that
apply across every module.

## Prerequisites

- `kind` binary on the `PATH`.
- A container runtime (`docker` or compatible) up and running; `kind`
  provisions the cluster as containers.

## Tasks

| Task | Description |
|------|-------------|
| `kind:start` | Run `kind create {{.KIND_CREATE_EXTRA_ARGS}} cluster`. |
| `kind:destroy` | Run `kind delete cluster`. |
| `kind:recreate` | Call `kind:destroy`, then `kind:start`. |

The `KIND_CREATE_EXTRA_ARGS` interpolation lands between `create` and
`cluster`, matching `kind`'s own flag ordering (`kind create cluster --config
…` becomes `kind create --config … cluster`). Use the override to pass
`--config`, `--name`, or `--image`.

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `KIND_CREATE_EXTRA_ARGS` | `""` | Extra arguments injected into `kind create … cluster`. |

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

Run `task kind:start`, `task kind:destroy`, or `task kind:recreate` from
the consumer's working directory.

## Troubleshooting

- **`kind:recreate` fails on the first run.** `kind:destroy` exits non-zero
  when there is no cluster to delete, which surfaces as a failure of
  `kind:recreate`. Use `kind:start` directly for fresh provisioning.
- **Custom node images or networking.** Pass `--image` or `--config`
  through `KIND_CREATE_EXTRA_ARGS`. The module doesn't own the `kind`
  config file; it lives in the consumer repository.
- **`kind` can't reach Docker.** Confirm `docker info` succeeds for the
  current user. On rootless setups, double-check that the Docker socket
  is reachable.
