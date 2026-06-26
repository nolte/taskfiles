---
title: worktree
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-06-26
source_language: en
---

# worktree

Parallele Arbeitskopien als [git worktrees](https://git-scm.com/docs/git-worktree)
erstellen und verwalten. Jedes Projekt, das diese Sammlung nutzt, erhält
denselben vorhersehbaren, wiederverwendbaren Weg, um einen isolierten Checkout
für einen Feature-Branch anzulegen, ohne den primären Checkout je von
`develop` wegzuschalten.

Siehe [Referenzen → Gemeinsamer Vertrag](../index.md#gemeinsamer-vertrag) für
die Konventionen zu `USER_WORKING_DIR`, Pin-Strategie und Override-Syntax,
die modulübergreifend gelten.

## Voraussetzungen

- `git` im `PATH`, ausgeführt innerhalb eines Repositories mit einem
  `origin`-Remote — `<repo>` wird aus `origin` abgeleitet, nie aus dem
  Arbeitsverzeichnis geraten.
- Optional die Umgebungsvariable `NOLTE_WORKTREE_ROOT`, um festzulegen, wo
  Worktrees landen. Sie gewinnt zur Laufzeit gegen die Variable
  `WORKTREE_ROOT_DEFAULT`; beide haben den Default `~/repos/.worktrees`.

## Layout

Jeder Worktree landet am selben vorhersehbaren Ort:

```text
${NOLTE_WORKTREE_ROOT:-~/repos/.worktrees}/<repo>/<slug>/
```

`<repo>` stammt aus dem `origin`-Remote und `<slug>` ist ein einzelnes
kebab-case-Pfadsegment (der Branch-Name ohne Prefix, sofern nicht explizit
angegeben).

## Tasks

| Task | Beschreibung |
|------|--------------|
| `worktree:add -- <branch> [slug]` | Den Base-Ref fetchen, `<branch>` aus `{{.WORKTREE_BASE_REF}}` in einem neuen Worktree erstellen und einen `.resume/<slug>/plan.md`-Plan-Stub anlegen. |
| `worktree:remove -- <slug> [force]` | Den Worktree für `<slug>` entfernen. Der Branch bleibt erhalten. `force` übergeben, um einen Worktree mit nicht committeter oder untracked Arbeit zu verwerfen (inklusive des Plan-Stubs). |
| `worktree:list` | `git worktree list` für das aktuelle Repository ausführen. |
| `worktree:root` | Den aufgelösten Worktree-Root dieser Maschine ausgeben. |

`worktree:add` validiert den Branch-Prefix gegen
`WORKTREE_ALLOWED_PREFIXES` (die Branching-Modell-Regel): Der Pfad-Slug darf
den Prefix weglassen, der Branch selbst muss aber einen tragen. Der Branch
wird stets aus einem frisch gefetchten `{{.WORKTREE_BASE_REF}}` geschnitten,
sodass er unabhängig vom Zustand des lokalen Checkouts an der Remote-Spitze
beginnt.

Der angelegte `.resume/<slug>/plan.md` ist ein Plan-before-work-Gate: vor
Beginn der eigentlichen Arbeit ausfüllen, damit eine frische, fortsetzbare
Session im Worktree die Arbeit von einem bekannten Startpunkt aufnehmen kann.
Er liegt unter `.resume/`, das das Konsument-Repository üblicherweise aus der
Versionskontrolle heraushält.

## Variablen

| Variable | Default | Zweck |
|----------|---------|-------|
| `WORKTREE_BASE_REF` | `origin/develop` | Ref, aus dem neue Branches geschnitten werden. |
| `WORKTREE_FETCH_REMOTE` | `origin` | Remote, das vor dem Erstellen des Worktrees gefetcht wird. |
| `WORKTREE_FETCH_BRANCH` | `develop` | Branch, der vor dem Erstellen des Worktrees gefetcht wird. |
| `WORKTREE_ALLOWED_PREFIXES` | `feat fix chore docs exp` | Leerzeichengetrennte Branch-Prefixes, die `add` akzeptiert. |
| `WORKTREE_ROOT_DEFAULT` | `~/repos/.worktrees` | Fallback-Root, wenn `NOLTE_WORKTREE_ROOT` nicht gesetzt ist. |

## Beispiel

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  worktree:
    taskfile: "{{.TASK_COLLECTION_BASE}}/taskfile-include-worktree.yaml"
    vars:
      WORKTREE_BASE_REF: "origin/main"
      WORKTREE_ALLOWED_PREFIXES: "feat fix chore"
```

Anschließend aus dem Arbeitsverzeichnis des Konsumenten:

```bash
# Worktree für einen Feature-Branch aus dem Base-Ref erstellen.
task worktree:add -- feat/parser-fix

# Expliziten kurzen Slug als Verzeichnisnamen übergeben.
task worktree:add -- chore/ci-tidy ci

# Inspizieren und aufräumen.
task worktree:list
task worktree:remove -- ci
```

## Fehlerbehebung

- **`worktree:add` lehnt den Branch ab.** Der Branch muss einen der Prefixes
  aus `WORKTREE_ALLOWED_PREFIXES` tragen (Default `feat fix chore docs exp`).
  Der Slug darf den Prefix weglassen, der Branch nicht.
- **`worktree:remove` scheitert ohne `force`.** `git worktree remove`
  weigert sich, einen Worktree mit nicht committeten oder untracked Dateien
  zu entfernen — und der angelegte `.resume/<slug>/plan.md` zählt als
  untracked, sofern das Konsument-Repository `.resume/` nicht gitignored. Mit
  `task worktree:remove -- <slug> force` erneut ausführen, um ihn zu
  verwerfen, oder die Arbeit zuvor committen bzw. verschieben.
- **Der Worktree landete am falschen Ort.** Der Root ist
  `NOLTE_WORKTREE_ROOT`, falls gesetzt, sonst `WORKTREE_ROOT_DEFAULT`. Mit
  `task worktree:root` den aufgelösten Wert der aktuellen Maschine anzeigen.
- **`origin` nicht gefunden.** Das Modul leitet `<repo>` aus dem
  `origin`-Remote ab. Eines hinzufügen (`git remote add origin …`) oder
  innerhalb eines Clones ausführen, der es bereits hat.
