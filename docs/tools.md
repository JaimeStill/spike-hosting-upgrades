# The tools

The spike's mise environments, marathon's settings, and what git leaves untracked; each
configuration file's header points at its section with a `See` line.

## The main environment

[`mise.toml`](../mise.toml) pins the tools `mise run check` and `mise run currency` use. Tasks never
install a missing tool (`task.run_auto_install = false`); `mise install` is the one step that reads
the network.

## The bench environment

[`mise.bench.toml`](../mise.bench.toml) holds the load tool the spike measures with from the
laptop, GuideLLM, and the runtimes it needs. It lives in its own environment, not mise.toml, so
`mise run check` never installs it. Activate it with `MISE_ENV=bench`: `MISE_ENV=bench mise
install`, then `MISE_ENV=bench mise exec -- guidellm`. mise's pipx backend installs GuideLLM
through uv, with its vision and audio extras, which the vision cells' image requests and the
audio-chat cells' audio requests need. Python's hold reason stays beside its pin in the file.

## marathon

[`.claude/marathon.toml`](../.claude/marathon.toml) declares the project kind: this spike is
context (a project-local Claude Code skill, dated reports, GuideLLM scenarios, and minimal
scripts), checked by `mise run check`. Its goals live in the coordinator's roadmap,
`standards-lab/roadmap/index.toml`. `mise run currency` reports every mise tool pinned behind its
latest, those of mise.toml and of the bench environment (mise.bench.toml). The engine pins stay
with spike-model-engines, whose suite this spike runs read-only. No gate.

Its `[remote]` table names the remote platform and the commands that publish and merge a finished
branch. The spike has no CI, so the merge doesn't wait on pull-request checks.

## Untracked files

[`.gitignore`](../.gitignore) leaves marathon's working files (`.claude/plans/`, `.claude/briefs/`)
untracked, and the run state under `.state/`: benchmark scratch output before its findings are
committed.
