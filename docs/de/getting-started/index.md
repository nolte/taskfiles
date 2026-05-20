---
title: Getting Started
audience:
  - taskfile-consumer-project
  - consumer-developer
content_mode: tutorial
track: developer-docs
last_updated: 2026-05-20
source_language: en
---

# Erste Schritte

Dieses Tutorial führt ein Konsument-Projekt durch die erste erfolgreiche
Nutzung eines Moduls. Am Ende läuft `task pre-commit:start` gegen das
Konsument-Repository, bezogen aus einem einzigen Remote-Include.

## Voraussetzungen

- Eine aktuelle [go-task](https://taskfile.dev/)-Installation im `PATH`.
- Das Konsument-Repository lokal ausgecheckt mit einer `Taskfile.yml`. Eine
  frische `Taskfile.yml` mit `version: '3'` reicht aus.
- Eine vorbereitete Python-Virtual-Environment unter `~/.venvs/development`,
  die das `pre-commit`-Paket enthält. Das Playbook
  [`nolte/workstation`](https://github.com/nolte/workstation) richtet sie
  ein; jede andere Ansible-Rolle oder manuelles `python -m venv`
  funktioniert genauso, solange der Pfad stimmt.

Das Tutorial nutzt bewusst `pre-commit`, weil es nur eine
Python-Virtual-Environment voraussetzt und weder `docker`, `kind` noch
einen Kubernetes-Cluster benötigt.

## 1. Collection-Basis in das Konsument-Taskfile aufnehmen

Ergänze in der `Taskfile.yml` des Konsumenten eine
`TASK_COLLECTION_BASE`-Variable und einen einzelnen Include:

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  pre-commit: "{{.TASK_COLLECTION_BASE}}/taskfile-include-pre-commit.yaml"
```

Das Beispiel pinnt auf `main`. Das ist praktisch, solange du das Modul
evaluierst. Für den produktiven Alltag wechsle auf ein veröffentlichtes
Tag (siehe [Pin-Strategie](../references/index.md#pin-strategie) unter
Referenzen).

## 2. Auflösung des Includes prüfen

Aus dem Arbeitsverzeichnis des Konsumenten die verfügbaren Tasks
auflisten:

```bash
task --list
```

Zwei Tasks aus dem Include erscheinen: `pre-commit:install` und
`pre-commit:start`. Wenn sie fehlen, ist entweder die Include-Adresse
falsch oder das Netzwerk erreicht `raw.githubusercontent.com` nicht.

## 3. Den ersten Task ausführen

```bash
task pre-commit:start
```

Der Task aktiviert `~/.venvs/development` und führt
`pre-commit run --all-files` im Arbeitsverzeichnis des Konsumenten aus.
Bei Erfolg gibt `pre-commit` pro Hook eine Zeile aus, jeweils mit
`Passed`, `Skipped` oder `Failed`. Ein scheiternder Hook ist ein Treffer
in der Prosa oder im Code des Konsumenten — kein Problem des Includes.

## 4. Auf ein veröffentlichtes Tag pinnen

Sobald der Include funktioniert, weiche von `main` ab, damit das Verhalten
über Maschinen hinweg deterministisch bleibt:

```yaml
vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/<tag>/src
```

Ersetze `<tag>` durch eine veröffentlichte Version aus der
[GitHub-Releases-Seite](https://github.com/nolte/taskfiles/releases). Alle
vier Module teilen die gleiche Basis-Adresse, sodass ein einzelner
Renovate-getriebener Bump alle Includes in einem Pull Request abdeckt.

## Was als Nächstes lesen

- [Referenzen → Module](../references/index.md) listet jeden Task, jede
  Variable und ein kopierfertiges Beispiel für die vier heute
  ausgelieferten Module.
- [Referenzen → Gemeinsamer Vertrag](../references/index.md#gemeinsamer-vertrag)
  erklärt die Konventionen, die modulübergreifend gelten
  (Arbeitsverzeichnis, Override-Syntax, Pin-Strategie).
- [Anleitungen → Mitwirken](../guides/contributing.md) beschreibt, wie ein
  neues Modul hinzukommt oder ein bestehender Task geändert wird.

## Quellen

- [`README.md`](https://github.com/nolte/taskfiles/blob/main/README.md)
  (Usage-Sektion)
- `src/taskfile-include-pre-commit.yaml`
