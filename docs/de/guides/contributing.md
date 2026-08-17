---
title: Contributing
audience:
  - module-maintainer
  - documentation-author
content_mode: how-to
track: developer-docs
last_updated: 2026-05-20
source_language: en
---

# Mitwirken

Die kanonische Anlaufstelle, um ein Modul hinzuzufügen, einen bestehenden
Task zu ändern oder die gerenderte Doku zu aktualisieren.
[`CLAUDE.md`](https://github.com/nolte/taskfiles/blob/main/CLAUDE.md) hält
dieselben Konventionen für KI-gestützte Edits fest — halte beide
Dokumente synchron, wenn sich der Vertrag ändert.

## Modul-Konventionen

Jede Include-Datei unter `src/` folgt demselben Vertrag. Halte ihn ein,
wenn du Module bearbeitest oder neue hinzufügst.

- **Dateiname.** `taskfile-include-<area>.yaml`. Das `<area>`-Segment ist
  der Schlüssel, unter dem Konsumenten den Include in `includes:`
  verdrahten.
- **Arbeitsverzeichnis.** Jeder Task setzt `dir: '{{.USER_WORKING_DIR}}'`.
  Befehle laufen im Arbeitsverzeichnis des Konsumenten, nicht in diesem
  Repository. Diese Zeile darf nie entfallen.
- **Justierbares Verhalten.** Justierbare Eingaben werden über `vars:` mit
  einem sinnvollen Default offengelegt (zum Beispiel
  `KIND_CREATE_EXTRA_ARGS`, `ARGOCD_EXTRA_ARGS`, `MKDOCS_PORT`,
  `KUBECTL_TIMEOUT`, `PYTHON_VENVS_BASEDIR`). Konsumenten überschreiben sie
  über die long-form `includes:`-Syntax, die unter
  [Referenzen → Gemeinsamer Vertrag](../references/index.md#gemeinsamer-vertrag)
  dokumentiert ist. Keine Werte hart codieren, die nachgelagerte Projekte
  ändern können müssen.
- **Kein eingebettetes Provisionieren.** Python-gestützte Tasks
  (`mkdocs:start`, `pre-commit:install`, `pre-commit:start`) aktivieren
  die vorbereiteten Virtual Environments unter `~/.venvs/docs` und
  `~/.venvs/development` des Konsumenten. Sie installieren keine
  Dependencies on-the-fly.
  [`nolte/workstation`](https://github.com/nolte/workstation) verantwortet
  die Venvs.

## Dokumentations-Konventionen

- Das `mkdocs-include-markdown-plugin` zieht den Intro-Block aus der README
  über die Marker `<!--intro-start-->` und `<!--intro-end-->` in die
  gerenderte Home-Seite. Diese Marker müssen erhalten bleiben; ein
  Verschieben bricht die Include-Integration ohne sichtbaren Build-Fehler.
- Jedes Modul bekommt eine Seite unter
  `docs/en/references/modules/` (sowie die passende Übersetzung unter
  `docs/de/references/modules/`) mit demselben Schema: kurze Einleitung,
  **Voraussetzungen**, **Tasks**, **Variablen**, **Beispiel**,
  **Fehlerbehebung**.
- Neue Modulnamen wandern in das lokale Vale-Vokabular unter
  `.github/styles/config/vocabularies/taskfiles/accept.txt`; sonst schlägt
  der `spelling-vale`-Workflow beim ersten Treffer in Prosa fehl.

## Lokale Prüfungen

Das Repository liefert eine kleine Wrapper-
[`Taskfile.yml`](https://github.com/nolte/taskfiles/blob/main/Taskfile.yml),
die auf die Module in `src/` delegiert:

```bash
task            # verfügbare Tasks auflisten
task lint       # alle pre-commit-Hooks laufen lassen (delegiert auf pre-commit:start)
task docs       # mkdocs-Site lokal servieren (delegiert auf mkdocs:start)
```

Sowohl `lint` als auch `docs` setzen die Venvs `~/.venvs/development` und
`~/.venvs/docs` voraus. Fehlt eine, scheitert der Task beim ersten Lauf.
Die richtige Reaktion ist, die Venv bereitzustellen — nicht, ein
`pip install` in den Task einzubauen. `requirements-dev.txt` pinnt den
mkdocs-Stack für `~/.venvs/docs`, falls das Workstation-Playbook gerade
nicht genutzt wird.

## Pull-Request-Ablauf

- Branche von `main` ab. Das Repository nutzt das spec-konforme
  Branching-Modell aus `nolte/claude-shared`.
- Pull Requests durchlaufen die wiederverwendbaren Workflows aus
  [`nolte/gh-plumbing`](https://github.com/nolte/gh-plumbing) unter einem
  gepinnten Commit-Digest (aktuell die `v2.0.0`-Zeile; den Digest selbst bitte
  aus `.github/workflows/` lesen, da Renovate ihn bumpt, ohne diese Seite
  anzufassen). Bei einem Pin-Bump alle Workflow-Referenzen gemeinsam
  aktualisieren und die Digest-Form beibehalten — ein blankes Tag lässt sich
  auf anderen Code umbiegen.
- Merges sind ausschließlich Squash und durchlaufen Automerge, sobald die
  Checks grün sind. Renovate-getriebene Dependency-Bumps gehen denselben
  Weg.
- Prosa-Änderungen müssen Vale bestehen (Microsoft + RedHat plus das
  [`nolte/vale-style`](https://github.com/nolte/vale-style)-Pack und das
  lokale `taskfiles`-Vokabular). Findings werden nicht per Datei-Ignore
  unterdrückt; entweder den Satz umformulieren oder, falls es sich
  tatsächlich um einen neuen Modulnamen handelt, die Vokabular-Datei
  erweitern.

## Audience-Artefakt erneut prüfen

Wenn sich der öffentliche Vertrag eines Moduls ändert (Task-Umbenennung,
Task-Entfernung, breaking-change `vars:`-Umbenennung oder ein
brandneues Modul), führe einen erneuten Blick auf
[`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md)
durch. Die Sektion `Revisit triggers` am Ende dieser Datei listet jedes
Ereignis, das einen Refresh der Audience-Analyse erfordert.
