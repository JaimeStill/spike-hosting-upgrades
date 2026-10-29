---
name: hosting-upgrades
description: Evaluates upgrades to one inference host's serving stack (its hardware configuration, its model engine, and its models) from what others publish. Probes the host live over SSH, read-only and without root, reconciles the probe with the project's host descriptor and policy, and writes a dated, cited report of upgrades. Use when asked to evaluate upgrades for a host, check what's new for a host's engine or models, or plan a host's next upgrade.
argument-hint: <host>
allowed-tools:
  - Bash(ssh * bash -s < ${CLAUDE_SKILL_DIR}/scripts/probe.sh)
  - Read
  - Edit(docs/reports/**)
---

# hosting-upgrades

Evaluates upgrades for one host a run: the host named by its SSH short name, here `$0`. A run
probes the host as it is now, reconciles what it finds with the project's descriptor of that host,
and writes one dated report. The skill knows no particular environment: the hosts and the rules
come from the project's own documents, and every other fact comes from the probe.

The run is interactive. It pauses and asks the architect rather than guessing or failing (see
"When to pause"), and it never runs a command that needs root (see "Facts that need root").

## Inputs

A run reads two documents from the project, relative to its root (`${CLAUDE_PROJECT_DIR}`), and
writes neither.

- **The host descriptor**, `docs/hosts/<host>.md`. It holds only:
  - the SSH short name the run reaches the host by
  - the declared model purposes: what the host serves or is meant to serve (agent, vision, audio,
    embedding, or whatever it serves), naming no model
  - optional engine watch items: named things the run must check, beside its own scan

  Every other fact about the host comes from probing it. [templates/host.md](templates/host.md)
  gives the shape, for an environment writing its own.
- **The policy**, `docs/policy.md`. It states the model-origin rule, the quantization floor, and
  the memory headroom a model set must leave. [templates/policy.md](templates/policy.md) gives
  the shape.

When a step needs a policy value the document doesn't state (a floor for a kind of model it
doesn't name, a headroom it leaves open), the run asks the architect for the value and records
the answer in the report as the architect's, never inventing one.

## The run

### 1. Load the inputs

1. Take the host from the argument, `$0`. With no argument, list the descriptors in `docs/hosts/`
   by their short names, ask which host to run on, and run on one host only.
2. Read `docs/hosts/<host>.md`. If it is absent, stop and say so: "No descriptor for `<host>` in
   `docs/hosts/`, so the run has no declared purposes to judge against; write one from the
   skill's `templates/host.md` and run again." Name the descriptors that do exist.
3. Read `docs/policy.md`. If it is absent, stop and say so: "The project has no policy document
   (`docs/policy.md`), so no candidate can be judged against the model-origin rule, the
   quantization floor, or the memory headroom; write one from the skill's `templates/policy.md`
   and run again."
4. If the descriptor holds anything beyond its three sections (a model name, an engine version, a
   memory figure), treat it as stale: the probe decides those facts, and the report notes the
   extra lines under "Proposed changes".

### 2. Probe

Run the bundled probe on the host over SSH, from the project root, exactly as:

```sh
ssh <short name> bash -s < ${CLAUDE_SKILL_DIR}/scripts/probe.sh
```

[scripts/probe.sh](scripts/probe.sh) is read-only and needs no root. It prints labeled sections
(`== os ==`, `== kernel ==`, `== firmware ==`, `== gpu ==`, `== memory ==`,
`== container-runtime ==`, `== engines ==`, `== endpoints ==`, `== models ==`, `== skipped ==`).
Each engine container, and each model a llama.cpp router lists, carries a `flags` line: its
launch arguments filtered to the ones that shape serving (context, parallel slots, batching, KV
cache, offload, memory), which is the incumbent's configuration step 6 weighs. A flag the line
doesn't show was not passed on the command line, and is at the engine's default unless it was set
another way the probe doesn't read (an environment variable such as `LLAMA_ARG_CTX_SIZE`, a
preset or config file); a flag outside the filter's list doesn't show either.
A probe whose command is absent on the host prints `skipped:` and the probe goes on; a skip is a
fact too, and the report keeps it. The probe prints no network address: it reads listening ports
from `ss -Hltn` and `docker port` and drops the address from each, and a final guard redacts any
IPv4 address, tailnet IPv6 address, or MagicDNS name that slips through, so its output can go into
the report as is.

- If SSH fails, stop and say the host is unreachable, quoting the error. Don't work around it.
- If the probe's output is incomplete (a section is missing, or docker reports no permission),
  say which sections are missing and ask whether to continue without them.

### 3. Reconcile with the descriptor

Compare what the probe found with what the descriptor declares, and pause on every discrepancy
(see "When to pause") before going on:

- **A served model whose purpose isn't declared**: map each model in `== endpoints ==` to a
  purpose from its name and, where unclear, its card. A model that fits no declared purpose is a
  discrepancy.
- **A declared purpose nothing serves**: a purpose with no served model, including the case where
  nothing serves at all. When nothing serves, the inventory says so, and the later steps judge
  against the installed engines (`== engines ==`) and the stored models (`== models ==`), once
  the architect confirms that is what the run should do.
- **A watch item the probe can't reach**: a watch item naming an engine or backend the host
  doesn't have is kept, not dropped; note it for "Proposed changes".

Record each answer the architect gives; the report cites it as the architect's.

### 4. Sources

Gather the public record for what the probe found, from the sources in
[sources.md](sources.md), which lists each by kind (hardware and host stack, engines, models,
benchmarks) and by vendor or project, with its URL and how to read it. Read the machine-readable
endpoint where one exists (the GitHub releases API, the Hugging Face API, Arch's package JSON),
and read it fresh: what a source said on an earlier run is not evidence today.

- **Read for the probed versions.** For each component the probe names (OS image, kernel,
  firmware, BIOS, driver or Mesa, each engine and its build), find what is newer, what changed
  between the probed version and the newest, and what is known to break.
- **Search beyond the list.** A web search finds benchmarks and reports the list doesn't hold.
  A found source is tiered by the same bar as a listed one, and a good one is proposed for the
  list under "Proposed changes".
- **Tier every source** as primary, attributed benchmark, or lead, by the bar in
  [sources.md](sources.md), "Tiers". A lead names something to check and never carries a verify
  verdict alone.
- **Never cite a blocklisted source** ([blocklist.md](blocklist.md)). When one carries a figure
  worth having, follow it to its original and cite that, or leave the figure out. A source met
  in this run that fails a blocklist criterion is proposed for the blocklist, with its reason,
  under "Proposed changes".

#### Citing

Every claim in the report cites its source inline, with its URL and the date it was read, as
`([name](https://...), read YYYY-MM-DD)`. A claim from the probe cites its section
(`probe == memory ==`); a claim from the architect cites the answer and the date. A figure the
run works out on paper rather than reads from a measurement is marked **estimate** and names its
method, for example "estimate: per-slot context = `--ctx-size` / `--parallel` when the KV cache
isn't unified, from `llama-context.cpp` at the probed build". A citation names the page the run
read itself; a search engine's result summary points to a page to read and is never the cited
source. A Sources-table row that names a group, such as "every model named above", does not
stand in for a claim's inline citation: each model's origin, base, and format claims cite that
model's own page.

### 5. Hardware configuration

Recommend adjustments to the host's hardware configuration, one per component that has a
candidate: kernel, firmware (linux-firmware, GPU firmware), BIOS, OS image, driver or Mesa, and
the GPU-reachable memory ceiling (the TTM limit on AMD; on GB10, the system memory). A component
already at its newest, with nothing known to break, gets one line saying so, with the source that
shows it.

Each adjustment gives:

- **From and to**: the probed version and the candidate.
- **Sources**: each with its tier and its citation.
- **Claimed gain**: what the sources claim, in their own terms, or "none claimed".
- **Risk**: what is known to break, whether it needs root, and its rollback (a package
  downgrade, a BIOS reflash, removing a modprobe file).
- **Verdict**: verify, hold, or skip, by the rules in "Verdicts" below, with the reason.

Order the adjustments verify first, then hold, then skip. A fact the probe can't read without
root (loaded GPU firmware, BIOS settings) is asked for as "Facts that need root" says.

### 6. Engines

An objective look at the most effective engine setup on the probed hardware, for the purposes the
descriptor declares.

1. **The incumbent.** Name the engine that serves (or, when nothing serves, the installed engines
   step 3 settled on), with its version, its backend, and its configuration from the probe's
   `flags` lines: context, parallel slots, KV cache (unified or split), batching, offload. Read
   each flag the line doesn't show at its default from the engine's source or docs at the probed
   version, and cite it, naming it a default read rather than a probed value. Note where the
   configuration works against a declared purpose (a per-slot context too short for agent
   sessions, slots that can't share a cache).
2. **The seed list, filtered to the backend.** Weigh the incumbent against llama.cpp, vLLM,
   SGLang, and TensorRT-LLM, keeping only what the probed backend supports: TensorRT-LLM only on
   NVIDIA, and on AMD only what the engine's own docs or published images list for the probed gfx
   target. Judge a packager (Ollama, LM Studio) by the engine and build it embeds, not as an engine
   of its own. For each engine kept, say whether its newest release supports the backend, how the
   host would install it, and what any attributed benchmark on the same hardware class measured
   against the incumbent.
3. **The scan.** Look each run for emerging capabilities and engines: a backend an engine newly
   supports (vLLM on Vulkan, or on ROCm for the probed gfx target), a change that improves
   concurrent-session throughput, a new engine built for the hardware. A newly found engine is
   weighed in this run like a seed-list engine, and proposed for the seed list under "Proposed
   changes".
4. **The watch items.** Answer each of the descriptor's watch items by name, under its own
   heading: what the sources say now, cited, and what changed since the last report if there is
   one.
5. **The conclusion.** Name the most effective engine platform and configuration to date for the
   host: either an adjustment to the incumbent (a version, a backend, a flag) or a migration to
   another engine, with its verdict by the same rules. Then list the other candidates, ordered
   verify, hold, skip.

An engine change is judged within how the host installs engines, which the probe shows (a
container from the engine's published image, a systemd unit, a package). A candidate that needs
another install method (building an image locally, installing from source on the host) is skip
until the architect changes the method, and the report says what it would take.

#### Verdicts

Every adjustment in steps 5 and 6 takes one verdict:

- **verify**: a source that names its hardware, engine version, and method (an attributed
  benchmark) measured a gain on the same host class and backend, and no such source reports a
  regression. A verify verdict is a reason to measure on this host, not a decision to adopt.
- **hold**: the only claim is release notes, or comes from another hardware class, or the
  upgrade needs a root step with no rollback.
- **skip**: sources show no gain or show a regression, or the upgrade breaks a rule: the policy,
  or an engine change outside how the host installs engines.

Two attributed sources that disagree on the gain are a pause (see "When to pause"); until the
architect answers, the adjustment is hold.

### 7. Models

The models that could serve each declared purpose, judged against the incumbent. The gates and
their checks are in [models.md](models.md); this step says what the section holds.

1. **The incumbents.** For each purpose, the model step 3 mapped to it, with its format and its
   configuration from the `flags` lines. When nothing serves and the probe doesn't show which
   stored model an engine would load (a router's presets live in a file the probe doesn't read),
   the incumbent for a purpose is the stored model mapped to it that ranks first by this step's
   own gates and sort among the stored models, and the report says so.
2. **The candidates.** Every stored model that isn't an incumbent, the newest models of the
   publishers in [sources.md](sources.md), "Models", and what a web search finds. A model whose
   card serves several purposes (a multimodal model that takes text, images, and audio) is a
   candidate for each, and the report says which incumbents it would replace.
3. **The gates, in order**: the policy (the origin rule, then the quantization floor, as
   `docs/policy.md` states them), a fit in the probed memory, and the host's engine serving the
   architecture on its backend. A model that fails a gate stops there and is listed with the gate
   it failed and why.
4. **Excluded on origin.** A model of an origin the policy excludes, or a fine-tune of such a
   base, goes in the section's "excluded on origin" list and never reaches a verdict. Each entry
   cites, inline, the URL and read date of the source that shows its origin.
5. **Sort and judge.** Models that pass every gate sort by published speed on the same hardware
   class, then by the card's evals for the purpose. Each takes a verdict by "Verdicts" (step 6),
   with its citations: a model's gain is measured speed on the same host class and backend, or a
   card eval for the purpose, against the incumbent's.

Order each purpose's rows verify, hold, skip; within a verdict, by speed, then by evals; a model
that failed a gate is skip and comes after the passing skips. When a gate needs a policy value
the document doesn't state, or a model's origin is unclear, pause (see "When to pause").

### 8. Model set

The most effective combination of one model per declared purpose, which the host can serve at
once.

1. **The candidates per purpose**: the top three from step 7 that pass every gate, plus the
   incumbent, so at most four per purpose. The report states this bound and how many sets it
   weighed. A model that serves several purposes can fill each of them in one set, and its memory
   counts once.
2. **Keep the sets that fit together**: the estimated memory of every model in the set, loaded at
   its configured context and slots, leaves the policy's headroom of the GPU-reachable ceiling
   free.
3. **Keep the sets the chosen engine can serve side by side**: the engine is the conclusion of
   step 6. Either one process holds several models (a llama.cpp router), or each model runs in its
   own process with its own memory reservation (vLLM's `--gpu-memory-utilization`, a share of the
   whole device), and the reservations, not the weights, must fit within the headroom.
4. **Recommend** the most effective set kept: compared first by the agent purpose's model (its
   place in step 7's order), then by the other purposes' places summed, then by memory left free.
   Give its estimated memory, marked **estimate** with its method (see [models.md](models.md),
   "Memory estimate"), why it wins, and the runner-up with why it lost. When no set but the
   incumbents fits, say so.

### 9. Verify next

One closing line naming a single item from across the sections: the verify item with the largest
claimed gain on the agent purpose, and among equal claimed gains, the lowest risk first (no root
and rolled back by removing a flag, before a root step with a rollback, before a reboot), with a
one-line reason. When no item is verify, say so, and name the best hold item by the same order,
with what would raise it to verify.

### 10. Proposed changes

Every change the run would make to a document it reads, each with its reason, for the architect
to accept or reject one by one. The run applies none of them (see "What a run writes"). Four
lists, each "None" when empty:

- **Descriptor watch items** (`docs/hosts/<host>.md`): a watch item to add, such as a scan finding
  worth checking each run, or one the probe can't reach (step 3); the descriptor's stale lines
  (step 1) and the purposes a discrepancy answer drops (step 3).
- **Trusted sources** ([sources.md](sources.md)): a source found beyond the list that meets its
  tier's bar (step 4).
- **Blocklist** ([blocklist.md](blocklist.md)): a source met in the run that fails a criterion,
  with what was found (step 4).
- **Engine seed list** (step 6): a newly found engine to weigh every run.

### 11. Write the report

The report is the run's only write: one file per host per date, at
`docs/reports/<host>/<YYYY-MM-DD>.md`, dated the day the run read its sources. A report is never
edited after its date; a later run writes a new report, and reads the last one only to say what
changed. If a report for the host already carries today's date, ask the architect whether this
run replaces it (the same day's run, redone) or waits for tomorrow.

The report's sections, in order:

```markdown
# <host>: hosting upgrades, <YYYY-MM-DD>

## Inventory
The probe's findings, by section, and the descriptor and policy the run read. Says plainly when
nothing serves, and what the run ranks against instead. Lists every probe skip, every fact that
needed root (with the architect's read-out or "declined"), and every pause with its answer.

## Hardware configuration
Step 5's adjustments, verify, then hold, then skip.

## Engines
Step 6: the incumbent, the seed list, the scan, each watch item by name, and the conclusion.

## Models
Step 7: per declared purpose, the incumbent and its candidates, each with its gates, speed,
evals, and verdict; then the models excluded on origin.

## Model set
Step 8: the bound on candidates per purpose, the sets weighed and kept, the recommended set with
its estimated memory and why it wins, and the runner-up.

## Verify next
Step 9's one line.

## Proposed changes
Step 10's four lists.

## Sources
Every source cited, with its tier, URL, and read date.
```

Within every section, items are ordered verify, then hold, then skip.

## When to pause

The run stops and asks the architect, rather than guessing or failing, in four cases:

1. **The probe contradicts the descriptor**: a served model whose purpose isn't declared, or a
   declared purpose nothing serves (step 3).
2. **Sources conflict on a claim**: two sources disagree on a version, a gain, or a support claim.
3. **A policy question arises**: the policy lacks a value a step needs, or a candidate sits on a
   rule's edge (an origin that's unclear, a format the floor doesn't name).
4. **A source's tier is unclear**: the run can't tell whether a source is primary, an attributed
   benchmark, or a lead.

A pause states what was found, cites where (the probe section, the descriptor line, the source),
gives the options with the one the run would take by default, and waits. For example:

```text
Pause: the probe contradicts the descriptor (gb10-1).

The descriptor (docs/hosts/gb10-1.md) declares four purposes: agent, vision, audio, embedding.
The probe finds nothing serving: == endpoints == reports nothing OpenAI-compatible on loopback,
both containers (llama, vllm) are exited, and both units (llama-router, vllm-server) are
disabled and inactive. So no declared purpose is served.

Installed: llama.cpp (ghcr.io/ggml-org/llama.cpp:server-cuda13-b11669), vLLM
(vllm/vllm-openai:v0.32.0), and 14 models in /srv/models.

How should the run go on?
  a. (default) Treat the installed engines and stored models as the incumbent: the inventory says
     nothing serves, and every section ranks against what is installed.
  b. The host is meant to serve fewer purposes: name the ones to drop, and the report proposes
     the descriptor change.
  c. Stop: the host is mid-change, and the run should wait until it serves again.
```

## Facts that need root

The probe reads only what an unprivileged user can. When a step needs a fact only root can read,
the run never runs sudo itself. It prints the exact command, says what fact it needs and why, asks
the architect to run it on the host and paste the output, and continues from the pasted output,
citing it in the report as the architect's read-out. For example:

```text
The report needs the GPU's loaded firmware versions, which only root can read. Run this on
framework and paste the output:

  sudo cat /sys/kernel/debug/dri/1/amdgpu_firmware_info
```

If the architect declines, the run goes on without the fact and the report says which fact is
missing and what it would have decided.

## What a run writes

A run writes nothing except its report: not the descriptor, not the policy, not the skill, and
nothing on the host. Changes it would make to any of them go into the report as proposals.
