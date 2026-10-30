# spike-hosting-upgrades

spike-hosting-upgrades is where the hosting stack learns to keep itself current from what others
publish. An agent skill reads the public record for each host class, engine, and model (engine
releases, public benchmarks, model cards), cites it, and writes a dated report of ranked upgrades.
Beside the upgrades, it finds and ranks what a workstation has fallen behind on, such as pending
system updates and failed units, and applies nothing.
Two anchor cells verify each upgrade on our own host before it is adopted, so local runs are
reserved for what no one publishes. The convention and its cadence are evidence for
v1.ai.hosting; the spike decides nothing itself.

The spike is the sub-goal `experiment.hosting.spike-hosting-upgrades` in the coordinator's roadmap,
`standards-lab/context/roadmap.toml`, where its tasks live. Its question is framed in
`standards-lab/context/ai-hosting.md`, under "Experiment: experiment.hosting", which holds the
experiment's rules and the answers of spike-model-hosting and spike-model-engines. It replaces
spike-model-benchmarks; the large-scale suite waits in the backlog as `model-evaluation`.

## The question

What convention evaluates an upgrade to the hosting stack (a host's hardware configuration, its
model host, or its models) from what others publish rather than benchmarks of our own?

## The evidence

1. One project-local Claude Code skill, `.claude/skills/hosting-upgrades/`. It reads the
   project's host descriptors (`docs/hosts/`) and policy (`docs/policy.md`), probes the host's
   inventory of hardware, engines, and models read-only and without root, and gathers engine
   releases, public benchmarks, model cards, and host-stack notes, each cited with its URL and the
   date it was read. Before the probe, it prints the permission rules the workspace needs and
   never writes settings.
2. A dated report of ranked upgrades per host (framework, gb10-1), at
   `docs/reports/<host>/<YYYY-MM-DD>.md`, in four kinds: hardware configuration, system updates
   and debt, model host, and models. Each upgrade carries its sources, the gain they claim, its
   risk, and a verdict: verify, take, hold, or skip.
3. Each host's top-ranked upgrade, verified by anchors A and B before and after in one session on
   that host, then adopted or rolled back. An anchor that moves beyond run noise is a finding.
4. The pool's candidates screened from sources per host class. A candidate the sources support is
   verified on its host with anchors A and B beside its role's incumbent in the same session, plus
   the local-only checks (footprint, cold start, API surface, whether a feature works). A host
   keeps only what both support.
5. For each verified upgrade, the published claim beside our anchors: how far the sources can be
   trusted.
6. The convention and its cadence: when the skill runs, what triggers a verification, and the
   record an adoption leaves. What stays with the backlog goal `model-evaluation` is named.

## Rules

The experiment's rules, in `ai-hosting.md`, govern every session. In short:

- **One new tool per task**, explained in its brief and walkthrough; at most four slices, the last
  a walkthrough the architect runs before the next task is planned.
- **Guided sessions.** Routine host steps that need no root the session runs itself over Tailscale
  SSH and records; root, a new tool's first walk, and the last slice's walkthrough are the
  architect's.
- **Benchmarks.** Local runs are only anchors A and B and the checks no one publishes. Each run is
  agreed in its task's plan round and takes at most 10 minutes unless the brief decides otherwise.
- **Anchors.** GuideLLM 0.8.1 from the laptop (`mise.bench.toml`), 512 prompt tokens in and
  exactly 256 out: A is 1 stream × 8 requests, B is 4 streams × 32 (`bench/`). A candidate model
  runs the same shape beside its role's incumbent. Every run records the engine version, the host
  stack, and `tailscale ping`.
- **Comparisons.** Only cells run in the same session on the same versions are compared.
- **Engines.** A host's engine changes through spike-model-engines' `engines` suite, run read-only
  from its clone with the version as its argument. A candidate needing its own preset arguments
  is an escalation.
- **Quantization floor** and **model origin**, as `docs/policy.md` states them; its origin rule is
  stricter than `ai-strategy.md`'s.
- **Hosts.** framework and gb10-1; gb10-2 is reserved for spike-ai-pipeline.

## Capabilities

- **The skill:** `.claude/skills/hosting-upgrades/`, the project-local Claude Code skill that
  probes a host and gathers, cites, and ranks what others publish. Its read-only probe is
  `scripts/probe.sh`. Its readiness check, run at the start of each run and alone as
  `/hosting-upgrades setup`, prints the permission rules the workspace needs and never writes
  settings.
- **The host descriptors and policy:** `docs/hosts/<host>.md` and `docs/policy.md`, the skill's
  inputs.
- **The dated reports:** ranked upgrades per host, `docs/reports/<host>/<YYYY-MM-DD>.md`.
- **The anchor scenarios:** anchors A and B, for the incumbent and for a candidate.
- **The verification findings:** before and after, adopted or rolled back.
- **The screened pool:** the pool's candidates, kept or dropped per host class.
- **The convention:** the method and its cadence.

## Path

The tasks, in the order they run; each cites the evidence it proves.

1. `skill`: the skill and its first dated report for each of framework and gb10-1, with
   read-only, no-root host probes (evidence 1, 2).
2. `verify-framework`: framework's top-ranked upgrade, verified by anchors A and B before and
   after, then adopted or rolled back; it also applies the run's take items, with rollbacks, and
   the skill gains its verification step (evidence 3, 5).
3. `verify-gb10`: the same on gb10-1, its root steps the architect's (evidence 3, 5).
4. `screen`: the pool's candidates screened for both host classes, each supported one verified
   beside its role's incumbent (evidence 4).
5. `answer`: a second dated report showing what moved, the cadence, README "The answer", and the
   answer section (evidence 2, 6).

## References

The spike reads these repositories for its setup, the anchors, and the verify and screen tasks,
and never writes to them. The skill takes none of them as inputs, except the findings a host
descriptor lists under Measurements. Each is a key in the
coordinator's `references.toml`, with its local checkout in `references.local.toml`:

- `spike-model-engines`: anchors A and B and their last readings, the `engines` suite, and the
  engine guides.
- `spike-model-hosting`: the pool document (`docs/pool.md`), its admission rules and speed floors,
  the model-card method, and the measurements `docs/policy.md`'s agent quality bar is drawn from.
- `claude-plugins`: the skill layout and the check, for the plugin the intake may route there.
- `dotfiles`: gb10-1's host-stack setup (`platforms/dgx/system-setup.sh`).
- `spike-harness-driver`: how harnesses load a skill.
