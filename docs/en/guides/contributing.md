---
title: Contributing
audience:
  - module-maintainer
  - documentation-author
content_mode: how-to
track: developer-docs
last_updated: 2026-05-20
---

# Contributing

The canonical entry point for adding a module, changing an existing task, or
updating the rendered docs.
[`CLAUDE.md`](https://github.com/nolte/taskfiles/blob/main/CLAUDE.md) records
the same conventions for AI-assisted edits. Keep both documents in sync
when the contract changes.

## Module conventions

Every include file under `src/` follows the same contract. Keep it intact
when editing or adding modules.

- **Filename.** `taskfile-include-<area>.yaml`. The `<area>` segment is the
  key consumers use under `includes:`.
- **Working directory.** Every task sets `dir: '{{.USER_WORKING_DIR}}'`.
  Commands run in the consumer's working directory, not in this repository.
  Don't drop this line.
- **Tunable behaviour.** Expose tunable inputs through `vars:` with a sensible
  default (for example `KIND_CREATE_EXTRA_ARGS`, `ARGOCD_EXTRA_ARGS`,
  `MKDOCS_PORT`, `KUBECTL_TIMEOUT`, `PYTHON_VENVS_BASEDIR`). Consumers
  override them through the long-form `includes:` syntax documented under
  [References → Common contract](../references/index.md#common-contract).
  Don't hard-code values that downstream projects might want to change.
- **No embedded provisioning.** Python-backed tasks (`mkdocs:start`,
  `pre-commit:install`, `pre-commit:start`) activate the consumer's
  pre-provisioned virtual environments at `~/.venvs/docs` and
  `~/.venvs/development`. They don't install dependencies on the fly.
  [`nolte/workstation`](https://github.com/nolte/workstation) owns the
  venvs.

## Documentation conventions

- `mkdocs-include-markdown-plugin` pulls the intro block from the README into
  the rendered home page through the `<!--intro-start-->` and
  `<!--intro-end-->` markers. Keep those markers in place; moving them
  breaks the include integration without an obvious build error.
- Every module gets a page under `docs/en/references/modules/` (and the
  matching translation under `docs/de/references/modules/`) with the same
  schema: short intro, **Prerequisites**, **Tasks**, **Variables**,
  **Example**, **Troubleshooting**.
- New module names go into the local Vale vocabulary at
  `.github/styles/config/vocabularies/taskfiles/accept.txt`; otherwise the
  spelling-vale workflow fails on the first prose mention.

## Local checks

The repository ships a small wrapper
[`Taskfile.yml`](https://github.com/nolte/taskfiles/blob/main/Taskfile.yml)
that delegates to the modules in `src/`:

```bash
task            # list available tasks
task lint       # run every pre-commit hook (delegates to pre-commit:start)
task docs       # serve the mkdocs site locally (delegates to mkdocs:start)
```

Both `lint` and `docs` depend on the venvs at `~/.venvs/development` and
`~/.venvs/docs`. When either venv is missing, the task fails on the first
run. The fix is to provision the venv, not to inline `pip install` into the
task. `requirements-dev.txt` pins the mkdocs stack for `~/.venvs/docs` when
the workstation playbook isn't in use.

## Pull request flow

- Branch off `main`. The repository uses the spec-conformant branching model
  from `nolte/claude-shared`.
- Pull requests run the reusable workflows from
  [`nolte/gh-plumbing`](https://github.com/nolte/gh-plumbing) at a pinned
  commit digest (currently `d51e51ec3ec17ceea09fe9eb40ac00857b6fa1be`, which is
  `v2.0.0`). Bump every workflow reference together when updating the pin, and
  keep the digest form; a bare tag can be moved onto different code.
- Merges are squash-only and automerge once checks pass. Renovate-driven
  dependency bumps follow the same path.
- Prose changes have to pass Vale (Microsoft + RedHat plus the
  [`nolte/vale-style`](https://github.com/nolte/vale-style) pack and the
  local `taskfiles` vocabulary). Don't silence findings with per-file
  ignore comments; either rephrase the line, or, for a genuinely new
  module name, extend the vocabulary file.

## Revisit the audience artefact

When the public contract of a module changes (a task rename, a task
removal, a breaking-change `vars:` rename, or a brand-new module file),
revisit [`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md).
The `Revisit triggers` section at the bottom of that file lists every event
that demands a refresh of the audience analysis.
