# spike-hosting-upgrades

A spike for the Standards Lab reference architecture. It builds a project-local Claude Code skill
that evaluates upgrades to the hosting stack (a host's hardware configuration, its model host, or
its models) from what others publish, and verifies each on our hosts, the Framework and gb10-1
(gb10-2 is reserved for spike-ai-pipeline), with anchor cells A and B. `README.md` is the front
page and gives the answer under "The answer". The repository is managed with the marathon
workflow, so start from `context/README.md`.

- **Rules:** sessions are guided where the architect is learning. The session runs routine host
  steps that need no root over Tailscale SSH, and the GuideLLM cells in the architect's view, from
  the commands the brief agreed; the architect keeps root, a new tool's or concept's first walk,
  the last slice's walkthrough, and every escalation's decision. Read the experiment's rules,
  `standards-lab/docs/ai-hosting.md#experiment-rules`, and the spike's own, `docs/capabilities.md`,
  "Rules", before any host step.
- **Standards:** `STANDARDS.md`, with pointers into the architecture repository.
- **Check:** `mise run check`, which shellchecks every tracked shell script, resolves every
  relative Markdown link, and runs marathon's lint-context and lint-references.
- **Currency:** `mise run currency`, which reports every pin behind its latest.
- **Goals:** the coordinator's roadmap, `standards-lab/roadmap/index.toml`, holds this spike's
  work.
- **References:** the repositories this spike reads are keys in the coordinator's
  `references.toml` and `references.local.toml`. The spike reads them and never writes to them,
  except spike-model-engines' `host/`, which experiment.hosting owns: its spikes may change it
  through pull requests, each citing the finding behind it.
