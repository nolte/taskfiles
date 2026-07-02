# Vision

`taskfiles` is the `nolte` portfolio's single source of reusable `Taskfile`
include modules. Each module ships as one YAML file under `src/`. Downstream
`nolte/*` projects wire a module remotely through `Taskfile`'s `remote-taskfiles`
experiment, pointing `TASK_COLLECTION_BASE` at the collection. There's no build
step and no runtime artefact. The YAML files are the product. Every task sets
`dir: '{{.USER_WORKING_DIR}}'`, so commands run in the consumer's working
directory.

## Outcomes

- **O-1**: downstream projects get consistent task targets by including
  `taskfiles`' reusable modules remotely instead of copying `Taskfile` logic into
  each repository. _(audience: Taskfile-consumer project)_
- **O-2**: consumer-side developers run predictable, idempotent task commands
  locally in their own working directory. _(audience: Consumer-side developer
  running tasks locally)_
- **O-3**: consumer-side CI/CD pipelines invoke the same task targets as local
  runs, so local and CI behaviour stay identical. _(audience: Consumer-side CI/CD
  pipeline)_
- **O-4**: the maintainer evolves the module collection with stable task
  signatures and tag stability, so consumer pins stay stable across changes.
  _(audience: Module maintainer)_
