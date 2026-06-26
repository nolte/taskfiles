---
title: worktree
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-06-26
---

# worktree

Create and manage parallel working copies as [git worktrees](https://git-scm.com/docs/git-worktree),
so every project in the portfolio gets the same predictable, reusable way to
spin up an isolated checkout for a feature branch — without ever switching the
primary checkout off `develop`.

See [References → Common contract](../index.md#common-contract) for the
`USER_WORKING_DIR`, pin-strategy, and override-syntax conventions that
apply across every module.

## Prerequisites

- `git` on the `PATH`, run from inside a repository that has an `origin`
  remote — `<repo>` is derived from `origin`, never guessed from the cwd.
- Optionally, the `NOLTE_WORKTREE_ROOT` environment variable to choose where
  worktrees land. It wins over the `WORKTREE_ROOT_DEFAULT` variable at
  runtime; both default to `~/repos/.worktrees`.

## Layout

Every worktree lands in the same predictable place:

```text
${NOLTE_WORKTREE_ROOT:-~/repos/.worktrees}/<repo>/<slug>/
```

`<repo>` comes from the `origin` remote and `<slug>` is a single
kebab-case path segment (the branch name with its prefix stripped, unless
you pass one explicitly).

## Tasks

| Task | Description |
|------|-------------|
| `worktree:add -- <branch> [slug]` | Fetch the base ref, create `<branch>` off `{{.WORKTREE_BASE_REF}}` in a new worktree, and seed a `.resume/<slug>/plan.md` plan stub. |
| `worktree:remove -- <slug> [force]` | Remove the worktree for `<slug>`. The branch is kept. Pass `force` to discard a worktree that still holds uncommitted or untracked work (including the seeded plan stub). |
| `worktree:list` | Run `git worktree list` for the current repository. |
| `worktree:root` | Print the resolved worktree root for this machine. |

`worktree:add` validates the branch prefix against
`WORKTREE_ALLOWED_PREFIXES` (the branching-model rule): the path slug may
drop the prefix, but the branch itself must carry one. The branch is always
cut from a freshly fetched `{{.WORKTREE_BASE_REF}}`, so it starts from the
remote tip regardless of the local checkout's state.

The seeded `.resume/<slug>/plan.md` is a plan-before-work gate: fill it in
before starting substantive work, so a fresh resumable session started in the
worktree can pick the work up from a known starting point. It lives under
`.resume/`, which the consumer repository typically keeps out of version
control.

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `WORKTREE_BASE_REF` | `origin/develop` | Ref new branches are cut from. |
| `WORKTREE_FETCH_REMOTE` | `origin` | Remote fetched before the worktree is created. |
| `WORKTREE_FETCH_BRANCH` | `develop` | Branch fetched before the worktree is created. |
| `WORKTREE_ALLOWED_PREFIXES` | `feat fix chore docs exp` | Space-separated branch prefixes accepted by `add`. |
| `WORKTREE_ROOT_DEFAULT` | `$HOME/repos/.worktrees` | Fallback root when `NOLTE_WORKTREE_ROOT` is unset. |

## Example

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  worktree:
    taskfile: "{{.TASK_COLLECTION_BASE}}/taskfile-include-worktree.yaml"
    vars:
      WORKTREE_BASE_REF: "origin/main"
      WORKTREE_ALLOWED_PREFIXES: "feat fix chore"
```

Then, from the consumer's working directory:

```bash
# Create a worktree for a feature branch off the base ref.
task worktree:add -- feat/parser-fix

# Pass an explicit short slug for the directory name.
task worktree:add -- chore/ci-tidy ci

# Inspect and clean up.
task worktree:list
task worktree:remove -- ci
```

## Troubleshooting

- **`worktree:add` rejects the branch.** The branch must carry one of the
  prefixes in `WORKTREE_ALLOWED_PREFIXES` (default `feat fix chore docs
  exp`). The slug may drop the prefix, but the branch must not.
- **`worktree:remove` fails without `force`.** `git worktree remove`
  refuses to drop a worktree with uncommitted or untracked files — and the
  seeded `.resume/<slug>/plan.md` counts as untracked unless the consumer
  gitignores `.resume/`. Re-run with `task worktree:remove -- <slug> force`
  to discard it, or commit/move the work first.
- **The worktree landed in the wrong place.** The root is
  `NOLTE_WORKTREE_ROOT` if set, otherwise `WORKTREE_ROOT_DEFAULT`. Run
  `task worktree:root` to see the resolved value for the current machine.
- **`origin` not found.** The module derives `<repo>` from the `origin`
  remote. Add one (`git remote add origin …`) or run inside a clone that
  already has it.
