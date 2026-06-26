---
title: References
audience:
  - taskfile-consumer-project
  - consumer-developer
  - consumer-ci
content_mode: reference
track: developer-docs
last_updated: 2026-05-20
---

# References

Information-oriented documentation. Use this section to look up the contract
of each module and the portfolio conventions that govern the repository.

## Module references

One page per include file under `src/`. Every page follows the same schema
(short intro, **Prerequisites**, **Tasks**, **Variables**, **Example**,
**Troubleshooting**) so consumers can scan all four without learning a new
layout each time.

- [mkdocs](modules/mkdocs.md): `mkdocs:start`
- [kind](modules/kind.md): `kind:start`, `kind:destroy`, `kind:recreate`
- [pre-commit](modules/pre-commit.md): `pre-commit:install`,
  `pre-commit:start`
- [k8s](modules/k8s.md): `k8s:bootstrap`, `k8s:install-argocd`
- [worktree](modules/worktree.md): `worktree:add`, `worktree:remove`,
  `worktree:list`, `worktree:root`

## Common contract

These rules hold for every module in the collection. Module pages don't
repeat them. Instead, they reference this section.

### USER_WORKING_DIR invariant

Every task sets `dir: '{{.USER_WORKING_DIR}}'`. Commands therefore run in the
directory the consumer invoked `task` from, never in the location of the
include file itself. Concretely:

- `task mkdocs:start` serves the `mkdocs.yml` next to the consumer's
  `Taskfile.yml`, not one inside this repository.
- `task pre-commit:start` runs on the consumer's
  `.pre-commit-config.yaml`.
- `task kind:start` writes the cluster kubeconfig wherever `kind` writes it
  by default for the current user.

### Pin strategy

`TASK_COLLECTION_BASE` is the single point of pinning for every include. The
address has the shape

```text
https://raw.githubusercontent.com/nolte/taskfiles/<ref>/src
```

where `<ref>` is one of:

- `main`: convenient while evaluating a module; behaviour can drift any
  time a maintainer pushes to `main`.
- A released tag, for example `v1.2.0`: recommended for day-to-day use.
  Drift is impossible until the consumer bumps the tag.
- A branch name: useful for testing an in-flight change with a real
  consumer; not appropriate for shared environments.

Because every module path shares the same `TASK_COLLECTION_BASE`, Renovate
(or any other dependency-bump tool) updates all four includes in one pull
request when the consumer pins to a tag.

### Per-module overrides

Each module exposes a small set of `vars:` defaults. The short-form
`includes:` syntax accepts the include path only:

```yaml
includes:
  mkdocs: "{{.TASK_COLLECTION_BASE}}/taskfile-include-mkdocs.yaml"
```

Overrides require the long-form syntax with a `vars:` block:

```yaml
includes:
  mkdocs:
    taskfile: "{{.TASK_COLLECTION_BASE}}/taskfile-include-mkdocs.yaml"
    vars:
      MKDOCS_PORT: 8080
```

Each module page lists its variables in the **Variables** table with the
default value and the purpose of the variable.

### Externally provisioned virtual environments

Python-backed modules (`mkdocs`, `pre-commit`) activate pre-provisioned
virtual environments. They don't install dependencies on the fly. The
defaults are `~/.venvs/docs` and `~/.venvs/development`. Both come from the
[`nolte/workstation`](https://github.com/nolte/workstation) playbook. Move
the base path with `PYTHON_VENVS_BASEDIR` when the playbook isn't in use.

## Repository governance

- [Governance and specs](governance.md): portfolio conventions, reusable
  workflows, dependency governance, Vale stack, Probot settings.

## Sources

- `src/taskfile-include-<area>.yaml` (canonical per-module contracts)
- [`CLAUDE.md`](https://github.com/nolte/taskfiles/blob/main/CLAUDE.md)
- [`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md)
