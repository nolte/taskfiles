# taskfiles

[![GitHub Project Stars](https://img.shields.io/github/stars/nolte/taskfiles.svg?label=Stars&style=social)](https://github.com/nolte/taskfiles) [![GitHub Issue Tracking](https://img.shields.io/github/issues-raw/nolte/taskfiles.svg)](https://github.com/nolte/taskfiles) [![GitHub LatestRelease](https://img.shields.io/github/release/nolte/taskfiles.svg)](https://github.com/nolte/taskfiles) [![.github/workflows/build-static-tests.yaml](https://github.com/nolte/taskfiles/actions/workflows/build-static-tests.yaml/badge.svg)](https://github.com/nolte/taskfiles/actions/workflows/build-static-tests.yaml) [![.github/workflows/release-cd-deliver-docs.yml](https://github.com/nolte/taskfiles/actions/workflows/release-cd-deliver-docs.yml/badge.svg)](https://github.com/nolte/taskfiles/actions/workflows/release-cd-deliver-docs.yml)

---

<!--intro-start-->
A curated collection of reusable [Taskfile](https://github.com/go-task/task) include modules. Each module ships as a single YAML file under `src/` and consumers wire it remotely through Taskfile's [remote-taskfiles](https://taskfile.dev/experiments/remote-taskfiles/) experiment. There is no build step and no runtime artefact—the YAML files themselves are the product.

| Module | Tasks | Key variables |
|--------|-------|---------------|
| [mkdocs](https://github.com/nolte/taskfiles/blob/main/src/taskfile-include-mkdocs.yaml) | `start`, `build` | `MKDOCS_PORT`, `MKDOCS_BUILD_EXTRA_ARGS`, `PYTHON_VENV_DIR_DOCS` |
| [kind](https://github.com/nolte/taskfiles/blob/main/src/taskfile-include-kind.yaml) | `start`, `destroy`, `recreate` | `KIND_CREATE_EXTRA_ARGS` |
| [pre-commit](https://github.com/nolte/taskfiles/blob/main/src/taskfile-include-pre-commit.yaml) | `install`, `start` | `PYTHON_VENVS_BASEDIR` |
| [k8s](https://github.com/nolte/taskfiles/blob/main/src/taskfile-include-k8s.yaml) | `bootstrap`, `install-argocd` | `ARGOCD_EXTRA_ARGS`, `KUBECTL_TIMEOUT` |
| [worktree](https://github.com/nolte/taskfiles/blob/main/src/taskfile-include-worktree.yaml) | `add`, `remove`, `list`, `root` | `WORKTREE_BASE_REF`, `WORKTREE_ALLOWED_PREFIXES`, `WORKTREE_ROOT_DEFAULT` |
| [asdf](https://github.com/nolte/taskfiles/blob/main/src/taskfile-include-asdf.yaml) | `prune` | `ASDF_RESOLVE_DIR`, `ASDF_KEEP_UNPINNED` |

Every task in every module sets `dir: '{{.USER_WORKING_DIR}}'`, so commands run in the consumer project's working directory, never in this repository.
<!--intro-end-->

## Usage

<!--usage-start-->
Wire the collection into a consumer Taskfile:

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  mkdocs: "{{.TASK_COLLECTION_BASE}}/taskfile-include-mkdocs.yaml"
  kind: "{{.TASK_COLLECTION_BASE}}/taskfile-include-kind.yaml"
  pre-commit: "{{.TASK_COLLECTION_BASE}}/taskfile-include-pre-commit.yaml"
  k8s: "{{.TASK_COLLECTION_BASE}}/taskfile-include-k8s.yaml"
  worktree: "{{.TASK_COLLECTION_BASE}}/taskfile-include-worktree.yaml"
  asdf: "{{.TASK_COLLECTION_BASE}}/taskfile-include-asdf.yaml"
```

Run any wired task from the consumer's working directory, for example:

```bash
task mkdocs:start
task kind:recreate
task pre-commit:install
task k8s:bootstrap
task worktree:add -- feat/parser-fix
task asdf:prune
```

Each `includes:` key is the task namespace, and the consumer chooses it. To run the worktree module under different vocabulary—say `workingcopy:remove` instead of `worktree:remove`—mount the same file under that key; every task answers under the new prefix with identical behaviour:

```yaml
includes:
  workingcopy: "{{.TASK_COLLECTION_BASE}}/taskfile-include-worktree.yaml"
```

### Prerequisites

* [go-task](https://taskfile.dev) CLI on the `PATH`.
* For `mkdocs:*`, a Python virtual environment at `~/.venvs/docs`, or any other path passed as `PYTHON_VENV_DIR_DOCS` (see [Per-module overrides](#per-module-overrides)).
* For `pre-commit:*`, a Python virtual environment at `~/.venvs/development`.
* For `kind:*` and `k8s:*`, the underlying `kind`, `kubectl`, and `helm` binaries on the `PATH`.
* For `worktree:*`, a `git` repository with an `origin` remote; optionally set `NOLTE_WORKTREE_ROOT` to choose where worktrees land (defaults to `~/repos/.worktrees`).
* For `asdf:*`, the [asdf](https://asdf-vm.com/) CLI on the `PATH` (written against asdf `v0.19`) with a populated `~/.tool-versions`.

The [nolte/workstation](https://github.com/nolte/workstation) playbook provisions both Python virtual environments. When a venv is missing, the affected task fails the first time it runs—provision it before invoking the task.

### Pin strategy

The preceding example pins to `main`, which is convenient for local experimentation but exposes consumers to drift. For repeatable behaviour, pin every include to a released tag instead:

```yaml
vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/<tag>/src
```

Replace `<tag>` with a released version from [the GitHub releases page](https://github.com/nolte/taskfiles/releases). Renovate-style consumers can group every `TASK_COLLECTION_BASE` bump into a single pull request because all four module paths share the same base address.

### Per-module overrides

Each module exposes a small set of `vars:` defaults. Override them with the long-form `includes:` syntax. A project that keeps its documentation tooling in a project-local virtual environment redirects the `mkdocs` module away from the machine-global `~/.venvs/docs` this way:

```yaml
includes:
  mkdocs:
    taskfile: "{{.TASK_COLLECTION_BASE}}/taskfile-include-mkdocs.yaml"
    vars:
      MKDOCS_PORT: 8080
      PYTHON_VENV_DIR_DOCS: .venv
```

An override takes effect only where the module declares the variable as `'{{.NAME | default "…"}}'`. A module that declares a plain literal instead wins over the value you pass and drops the override without a word. **Today `mkdocs` alone uses that form.** The `kind`, `k8s`, `pre-commit`, `worktree`, and `asdf` modules still declare plain literals, so an override you pass them changes nothing. Treat their variables as read-only defaults until a later change converts them.

An exported environment variable of the same name also reaches these defaults. A `MKDOCS_PORT` set in a CI environment therefore moves the serve port, even when no consumer file mentions it.

The rendered [module pages](https://nolte.github.io/taskfiles/) document every task, every variable, and a copy-paste example per module.
<!--usage-end-->

## Contributing

The full module conventions live in [`CLAUDE.md`](./CLAUDE.md) (intended both for humans and for AI-assisted edits) and, in narrative form, on the [Contributing page](https://nolte.github.io/taskfiles/guides/contributing/) of the rendered docs. The short version:

* Filenames are `taskfile-include-<area>.yaml`. The `<area>` segment is the key consumers wire under `includes:`.
* Every task sets `dir: '{{.USER_WORKING_DIR}}'` so behaviour stays anchored to the consumer's working directory.
* Tunable inputs go through `vars:` with a default that works out of the box.
* Python-backed tasks activate venvs at `~/.venvs/docs` or `~/.venvs/development` rather than installing dependencies themselves.

Pull requests run through the reusable `nolte/gh-plumbing` workflows. Merges are squash-only and automerge once checks pass.

## Governance and specs

This repository follows the portfolio conventions shipped by [`nolte/claude-shared`](https://github.com/nolte/claude-shared) (project structure, branching model, release automation, audience identification) and consumes the reusable workflows from [`nolte/gh-plumbing`](https://github.com/nolte/gh-plumbing) at a pinned commit digest. Dependency bumps land through Renovate, which extends `nolte/gh-plumbing//renovate-configs/common`.

For the recorded audience analysis that drives the documentation structure, see [`AUDIENCES.md`](./AUDIENCES.md).

## Links

<!--links-start-->
* [nolte/workstation](https://github.com/nolte/workstation): workstation configuration that provisions the Python virtual environments listed under Prerequisites.
* [Taskfile.dev](https://taskfile.dev): upstream documentation for go-task, including the remote-taskfiles experiment.
<!--links-end-->
