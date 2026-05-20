---
title: k8s
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-05-20
source_language: en
---

# k8s

Einen minimalen Satz an Kubernetes-Services in den aktuellen Cluster
einspielen.

Siehe [Referenzen → Gemeinsamer Vertrag](../index.md#gemeinsamer-vertrag) für
die Konventionen zu `USER_WORKING_DIR`, Pin-Strategie und Override-Syntax,
die modulübergreifend gelten.

## Voraussetzungen

- `kubectl`- und `helm`-Binaries im `PATH`.
- Ein erreichbarer Kubernetes-Cluster, typischerweise ein über
  `task kind:start` gestarteter [kind](kind.md)-Cluster. Der aktuelle
  `kubectl`-Kontext entscheidet, welcher Cluster die Installation
  empfängt.

## Tasks

| Task | Beschreibung |
|------|--------------|
| `k8s:bootstrap` | Den vollständigen Bootstrap ausführen (heute: delegiert auf `install-argocd`). |
| `k8s:install-argocd` | ArgoCD mit `helm template` rendern und in den `argocd`-Namespace applyen. |

`install-argocd` führt vier Schritte in dieser Reihenfolge aus:

1. `kubectl create namespace argocd || true`: idempotent bei Re-Runs.
2. `helm repo add argo https://argoproj.github.io/argo-helm`: der
   helm-Client gibt eine Warnung zurück, wenn das Repository bereits
   unter derselben Adresse registriert ist; ein Fehler tritt nur auf,
   wenn die Adresse von der registrierten abweicht.
3. `helm repo update`: aktualisiert den lokalen Index.
4. `helm template argocd argo/argo-cd {{.ARGOCD_EXTRA_ARGS}} --namespace=argocd
   | kubectl --timeout={{.KUBECTL_TIMEOUT}} apply -n argocd -f -`:
   rendert das Chart und applyt es.

## Variablen

| Variable | Default | Zweck |
|----------|---------|-------|
| `ARGOCD_EXTRA_ARGS` | `""` | Zusätzliche Argumente, die an `helm template argocd argo/argo-cd` übergeben werden (zum Beispiel `--set global.image.tag=v2.10.0`). |
| `KUBECTL_TIMEOUT` | `120s` | Timeout für den `kubectl apply`-Schritt. |

## Beispiel

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

`task k8s:bootstrap` (oder direkt `task k8s:install-argocd`) aus dem
Arbeitsverzeichnis des Konsumenten aufrufen.

## Fehlerbehebung

- **`kubectl apply` läuft in einen Timeout.** `KUBECTL_TIMEOUT` erhöhen.
  Langsamere Cluster und größere ArgoCD-Installationen brauchen mehr
  Puffer als die Default-`120s`.
- **`helm repo add` scheitert beim Re-Run.** Der helm-Client exit Code
  ungleich null, wenn das `argo`-Repository bereits unter einer anderen
  Adresse registriert ist. Den konfliktierenden Eintrag mit
  `helm repo remove argo` entfernen und den Task erneut ausführen.
- **Falscher Cluster empfängt die Installation.** Der Task nutzt den
  aktuellen `kubectl`-Kontext. `kubectl config current-context` vor dem
  Bootstrap prüfen.
