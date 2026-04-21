# taskfiles

[![GitHub Project Stars](https://img.shields.io/github/stars/nolte/taskfiles.svg?label=Stars&style=social)](https://github.com/nolte/taskfiles) [![GitHub Issue Tracking](https://img.shields.io/github/issues-raw/nolte/taskfiles.svg)](https://github.com/nolte/taskfiles) [![GitHub LatestRelease](https://img.shields.io/github/release/nolte/taskfiles.svg)](https://github.com/nolte/taskfiles) [![.github/workflows/build-static-tests.yaml](https://github.com/nolte/taskfiles/actions/workflows/build-static-tests.yaml/badge.svg)](https://github.com/nolte/taskfiles/actions/workflows/build-static-tests.yaml) [![.github/workflows/release-cd-deliver-docs.yml](https://github.com/nolte/taskfiles/actions/workflows/release-cd-deliver-docs.yml/badge.svg)](https://github.com/nolte/taskfiles/actions/workflows/release-cd-deliver-docs.yml)

---

<!--intro-start-->
Collection of reusable [Taskfile](https://github.com/go-task/task) includes.

* [mkdocs](./src/taskfile-include-mkdocs.yaml): local preview and doc generation
* [kind](./src/taskfile-include-kind.yaml): control a local development cluster
* [pre-commit](./src/taskfile-include-pre-commit.yaml): local linting
* [k8s](./src/taskfile-include-k8s.yaml): base commands for bootstrapping
<!--intro-end-->

## Usage

<!--usage-start-->
Include this task collection in your [Taskfile](https://taskfile.dev/experiments/remote-taskfiles/):

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  mkdocs: "{{.TASK_COLLECTION_BASE}}/taskfile-include-mkdocs.yaml"
  kind: "{{.TASK_COLLECTION_BASE}}/taskfile-include-kind.yaml"
  pre-commit: "{{.TASK_COLLECTION_BASE}}/taskfile-include-pre-commit.yaml"
  k8s: "{{.TASK_COLLECTION_BASE}}/taskfile-include-k8s.yaml"
```

### Prerequisites

* [go-task](https://taskfile.dev) CLI
* Python virtual environments at `~/.venvs/docs` (for `mkdocs:*` tasks) and `~/.venvs/development` (for `pre-commit:*` tasks), as provisioned by [nolte/workstation](https://github.com/nolte/workstation).
<!--usage-end-->

## Links

<!--links-start-->
* [nolte/workstation](https://github.com/nolte/workstation): workstation configuration.
<!--links-end-->
