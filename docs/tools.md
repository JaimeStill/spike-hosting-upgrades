# The tools

This page gives the reasoning behind the spike's configuration: its mise environments, marathon's
settings, what git leaves untracked, and the check and currency scripts. Each configuration file's
header points at its section with a `See` line.

## The main environment

[`mise.toml`](../mise.toml) pins the tools `mise run check` and `mise run currency` use. Tasks never
install a missing tool (`task.run_auto_install = false`); `mise install` is the one step that reads
the network.

## The bench environment

[`mise.bench.toml`](../mise.bench.toml) holds GuideLLM, the load tool the spike runs from the
laptop, and the runtimes it needs. It lives in its own environment, not mise.toml, so
`mise run check` never installs it. Activate it with `MISE_ENV=bench`:
`MISE_ENV=bench mise install`, then `MISE_ENV=bench mise exec -- guidellm`. mise's pipx backend
installs GuideLLM through uv, with its vision and audio extras, which the vision cells' image
requests and the audio-chat cells' audio requests need. The reason Python is held stays beside its
pin in the file.

## marathon

[`.claude/marathon.toml`](../.claude/marathon.toml) declares the project kind: this spike is
context (a project-local Claude Code skill, dated reports, GuideLLM scenarios, and minimal
scripts), checked by `mise run check`, and declares no gate. Its goals live in the coordinator's
roadmap, `standards-lab/roadmap/index.toml`. Its currency command, `mise run currency`, reports the
mise pins ([Currency](#currency)); the engine pins stay with spike-model-engines, whose suite this
spike runs read-only.

Its `[remote]` table names the remote platform and the commands that publish and merge a finished
branch. The spike has no CI, so the merge doesn't wait on pull-request checks.

## Untracked files

[`.gitignore`](../.gitignore) leaves marathon's working files (`.claude/plans/`, `.claude/briefs/`)
untracked, and the run state under `.state/`: benchmark scratch output before its findings are
committed.

## The check

[`scripts/check.sh`](../scripts/check.sh), run by `mise run check`, shellchecks every tracked
script, the ones whose first line is a sh or bash shebang, and resolves every relative link in a
tracked Markdown file. A link is relative when it names no scheme and isn't an in-page anchor, and
its fragment is dropped before it is resolved, so a link resolves when its file exists; the anchor
is not checked. It then runs marathon's lint-context and lint-references, which mise.toml pins
with marathon's release, and fails if either failed, after both have run. A lint missing from PATH
fails with `FAIL: <lint> is not on PATH; run mise install`.

## Currency

[`scripts/currency.sh`](../scripts/currency.sh), run by `mise run currency`, reads mise.toml and
the bench environment (mise.bench.toml, GuideLLM's) together: `MISE_ENV=bench` loads both. mise
lists a tool not installed here with no bump, so its pin is compared with its latest instead. A pin
held on purpose, as GuideLLM's Python is, is reported like any other, and its comment beside the
pin says why it is held.
