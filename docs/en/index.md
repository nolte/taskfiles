---
title: taskfiles
audience:
  - taskfile-consumer-project
  - consumer-developer
content_mode: meta
track: developer-docs
last_updated: 2026-05-20
---

# taskfiles

{%
   include-markdown "../../README.md"
   start="<!--intro-start-->"
   end="<!--intro-end-->"
%}

## Where to start

This site serves three reader clusters. Pick the one that matches the task at hand:

- **Adopt a module.** Wire an include into a consumer project, pick a pin, tune
  the variables. Start with [Getting Started](getting-started/index.md), then
  open the matching page under [References → Modules](references/index.md).
- **Contribute back.** Add a module, change an existing task, or update the
  rendered docs. Read [Guides → Contributing](guides/contributing.md).
- **Verify conformance.** Confirm the repository still satisfies the portfolio
  specs (project structure, release automation, Renovate, Vale). Read
  [References → Governance and specs](references/governance.md).

The structure above reflects the audience analysis recorded in
[`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md).
Every page declares its `audience`, `content_mode`, and `track` in its
front matter so the link between an audience and the content it gets stays
visible.

## Sources

- [`README.md`](https://github.com/nolte/taskfiles/blob/main/README.md) (intro,
  via marker-bounded include)
- [`AUDIENCES.md`](https://github.com/nolte/taskfiles/blob/main/AUDIENCES.md)
