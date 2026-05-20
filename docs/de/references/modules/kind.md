---
title: kind
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-05-20
source_language: en
---

# kind

Einen lokalen [kind](https://kind.sigs.k8s.io/)-Entwicklungs-Cluster
steuern.

Siehe [Referenzen → Gemeinsamer Vertrag](../index.md#gemeinsamer-vertrag) für
die Konventionen zu `USER_WORKING_DIR`, Pin-Strategie und Override-Syntax,
die modulübergreifend gelten.

## Voraussetzungen

- `kind`-Binary im `PATH`.
- Eine laufende Container-Runtime (`docker` oder kompatibel); `kind`
  stellt den Cluster als Container bereit.

## Tasks

| Task | Beschreibung |
|------|--------------|
| `kind:start` | `kind create {{.KIND_CREATE_EXTRA_ARGS}} cluster` ausführen. |
| `kind:destroy` | `kind delete cluster` ausführen. |
| `kind:recreate` | `kind:destroy`, dann `kind:start` aufrufen. |

Die Interpolation von `KIND_CREATE_EXTRA_ARGS` landet zwischen `create`
und `cluster`, sodass `kind`s eigene Flag-Reihenfolge erhalten bleibt
(aus `kind create cluster --config …` wird `kind create --config …
cluster`). Damit lassen sich `--config`, `--name` oder `--image` übergeben.

## Variablen

| Variable | Default | Zweck |
|----------|---------|-------|
| `KIND_CREATE_EXTRA_ARGS` | `""` | Zusätzliche Argumente, die in `kind create … cluster` injiziert werden. |

## Beispiel

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

`task kind:start`, `task kind:destroy` oder `task kind:recreate` aus dem
Arbeitsverzeichnis des Konsumenten aufrufen.

## Fehlerbehebung

- **`kind:recreate` scheitert beim ersten Lauf.** `kind:destroy` exit
  Code ungleich null, wenn kein Cluster zu löschen vorhanden ist, was
  als Fehler von `kind:recreate` durchschlägt. Für eine frische
  Bereitstellung direkt `kind:start` verwenden.
- **Eigene Node-Images oder Netzwerk-Settings.** Über
  `KIND_CREATE_EXTRA_ARGS` `--image` oder `--config` übergeben. Das Modul
  verwaltet die `kind`-Config-Datei nicht; sie liegt im
  Konsument-Repository.
- **`kind` erreicht Docker nicht.** Bestätigen, dass `docker info` für
  den aktuellen User erfolgreich ist. Bei rootless-Setups doppelt prüfen,
  dass der Docker-Socket erreichbar ist.
