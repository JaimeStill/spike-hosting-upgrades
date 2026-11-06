# Measure

`/hosting-upgrades measure <host>` takes what the host's last survey left for local cells to a
decision, under one harness: the host's own items (updates, removals, settings), an engine move
judged by the engine rule, and a candidate screen judged by the keep rule. A survey ranks what the
public record says; a measure settles it on the host. It writes one dated measure record per run,
at `docs/measures/<host>/<YYYY-MM-DD>.md` (rules.md, "Dated records"). The verify findings
(`docs/findings/verify-<host>.md`) and screen records (`docs/screens/<host>/`) that came before it
stay as history and are read as the host's earlier readings.

Measure is interactive and guided. Every command that changes or loads the host is printed before
it runs, run by whoever rules.md, "Who runs what", assigns it, and recorded as run. It applies the
default rules without asking (rules.md, "Default rules") and pauses only as rules.md, "Pause",
says. At its end the host serves the set it served at the start, or the set a verdict adopts.

## 1. Setup

1. Run setup.md, steps 1 to 3, with measure's rules: the inputs, the readiness check, the probe.
   From the probe: the engine and its build, the GPU-reachable ceiling (`== memory ==`), and the
   host's set, one model per purpose, each by its router ID (`== endpoints ==`). This is the set
   the passes measure beside and restore.
2. **The last survey.** Read the host's last report in `docs/reports/<host>/` (rules.md, "Dated
   records"). If the directory holds none, stop and say so: "No survey for `<host>` in
   `docs/reports/<host>/`, so there is nothing to measure; run `/hosting-upgrades survey <host>`
   first." Name the report read, by its path and date.
3. **The earlier readings.** The findings the descriptor lists under "Measurements", and the
   host's verify finding, screen records, and measure records, if any. The first anchors are set
   beside them (rules.md, "Figures").
4. **What moved.** Compare the probe with the report's Inventory and with each item's own "what the
   probe shows". Name every item whose state has moved since the report, cited to the probe
   section that shows it: an update now on the host's channel that wasn't (`== updates ==`), an
   item that is gone (a container, an image, a snapshot), a unit or a container whose state
   changed, a kernel now running or newly installed, a setting now at another value. An item that
   hasn't moved says so. Ask the architect what they ran on the host since the report (an update,
   an autoremove, a regenerated spec), and name each step as they report it, beside the probe
   section that reads it back, or with "not visible to the probe" when none does. Measure doesn't
   research again: a moved item goes to the architect's decision with its movement beside it, and
   a change that would alter its verdict is a pause.

   For example, on framework against its 2026-10-30-2 report:

   ```text
   Moved since docs/reports/framework/2026-10-30-2.md:
     - linux-omarchy: 7.2.15-1 is now on the host's channel (probe == updates ==); the report held
       7.2.14, which hadn't reached it.
   Not moved: the other ten items.
   ```
5. **Blockers, before the first load.** Re-check every entry of the blocker register
   (`docs/blockers.md`) that names this host, as survey.md, "Blocker register", items 1 to 3, say:
   each issue and pull request with `gh issue view` or `gh pr view`, and a merged fix with
   `scripts/fix-in-image.sh` for the host's class. Move each entry's state, upstream line, and
   last-checked date in place, and list the entries in the record with their states. An entry
   whose state moved since the last survey is a pause when it bears on what this measure runs (a
   fix now in the build an engine move would take, a blocker the move would cross); otherwise it
   is noted and the measure goes on. When a pass shows a blocked thing working on a build with the
   fix, the entry becomes **cleared on the host** for this host, citing this record, and is
   deleted once cleared on every host it names. A pass that measures a new blocker's cost adds its
   entry, linked to this record.

## 2. What this measure runs

From the last survey:

- **The host's items**: every verify, take, and hold item in its "Hardware configuration" and
  "System updates and debt". An item listed in two sections by reference (a kernel's row and its
  reboot item, say) is one item. Step 3 takes them to a decision.
- **An engine move**, when the survey's engine conclusion, or its "Verify next" line, is a newer
  build of the engine the host serves. Its candidate is the build rules.md, "Default rules", item 1,
  gives, which the record names with why. Step 6.
- **A candidate screen**, of one candidate the architect names at the start, with the section it
  loads on: one in the survey's "Needs measurement", or the model its "Verify next" names. Step 7.

The engine and model rows the survey ranks verify or hold, other than the ones this measure runs,
are listed by name, as left for a later measure, with no decision asked on them. Each engine move
and candidate screen is its own pass on one state (rules.md, "Cells"): the engine move runs first,
so a candidate's pass runs on the build that stays. With neither named, measure settles the host's
items, lists the candidates, and stops before any load.

## 3. The host's items

List every item from step 2's first bullet, ordered as the survey orders them (verify, take, hold,
then by section), each with its verdict, the survey's recommendation, and its movement from step
1. Ask the architect's decision on each:

- **apply**: make the change the item names.
- **remove**: take the item off the host (an image, a container, a stored model, a cache).
- **close**: no action, with the architect's reason in a line (not on the host's channel, a
  headroom met, a section no agent loads).

Record each decision with its date, as the architect's. For each item to apply or remove, print:

- **The exact commands**, in the order they run, each in the form that runs it from this machine
  (`ssh <host> <command>`, or `ssh -t <host> sudo <command>` for root). They come from the survey's
  row (its remedy and rollback), checked against the probe today. A removal its tool can rehearse
  is rehearsed first (a dry run), and the dry run's output goes to the architect before the
  removal.
- **Who runs each step** (rules.md, "Who runs what").
- **The rollback**, as commands, and whether it needs root.
- **Whether a reboot is needed.** The changes that need a reboot share one reboot, after which the
  probe reads them back: the new kernel running, each engine up with its port published (survey.md,
  "Boot-order check").

**An offered update with no known rollback is an escalation** (rules.md, "Pause"): a firmware
update `fwupdmgr` lists, a BIOS, anything else with no downgrade path. Measure prints it, says it
has no rollback, and asks the architect, who decides it outside the defaults. An approved one gets a
reboot of its own, after the host's other changes have booted cleanly, so a failure is traceable to
it.

Order the work so that each pass measures one state: the host stack first (its updates, its
settings, the reboot, a probe), then any approved escalation and its reboot, then the engine move,
then the candidate screen, then the removals, each read back by the probe.

## 4. Gates before any load

Re-check, under the policy as it reads today, the gates of every model a pass loads that the
survey didn't measure here: the candidate a screen measures, and, for an engine move, every model
its cells load, one per purpose with cells. Each by [models.md](models.md):

1. **Origin** ("Origin"): the evidence chain, read fresh, with the screening-list script
   (`.claude/skills/hosting-upgrades/scripts/screen.sh "<name>" ...`).
2. **Artifact integrity** ("Artifact integrity"): the format of the file the host would load, from
   the probe's `magic` line for a stored file, or the Hub's per-file scan or
   `.claude/skills/hosting-upgrades/scripts/magic.sh "<org>/<repo>" "<file>"` for one not stored,
   and its projector's the same way. Then the chat-template check: the GGUF's embedded template
   against the publisher's, read from the repository's `chat_template.jinja` when it has one
   (Google keeps it there, and its `tokenizer_config.json` carries no `chat_template`), and
   otherwise from `tokenizer_config.json`'s `chat_template`; a single trailing newline is no
   difference (`jq -r` adds one), and any other difference is quoted.
3. **The quantization floor** ("Quantization floor"): the path its build takes, and the publisher's
   quality statement quoted for path 1.
4. **Fit** ("Gate 2: fit"): its memory estimate at its purpose's load target against the probed
   ceiling and the policy's headroom, and the model set it would join.

Each gate cites what it read, with its date (rules.md, "Citing"). A candidate that fails a gate is
not measured, and the record names the gate and what failed it. A model an engine move's cells need
that fails a gate is a pause (rules.md, "Pause"): its purpose's cells wait until the architect names
another model for it.

For a candidate screen, beside its gates:

1. **The conform profile for the host's class**, `bench/conform/<class>.toml` (`strix-halo` for a
   Strix Halo host, `nvidia-cuda` for a GB10), when the candidate serves the agent purpose,
   validated by spike-model-hosting's profile loader from its checkout, read-only (the session, no
   root), where `<project>` is this project's root:

   ```sh
   cd <spike-model-hosting checkout> && mise exec -- go run ./hosting/cmd/profile validate <project>/bench/conform/<class>.toml
   ```

   It prints `<path>: valid`. The profile names the router IDs of the candidate's set: the
   candidate's section for each purpose it would take, and the host set's models for the others. A
   profile whose IDs differ from the router's `/models`, or that fails to validate, is a pause.
2. **The candidate's section** on the host's clone of the repository that owns the preset
   (spike-model-engines' `host/llama-preset/models.ini`), from the branch that adds it, pushed over
   ssh and the router restarted so it reads it (the session, no root), each command printed before
   it runs; the router's `/models` reads the section back, unloaded.

## 5. Build gate

Before an engine move's cells: the class's image exists for the build (a registry read), and after
the move every preset section loads, one at a time, before any cell; a failed load rolls back at
once (rules.md, "Default rules", item 1).
TODO(slice 3): the gate's commands, its record rows, and its rollback.

## 6. The engine move

An engine move measures the host's set on two builds of the engine, in one pass, in this order:

1. **The incumbent build's cells**, on the build the probe shows serving.
2. **The move to the candidate build**, through spike-model-engines' `engines` suite, run from the
   host's clone of it, with the candidate's version as its argument (the session's step, no root):

   ```sh
   ssh <host> 'cd <clone> && host/engines <engine> update <candidate build>; echo "exit $?"'
   ```

   `<engine>` is the suite's name for how the host runs the engine (`llama` for llama.cpp in a
   container). The update pulls the candidate's image before it replaces the container, so a failed
   pull leaves the incumbent serving, and it refuses while another engine serves. The new container
   starts with no model loaded. Read back the build it runs, by the probe's `== engines ==` and the
   engine's own report of its build. Then the build gate (step 5).
3. **The same cells on the candidate build**, in the same order, each model from a fresh load
   (rules.md, "Fresh loads"), so the two builds' cells differ only by the build.

**The cells.** One pair per purpose the host serves whose load the project's `bench/` has
scenarios for, on the model that serves the purpose in the host's set (with step 3's decisions
applied), each model gated (step 4):

- agent: anchors A and B, on the agent purpose's section;
- vision: shape A and B, on the vision purpose's model;
- transcription (audio): ASR A and B, on the audio purpose's model;
- a purpose with no scenario (embedding) has no cells, and the record says so.

Each cell's row is as rules.md, "Figures", gives it for two builds. The reasoning check runs on each
build's ASR cells, and the transcripts compare the audio model's ASR B on each build (rules.md,
"Reasoning check", "Transcripts").

Print the pass before it runs. For example, on gb10-1 against its 2026-10-31 report:

```text
Engine move: llama.cpp b11669 -> b12033 (server-cuda13), kernel 7.0.0-1024, one pass.
Each cell: GuideLLM 0.8.1 from this machine, http://gb10-1:8080, timeout 10m, fresh load.
  b11669   1 Anchor A  gpt-oss-120b MXFP4, agent section    1 x 8, 512 / 256
           2 Anchor B  gpt-oss-120b MXFP4, agent section    4 x 32, 512 / 256
           3 Vision A  Gemma 4 26B-A4B QAT Q4_0             1 x 8, 512 / 256, thinking on
           4 Vision B  Gemma 4 26B-A4B QAT Q4_0             4 x 32, 512 / 256, thinking on
           5 ASR A     Gemma 4 E4B Q8_0                     1 x 8 LibriSpeech clips, <=256 out
           6 ASR B     Gemma 4 E4B Q8_0                     4 x 32 clips, <=256 out
  move     ssh gb10-1 'cd <clone> && host/engines llama update b12033; echo "exit $?"'
  gate     every preset section loaded, one at a time (step 5)
  b12033   7-12 the same six cells
Embedding: no cells (no scenario). Verdict: the engine rule (step 8).
```

## 7. The candidate screen

A candidate screen measures one candidate beside the host's set in one session, in two phases:

- **Phase 1** runs on the host's set as served.
- **Phase 2** runs on the candidate's set: the candidate's section serving each purpose it would
  take, with those purposes' models unloaded, and the host's models for its other purposes loaded.

Every cell follows rules.md, "Cells", "Fresh loads", and "Caps". The candidate's agent tiers and
conform share one fresh load of its section; every other cell runs from its own. The host's set is
restored at the end (step 9).

The cells, for an agent candidate that would also take vision; a candidate of another purpose runs
that purpose's rows, and anchors A and B in both phases, so the agent's anchors after the change
are set beside those before it:

| Phase | Cell | Model, section | Scenario | Load | Informs |
|---|---|---|---|---|---|
| 1 | Anchor A, B | the set's agent, on the anchor section the host's earlier readings used | `anchor-a.yaml`, `anchor-b.yaml` | 1 × 8, 4 × 32, 512 / 256 | the incumbent's decode and TTFT, and concurrency |
| 1 | Long A | the set's agent, on the set's own section | `long-a.yaml` | 1 × 4, 8,192 / 512 | prefill and TTFT beside the candidate's |
| 1 | Long B | the same, with the whole set loaded | `long-b.yaml` | 4 × 16, 8,192 / 512 | streams at agent prompt size; the set's memory read after |
| 1 | Sweep | the set's agent, on a section with a slot for each of the sweep's streams | `sweep.yaml` | 1/4/16/32 streams, 512 / 256, 60 s a level | capacity at the load target |
| 1 | Vision A, B | the set's vision model, on its section | `vision-a.yaml`, `vision-b.yaml` | 1 × 8, 4 × 32, 720p + 200 / 64 | the reasoning count and the vision baseline |
| 2 | Cold start | the candidate's section | the router's API | a load from unloaded, timed | local only |
| 2 | Shape A, B | the same | `shape-a.yaml`, `shape-b.yaml` | 1 × 8, 4 × 32, 512 / 256, thinking on | the decode floor, beside anchors A and B |
| 2 | Long A | the same | `long-a.yaml` | 1 × 4, 8,192 / 512 | the prefill and TTFT floors |
| 2 | Long B | the same, with the candidate's set loaded | `long-b.yaml` | 4 × 16, 8,192 / 512 | the stream floor; the set's memory read after |
| 2 | Sweep | the same | `sweep.yaml` | as phase 1's | capacity at the load target |
| 2 | Vision A, B | the same | `vision-a.yaml`, `vision-b.yaml` | as phase 1's | the vision floor and the reasoning count |
| 2 | BFCL single | the same, one fresh load | spike-model-hosting's tier list | 100 samples, 4 in flight | the single-turn floor |
| 2 | BFCL multi | the same load | spike-model-hosting's tier list | 20 samples, 4 in flight | the multi-turn floor |
| 2 | Conform | the same load | `bench/conform/<class>.toml` | Pi, k = 5, 9 capabilities | tool reliability and the API surface |

The anchor section a host's earlier readings used may not be the set's own (framework's anchors ran
on the 4-slot section, with the set's agent unloaded meanwhile); a section that gives a slot fewer
than 8,704 tokens can't hold a long cell, so the long cells run on the set's own section on every
host. A model whose own agent-tier runs set the policy's floors (gpt-oss-120b's two runs, less their
spread, `docs/policy.md`, "Agent quality bar") doesn't run them again.

TODO(slice 3): the monitors during cells (GPU clocks and throttle reasons), the memory floor that
stops a long run with readouts at a set interval, and the sweep's completed-request and
every-token figures.

**The agent tiers**, spike-model-hosting's, run from this machine in its checkout, read-only: its
consumers mise environment, its suites project (Inspect AI and inspect_evals' stock BFCL task), and
its seeded tier lists, with every output and cache in this project's ignored `.state/`, so the
checkout is never written. At the router's defaults (the card's sampling, the template's default
reasoning), with parallel tool calls allowed, 4 requests in flight, the count the floors were
measured at. A tier runs its whole list: no `--bar`, so no early stop. A new tool's first walk is
the architect's (rules.md, "Who runs what"); after it, the session runs them:

```sh
cd <spike-model-hosting checkout>/evaluation && S=<project>/.state/measure/<host> && PYTHONDONTWRITEBYTECODE=1 UV_PROJECT_ENVIRONMENT=$S/../suites-venv HF_HOME=$S/../cache/huggingface INSPECT_EVALS_CACHE_DIR=$S/../cache/inspect_evals MISE_ENV=consumers timeout 15m mise exec -- uv run --project suites --locked --no-python-downloads python suites/agent_quality.py eval --router http://<host>:<port> --model <section> --tier bfcl-<single|multi> --list tiers/agent-bfcl-<single|multi>.txt --slots 4 --output $S/bfcl-<single|multi>
cd <spike-model-hosting checkout>/evaluation && MISE_ENV=consumers timeout 10m mise exec -- go run ./cmd/evaluate conform -router http://<host>:<port> -profile <project>/bench/conform/<class>.toml -consumers pi -k 5 -state <project>/.state/measure/<host>/conform
```

A tier's figure is its accuracy over its whole list, read from the Inspect JSON log the tier leaves
under its output directory. Conform's figure is its table: each capability's trials passed of 5,
and the invalid requests. A tier whose request carries no token cap can run on; a reply past the
tier's cap is a cap hit (rules.md, "Default rules", item 3).

**The local-only checks**, each recorded with its command as run:

- **Cold start**: the router's `/models/load` for the candidate's section from unloaded, timed until
  `/models` reads it loaded (the session, no root), as spike-model-engines' setup times a load.
- **Memory**, read warmed after each set's long B cell, with the set still loaded: on a GB10,
  `ssh <host> grep ^MemAvailable /proc/meminfo`; on a Strix Halo, the GTT in use,
  `ssh <host> 'cat /sys/class/drm/card*/device/mem_info_gtt_used'`.
- **Each slot's context**, read back from the router for the candidate's section:
  `curl -s "http://<host>:<port>/props?model=<section>" | jq '{n_ctx: .default_generation_settings.n_ctx, total_slots}'`.
- **The API surface**: chat completions with tools under `tool_choice` `required`,
  `response_format` `json_schema`, and image input, each answered without error, read from
  conform's recordings (its state's `conform/wire/`) and one request each against the section.
- **Whether a feature works**: images on the candidate's section, and replies with no unprompted
  reasoning.

The reasoning check runs on every vision and ASR cell, both phases' (rules.md, "Reasoning check"),
and for a transcription candidate the transcripts compare its ASR B with the incumbent's (rules.md,
"Transcripts").

Print the pass before it runs. For example, on framework:

```text
Candidate screen: framework, llama.cpp b11960 (server-vulkan), Gemma 4 26B-A4B QAT on its agent section.
Each cell: GuideLLM 0.8.1 from this machine, http://framework:8080, fresh load, the session.
  phase 1, the host's set
   1 Anchor A     gpt-oss-120b, 4-slot section *         1 x 8, 512 / 256          timeout 10m
   2 Anchor B     the same                               4 x 32, 512 / 256         timeout 10m
   3 Long A       gpt-oss-120b, the set's section        1 x 4, 8,192 / 512        timeout 10m
   4 Long B       the same, the set loaded; GTT after    4 x 16, 8,192 / 512       timeout 10m
   5 Sweep        gpt-oss-120b, 16-slot section          1/4/16/32, 60 s a level   timeout 10m
   6 Vision A, B  26B-A4B QAT, vision section            1 x 8 / 4 x 32, 720p      timeout 10m each
  phase 2, the candidate's set (gpt-oss-120b and the vision section unloaded)
   7 Cold start   26B-A4B QAT, agent section             API load, timed           the session
   8 Shape A, B   the same                               1 x 8 / 4 x 32, thinking  timeout 10m each
   9 Long A       the same                               1 x 4, 8,192 / 512        timeout 10m
  10 Long B       the same, the set loaded; GTT after    4 x 16, 8,192 / 512       timeout 10m
  11 Sweep        the same                               1/4/16/32, 60 s a level   timeout 10m
  12 Vision A, B  the same                               1 x 8 / 4 x 32, 720p      timeout 10m each
  13 BFCL single  the same, one fresh load               100 samples, 4 in flight  timeout 15m
  14 BFCL multi   the same load                          20 samples, 4 in flight   timeout 15m
  15 Conform      the same load                          Pi, k = 5                 timeout 10m
  * the set's agent unloaded meanwhile. The set restored at the end, read back by /models and the probe.
```

## 8. The verdict

Each rule states what it gave on each condition, with its figures, then the outcome; the architect
may overrule it, and the record gives the overrule and its reason beside what the rule gave. "Run
noise" below is rules.md, "Figures".

**The engine rule.** For an engine move, adopt the candidate build only when all four hold:

- every cell on the candidate is within run noise of the same cell on the incumbent, or ahead of
  it, by the cell's figure (output tok/s, or audio seconds a second for an ASR cell)
- every cell of the pass, on both builds, holds its full request count
- the audio model's ASR B word differences on the candidate are within the incumbent's total plus
  run noise's share of the reference words
- the reasoning check on the candidate's ASR cells counts no more replies than on the incumbent's,
  for each of its two counts (the thought channel, the text)

Otherwise roll back. A gain need not exceed run noise: engines stay current (the experiment's
rule), so a candidate that holds every cell is adopted.

**On adopt**, the candidate serves, and measure prints its rollback exactly: the suite's update to
the incumbent build, the session's step, no root:

```sh
ssh <host> 'cd <clone> && host/engines <engine> update <incumbent build>; echo "exit $?"'
```

The rollback pulls the incumbent build's image again, since the update to the candidate removed
every image of every other build, server and full, in every flavor, and every untagged image
(spike-model-engines `host/engines-llama-update`, `llama_remove_images` in `host/llama.sh`). Forward
again is the same update with the candidate build. **On roll back**, the session runs that same
update now, and the probe reads the incumbent build back as serving. Either way, the host's set is
then loaded on the build that stays, by rules.md, "Fresh loads".

**The keep rule.** For a candidate screen, keep only when every condition that applies to the
candidate's purposes holds; otherwise drop:

- **Gates**: every gate passes (step 4), and no open tracker report has the engine's parser
  rejecting the model's tool calls.
- **Capability**: for the agent purpose, BFCL single-turn at least 0.630 and multi-turn at least
  0.325, each on its whole list (`docs/policy.md`, "Agent quality bar"), and conform through Pi
  passes every applicable capability 5 of 5, with 0 invalid requests. For transcription, the
  candidate's ASR B word differences are within the incumbent's total plus run noise's share of the
  reference words.
- **Completeness**: every cell holds its full request count.
- **Speed** (`docs/policy.md`, "Speed floors"), for each purpose the candidate takes: for the agent,
  shape A at least 20 output tok/s; long A prefill at least 500 tok/s, with TTFT median at most 20
  s; long B ITL median at most 100 ms (each stream at least 10 tok/s); for vision, every vision A
  and B request answered within 10 s. The set's same-session figures go beside them.
- **Capacity**, at the load target (rules.md, "Load targets"): the highest sweep level where the
  candidate's ITL median stays at 100 ms or less is at least its purpose's target concurrency and
  at least the incumbent's, and every one of the candidate's slots holds the target's context, as
  the router reports it.
- **Memory**: the candidate's set leaves the policy's headroom (`docs/policy.md`, "Memory
  headroom") and uses no more than the host's set read the same way in the same session.
- **Reasoning**: on the candidate's vision and ASR cells, no more replies reasoned than on the
  incumbent's, for each of the two counts.
- **Anchors**, for a candidate of a purpose other than the agent: anchors A and B in phase 2 are
  each within run noise of phase 1's.

A keep is recorded, and the host's set is restored either way (step 9). Adopting a kept candidate
into the served set is the architect's decision, recorded with its date; a task whose brief allows
it changes the set by rules.md, "Fresh loads". On adoption the incumbent the candidate replaces is
retired: the engine serves the candidate, and the incumbent is unloaded. Its files leave the store
only once the walkthrough confirms the candidate, with their rollback (a download) printed.

## 9. The end state

Restore the host's set by rules.md, "Fresh loads", then read it back by the router's `/models` and
the probe: the host serves what it served at the start, or the set a verdict adopted. A clone moved
to a branch for the pass returns to its default branch with the router restarted, unless a keep
leaves the branch's pull request open; the brief says which.

## 10. Write the record

The record is measure's own write: a dated record at `docs/measures/<host>/<YYYY-MM-DD>.md`
(rules.md, "Dated records"). Beside it, measure updates only the blocker register's entries for
this host in place (step 1, item 5). It is written once, when the measure ends (after the end state is read
back, or when the architect stops it, saying where it stopped), and never edited. A measure stopped
before any decision writes no record unless the architect asks for one. It writes nothing else: not
the survey, the pool, the descriptor, the policy, the skill, or its conform profiles, and nothing on
the host beyond the steps the record gives as run.

TODO(slice 3): the shipped step helpers (load, unload, run a cell, summarize, memory, readout,
watch), sourced and called one step at a time, every command logged by xtrace with a timestamped
prompt into ignored state, and the record quoting that log for its commands as run.

The record's sections, in order; a section with nothing in this run says "None":

```markdown
# <host>: measure of <report path>, <YYYY-MM-DD>

## Inputs and probe
The survey read, by its path and date; the descriptor (its purposes and load targets) and policy
read; the readiness rules found missing and the answer; the probe's date and inventory; every item
that moved since the survey, cited to its probe section; the engine move and candidate this measure
runs, with why; and the rows left for a later measure (step 2).

## Decisions
One row per host item, in step 3's order: the item, its survey verdict, the architect's decision
(apply, remove, or close) with its date, the reason for a closure, and the outcome.

## Host stack
Each applied item: every command exactly as run, who ran it (the architect, with root, or the
session), its output where it settles something, its rollback, and the reboot; each escalation,
with the architect's decision; then the probe that read the stack back.

## Gates
Each model gated before its load (step 4), each gate with what it read and its citation, and the
conform profile's validation as run.

## Engine move: <engine> <incumbent build> to <candidate build>
The candidate and why (rules.md, "Default rules", item 1: the builds passed over, with the reads
that showed them unimaged or failing). The build gate (step 5). The pass's routing check, its kernel
and host stack, and `tailscale ping -c 1`. Every command exactly as run: the incumbent build's
cells, the move through the suite with its output and the build read back, the candidate build's
cells. One row per cell, as rules.md, "Figures", gives it for two builds. A purpose with no cells,
named with its reason.

## Candidate screen: <candidate>, <section>
The routing check, the engine build and host stack, and `tailscale ping -c 1`. Every command exactly
as run, in order, with who ran it. Phase 1's cells, then phase 2's, each row as rules.md, "Figures",
gives it, with the earlier claims beside it. Each agent tier's command as run, its accuracy on its
whole list against its floor, and its time; conform's table, invalid requests, and fit. The local-
only checks: cold start, each set's memory read-out, each slot's context as the router reports it,
the API surface, and whether each feature works, each with its command as run.

## Transcripts
For a transcription purpose: the command as run, each model's (or each build's) word differences,
the reference words, and the pairs that differ.

## Reasoning
The reasoning check as run, both counts for each cell it ran on, each flagged reply quoted by its
opening.

## Retries and cap hits
Each time a default rule applied (rules.md, "Default rules"): the step, what failed or hit its cap,
the retry as run, and what the verdict's rule read from it.

## Verdict
For each pass, its rule (the engine rule or the keep rule), what it gave on each condition with its
figures, the outcome (adopt or roll back; keep or drop), and any overrule by the architect with its
reason beside what the rule gave. On an engine adopt, the rollback exactly as printed; on roll
back, the update as run and the probe reading the incumbent back. On a candidate's adoption, the
architect's decision with its date.

## The claim beside the anchors
The published claim the survey cited for each measured item, with its source, beside what this
host measured, and how far the source held. The first anchors beside the host's last earlier
readings, and any move beyond run noise, named as a finding.

## Removals
Each removal: the dry run, the command as run, the space freed, its rollback, and the probe reading
it back as gone.

## Where <retired model> still lives
On a candidate's adoption only: a table of every place that still names the retired model and that
measure didn't change (a preset, a script, a guide, a finding, another host, a consumer's model
list), with its repository and path, addressed to whatever comes to own the host tooling.

## Closures
Each item closed with no action, with its reason: the standing closures below, and any the
architect makes in this measure.

## End state
The host's set, read back by `/models` and the probe; the clone's branch and the router's restart.

## Sources
Every source cited, with its tier, URL, and read date.
```

**The standing closures**, which every record's "Closures" carries until the architect reopens one
(the architect's decisions, 2026-11-04):

- **E4B QAT's logit-bias ban on `<|channel>`**: closed, no action. Its unprompted reasoning was in
  the reply's plain text, which a ban on the channel token can't reach, and Google has published no
  revision of `google/gemma-4-E4B-it-qat-q4_0-gguf` since the one verify-framework rolled back (sha
  4b4a2c1d, 2026-07-17); E4B QAT is revisited only on a revision (framework's descriptor's watch
  item).
- **12B QAT's and 31B QAT's reasoning check**: closed, no action. Neither serves a purpose nor is a
  measured candidate, so the check runs on the measured candidates alone; both are named as not
  checked.
