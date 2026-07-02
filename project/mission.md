---
mission_statement: "Taskfiles gives downstream nolte/* projects one centralised, remotely included collection of reusable Taskfile modules, so they get consistent task targets across local and CI runs without copying Taskfile logic into each repository."
relevant_outcomes: [O-1, O-2, O-3, O-4]
audiences:
  - Taskfile-consumer project
  - Consumer-side developer running tasks locally
  - Consumer-side CI/CD pipeline
  - Module maintainer
verifies_via: F-1:acceptance-1
time_bound:
  kind: mvp_completion
mvp_status: achieved
created: 2026-07-02
revised_at: null
---

## Statement

`taskfiles` gives downstream `nolte/*` projects one centralised,
remotely included collection of reusable `Taskfile` modules. They get consistent
task targets across local and CI runs without copying `Taskfile` logic into each
repository.

- **Specific**: the statement names *what* (a remotely included collection of
  reusable `Taskfile` modules) and *for whom* (the consumer audiences plus the
  module maintainer, resolved in `audiences`).
- **Measurable**: `verifies_via: F-1:acceptance-1`. F-1's acceptance criterion 1
  measures the mission. A consumer project includes a module remotely and its
  task target runs green.
- **Achievable**: the minimum viable product is the shipped
  `reusable-taskfile-collection` capability. Roadmap item R-1 carries `mvp:
  true`, `detail: fine`, and `target_sprint: 1`.
- **Relevant**: `relevant_outcomes: [O-1, O-2, O-3, O-4]`. Each entry resolves to
  an outcome in `project/goals.md`.
- **Time-bound**: `time_bound: { kind: mvp_completion }`. The bound is the moment
  the shipped minimum viable product reaches achieved status, not a calendar
  date.

## Audiences

- **Taskfile-consumer project**: the minimum viable product delivers a collection
  of `src/taskfile-include-*.yaml` modules that a project wires in remotely
  through `TASK_COLLECTION_BASE`. The project gets stable per-module task
  signatures without copying `Taskfile` logic.
- **Consumer-side developer running tasks locally**: the minimum viable product
  delivers predictable, idempotent task commands. A developer runs
  `task <module>:<task>` in their own working directory, honoured by the
  `dir: '{{.USER_WORKING_DIR}}'` invariant.
- **Consumer-side CI/CD pipeline**: the minimum viable product delivers the same
  task targets that developers run locally. A pipeline invokes them, so local and
  CI behaviour stay identical.
- **Module maintainer**: the minimum viable product delivers a single place to
  evolve the module collection. Stable task signatures and tag stability keep
  consumer pins stable when the collection changes.

## Verification

Feature **F-1: Reusable-Taskfile adoption** verifies the mission through
acceptance criterion 1: *"A downstream `nolte/*` project includes a
`taskfile-include-*.yaml` module remotely through `TASK_COLLECTION_BASE` and its
task target runs green."* This is the `verifies_sprint_value` criterion for
sprint 0001. It already holds across the portfolio, because sibling repositories
wire these modules and run their targets. The mission therefore records the
shipped minimum viable product as `achieved`.

## Source

- **Audience artefact**: `AUDIENCES.md` at the `taskfiles` repository root,
  consulted at its current develop tip. The four `audiences` entries are the
  three primary direct-consumer and operator audiences plus the module
  maintainer.
- **Outcomes referenced**: O-1, O-2, O-3, O-4 from `project/goals.md`.
- **Authored by**: the `mission-define` cascade (issue `nolte/claude-shared#262`
  mission-authoring backfill), 2026-07-02. The cascade models the minimum viable
  product retroactively. `taskfiles`' capability already carried `status: active`
  when the repository adopted the planning suite, so the roadmap records R-1 as
  `status: done` and opens `mvp_status` at `achieved` rather than `defining`.
