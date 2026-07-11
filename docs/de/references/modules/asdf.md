---
title: asdf
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-07-11
source_language: en
---

# asdf

Veraltete [asdf](https://asdf-vm.com/)-Tool-Versionen erkennen und die
entfernen, die nicht mehr verwendet werden. Für jedes installierte
asdf-Plugin wird die Version behalten, die asdf aktuell auflöst; jede andere
installierte Version wird zum Entfernungs-Kandidaten. So lässt sich eine
Maschine, auf der sich viele alte Runtimes angesammelt haben, wieder auf das
zurechtstutzen, was sie tatsächlich ausführt.

Siehe [Referenzen → Gemeinsamer Vertrag](../index.md#gemeinsamer-vertrag) für
die Konventionen zu `USER_WORKING_DIR`, Pin-Strategie und Override-Syntax,
die modulübergreifend gelten.

## Voraussetzungen

- `asdf` im `PATH`. Das Modul ist gegen asdf `v0.19` (die Go-Neufassung)
  geschrieben, wo `asdf list <plugin>` die aktive Version mit `*` markiert.
- Eine gefüllte `~/.tool-versions` (oder das über `ASDF_RESOLVE_DIR`
  benannte Verzeichnis), damit der Task erkennt, welche Version aktiv ist.
  Plugins ohne aktive Version werden standardmäßig übersprungen — siehe
  `ASDF_KEEP_UNPINNED`.

## Tasks

| Task | Beschreibung |
|------|--------------|
| `asdf:prune -- [apply] [plugin...]` | Pro Plugin veraltete Versionen melden. Läuft standardmäßig als Dry-Run; mit `apply` wird für jeden Kandidaten `asdf uninstall` ausgeführt. Optionale Plugin-Namen schränken den Scan ein. |

Pro Plugin wird die Version behalten, die asdf in `ASDF_RESOLVE_DIR` auflöst
(das `*` aus `asdf list`, also der globale `~/.tool-versions`-Pin); jede
andere installierte Version ist ein Kandidat. Der Task **entfernt nie etwas,
solange `apply` nicht übergeben wird** — ohne `apply` gibt er nur aus, was er
entfernen würde.

Plugins ohne aktive Version werden übersprungen, sodass ein ungepinntes Tool
nie versehentlich komplett gelöscht wird. `ASDF_KEEP_UNPINNED` auf `false`
setzen, um stattdessen jede installierte Version eines ungepinnten Plugins
als Kandidat zu behandeln.

## Variablen

| Variable | Default | Zweck |
|----------|---------|-------|
| `ASDF_RESOLVE_DIR` | `$HOME` | Verzeichnis, gegen das die aktive Version aufgelöst wird. Der Default sieht die globale `~/.tool-versions` und ignoriert eine projektlokale `.tool-versions`. Auf `{{.USER_WORKING_DIR}}` setzen, um einen projektlokalen Pin zu berücksichtigen. |
| `ASDF_KEEP_UNPINNED` | `true` | Plugins ohne aktive Version unangetastet lassen. Auf `false` setzen, um auch ungepinnte Plugins zu prunen (gefährlich — dann ist jede installierte Version ein Kandidat). |

## Beispiel

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  asdf: "{{.TASK_COLLECTION_BASE}}/taskfile-include-asdf.yaml"
```

Anschließend von überall:

```bash
# Veraltete Versionen über alle Plugins melden (Dry-Run — entfernt nichts).
task asdf:prune

# Jede veraltete Version tatsächlich deinstallieren.
task asdf:prune -- apply

# Den Scan auf ein oder mehrere Plugins einschränken.
task asdf:prune -- golang
task asdf:prune -- apply golang kubectl
```

## Fehlerbehebung

- **`asdf is not installed`.** Die `asdf`-CLI liegt nicht im `PATH`. Sie
  installieren (oder über [nolte/workstation](https://github.com/nolte/workstation)
  provisionieren) und erneut versuchen.
- **Ein Plugin, das gestutzt werden sollte, wird übersprungen.** Es hat keine
  aktive Version in der aufgelösten `.tool-versions`. Pinne sie, oder setze
  `ASDF_KEEP_UNPINNED: "false"`, um es dennoch zu prunen.
- **Ein Kandidat ließ sich nicht entfernen.** `asdf uninstall` ist für diese
  Version fehlgeschlagen (etwa weil ein laufender Prozess sie noch hält). Der
  Task meldet den Fehler, macht weiter und beendet sich am Ende mit einem
  Fehlercode ungleich null. Erneut ausführen oder von Hand deinstallieren.
- **Die falschen Versionen wurden behalten.** Die aktive Version wird gegen
  `ASDF_RESOLVE_DIR` aufgelöst (Default `$HOME`); eine projektlokale
  `.tool-versions` wird ignoriert, sofern `ASDF_RESOLVE_DIR` nicht auf dieses
  Verzeichnis zeigt.
