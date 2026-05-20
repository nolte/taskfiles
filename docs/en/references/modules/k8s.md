---
title: k8s
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-05-20
---

# k8s

Bootstrap a minimal set of Kubernetes services into the current cluster.

See [References → Common contract](../index.md#common-contract) for the
`USER_WORKING_DIR`, pin-strategy, and override-syntax conventions that
apply across every module.

## Prerequisites

- `kubectl` and `helm` binaries on the `PATH`.
- A reachable Kubernetes cluster, typically a [kind](kind.md) cluster
  started through `task kind:start`. The current `kubectl` context decides
  which cluster receives the install.

## Tasks

| Task | Description |
|------|-------------|
| `k8s:bootstrap` | Run the full bootstrap (today: delegates to `install-argocd`). |
| `k8s:install-argocd` | Render ArgoCD with `helm template` and apply it to the `argocd` namespace. |

`install-argocd` performs four steps in order:

1. `kubectl create namespace argocd || true`: idempotent on re-runs.
2. `helm repo add argo https://argoproj.github.io/argo-helm`: the helm
   client returns a warning when the repository already exists with the
   same address; it exits non-zero only when the address differs from the
   registered one.
3. `helm repo update`: refreshes the local index.
4. `helm template argocd argo/argo-cd {{.ARGOCD_EXTRA_ARGS}} --namespace=argocd
   | kubectl --timeout={{.KUBECTL_TIMEOUT}} apply -n argocd -f -`: renders
   the chart and applies it.

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `ARGOCD_EXTRA_ARGS` | `""` | Extra arguments passed to `helm template argocd argo/argo-cd` (for example `--set global.image.tag=v2.10.0`). |
| `KUBECTL_TIMEOUT` | `120s` | Timeout for the `kubectl apply` step. |

## Example

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  k8s:
    taskfile: "{{.TASK_COLLECTION_BASE}}/taskfile-include-k8s.yaml"
    vars:
      ARGOCD_EXTRA_ARGS: "--set global.image.tag=v2.10.0"
      KUBECTL_TIMEOUT: "300s"
```

Run `task k8s:bootstrap` (or `task k8s:install-argocd` directly) from the
consumer's working directory.

## Troubleshooting

- **`kubectl apply` times out.** Increase `KUBECTL_TIMEOUT`. Slower
  clusters and larger ArgoCD installs need more headroom than the default
  `120s`.
- **`helm repo add` fails on a re-run.** The helm client exits non-zero
  when the `argo` repository is already registered under a different
  address. Remove the conflicting entry with `helm repo remove argo` and
  re-run the task.
- **Wrong cluster receives the install.** The task uses the current
  `kubectl` context. Check `kubectl config current-context` before running
  the bootstrap.
