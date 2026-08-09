---
title: References
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-05-20
source_language: en
---

# Referenzen

Informations-orientierte Dokumentation. Hier nachschlagen, wenn der Vertrag
eines Moduls oder die Portfolio-Konventionen des Repositories gebraucht
werden.

## Modul-Referenzen

Eine Seite pro Include-Datei unter `src/`. Jede Seite folgt demselben
Schema (kurze Einleitung, **Voraussetzungen**, **Tasks**, **Variablen**,
**Beispiel**, **Fehlerbehebung**), sodass Konsumenten alle vier scannen
können, ohne sich jedes Mal in ein neues Layout einzuarbeiten.

- [mkdocs](modules/mkdocs.md): `mkdocs:start`, `mkdocs:build`
- [kind](modules/kind.md): `kind:start`, `kind:destroy`, `kind:recreate`
- [pre-commit](modules/pre-commit.md): `pre-commit:install`,
  `pre-commit:start`
- [k8s](modules/k8s.md): `k8s:bootstrap`, `k8s:install-argocd`
- [worktree](modules/worktree.md): `worktree:add`, `worktree:remove`,
  `worktree:list`, `worktree:root`
- [asdf](modules/asdf.md): `asdf:prune`

## Gemeinsamer Vertrag

Diese Regeln gelten für jedes Modul der Sammlung. Die Modul-Seiten
wiederholen sie nicht, sondern verweisen auf diese Sektion.

### USER_WORKING_DIR-Invariante

Jeder Task setzt `dir: '{{.USER_WORKING_DIR}}'`. Befehle laufen damit in
dem Verzeichnis, aus dem der Konsument `task` aufgerufen hat, niemals am
Ort der Include-Datei selbst. Konkret heißt das:

- `task mkdocs:start` serviert das `mkdocs.yml` neben der `Taskfile.yml`
  des Konsumenten, nicht irgendeines aus diesem Repository.
- `task pre-commit:start` läuft gegen die `.pre-commit-config.yaml` des
  Konsumenten.
- `task kind:start` schreibt die Cluster-kubeconfig dorthin, wohin `kind`
  sie für den aktuellen User standardmäßig schreibt.

### Pin-Strategie

`TASK_COLLECTION_BASE` ist der einzige Pin-Punkt für jeden Include. Die
Adresse hat die Form

```text
https://raw.githubusercontent.com/nolte/taskfiles/<ref>/src
```

wobei `<ref>` einer der folgenden Werte ist:

- `main`: praktisch beim Evaluieren eines Moduls; das Verhalten kann
  driften, sobald ein Maintainer auf `main` pusht.
- Ein veröffentlichtes Tag, zum Beispiel `v1.2.0`: für den
  produktiven Alltag empfohlen. Drift ist ausgeschlossen, bis der
  Konsument das Tag selbst bumpt.
- Ein Branch-Name: nützlich, um eine laufende Änderung gegen einen
  echten Konsumenten zu testen; für geteilte Umgebungen ungeeignet.

Weil jeder Modulpfad dieselbe `TASK_COLLECTION_BASE` teilt, aktualisiert
Renovate (oder ein anderes Dependency-Bump-Tool) alle vier Includes in
einem einzigen Pull Request, sobald der Konsument auf ein Tag pinnt.

### Modulweise Overrides

Jedes Modul stellt einen kleinen Satz an `vars:`-Defaults bereit. Die
Kurzform der `includes:`-Syntax akzeptiert nur den Include-Pfad:

```yaml
includes:
  mkdocs: "{{.TASK_COLLECTION_BASE}}/taskfile-include-mkdocs.yaml"
```

Overrides verlangen die Langform mit einem `vars:`-Block:

```yaml
includes:
  mkdocs:
    taskfile: "{{.TASK_COLLECTION_BASE}}/taskfile-include-mkdocs.yaml"
    vars:
      MKDOCS_PORT: 8080
```

Jede Modul-Seite listet ihre Variablen in der **Variablen**-Tabelle mit
Default-Wert und Zweck.

### Extern bereitgestellte Virtual Environments

Python-gestützte Module (`mkdocs`, `pre-commit`) aktivieren vorbereitete
Virtual Environments; sie installieren keine Dependencies on-the-fly. Die
Defaults sind `~/.venvs/docs` und `~/.venvs/development`; beide kommen
aus dem
[`nolte/workstation`](https://github.com/nolte/workstation)-Playbook.
Wenn das Playbook nicht in Verwendung ist, verschiebe den Basis-Pfad über
`PYTHON_VENVS_BASEDIR`.

## Repository-Governance

- [Governance und Specs](governance.md): Portfolio-Konventionen,
  wiederverwendbare Workflows, Dependency-Governance, Vale-Stack,
  Probot-Settings.

## Quellen

- `src/taskfile-include-<area>.yaml` (kanonische Pro-Modul-Verträge)
- [`CLAUDE.md`](https://github.com/nolte/taskfiles/blob/main/CLAUDE.md)
- [`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md)
