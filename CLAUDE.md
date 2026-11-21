# spike-hosting-upgrades

A spike for the Standards Lab reference architecture. It builds a project-local Claude Code skill
that evaluates upgrades to the hosting stack (a host's hardware configuration, its model host, or
its models) from what others publish, and verifies each on our hosts, the Framework and gb10-1
(gb10-2 is reserved for spike-ai-pipeline), with anchor cells A and B. `README.md` is the front
page and gives the answer under "The answer". The repository is managed with the marathon
workflow, so start from `context/README.md`.

- **Rules:** read the experiment's rules, `standards-lab/docs/ai-hosting.md#experiment-rules`, and
  the spike's own, `docs/capabilities.md`, "Rules", before any host step.
- **Standards:** `STANDARDS.md`, with pointers into the architecture repository.
- **Check:** `mise run check`, which shellchecks every tracked shell script, resolves every
  relative Markdown link, and runs marathon's lint-context and lint-references.
- **Currency:** `mise run currency`, which reports every pin behind its latest.
- **Goals:** any further work on this spike is a goal in the coordinator's roadmap,
  `standards-lab/roadmap/index.toml`; its answer is recorded in `standards-lab/docs/ai-hosting.md`,
  "The spikes' answers".
- **References:** the repositories this spike reads are keys in the coordinator's
  `references.toml` and `references.local.toml`. The spike reads them and never writes to them.
