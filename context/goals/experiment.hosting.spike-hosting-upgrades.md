# goal · experiment.hosting.spike-hosting-upgrades

- **State:** idle
- **Task:** none
- **Branch:** none

## Tasks

1. [ ] skill
2. [ ] verify-framework
3. [ ] verify-gb10
4. [ ] screen
5. [ ] answer

## Decisions

- setup: evidence is six items (the skill; the dated ranked report; top upgrade verified per host
  by anchors A and B; the pool screened; claim beside anchors; the convention and cadence).
- setup: the skill is project-local Claude Code (`.claude/skills/`); rejected a plugin in the
  spike, since the intake can route a plugin to claude-plugins; rejected Pi and OpenCode support
  for the spike.
- setup: kind context; check shellchecks tracked scripts and resolves relative Markdown links;
  currency over mise tools (mise.toml and the bench environment); no gate, no CI; public remote.
- setup: engine changes run spike-model-engines' `engines` suite read-only with the version as its
  argument; rejected copying the suite and presets, which would fork what the intake takes from
  spike-model-engines. A candidate needing its own preset arguments is an escalation.
- setup: a candidate model's anchors use the same shape (A 1×8, B 4×32, 512 in, 256 out) beside
  its role's incumbent in the same session; rejected gpt-oss-120b's anchors alone, which can't
  show another model's speed.
- setup: references spike-model-engines, spike-model-hosting, claude-plugins, dotfiles,
  spike-harness-driver; personal-agents left out as superseded.
- setup: hosts are framework and gb10-1; gb10-2 stays reserved for spike-ai-pipeline.
- setup: GuideLLM 0.8.1 bench environment copied from spike-model-engines so the anchors stay
  comparable; anchor scenarios copied into `bench/`.

## Pending edits

(none)
