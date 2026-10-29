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
  the last slice's walkthrough, and every escalation's decision. Read `context/README.md`,
  "Rules", and the experiment's rules in `standards-lab/context/ai-hosting.md`, "Experiment:
  experiment.hosting", before any host step.
- **Standards:** `STANDARDS.md`, with pointers into the architecture repository.
- **Check:** `mise run check`, which shellchecks every tracked shell script and resolves every
  relative Markdown link.
- **Currency:** `mise run currency`, which reports every pin behind its latest.
- **Goals:** this spike's tasks live in the coordinator's roadmap,
  `standards-lab/context/roadmap.toml`, under `experiment.hosting.spike-hosting-upgrades`. Its
  goal record is `context/goals/experiment.hosting.spike-hosting-upgrades.md`.
- **References:** the repositories this spike reads are keys in the coordinator's
  `references.toml` and `references.local.toml`. The spike reads them and never writes to them.
