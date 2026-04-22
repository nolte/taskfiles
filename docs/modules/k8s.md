# k8s

Bootstrap a minimal set of Kubernetes services into the current cluster.

## Tasks

| Task | Description |
|------|-------------|
| `k8s:bootstrap` | Run the full bootstrap (currently: `install-argocd`) |
| `k8s:install-argocd` | Render ArgoCD with `helm template` and apply it to the `argocd` `namespace` |

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `ARGOCD_EXTRA_ARGS` | `""` | Extra arguments passed to `helm template argocd argo/argo-cd` |
| `KUBECTL_TIMEOUT` | `120s` | Timeout for `kubectl apply` |

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
