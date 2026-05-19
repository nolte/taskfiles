# Audiences — nolte/taskfiles

<!--
Produced via the `audience-identify` skill, following
spec/project/audience-identification/.
Do not add audiences without first declaring the bounded context below.
-->

## Bounded context

`nolte/taskfiles` is a curated collection of reusable Taskfile include modules
(one YAML file per topic area under `src/`), consumed by downstream projects
via Taskfile's `remote-taskfiles` experiment through a `TASK_COLLECTION_BASE`
URL pointer. The product is the YAML files themselves — no build artifact, no
runtime code, no distributable library. The contract covers the public task
signatures per module, the `vars:` defaults, and the `dir: '{{.USER_WORKING_DIR}}'`
invariant.

**In scope**

- YAML modules under `src/taskfile-include-<area>.yaml`
- Per-module documentation under `docs/modules/`, `README.md`, the mkdocs site
- CI / release pipeline for the collection (release-drafter, release-publish,
  refresh-master, gh-pages deliver)
- Module conventions as recorded in `CLAUDE.md`

**Out of scope**

- The wrapped tools themselves (`kind`, `mkdocs`, `kubectl`, `helm`,
  `pre-commit`, ArgoCD)
- Pre-provisioned Python virtual environments (`~/.venvs/docs`,
  `~/.venvs/development`), which are managed by `nolte/workstation`
- Consumer projects' own Taskfiles
- Each consumer's choice of `TASK_COLLECTION_BASE` URL and pin strategy

## Audiences

Each entry: label, relationship category, interaction surface, expectation,
documentation `track` (`user-docs` or `developer-docs` per
spec/project/docs-audience-tracks/), open questions, `confirmed` or `assumed`,
criticality (primary / secondary / peripheral). A whole category is marked
`none — <reason>` when it does not apply.

This repository serves only `developer-docs` audiences; no end-user
documentation track applies, because the product is consumed exclusively by
other engineers wiring Taskfile includes into their own projects.

### Direct consumers

- **Taskfile-consumer project** — _category_: direct-consumer ·
  _surface_: `remote-taskfiles` include via `TASK_COLLECTION_BASE` URL plus the
  documented `vars:` override points ·
  _expects_: stable per-module task signatures (`mkdocs:start`,
  `kind:start|destroy|recreate`, `pre-commit:install|start`,
  `k8s:bootstrap|install-argocd`), predictable `vars:` defaults, honoured
  `dir: '{{.USER_WORKING_DIR}}'` invariant, semver-style tag stability on
  `main` ·
  _track_: `developer-docs` ·
  _status_: `assumed` ·
  _criticality_: primary
  - Open questions: concrete identity of the consumers; how many repositories
    pin against this collection; which pin strategy (`@main`, `@<tag>`, branch)
    they use.

### Operators

- **Consumer-side developer running tasks locally** — _category_: operator ·
  _surface_: `task <module>:<task>` executed inside the consumer's working
  directory on a developer workstation ·
  _expects_: idempotent re-runs (e.g. `kubectl create namespace argocd || true`),
  clear error messages when prerequisites are missing (tool not installed,
  venv not provisioned), no destructive default actions ·
  _track_: `developer-docs` ·
  _status_: `assumed` ·
  _criticality_: primary
  - Open questions: how broadly the "operator" framing extends here; whether
    consumers ever wrap these tasks in a non-trivial automation harness.

- **Consumer-side CI/CD pipeline** — _category_: operator ·
  _surface_: GitHub Actions or another CI runner invokes `task lint`,
  `task docs`, or a specific module task as a pipeline step ·
  _expects_: deterministic behaviour, reliable exit codes, no implicit
  interactivity, no hard path assumptions beyond `USER_WORKING_DIR` ·
  _track_: `developer-docs` ·
  _status_: `assumed` ·
  _criticality_: secondary
  - Open questions: how often these modules are actually invoked from a
    consumer CI today, and which failure modes show up there.

### Contributors / maintainers

- **Module maintainer** — _category_: contributor ·
  _surface_: edits to `src/taskfile-include-<area>.yaml` via pull requests,
  bound by the module conventions recorded in `CLAUDE.md` ·
  _expects_: documented conventions (`USER_WORKING_DIR`, `vars:` defaults, no
  embedded venv provisioning), traceable reviews, green Vale and pre-commit,
  squash-only automerge ·
  _track_: `developer-docs` ·
  _status_: `assumed` ·
  _criticality_: primary
  - Open questions: who, besides the repo owner, contributes today; whether
    a separate `CONTRIBUTING.md` should split off from `CLAUDE.md`.

- **Documentation author** — _category_: contributor ·
  _surface_: `README.md`, `docs/modules/*.md`, `mkdocs.yml`, the local Vale
  vocabulary under `.github/styles/config/vocabularies/taskfiles/` ·
  _expects_: stable documentation architecture (per-module pages with
  Tasks / Variables / Example schema), Vale clean including module names in
  vocabulary ·
  _track_: `developer-docs` ·
  _status_: `assumed` ·
  _criticality_: secondary
  - Open questions: whether documentation authors and module maintainers are
    the same individuals in practice.

### Governing parties

- **nolte portfolio architecture conventions** — _category_: governing ·
  _surface_: the portfolio-wide specs under `spec/project/` shipped by
  `nolte/claude-shared` (`project-structure`, `branching-model`,
  `pull-request-workflow`, `release-automation`, `audience-identification`,
  …), plus the reusable workflows under `nolte/gh-plumbing` ·
  _expects_: this repository remains spec-conformant (squash-only,
  tag-pinned reusable workflows, Probot Settings, Renovate, mkdocs structure,
  Vale through shared vocabularies) ·
  _track_: `developer-docs` ·
  _status_: `confirmed` (the specs ship in `nolte/claude-shared` and were
  applied against this repository multiple times in the audit and apply
  passes that produced this artifact) ·
  _criticality_: primary
  - Open questions: none.

- **Renovate / dependency-pinning governance** — _category_: governing ·
  _surface_: `renovate.json5` extending `nolte/gh-plumbing//renovate-configs/common#<tag>`;
  automated dependency-bump PRs ·
  _expects_: pins stay in a Renovate-friendly tag-pinned form, no floating
  `@develop` references after the v1.1.18 catch-up in PR #22 ·
  _track_: `developer-docs` ·
  _status_: `confirmed` (PR #19 in the recent history was a Renovate-driven
  bump landing through the standard PR / automerge path) ·
  _criticality_: secondary
  - Open questions: none.

### Indirect audiences

`none — the modules are purely developer tooling. Every person affected by
their operation is already covered under "Operators" or "Direct consumers";
there are no end users behind a service that this repository operates.`

## Open questions (cross-cutting)

- Which downstream `nolte/*` repositories actually consume this collection
  today, and at which pin? Without this list the Direct-consumer entry
  cannot be promoted from `assumed` to `confirmed`.
- Should the contribution conventions currently embedded in `CLAUDE.md`
  (USER_WORKING_DIR invariant, externally-provisioned venvs, `vars:`
  defaults) be split into a stand-alone `CONTRIBUTING.md` so the
  contributor audience has a single canonical entry point?
- Should an indirect-audience entry be revived later for a threat-modeling
  pass? The `none` decision here is documentation-driven, not security-
  driven.

## Revisit triggers

- A new module `src/taskfile-include-<area>.yaml` is added.
- An existing task is renamed, removed, or gets a breaking-change `vars:`
  rename.
- The `TASK_COLLECTION_BASE` URL scheme changes (for example a move away
  from the `remote-taskfiles` experiment).
- A concrete consumer reports a regression — that consumer becomes a
  candidate for promoting the Direct-consumer entry to `confirmed`.
- The portfolio adds a new spec under `spec/project/` that this repository
  is expected to satisfy (audience changes from "governing parties").
- A future threat-model or SLA spec consumes this audience list and
  surfaces a previously invisible indirect audience.
