---
title: Governance and specs
audience:
  - portfolio-conventions
  - renovate-governance
content_mode: explanation
track: developer-docs
last_updated: 2026-05-20
source_language: en
---

# Governance und Specs

Diese Seite ist die Anlaufstelle für alle, die prüfen möchten, ob das
Repository die Portfolio-Konventionen weiterhin erfüllt. Sie dupliziert
nicht die Upstream-Specs, sondern listet die Anlaufstellen und den
aktuellen Pin-Stand.

## Portfolio-Konventionen

Das Repository folgt den projektübergreifenden Specs aus
[`nolte/claude-shared`](https://github.com/nolte/claude-shared):

- `project-structure`: Verzeichnislayout, Pflichtdateien, README-Aufbau.
- `branching-model`: Branch-Benennung und -Schutz.
- `pull-request-workflow`: ausschließlich Squash-Merges, Automerge nach
  grünen Checks.
- `release-automation`: Release-Drafter und Release-Publish-Ablauf.
- `audience-identification`: die Spec, die
  [`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md)
  hervorgebracht hat.
- `docs-audience-tracks`: trennt Dokumentation in `user-docs` und
  `developer-docs`. Dieses Repository bedient ausschließlich den
  `developer-docs`-Track.

Das Audience-Artefakt in `AUDIENCES.md` ist die kanonische Aufzeichnung
darüber, wer dieses Repository konsumiert. Jeder Doku-Refactor lässt sich
darauf zurückführen.

## Wiederverwendbare Workflows

Jeder Workflow unter `.github/workflows/` delegiert an einen
wiederverwendbaren Workflow in
[`nolte/gh-plumbing`](https://github.com/nolte/gh-plumbing). Jede Referenz ist
auf einen vollständigen Commit-Digest gepinnt, mit der zugehörigen Version als
nachgestelltem Kommentar; der aktuelle Pin ist
**`d51e51ec3ec17ceea09fe9eb40ac00857b6fa1be` (`v2.0.0`)**. Bei einem Bump alle
Workflow-Referenzen gemeinsam aktualisieren, da gemischte Versionen zwischen
Workflows eine bekannte Drift-Quelle sind.

| Workflow | Wiederverwendbares Ziel |
|----------|-------------------------|
| `automerge.yaml` | `reusable-automerge.yaml` |
| `build-static-tests.yaml` | `reusable-pre-commit.yaml`, `reusable-chain-bench.yaml`, `reusable-trivy.yaml` |
| `release-cd-deliver-docs.yml` | `reusable-mkdocs.yaml` |
| `release-cd-refresh-master.yml` | `reusable-release-cd-refresh-master.yml` |
| `release-drafter.yml` | `reusable-release-drafter.yml` |
| `release-publish.yml` | `reusable-release-publish.yml` |
| `spelling.yaml` | `reusable-spelling-vale.yaml` |

## Dependency-Governance

Renovate läuft gegen dieses Repository über
[`renovate.json5`](https://github.com/nolte/taskfiles/blob/main/renovate.json5),
das `nolte/gh-plumbing//renovate-configs/common` an einem gepinnten Tag
erweitert. Konkrete Erwartungen:

- Alle `uses:`-Referenzen in Workflows pinnen auf einen vollständigen
  Commit-Digest, mit der veröffentlichten Version als nachgestelltem Kommentar.
  Keine schwebenden `@develop`- oder `@main`-Referenzen und kein blankes Tag:
  Ein Tag lässt sich auf anderen Code umbiegen — genau das tat die
  Kompromittierung von `tj-actions/changed-files` im März 2025.
- Renovate gruppiert Dependency-Bumps in einen einzigen Pull Request,
  sodass Reviewer pro Zyklus einen Batch sehen.
- Pull Requests landen über den Standard-Automerge-Pfad, sobald die
  Checks grün sind.

## Vale und Prosa

Vale lintet Prosa mit den Microsoft- und RedHat-Paketen sowie dem
[`nolte/vale-style`](https://github.com/nolte/vale-style)-Release-Pin aus
`.vale.ini`. Das lokale Vokabular unter
`.github/styles/config/vocabularies/taskfiles/accept.txt` deckt Modulnamen
(`k8s`, `kind`, `pre-commit`, `taskfiles`) sowie gängige Fachbegriffe
(`venv`, `automerge`, `namespace`, `repo`, `config`, `kubeconfig`) ab.
Neue Modulnamen wandern dorthin, sobald ein neues Modul eingeführt wird.

Zwei Microsoft-Regeln sind in `.vale.ini` bewusst deaktiviert:
`Microsoft.Ranges` und `Microsoft.RangeFormat`. Die Range-Alerts feuern
auf YAML-Front-Matter-Daten wie `last_updated: 2026-05-20` und auf
Versions-Pins wie `mkdocs==1.6.1` oder `v1.1.18`, die im narrativen Sinn
keine Bereiche sind.

Außerdem deaktiviert eine separate Sektion im `.vale.ini` die
Microsoft-Stilregeln für `docs/de/**/*.md`, weil der Microsoft-Style nur
für englische Prosa entworfen ist; gegen deutsche Texte würde er Lärm
ohne Mehrwert produzieren.

## Probot-Settings

`.github/settings.yml` liefert die Repository-Settings (Branch-Schutz,
Labels, Automerge-Konfiguration) über die Probot-Settings-App aus. Das
Dokument ist die Source of Truth; manuelle Änderungen in der GitHub-UI
weichen vom Spec ab.
