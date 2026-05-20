---
title: taskfiles
audience:
  - taskfile-consumer-project
  - consumer-developer
content_mode: meta
track: developer-docs
last_updated: 2026-05-20
source_language: en
---

# taskfiles

`nolte/taskfiles` ist eine kuratierte Sammlung wiederverwendbarer
[Taskfile](https://github.com/go-task/task)-Include-Module. Jedes Modul
liegt als einzelne YAML-Datei unter `src/` und wird von Konsument-Projekten
über das Taskfile-Experiment
[remote-taskfiles](https://taskfile.dev/experiments/remote-taskfiles/)
eingebunden. Es gibt keinen Build-Schritt und kein Laufzeitartefakt — die
YAML-Dateien selbst sind das Produkt.

Jeder Task in jedem Modul setzt `dir: '{{.USER_WORKING_DIR}}'`, sodass
Befehle im Arbeitsverzeichnis des Konsument-Projekts laufen, niemals in
diesem Repository.

## Wo anfangen

Diese Site bedient drei Lesergruppen. Wähle die Sektion, die zur aktuellen
Aufgabe passt:

- **Modul einbinden.** Einen Include in ein Konsument-Projekt verdrahten,
  einen Pin auswählen, die Variablen anpassen. Start unter
  [Erste Schritte](getting-started/index.md), dann die passende Seite unter
  [Referenzen → Module](references/index.md).
- **Mitwirken.** Ein Modul hinzufügen, einen bestehenden Task ändern oder
  die gerenderte Dokumentation anpassen. Siehe
  [Anleitungen → Mitwirken](guides/contributing.md).
- **Konformität prüfen.** Bestätigen, dass das Repository die
  Portfolio-Specs (Projektstruktur, Release-Automation, Renovate, Vale)
  weiterhin erfüllt. Siehe
  [Referenzen → Governance und Specs](references/governance.md).

Die Struktur folgt der Audience-Analyse in
[`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md).
Jede Seite deklariert in ihrem Front-Matter `audience`, `content_mode` und
`track`, sodass der Bezug zwischen Zielgruppe und Inhalt sichtbar bleibt.

## Quellen

- [`README.md`](https://github.com/nolte/taskfiles/blob/main/README.md)
  (Intro)
- [`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md)
