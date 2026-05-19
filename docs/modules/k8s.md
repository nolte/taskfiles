# k8s

Bootstrap a minimal set of Kubernetes services into the current cluster.

## Prerequisites

* `kubectl` and `helm` binaries on the `PATH`.
* A reachable Kubernetes cluster, typically a [kind](kind.md) cluster started through `task kind:start`. The current `kubectl` context decides which cluster receives the install.

## Tasks

| Task | Description |
|------|-------------|
| `k8s:bootstrap` | Run the full bootstrap (today: delegates to `install-argocd`). |
| `k8s:install-argocd` | Render ArgoCD with `helm template` and apply it to the `argocd` namespace. |

`install-argocd` creates the `argocd` namespace when it doesn't exist (`kubectl create namespace argocd || true`), adds the `argo` Helm repository, refreshes the index, and pipes `helm template argocd argo/argo-cd` into `kubectl apply` with a configurable timeout.

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

Then run `task k8s:bootstrap` (or `task k8s:install-argocd` directly) from the consumer's working directory.

## Troubleshooting

* `kubectl apply` times out: increase `KUBECTL_TIMEOUT`. Slower clusters and larger ArgoCD installs need more headroom than the default `120s`.
* `helm repo add` fails on a re-run because the repo is already registered. The task tolerates this case for `kubectl create namespace`, but `helm` exits non-zero on duplicate adds. Remove the existing entry with `helm repo remove argo` when it causes a failure.
