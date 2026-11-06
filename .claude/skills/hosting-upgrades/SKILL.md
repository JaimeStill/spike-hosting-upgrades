---
name: hosting-upgrades
description: Evaluates upgrades to one inference host's serving stack (its hardware configuration, model engine, and models) and settles them on the host. Its survey mode probes the host over SSH, read-only and without root, reads what others publish (engine releases, public benchmarks, model cards, a named model pool), ranks what the workstation has fallen behind on (pending package and firmware updates, failed units, images behind their tag, unused images and models, configuration that differs from its descriptor), judges each against the load targets of the purposes the host serves, and writes a dated, cited report giving each item a verdict (verify, take, hold, or skip); it applies nothing. Its measure mode takes the last survey to local cells under one harness, an engine move judged by the engine rule and a candidate model judged by the keep rule, and writes a dated measure record. Use when asked to survey or evaluate upgrades for a host, find what it has fallen behind on, gate a model pool for a host, plan its next upgrade, measure or settle a survey's items, move a host's engine build, or screen a candidate model on a host.
argument-hint: setup | survey <host> | measure <host>
---

# hosting-upgrades

Evaluates upgrades to the hosting stack, one host a run: what others publish about the host's
hardware configuration, its model host (the engine), and its models, set against what the host runs
today and the load it is meant to carry, then settled on the host with local cells where no one
publishes the answer. The skill knows no particular environment: the hosts, their purposes, and the
rules come from the project's own documents, and every other fact comes from a read-only probe of
the host.

## Modes

The first argument, `$0`, names the mode, and the second, `$1`, the host by its SSH short name.

| Mode | When | Reads | Writes |
|---|---|---|---|
| `setup` | a new workspace, a new host, or a changed rule set | the descriptors and the settings | nothing |
| `survey <host>` | on the project's cadence (`docs/convention.md`), or before any change to the host | the probe and the public record | `docs/reports/<host>/<YYYY-MM-DD>.md` |
| `measure <host>` | after a survey, to settle its items on the host | the last survey and local cells | `docs/measures/<host>/<YYYY-MM-DD>.md` |

- **`setup`** runs the readiness check alone, for every host and both modes, prints the permission
  rules the workspace needs, each marked present or missing, and stops. Read
  [setup.md](setup.md), "Readiness check".
- **`survey <host>`** is the public record: the probe, the system's debt, the hardware
  configuration, the engine, a flag-by-flag configuration review, the models (discovery
  and the pool a descriptor names among them), and the blocker register's upstream states,
  each item cited and given verify, take, hold, or skip, judged against the host's load
  targets. It applies nothing; it reads sources through the project's research cache. Read
  [setup.md](setup.md), then [survey.md](survey.md).
- **`measure <host>`** is local cells: it takes the last survey's host items to a decision,
  moves the engine to a newer build under the engine rule, screens one candidate model beside
  the host's set under the keep rule, and checks a section's keys with and without them. Its
  shipped step helpers run each step, one call at a time, and log every command. It changes
  the host only by commands it prints and records as run, and ends with the host serving its
  set. Read [setup.md](setup.md), then [measure.md](measure.md).

With no mode, or a host alone, ask which mode to run; the default is `survey`. With a mode and no
host, list the descriptors in `docs/hosts/` by their short names and ask which host to run on; a
run covers one host only. The earlier verbs map onto these: a bare host's report run and the screen
mode's pool gating are `survey`, and the verify mode and the screen mode's cells are `measure`.

Load only the files the mode names. Both modes cite the shared rules, [rules.md](rules.md), by
heading; read a rule there when a step cites it.

## Inputs

A run reads two documents from the project, relative to its root (`${CLAUDE_PROJECT_DIR}`), and
writes neither.

- **The host descriptor**, `docs/hosts/<host>.md`. It holds only:
  - the SSH short name the run reaches the host by
  - the purposes the host serves today (agent, vision, audio, embedding, or whatever it serves),
    naming no model, each with its load target: the concurrent sessions or requests it is sized
    for and the context each reaches, citing where each figure comes from (rules.md, "Load
    targets")
  - its run noise: a within-session and an across-days spread, each from cited same-build
    readings (rules.md, "Figures")
  - optional watch items: named things the survey must check, beside its own scan, of any kind
    (hardware, system, or engine), each answered by name in the report section of its kind
  - optional measurements: the workspace's own dated findings on this host, each a reference name
    plus a path, which a run counts as attributed benchmarks ([sources.md](sources.md), "Tiers")
  - an optional pool: another spike's model pool document, a reference name plus a path in the
    same form, whose rows the survey gates as candidates

  Every other fact about the host comes from probing it. [templates/host.md](templates/host.md)
  gives the shape.
- **The policy**, `docs/policy.md`. It states the model-origin rule, artifact integrity with the
  code the architect has accepted, the quantization floor, the agent quality bar, the speed floors
  per purpose, the minimum context per agent session, and the memory headroom a model set must
  leave. [templates/policy.md](templates/policy.md) gives the shape.

Which host serves which purpose, and at what load, is decided outside the skill (by
spike-model-layout, for this project's hosts); the skill judges against what the descriptor lists
and assumes no fixed set of purposes.

## The files

| File | What it holds | Loaded |
|---|---|---|
| [setup.md](setup.md) | the inputs, the readiness check, the probe | every mode, first |
| [survey.md](survey.md) | the survey's steps, its verdicts, its research split, and the report's template | `survey` |
| [measure.md](measure.md) | the measure's harness and steps, the build gate, the engine, keep and settings rules, and the record's template | `measure` |
| [rules.md](rules.md) | the shared rules: who runs what, the default rules, load targets, citing, dated records, fresh loads, cells, caps, figures, the reasoning check, transcripts, routing, pause, root | when a step cites one |
| [models.md](models.md) | the model gates: origin, artifact integrity, the floor, fit, the engine, the agent bar, speed, and the memory estimate | when a step gates a model |
| [sources.md](sources.md) | the trusted sources by kind, their tiers, and how to read each | when a step reads a source |
| [blocklist.md](blocklist.md) | sources never cited, with the criteria | with sources.md |
| [scripts/probe.sh](scripts/probe.sh) | the read-only, no-root host probe | setup.md, step 3 |
| [scripts/screen.sh](scripts/screen.sh) | reads the screening list for the origin research | models.md, "Origin" |
| [scripts/magic.sh](scripts/magic.sh) | reads a Hub file's first 4 bytes | models.md, "Artifact integrity" |
| [scripts/fix-in-image.sh](scripts/fix-in-image.sh) | reads whether a merged fix is in a class's newest imaged build | survey.md, "Blocker register" |
| [scripts/measure-lib.sh](scripts/measure-lib.sh) | measure's step helpers, sourced, and its command log | measure.md, "The harness" |
| [templates/host.md](templates/host.md), [templates/policy.md](templates/policy.md) | the shapes of the two inputs | when a project writes its own |

## A host's cycle

1. `setup`, once for the workspace and again when a host or a rule changes; add what it prints.
2. `survey <host>` reads the public record and ranks the host's items. Its "Needs measurement" and
   "Verify next" name what only the host can settle.
3. `measure <host>` settles them: the host's items to apply, remove, or close, then at most one
   engine move, one candidate screen, and a settings check, each its own pass on one state.
4. The next `survey <host>` reads the measure records as attributed benchmarks on the host, and
   says what moved since the last report.

A run that needs a fact the probe can't read without root, or a value the policy doesn't state,
asks for it and records the answer as the architect's; it never invents one.

## How a run behaves

- **Interactive.** A run pauses and asks the architect only for a choice the rules don't settle
  (rules.md, "Pause"); what the default rules settle it settles itself and records (rules.md,
  "Default rules").
- **No root.** It never runs a command that needs root: it prints it for the architect (rules.md,
  "Root").
- **Guided.** Every command that changes or loads a host is printed before it runs, run by the
  session or the architect as rules.md, "Who runs what", assigns it, and recorded as run.
- **Cited.** Every claim cites its source with its URL and read date (rules.md, "Citing").
- **No grants.** The skill's frontmatter grants no tools: a skill's grant clears at the user's
  next message, so the durable grants are the settings rules `setup` prints. It never writes a
  settings file.

## What a run writes

- `setup` writes nothing.
- `survey` writes its dated report, and updates in place the research cache (`docs/research.md`)
  and the blocker register (`docs/blockers.md`); not the descriptor, the policy, the pool, or the
  skill, and nothing on the host. Changes it would make to any of them are proposals.
- `measure` writes its dated measure record, and updates its host's register entries and, when it
  repeated cells, the descriptor's run noise (measure.md, "Write the record"). The commands
  that change the host are printed, run as rules.md, "Who runs what", assigns them, and recorded in
  the record as run.

The verify findings (`docs/findings/verify-<host>.md`) and screen records
(`docs/screens/<host>/<YYYY-MM-DD>.md`) the earlier modes wrote stay as history: no run edits them,
and measure reads them as the host's earlier readings.
