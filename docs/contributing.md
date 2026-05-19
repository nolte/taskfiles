# Contributing

This page is the canonical entry point for anyone who wants to add a module, change an existing task, or update the rendered documentation. The module conventions also live in [`CLAUDE.md`](https://github.com/nolte/taskfiles/blob/main/CLAUDE.md) for AI-assisted edits. Keep both documents in sync.

## Module conventions

Every include file under `src/` follows the same contract. Keep it intact when editing or adding modules.

* **Filename.** `taskfile-include-<area>.yaml`. The `<area>` segment is the key consumers use under `includes:`.
* **Working directory.** Every task sets `dir: '{{.USER_WORKING_DIR}}'`. Commands run in the consumer's working directory, not in this repository. Don't drop this line.
* **Tunable behaviour.** Expose tunable inputs through `vars:` with a sensible default (`KIND_CREATE_EXTRA_ARGS`, `ARGOCD_EXTRA_ARGS`, `MKDOCS_PORT`, `KUBECTL_TIMEOUT`, `PYTHON_VENVS_BASEDIR`, …). Consumers override them through the long-form `includes:` syntax. Never hard-code values that downstream projects might want to change.
* **No embedded provisioning.** Python-backed tasks (`mkdocs:start`, `pre-commit:install`, `pre-commit:start`) activate the consumer's pre-provisioned virtual environments at `~/.venvs/docs` and `~/.venvs/development`. They don't install dependencies on the fly. [nolte/workstation](https://github.com/nolte/workstation) owns the venvs.

## Documentation conventions

* `mkdocs-include-markdown-plugin` pulls the intro and usage blocks from the README into `docs/index.md`. Keep the `<!--intro-start-->`, `<!--intro-end-->`, `<!--usage-start-->`, and `<!--usage-end-->` markers in place; moving them breaks the include integration without an obvious error.
* Every module gets a page under `docs/modules/` with the same schema: short intro, `Prerequisites`, `Tasks`, `Variables`, `Example`, `Troubleshooting`.
* New module names go into the local Vale vocabulary at `.github/styles/config/vocabularies/taskfiles/accept.txt`; otherwise the spelling-vale workflow fails.

## Local checks

The repository ships a small wrapper [`Taskfile.yml`](https://github.com/nolte/taskfiles/blob/main/Taskfile.yml) that delegates to the modules in `src/`:

```bash
task            # list available tasks
task lint       # run every pre-commit hook (delegates to pre-commit:start)
task docs       # serve the mkdocs site locally (delegates to mkdocs:start)
```

Both depend on the venvs at `~/.venvs/development` and `~/.venvs/docs`. When either venv is missing, the task fails the first time it runs. The fix is always to provision the venv, not to install dependencies inside the task.

`requirements-dev.txt` pins the mkdocs stack for the `~/.venvs/docs` venv when the workstation playbook isn't in use.

## Pull request flow

* Branch off `main`. The repository uses the spec-conformant branching model from `nolte/claude-shared`.
* Pull requests run the reusable workflows from [`nolte/gh-plumbing`](https://github.com/nolte/gh-plumbing) at a pinned tag (currently `v1.1.18`). Bump every workflow reference together when updating the pin.
* Merges are squash-only and automerge once checks pass. Renovate-driven dependency bumps follow the same path.
* Prose changes have to pass Vale (Microsoft + RedHat + the [`nolte/vale-style`](https://github.com/nolte/vale-style) pack plus the local `taskfiles` vocabulary). Don't silence findings with per-file ignore comments; either rephrase the line or, for a genuinely new module name, extend the vocabulary file.

## Audience artefact

When the public contract of a module changes (task rename, removal, breaking-change `vars:` rename, or a new module file), revisit [`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md). The recorded `Revisit triggers` section lists the events that demand a refresh of the audience analysis.
