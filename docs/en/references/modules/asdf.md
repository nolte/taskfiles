---
title: asdf
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-07-11
---

# asdf

Detect stale [asdf](https://asdf-vm.com/) tool versions and remove the ones
that are no longer in use. For every installed asdf plugin, the version asdf
currently resolves is kept, and every other installed version becomes a
removal candidate — so a machine that has accumulated many old tool versions
can be trimmed back to what it actually runs.

See [References → Common contract](../index.md#common-contract) for the
`USER_WORKING_DIR`, pin-strategy, and override-syntax conventions that
apply across every module.

## Prerequisites

- `asdf` on the `PATH`. The module is written against asdf `v0.19` (the Go
  rewrite), where `asdf list <plugin>` marks the active version with `*`.
- A populated `~/.tool-versions` (or the directory named by
  `ASDF_RESOLVE_DIR`) so the task can tell which version is active. Plugins
  that have no active version are skipped by default — see `ASDF_KEEP_UNPINNED`.

## Tasks

| Task | Description |
|------|-------------|
| `asdf:prune -- [apply] [plugin...]` | Report stale versions per plugin. Runs as a dry run by default; pass `apply` to `asdf uninstall` each candidate. Optional plugin names restrict the scan. |

For each plugin, the version asdf resolves in `ASDF_RESOLVE_DIR` (the `*` in
`asdf list`, i.e. the global `~/.tool-versions` pin) is kept; every other
installed version is a candidate. The task **never removes anything unless you
pass `apply`** — without it, it only prints what it would remove.

Plugins with no active version are skipped, so an unpinned tool is never wiped
out entirely by accident. Set `ASDF_KEEP_UNPINNED` to `false` to treat every
installed version of an unpinned plugin as a candidate instead.

## Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `ASDF_RESOLVE_DIR` | `$HOME` | Directory the active version is resolved against. The default sees the global `~/.tool-versions` and ignores any project-local `.tool-versions`. Set to `{{.USER_WORKING_DIR}}` to honour a project-local pin. |
| `ASDF_KEEP_UNPINNED` | `true` | Leave plugins that have no active version untouched. Set to `false` to also prune unpinned plugins (dangerous — it makes every installed version a candidate). |

## Example

```yaml
version: '3'

vars:
  TASK_COLLECTION_BASE: https://raw.githubusercontent.com/nolte/taskfiles/main/src

includes:
  asdf: "{{.TASK_COLLECTION_BASE}}/taskfile-include-asdf.yaml"
```

Then, from anywhere:

```bash
# Report stale versions across every plugin (dry run — removes nothing).
task asdf:prune

# Actually uninstall every stale version.
task asdf:prune -- apply

# Restrict the scan to one or more plugins.
task asdf:prune -- golang
task asdf:prune -- apply golang kubectl
```

## Troubleshooting

- **`asdf is not installed`.** The `asdf` CLI is not on the `PATH`. Install
  it (or provision it via [nolte/workstation](https://github.com/nolte/workstation))
  and retry.
- **A plugin you expected to be trimmed is skipped.** It has no active version
  pinned in the resolved `.tool-versions`. Pin it, or set
  `ASDF_KEEP_UNPINNED: "false"` to prune it anyway.
- **A candidate failed to remove.** `asdf uninstall` failed for that version
  (for example, a running process still holds it). The task reports it as
  failed, keeps going, and exits non-zero at the end. Re-run, or uninstall it
  by hand.
- **The wrong versions were kept.** The active version is resolved against
  `ASDF_RESOLVE_DIR` (`$HOME` by default), so a project-local `.tool-versions`
  is ignored unless you point `ASDF_RESOLVE_DIR` at that directory.
