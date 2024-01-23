# taskfiles

[![GitHub Project Stars](https://img.shields.io/github/stars/nolte/taskfiles.svg?label=Stars&style=social)](https://github.com/nolte/taskfiles) [![GitHub Issue Tracking](https://img.shields.io/github/issues-raw/nolte/taskfiles.svg)](https://github.com/nolte/taskfiles) [![GitHub LatestRelease](https://img.shields.io/github/release/nolte/taskfiles.svg)](https://github.com/nolte/taskfiles) [![.github/workflows/build-static-tests.yaml](https://github.com/nolte/taskfiles/actions/workflows/build-static-tests.yaml/badge.svg)](https://github.com/nolte/taskfiles/actions/workflows/build-static-tests.yaml) [![.github/workflows/release-cd-deliver-docs.yml](https://github.com/nolte/taskfiles/actions/workflows/release-cd-deliver-docs.yml/badge.svg)](https://github.com/nolte/taskfiles/actions/workflows/release-cd-deliver-docs.yml)

---

<!--intro-start-->
Collection of reusable [Taskfile](https://github.com/go-task/task).

* [mkdocs](), for local usage and generate the docs
* [kind](), for control local development cluster
* [pre-commit](), for local linting
* [k8s](), for base commands useful for bootstrapping


<!--intro-end-->

## Usage

<!--usage-start-->
Include this task collection into your [Taskfile](https://taskfile.dev/experiments/remote-taskfiles/)

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/feature/k8s-tasks/src

includes:
  mkdocs: "{{.TASK_COLLECTION_BASE}}/taskfile-include-mkdocs.yaml"
  pre-commit: "{{.TASK_COLLECTION_BASE}}/taskfile-include-pre-commit.yaml"
  ...
...
```
<!--usage-end-->

## Links

<!--links-start-->
* [nolte/workstation](https://github.com/nolte/workstation), for configure our Workstation.
<!--links-end-->
