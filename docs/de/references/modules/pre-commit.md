---
title: pre-commit
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-05-20
source_language: en
---

# pre-commit

[pre-commit](https://pre-commit.com/)-Hooks aus einer vorbereiteten
Python-Virtual-Environment ausführen.

Siehe [Referenzen → Gemeinsamer Vertrag](../index.md#gemeinsamer-vertrag) für
die Konventionen zu `USER_WORKING_DIR`, Pin-Strategie, Override-Syntax
und Virtual Environments, die modulübergreifend gelten.

## Voraussetzungen

- Eine Python-Virtual-Environment unter `~/.venvs/development`, die das
  `pre-commit`-Paket enthält. Das Playbook
  [`nolte/workstation`](https://github.com/nolte/workstation) richtet sie
  ein.
- Das Konsument-Repository hat eine `.pre-commit-config.yaml`.

## Tasks

| Task | Beschreibung |
|------|--------------|
| `pre-commit:install` | Development-Venv aktivieren und `pre-commit install` ausführen. |
| `pre-commit:start` | Development-Venv aktivieren und `pre-commit run --all-files` ausführen. |

## Variablen

| Variable | Default | Zweck |
|----------|---------|-------|
| `PYTHON_VENVS_BASEDIR` | `~/.venvs/` | Basisverzeichnis für die Python-Virtual-Environments. |
| `PYTHON_VENV_DIR_DEVELOPMENT` | `{{.PYTHON_VENVS_BASEDIR}}/development` | Vollständiger Pfad zur Development-Virtual-Environment. |

## Beispiel

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  pre-commit: "{{.TASK_COLLECTION_BASE}}/taskfile-include-pre-commit.yaml"
```

Typischer lokaler Ablauf:

```bash
task pre-commit:install   # einmalig, registriert den Git-Hook
task pre-commit:start     # bei Bedarf, läuft alle Hooks über alle Dateien
```

In CI direkt `task pre-commit:start` ausführen. Ein frischer Runner hat
keinen Git-Hook zu installieren.

## Fehlerbehebung

- **`pre-commit: command not found`.** Die Development-Venv fehlt oder
  ist leer. Prüfen, ob `~/.venvs/development/bin/activate` existiert und
  ob die Venv das `pre-commit`-Paket enthält.
- **Ein Hook scheitert beim ersten Lauf.** `pre-commit` muss die
  Hook-Umgebung beim ersten Mal noch abholen und bauen. Denselben Task
  erneut ausführen; `pre-commit` cached Hook-Umgebungen unter
  `~/.cache/pre-commit/`.
- **Hooks melden keine Dateien.** Bestätigen, dass der `task`-Befehl aus
  dem Wurzelverzeichnis des Konsument-Repositories aufgerufen wird
  (`USER_WORKING_DIR`), nicht aus einem Unterverzeichnis ohne getrackte
  Dateien.
