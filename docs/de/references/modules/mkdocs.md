---
title: mkdocs
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-05-20
source_language: en
---

# mkdocs

Servieren der [mkdocs](https://www.mkdocs.org/)-Site des
Konsument-Projekts aus einer vorbereiteten Python-Virtual-Environment.

Siehe [Referenzen → Gemeinsamer Vertrag](../index.md#gemeinsamer-vertrag) für
die Konventionen zu `USER_WORKING_DIR`, Pin-Strategie, Override-Syntax
und Virtual Environments, die modulübergreifend gelten.

## Voraussetzungen

- Eine Python-Virtual-Environment unter `~/.venvs/docs`, die den
  mkdocs-Stack des Konsumenten enthält. Das Playbook
  [`nolte/workstation`](https://github.com/nolte/workstation) richtet sie
  ein; andernfalls `PYTHON_VENVS_BASEDIR` auf einen anderen Ort zeigen
  lassen.
- Das `mkdocs.yml` des Konsumenten liegt im Arbeitsverzeichnis, aus dem
  der `task`-Befehl läuft (`USER_WORKING_DIR`).

## Tasks

| Task | Beschreibung |
|------|--------------|
| `mkdocs:start` | `PYTHON_VENV_DIR_DOCS` aktivieren und `mkdocs serve -a localhost:{{.MKDOCS_PORT}}` ausführen. |

## Variablen

| Variable | Default | Zweck |
|----------|---------|-------|
| `MKDOCS_PORT` | `8001` | Port für `mkdocs serve`. |
| `PYTHON_VENVS_BASEDIR` | `~/.venvs/` | Basisverzeichnis für die Python-Virtual-Environments. |
| `PYTHON_VENV_DIR_DOCS` | `{{.PYTHON_VENVS_BASEDIR}}/docs` | Vollständiger Pfad zur Docs-Virtual-Environment. |

## Beispiel

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

`task mkdocs:start` aus dem Verzeichnis aufrufen, in dem das `mkdocs.yml`
des Konsumenten liegt.

## Fehlerbehebung

- **`mkdocs: command not found`.** Die Docs-Venv fehlt oder ist leer.
  Prüfen, ob `~/.venvs/docs/bin/activate` existiert und ob die Venv das
  `mkdocs`-Paket enthält.
- **Port bereits in Verwendung.** Ein anderes `mkdocs serve` belegt
  bereits den Default-Port. `MKDOCS_PORT` wie im obigen Beispiel
  überschreiben.
- **mkdocs serviert eine andere Site als erwartet.** Der Task nutzt
  `USER_WORKING_DIR`. Prüfen, dass das Verzeichnis, aus dem `task`
  aufgerufen wird, das `mkdocs.yml` des Konsumenten enthält.
