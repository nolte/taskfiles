# Roadmap

This file is the work queue governed by `spec/project/roadmap/`. Each entry is a
level-3 heading followed by a `yaml` code block (`id`, `title`, `detail`,
`outcomes`, `target_sprint`, `mvp`, `status`, in that order) and a free-text
body. `roadmap-plan` and `roadmap-refine` own the detail level (`detail`: `fine`
/ `coarse` / `backlog`) and the status lifecycle (`status`: `proposed`,
`active`, `done`, plus `cancelled`). Don't hand-edit those fields here.

Entries carry monotonically increasing IDs starting at `R-1`, never reused.
Outcome IDs (`O-n` in `goals.md`) are an independent counter. The two streams
never cross.

`taskfiles` shipped the minimum-viable-product item below before adopting the
planning suite, because it's a mature, portfolio-wide configuration source. This
roadmap records it retroactively as `status: done`, mapped to sprint 1, so the
mission's minimum viable product resolves. See `project/mission.md` §Source.

## Phase 1: Shared task-target baseline

### R-1: Reusable Taskfile include collection

```yaml
id: R-1
title: Reusable Taskfile include collection
detail: fine
outcomes: [O-1, O-2, O-3]
target_sprint: 1
mvp: true
status: done
```

The `src/taskfile-include-*.yaml` module collection covers `mkdocs`,
`pre-commit`, `kind`, `k8s`, and `worktree` task targets. Downstream `nolte/*`
projects include a module remotely by pointing `TASK_COLLECTION_BASE` at the
collection. Every task honours the `dir: '{{.USER_WORKING_DIR}}'` invariant, so
commands run in the consumer's directory. Capability
`reusable-taskfile-collection` in `project/portfolio.yml`.
