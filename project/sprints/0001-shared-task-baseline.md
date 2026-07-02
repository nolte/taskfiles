---
number: 1
status: closed
started: 2026-07-02
ended: 2026-07-02
value_statement: Downstream nolte/* projects include the reusable Taskfile modules remotely and get consistent task targets across local and CI runs without copying Taskfile logic.
artifact_ref: develop (shipped capability, pre-planning-suite)
roadmap_items: [R-1]
features: [F-1]
---

## Goal

Downstream `nolte/*` projects obtain consistent task targets from one
centralised, remotely included collection of reusable `Taskfile` modules. The
consumer no longer copies `Taskfile` logic into each repository. F-1
`acceptance-1` verifies success: a consumer project includes a module remotely
through `TASK_COLLECTION_BASE` and its task target runs green.

## Features

- [F-1](../features/reusable-taskfile-adoption.md): Reusable-Taskfile adoption, status: done

## Out of scope

- Pinning concrete consumer identities and pin strategies. `AUDIENCES.md` tracks
  these as open questions, outside the shipped scope.
- The wrapped tools themselves (`kind`, `mkdocs`, `kubectl`, `helm`,
  `pre-commit`, ArgoCD), which sit outside the bounded context.

## Review notes

Retroactive reconciliation (2026-07-02): `taskfiles`' `reusable-taskfile-collection`
capability already carried `status: active` and served the portfolio before this
repository adopted the planning suite (issue `nolte/claude-shared#262`
mission-authoring backfill). This sprint therefore records roadmap item R-1 and
feature F-1 as `done`, and itself as `closed`. That documents the delivered
minimum viable product rather than new planned work. The value verifier F-1
`acceptance-1` already holds: sibling repositories wire these modules and run
their task targets.
