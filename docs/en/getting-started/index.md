---
title: Getting Started
audience:
  - taskfile-consumer-project
  - consumer-developer
content_mode: tutorial
track: developer-docs
last_updated: 2026-05-20
---

# Getting Started

This tutorial walks a consumer project through the first successful use of one
of the modules. By the end, `task pre-commit:start` runs against the consumer
repository, sourced from a single remote include.

## Prerequisites

- A recent [go-task](https://taskfile.dev/) on the `PATH`.
- The consumer repository checked out locally with a `Taskfile.yml`. A new
  `Taskfile.yml` with the bare minimum (`version: '3'`) is enough.
- A pre-provisioned Python virtual environment at `~/.venvs/development`
  containing the `pre-commit` package. The
  [`nolte/workstation`](https://github.com/nolte/workstation) playbook
  provisions it; any other Ansible role or manual `python -m venv` works
  too, as long as the path matches.

The tutorial uses `pre-commit` because it depends only on a Python virtual
environment, not on `docker`, `kind`, or a Kubernetes cluster.

## 1. Wire the collection base into the consumer Taskfile

Add a `TASK_COLLECTION_BASE` variable and a single include to the consumer's
`Taskfile.yml`:

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  pre-commit: "{{.TASK_COLLECTION_BASE}}/taskfile-include-pre-commit.yaml"
```

The example pins to `main`, which is convenient while you are evaluating the
module. For day-to-day use, switch to a released tag (see
[Pin strategy](../references/index.md#pin-strategy) under References).

## 2. Confirm the include resolved

From the consumer's working directory, list the available tasks:

```bash
task --list
```

Two tasks from the include show up: `pre-commit:install` and
`pre-commit:start`. If they don't, the include address is wrong or the
network can't reach `raw.githubusercontent.com`.

## 3. Run the first task

```bash
task pre-commit:start
```

The task activates `~/.venvs/development` and runs
`pre-commit run --all-files` inside the consumer's working directory. On
success, `pre-commit` prints one line per hook with either `Passed`,
`Skipped`, or `Failed`. A failing hook points at the consumer's prose or
code; it isn't a problem with the include.

## 4. Pin to a released tag

Once the include works, switch the base address away from `main` to make
the behaviour deterministic across machines:

```yaml
vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/<tag>/src
```

Replace `<tag>` with a released version from
[the GitHub releases page](https://github.com/nolte/taskfiles/releases). All
four modules share the same base address, so a single Renovate-driven
update covers every include in one pull request.

## What to read next

- [References → Modules](../references/index.md) lists every task, every
  variable, and a copy-paste example for the four modules that ship today.
- [References → Common contract](../references/index.md#common-contract)
  explains the conventions that apply across all modules (working directory,
  override syntax, pin strategy).
- [Guides → Contributing](../guides/contributing.md) covers adding a new
  module or changing an existing task.

## Sources

- [`README.md`](https://github.com/nolte/taskfiles/blob/main/README.md)
  (usage section)
- `src/taskfile-include-pre-commit.yaml`
