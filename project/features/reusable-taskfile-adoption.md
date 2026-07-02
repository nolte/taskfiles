---
id: F-1
title: Reusable-Taskfile adoption
status: done
roadmap_item: R-1
sprint: 1
created: 2026-07-02
ended: 2026-07-02
verifies_sprint_value: acceptance-1
consistency_check:
  performed_at: 2026-07-02
  agent_version: manual-fallback (retroactive; feature-consistency-reviewer not run cross-repo)
  findings:
    - kind: clean
      target: project/features/
      resolution: proceed
      evidence: "project/features/ empty (first decomposition); no feature-to-feature overlap possible."
    - kind: prior-art
      target: src/taskfile-include-mkdocs.yaml
      resolution: proceed
      evidence: "The src/taskfile-include-*.yaml module collection already exists and is consumed portfolio-wide; F-1 documents the shipped adoption contract, it does not build new modules."
---

## Description

F-1 is the mission-verifying feature for `taskfiles`' shipped minimum viable
product. It captures the adoption contract of the reusable `Taskfile` module
collection (R-1). A downstream `nolte/*` project adopts a module by including it
remotely through `TASK_COLLECTION_BASE`. The contract holds when the include
resolves and the consumer's task target runs green. This already holds across
the portfolio, because sibling repositories wire these modules and run their
targets. The retroactive reconciliation therefore records this feature as `done`
(issue `nolte/claude-shared#262`).

## Acceptance criteria

- [x] **acceptance-1** A downstream `nolte/*` project includes a
  `taskfile-include-*.yaml` module remotely through `TASK_COLLECTION_BASE` and its
  task target runs green. _(This is the sprint value verifier.)_
- [x] **acceptance-2** Every task honours the `dir: '{{.USER_WORKING_DIR}}'`
  invariant, so commands run in the consumer's working directory.
- [x] **acceptance-3** Per-module task signatures stay stable across tags, so
  existing consumer pins keep resolving.

## Test hooks

- **acceptance-1**: a sibling repository's Taskfile that includes a module and
  runs its target shows this; passing.
- **acceptance-2**: manual review of each `src/taskfile-include-*.yaml` module for
  the `dir` invariant; passing.
- **acceptance-3**: manual review of the tag and signature convention; passing.

## Consistency notes

This is a retroactive documentation feature. The underlying capability
(`reusable-taskfile-collection`) predates the planning suite. This feature
introduces no new implementation. It exists so the mission's
`verifies_via: F-1:acceptance-1` and sprint 1's `value_statement` resolve to a
real acceptance criterion.

## References

- `project/portfolio.yml` capability `reusable-taskfile-collection`
- `AUDIENCES.md` audience "Taskfile-consumer project"
- `README.md` module table (the published `src/taskfile-include-*.yaml` catalogue)
