---
title: Governance and specs
audience:
  - portfolio-conventions
  - renovate-governance
content_mode: explanation
track: developer-docs
last_updated: 2026-05-20
---

# Governance and specs

This page is the entry point for anyone who needs to verify that the
repository still satisfies the portfolio conventions. It doesn't duplicate
the upstream specs. Instead, it lists the entry points and the current pin
state.

## Portfolio conventions

The repository follows the project-wide specs shipped by
[`nolte/claude-shared`](https://github.com/nolte/claude-shared):

- `project-structure`: directory layout, mandatory files, README anatomy.
- `branching-model`: branch naming and protection.
- `pull-request-workflow`: squash-only merges, automerge after green
  checks.
- `release-automation`: release-drafter and release-publish flow.
- `audience-identification`: the spec that produced
  [`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md).
- `docs-audience-tracks`: splits documentation into `user-docs` and
  `developer-docs`. This repository serves only the `developer-docs` track.

The audience artefact in `AUDIENCES.md` is the canonical record of who
consumes the repository. Every documentation refactor traces back to it.

## Reusable workflows

Every workflow under `.github/workflows/` delegates to a reusable workflow
in [`nolte/gh-plumbing`](https://github.com/nolte/gh-plumbing). Each reference
is pinned to a full-length commit digest with the corresponding version as a
trailing comment; the current pin is
**`d51e51ec3ec17ceea09fe9eb40ac00857b6fa1be` (`v2.0.0`)**. Bump every workflow
reference together when updating, because mixing versions between workflows is
a known source of drift.

| Workflow | Reusable target |
|----------|-----------------|
| `automerge.yaml` | `reusable-automerge.yaml` |
| `build-static-tests.yaml` | `reusable-pre-commit.yaml`, `reusable-chain-bench.yaml`, `reusable-trivy.yaml` |
| `release-cd-deliver-docs.yml` | `reusable-mkdocs.yaml` |
| `release-cd-refresh-master.yml` | `reusable-release-cd-refresh-master.yml` |
| `release-drafter.yml` | `reusable-release-drafter.yml` |
| `release-publish.yml` | `reusable-release-publish.yml` |
| `spelling.yaml` | `reusable-spelling-vale.yaml` |

## Dependency governance

Renovate runs on this repository through
[`renovate.json5`](https://github.com/nolte/taskfiles/blob/main/renovate.json5),
which extends `nolte/gh-plumbing//renovate-configs/common` at a pinned tag.
Concrete expectations:

- All workflow `uses:` references pin to a full-length commit digest, with the
  released version named in a trailing comment. No floating `@develop` or
  `@main` references, and no bare tag: a tag can be moved onto different code,
  which is what the March 2025 `tj-actions/changed-files` compromise did.
- Renovate groups dependency bumps into a single pull request so reviewers
  see one batch per cycle.
- Pull requests land through the standard automerge path once checks pass.

## Vale and prose

Vale lints prose with the Microsoft and RedHat packages plus the
[`nolte/vale-style`](https://github.com/nolte/vale-style) release pin from
`.vale.ini`. The local vocabulary at
`.github/styles/config/vocabularies/taskfiles/accept.txt` covers module
names (`k8s`, `kind`, `pre-commit`, `taskfiles`) along with common technical
terms (`venv`, `automerge`, `namespace`, `repo`, `config`). Add new module
names there when introducing a module.

Two Microsoft rules stay off in `.vale.ini` on purpose: `Microsoft.Ranges`
and `Microsoft.RangeFormat`. The number-range alerts fire on YAML
front-matter dates such as `last_updated: 2026-05-20` and on version
pins such as `mkdocs==1.6.1` or `v1.1.18`, which aren't ranges in the
narrative sense.

## Probot settings

`.github/settings.yml` ships the repository settings (branch protection,
labels, automerge configuration) through the Probot Settings app. Treat
it as the source of truth. Manual changes in the GitHub UI drift away from
the spec.
