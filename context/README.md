# spike-hosting-upgrades

spike-hosting-upgrades is where the hosting stack learns to keep itself current from what others
publish. An agent skill reads the public record for each host class, engine, and model (engine
releases, public benchmarks, model cards), cites it, and writes a dated report of ranked upgrades.
Beside the upgrades, it finds and ranks what a workstation has fallen behind on, such as pending
system updates and failed units, and applies nothing.
Two anchor cells verify each upgrade on our own host before it is adopted, so local runs are
reserved for what no one publishes. The convention and its cadence are evidence for
v1.ai.hosting; the spike decides nothing itself.

The spike answers for experiment.hosting, and the coordinator's roadmap,
`standards-lab/roadmap/index.toml`, holds its work. The coordinator records its
answer in `standards-lab/docs/ai-hosting.md`, "The spikes' answers". It replaces spike-model-benchmarks; the large-scale suite
waits in the backlog as `model-evaluation`. Each capability in detail, the tasks in the order they
ran, the repositories the spike reads, and its own rules are in
[`docs/capabilities.md`](../docs/capabilities.md).

## The question

What convention evaluates an upgrade to the hosting stack (a host's hardware configuration, its
model host, or its models) from what others publish rather than benchmarks of our own?

## The answer

The answer is in the top-level [`README.md`](../README.md#the-answer).

## The evidence

1. One project-local Claude Code skill, `.claude/skills/hosting-upgrades/`. It reads the
   project's host descriptors (`docs/hosts/`) and policy (`docs/policy.md`), probes the host's
   inventory of hardware, engines, and models read-only and without root, and gathers engine
   releases, public benchmarks, model cards, and host-stack notes, each cited with its URL and the
   date it was read. Before the probe, it prints the permission rules the workspace needs and
   never writes settings. Records: [`skill.md`](../docs/findings/skill.md), the reports in item
   2, and framework's [measure](../docs/measures/framework/2026-11-06.md).
2. A dated report of ranked upgrades per host (framework, gb10-1), at
   `docs/reports/<host>/<YYYY-MM-DD>.md`, or `<YYYY-MM-DD>-N.md` for a later run the same day, in
   four kinds: hardware configuration, system updates and debt, model host, and models. Each upgrade carries its sources, the gain they claim, its
   risk, and a verdict: verify, take, hold, or skip. Records: framework's
   [2026-10-30](../docs/reports/framework/2026-10-30.md),
   [2026-10-30-2](../docs/reports/framework/2026-10-30-2.md), and
   [2026-11-06](../docs/reports/framework/2026-11-06.md); gb10-1's
   [2026-10-30](../docs/reports/gb10-1/2026-10-30.md),
   [2026-10-31](../docs/reports/gb10-1/2026-10-31.md),
   [2026-11-06](../docs/reports/gb10-1/2026-11-06.md), and
   [2026-11-06-2](../docs/reports/gb10-1/2026-11-06-2.md).
3. Each host's top-ranked upgrade, verified by anchors A and B before and after in one session on
   that host, then adopted or rolled back. An anchor that moves beyond run noise is a finding.
   Records: [`verify-framework.md`](../docs/findings/verify-framework.md),
   [`verify-gb10-1.md`](../docs/findings/verify-gb10-1.md), and framework's
   [measure](../docs/measures/framework/2026-11-06.md).
4. The pool's candidates screened from sources per host class. A candidate the sources support is
   verified on its host with anchors A and B beside its role's incumbent in the same session, plus
   the local-only checks (footprint, cold start, API surface, whether a feature works). A host
   keeps only what both support. Records: the screens of
   [framework](../docs/screens/framework/2026-11-04.md) and
   [gb10-1](../docs/screens/gb10-1/2026-11-05.md), and the second surveys' "Needs measurement"
   ([framework](../docs/reports/framework/2026-11-06.md),
   [gb10-1](../docs/reports/gb10-1/2026-11-06-2.md)).
5. For each verified upgrade, the published claim beside our anchors: how far the sources can be
   trusted. Records: [`verify-framework.md`](../docs/findings/verify-framework.md),
   [`verify-gb10-1.md`](../docs/findings/verify-gb10-1.md), the
   [gb10-1 screen](../docs/screens/gb10-1/2026-11-05.md), and framework's
   [measure](../docs/measures/framework/2026-11-06.md).
6. The convention and its cadence: when the skill runs, what triggers a measure, and the record
   an adoption leaves. What stays with the backlog goal `model-evaluation` is named. Records:
   [`convention.md`](../docs/convention.md) and the records it cites, with the second surveys of
   [framework](../docs/reports/framework/2026-11-06.md) and
   [gb10-1](../docs/reports/gb10-1/2026-11-06-2.md).

## Capability map

- **The skill and its modes** (built): [`SKILL.md`](../.claude/skills/hosting-upgrades/SKILL.md),
  with [`setup.md`](../.claude/skills/hosting-upgrades/setup.md),
  [`survey.md`](../.claude/skills/hosting-upgrades/survey.md),
  [`measure.md`](../.claude/skills/hosting-upgrades/measure.md), and the shared
  [`rules.md`](../.claude/skills/hosting-upgrades/rules.md).
- **The bundled scripts and step helpers** (built): the skill's
  [`scripts/`](../.claude/skills/hosting-upgrades/scripts/), reasoning in
  [`scripts.md`](../.claude/skills/hosting-upgrades/scripts.md).
- **Host descriptors and policy** (built): [`docs/hosts/`](../docs/hosts/) and
  [`docs/policy.md`](../docs/policy.md).
- **Dated reports and measure records** (built): [`docs/reports/`](../docs/reports/) and
  [`docs/measures/`](../docs/measures/).
- **Research cache** (built): [`docs/research.md`](../docs/research.md).
- **Blocker register** (built): [`docs/blockers.md`](../docs/blockers.md).
- **Anchor scenarios and conform profiles** (built): [`bench/`](../bench/) and
  [`bench/conform/`](../bench/conform/), sized in [`docs/bench.md`](../docs/bench.md).
- **Verification findings and screen records** (built): history from the modes measure replaced:
  [`docs/findings/`](../docs/findings/) and [`docs/screens/`](../docs/screens/).
- **gb10-2 alignment report** (built): for spike-ai-pipeline,
  [`docs/findings/gb10-2-upgrade.md`](../docs/findings/gb10-2-upgrade.md).
- **The convention** (built): [`docs/convention.md`](../docs/convention.md).
- **Tools, check, and currency** (built): [`mise.toml`](../mise.toml),
  [`scripts/`](../scripts/), reasoning in [`docs/tools.md`](../docs/tools.md).

## Rules

The experiment's rules, `standards-lab/docs/ai-hosting.md#experiment-rules`, govern every session.
The spike's own (anchors, engines, hosts, benchmarks) are in
[`docs/capabilities.md`](../docs/capabilities.md#rules).
