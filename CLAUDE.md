# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of reusable [go-task](https://taskfile.dev) include files. Each file in `src/` is published as a standalone module that downstream projects consume remotely via Taskfile's [remote-taskfiles](https://taskfile.dev/experiments/remote-taskfiles/) experiment (see the `TASK_COLLECTION_BASE` URL pattern in `README.md`). There is no build artifact — the YAML files themselves are the product.

## Module conventions

Every include file in `src/` follows the same contract; preserve it when editing or adding modules:

- Filename is `taskfile-include-<area>.yaml`. The `<area>` is what consumers use as the `includes:` key.
- Every task sets `dir: '{{.USER_WORKING_DIR}}'` so commands run in the consumer's working directory, not this repo. Do not drop this.
- Python-backed tasks (`mkdocs`, `pre-commit`) activate pre-provisioned venvs at `~/.venvs/docs` and `~/.venvs/development` rather than installing dependencies themselves — the consumer's machine is expected to have them (these venvs are provisioned by [nolte/workstation](https://github.com/nolte/workstation)).
- Tunable behavior is exposed via `vars:` with sensible defaults (e.g., `KIND_CREATE_EXTRA_ARGS`, `ARGOCD_EXTRA_ARGS`, `MKDOCS_PORT`) so consumers can override without forking. Write every such variable as `'{{.NAME | default "<fallback>"}}'`, never as a plain literal: a plain literal in a module's own `vars:` block wins over the value a consumer passes at the `includes:` site, so the module silently ignores the override and the contract is broken. Each default **must** be a self-contained literal and must never be derived from another variable in the same block (no `printf "%s/sub" .OTHER_VAR`): that derivation resolves against a scope which doesn't always carry the base, and where a consumer happens to declare a same-named variable in its root `vars:` the base renders as nil, so the task fails with a shell parse error instead of falling back. Note that an exported environment variable of the same name reaches these defaults too. As of this writing only `mkdocs` is converted; the other modules still use plain literals and silently ignore overrides.

## Common commands

```bash
# List tasks wired into the local Taskfile
task

# Serve the mkdocs site locally (requires ~/.venvs/docs)
task mkdocs:start

# Run all pre-commit hooks against the repo (requires ~/.venvs/development)
pre-commit run --all-files
```

`requirements-dev.txt` pins the mkdocs stack; install it into `~/.venvs/docs` if the venv does not already exist.

## Docs pipeline

`docs/index.md` pulls content from `README.md` between the `<!--intro-start-->/<!--intro-end-->` and `<!--usage-start-->/<!--usage-end-->` markers via `mkdocs-include-markdown-plugin`. When editing README sections that sit between those markers, verify the rendered docs still make sense — the markers are the integration point, do not remove them.

## CI

All workflows in `.github/workflows/` delegate to reusable workflows in `nolte/gh-plumbing` (pre-commit, trivy, chain-bench, mkdocs publish, release-drafter). Every `uses:` reference is pinned to a full-length commit digest with the version as a trailing comment — currently `d51e51ec3ec17ceea09fe9eb40ac00857b6fa1be # v2.0.0`. Never replace a digest pin with a bare tag; bump all workflow references together.

Prose in Markdown is linted with Vale using the config in `.vale.ini` (Microsoft + RedHat + nolte custom styles).
