# Capabilities, references, and rules

This page details the spike's built capabilities, the repositories it reads, and its rules.
[`context/README.md`](../context/README.md) holds the capability map and the evidence these serve.

## Capabilities

- **The skill:** `.claude/skills/hosting-upgrades/`, the project-local Claude Code skill. Its entry
  file, `SKILL.md`, names three modes (`setup`, `survey <host>`, `measure <host>`) and loads one
  reference file per mode, `setup.md`, `survey.md` or `measure.md`, beside `rules.md`, the shared
  rules each mode cites. `/hosting-upgrades setup` runs the readiness check alone, printing the
  permission rules the workspace needs; it never writes settings.
- **The host descriptors and policy:** `docs/hosts/<host>.md` and `docs/policy.md`, the skill's
  inputs. Each descriptor lists the purposes its host serves, each with its load target, and its
  run noise, a within-session and an across-days spread.
- **The survey mode:** `/hosting-upgrades survey <host>` probes the host read-only and without
  root (`scripts/probe.sh`), reviews its configuration flag by flag against published practice,
  gathers, cites, and ranks what others publish (models others run on the class, and the pool a
  descriptor names), judges each item against the host's load targets, and writes the dated
  report; it applies nothing.
- **The dated reports:** ranked upgrades per host, `docs/reports/<host>/<YYYY-MM-DD>.md`, or
  `<YYYY-MM-DD>-N.md` for a later run the same day.
- **The research cache:** `docs/research.md`, one entry per source with what it said and when it
  was read, updated in place; a survey re-reads a source only after 14 days or when its subject
  changes.
- **The blocker register:** `docs/blockers.md`, one entry per blocker naming the hosts it affects,
  its measured cost, its upstream issue or pull request, and its state. Every survey checks each
  entry upstream with `gh`, and `scripts/fix-in-image.sh` reads whether a merged fix is in the
  newest build with an image for the host class.
- **The measure mode:** `/hosting-upgrades measure <host>` settles the last survey's items on the
  host with local cells: an engine move under the engine rule, behind a build gate; a candidate
  model beside the host's set under the keep rule; and a settings check. It writes the dated
  measure record, `docs/measures/<host>/<YYYY-MM-DD>.md`.
- **The step helpers:** `scripts/measure-lib.sh`, sourced and called one step at a time. They log
  every command and what each helper prints to `.state/measure/<host>/<YYYY-MM-DD>.log`, which
  the measure record quotes for its commands as run.
- **The anchor scenarios and instruments:** anchors A and B, for the incumbent and for a
  candidate; the conform profiles, `bench/conform/`; and the vision, sweep, and long-prompt
  scenarios in `bench/`.
- **The verification findings and screen records**, history from the verify and screen modes that
  measure replaced: `docs/findings/verify-<host>.md` (framework's
  `docs/findings/verify-framework.md`, gb10-1's `docs/findings/verify-gb10-1.md`) and
  `docs/screens/<host>/<YYYY-MM-DD>.md`, both named in `STANDARDS.md`.
- **The gb10-2 alignment report:** `docs/findings/gb10-2-upgrade.md`, the steps that bring gb10-2
  in line with gb10-1, each with who runs it and its rollback, for spike-ai-pipeline to apply.
- **The convention:** `docs/convention.md`, how the project evaluates an upgrade. It states when
  survey runs, what triggers a measure, the record an adoption leaves, how proposals are settled,
  the blocker register, the research cache, per-host load targets, and what stays with
  `model-evaluation`, each statement citing its record.

## References

The spike reads these repositories for its setup, the anchors, and the verify and screen tasks, and
never writes to them. The skill takes none of them as inputs, except the findings a host descriptor
lists under Measurements and the pool its Pool section names, which the survey gates. Each is a key
in the coordinator's `references.toml`, with its local checkout in `references.local.toml`:

- `spike-model-engines`: anchors A and B and their last readings, the `engines` suite, and the
  engine guides.
- `spike-model-hosting`: the pool document (`docs/pool.md`), its admission rules and speed floors,
  the model-card method, the measurements `docs/policy.md`'s agent quality bar is drawn from, and
  the agent tiers (BFCL and conform) and profile loader the measure mode runs read-only from its
  clone.
- `claude-plugins`: the skill layout and the check, for the plugin the intake may route there.
- `dotfiles`: gb10-1's host-stack setup (`platforms/dgx/system-setup.sh`).
- `spike-harness-driver`: how harnesses load a skill.

## Rules

The experiment's rules, `standards-lab/docs/ai-hosting.md#experiment-rules`, govern every
session. In short:

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
  stricter than `standards-lab/context/ai-strategy.md`'s.
- **Hosts.** framework and gb10-1; gb10-2 is reserved for spike-ai-pipeline.
