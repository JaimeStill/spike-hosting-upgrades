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

## The harness

Every step that loads the host, runs a cell, or reads the host during cells goes through one
set of shipped helpers, [scripts/measure-lib.sh](scripts/measure-lib.sh), and every command they
run is logged. The same helpers serve an engine move, a candidate screen, and a settings check.

### Step helpers

The helpers are bash functions, sourced from the project root with the host's SSH short name (and
the router's port, 8080 by default):

```sh
source .claude/skills/hosting-upgrades/scripts/measure-lib.sh <host>
```

Sourcing only defines them and starts the command log; it reads nothing from the host. Each call
is one step, printed before it runs and run in the architect's view by whoever rules.md, "Who runs
what", assigns it. None runs a benchmark on its own or chains cells: the pass's order is the
procedure's, one call at a time. The session's shell doesn't keep functions between its commands,
so each command it runs starts with the `source` line, as in
`source .claude/skills/hosting-upgrades/scripts/measure-lib.sh framework && load <section>`; the
architect's own shell sources it once.

| Helper | What one call does |
|---|---|
| `loaded` | Lists the sections the router has loaded or loading (`/models`). |
| `load <section>` | `/models/load` for the section, waits until `/models` reads it loaded (up to `MEASURE_LOAD_WAIT`, 600 s), and prints the time it took (a cold start, when the section was unloaded) and the loaded instance's serving arguments (`--ctx-size`, `--parallel`, `--kv-unified`, `--cache-ram`, `--no-cache-idle-slots`, the checkpoint flags). A failed load returns 1. |
| `unload <section>` | `/models/unload` for the section, and waits until `/models` reads it unloaded. `unload --all` does so for every loaded section, one at a time. |
| `cell <name> <scenario> [<section> <tokenizer>]` | One GuideLLM cell, as rules.md, "Cells", gives its command, from `bench/<scenario>.yaml`, capped at `MEASURE_CELL_CAP` (10m), under `watch`; its result is `.state/measure/<host>/<name>.json`, its output `<name>.log`. A name already used is refused, so a rerun takes a new name. It ends with `summarize <name>`. |
| `tier <name> <bfcl-single\|bfcl-multi> <section> [<N>]` | One of spike-model-hosting's BFCL tiers ("The agent tiers"), capped at `MEASURE_TIER_CAP` (15m), under `watch`, its Inspect log under `.state/measure/<host>/<name>/`. With `<N>`, the tier's list cut to its first N samples, its header kept. It ends with `summarize <name>`. |
| `conform <name> <class> [<k>]` | One conform run through Pi on `bench/conform/<class>.toml` (k = 5 by default), capped at `MEASURE_CONFORM_CAP` (10m), under `watch`. |
| `summarize <name>` | A result's figures: for a cell, each benchmark's request counts and whether it is full, its completed-request and every-token output figures (rules.md, "Figures"), TTFT and ITL medians, and audio seconds a second for an ASR cell; for a tier, samples done and passing, each sample's time, the largest reply with its sample, and the cap hits (rules.md, "Caps"); then the step's exit and its watch: the lowest memory available, and each distinct GPU reading with its count. |
| `memory` | One read-out on the host: the memory available to the GPU, where it is read, and the floor. |
| `routing` | rules.md's routing check ("Routing"), its three commands as given there, for the host and the router's port: the host's `.lan` A and AAAA records, what the bare name resolves to, and 50 connects to `/health`. Reading the result against the check is the caller's. |
| `readout [<since>]` | The router's log since a time (default 5 minutes ago): idle-slot saves, prompt saves, context checkpoints created, and the decode rate of replies of 90 tokens or more (mean, min, max); then `memory`. |
| `watch <name> <command...>` | Runs one command with the monitor ("During cells"). `cell`, `tier` and `conform` run under it; any other long step the brief caps is called through it. Its exit is the command's (124 at the cap), written to `<name>.exit` with the floor's reason when the floor stopped it. |
| `image <class> <build>` | Whether the class's server image exists for the build on ghcr.io, by the registry's manifest check (an anonymous pull token, as `scripts/fix-in-image.sh` takes, then a HEAD of the tag's manifest). |
| `gate` | The build gate's loads ("Build gate"): every section the router lists, loaded alone, one at a time. |

`watch`, while it is defined, shadows procps' `watch` in that shell.

### The command log

Sourcing turns on xtrace in the shell, with a timestamped prompt,
`PS4='+ $(date -Is) ${FUNCNAME[0]:+${FUNCNAME[0]}: }'`, and sends its lines through
`BASH_XTRACEFD` to `.state/measure/<host>/<YYYY-MM-DD>.log` (ignored, under `.state/`), appended
each time it is sourced. Every command after it is logged with its time: a line with no helper's
name is a call the session or the architect made (`load gpt-oss-120b-MXFP4-set-a`), and a line
naming one is a command that helper ran (`load: curl -s --max-time 30 -X POST
http://framework:8080/models/load ...`, `cell: env -C ... MISE_ENV=bench timeout 10m mise exec --
guidellm run -c bench/anchor-a.yaml ...`). A poll or a sampling loop logs one line saying what it
does, not each pass.

What a helper prints to standard output lands in the log too, as the terminal shows it, each line
marked `= <ISO time> <helper>: ` so it reads apart from the `+` lines of xtrace: a load's time and
serving arguments (`= 2026-11-06T10:12:40-05:00 load: load gpt-oss-120b-MXFP4-set-a: loaded in
41.3 s`), a cell's or a tier's figures, a readout's decode figures, a memory read-out, the routing
check's lines. A helper called inside another (`cell`'s `watch` and `summarize`) marks its lines
under the outer one's name, once. What a helper prints to standard error, and what a command
outside the helpers prints, isn't marked; `set +x` stops both.

The log holds no tailnet address, so a record can quote it (STANDARDS.md rules out committing
tailnet identifiers): `routing` looks up the host's tailnet addresses and compares the bare name's
untraced, and logs only its labels (`tailnet`, `NOT-TAILNET`) on its `= ` line. A command outside
the helpers that prints or expands an address is the session's to keep out of the log.

A pass's steps before its first helper are logged only if the helpers are sourced first, so they
are (step 1): readiness, the probe, `tailscale ping`, the blocker checks (`gh issue view`,
`gh pr view`, `scripts/fix-in-image.sh`), an engine move and a preset change each run in a shell
that has sourced them, and the routing check is the `routing` helper. A command that starts with
the `source` line no longer matches an exact rule of the project's settings (the probe's), so it
asks.

Reading a finished run's results again (`summarize` on a cell's name after the pass) sources the
helpers read-only, so the day's log doesn't gain a second copy of figures already in it:

```sh
MEASURE_LOG=off source .claude/skills/hosting-upgrades/scripts/measure-lib.sh <host> && summarize <name>
```

With `MEASURE_LOG=off` sourcing opens no log and leaves xtrace off; `summarize`, `loaded`,
`memory`, `readout`, `routing` and `image` run, and the helpers that load the host (`load`,
`unload`, `watch`, `cell`, `tier`, `conform`, `gate`) refuse. The record's "Commands as run"
quotes the log ("Write the record").

### During cells

`watch` is the monitor every cell and long step runs under:

- **GPU clocks and limits**, sampled every `MEASURE_SAMPLE_EVERY` (10 s) over SSH into
  `.state/measure/<host>/<name>.watch.tsv`: on a GB10, nvidia-smi's SM clock, its maximum, the
  active throttle reasons (`clocks_throttle_reasons.active`, a bitmask, where 0x0 is none),
  temperature, power and utilization; on a Strix Halo, amdgpu's sysfs: the current sclk level
  (`pp_dpm_sclk`), `gpu_busy_percent`, and hwmon's edge temperature and power. Each sample also
  reads the memory available. `summarize` gives each distinct reading with its count, so a cell
  that ran throttled, or on a clock below the rest, shows beside its figure; the record gives
  them, and a cell whose readings differ from its pair's is named.
- **The memory floor** (rules.md, "Caps"): set `MEASURE_FLOOR_GIB` to the policy's headroom on
  the probed ceiling before the first `watch` (12.2 on gb10-1, 11.2 on framework); `watch`
  refuses to start without it. When a sample reads less available, `watch` stops the command and
  everything it started, and records the floor's reason; the stop is a cap hit.
- **Readouts** every `MEASURE_READOUT_EVERY` (300 s, the screen's 5 minutes) while the command
  runs, and one for the whole run at its end: `readout` over the interval just past.

### The sweep's figures

Each sweep level's row gives both figures rules.md, "Figures", defines, as `summarize` prints
them: the completed-request figure and the every-token figure, with the level's completed,
incomplete and errored counts. The capacity condition reads each level's ITL median.

## 1. Setup

1. **The helpers first.** Source the helpers for the host ("Step helpers"), which starts the
   day's command log, before anything runs on the host or its network path; each command from
   here on runs in a shell that has sourced them, so the probe, the routing check (`routing`) and
   `tailscale ping` are in the log ("The command log"). Then run setup.md, steps 1 to 3, with
   measure's rules: the inputs, the readiness check, the probe.
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
6. **The harness.** With the helpers sourced since item 1, set the memory floor from the probe's
   ceiling (`== memory ==`) and the policy's headroom: `MEASURE_FLOOR_GIB`, 10% of the ceiling
   under today's policy. Read the descriptor's "Run noise": its within-session and across-days
   spreads, and which are provisional (rules.md, "Figures"). A descriptor with none is a pause.

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
- **A settings check**, of a served section's keys that a decision left owed a measurement on
  this host (a key the shared preset gave it unmeasured here), or that the survey's configuration
  review ranks verify: the section with and without the keys, on the same build, beside the
  anchors' repeats. "A settings check", after step 7.

The engine and model rows the survey ranks verify or hold, other than the ones this measure runs,
are listed by name, as left for a later measure, with no decision asked on them. Each engine move,
candidate screen, and settings check is its own pass on one state (rules.md, "Cells"): the engine
move runs first, so the other passes run on the build that stays. With none of them named, measure
settles the host's items, lists the candidates, and stops before any load.

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
once (rules.md, "Default rules", item 1). The gate tests what the move can break before a cell
spends time on it: b12125 had no image for gb10, and b12124 couldn't resolve Google's QAT
sections (`docs/screens/gb10-1/2026-11-05.md`, "The engine move").

1. **The image**, before the move, from this machine (the session; it reads only), for the
   class (`gb10` or `strix-halo`) and the candidate build:

   ```sh
   image <class> <candidate build>
   ```

   It prints `exists` or `NOT FOUND`. A build with no image is passed over, and the newest imaged
   build older than it and newer than the incumbent becomes the candidate (rules.md, "Default
   rules", item 1); `scripts/fix-in-image.sh` and the survey's currency read name the builds, and
   `image` confirms the one taken.
2. **The move** (step 6, item 2), and the build read back.
3. **Every section loads**, after the move and before any cell (the session, no root):

   ```sh
   gate
   ```

   It unloads every section, then loads each section the router lists, alone, one at a time,
   reading each back loaded (with its time and arguments) and unloading it before the next. It
   stops at the first section that fails to load, naming it. The build gate's failed load is
   not retried ("Default rules", item 2, retries a cell's load, not the gate's): the move rolls
   back at once, by the suite's update to the incumbent build, the session's step, no root:

   ```sh
   ssh <host> 'cd <clone> && host/engines <engine> update <incumbent build>; echo "exit $?"'
   ```

   then the probe reads the incumbent back as serving, the host's set is loaded again by rules.md,
   "Fresh loads", and the next candidate, if any is left, starts its own pass from the image read.
   The candidate's cells don't run.

**The record's rows**, under its engine move: one row for the image read (the build, the image
tag, `exists` or `NOT FOUND`, the read's time from the log), one per build passed over with its
reason, and one per section the gate loaded (the section, `loaded` or `failed`, its load time,
and for a failure the router's error from `/models` or its log); then the rollback as run, when
the gate failed, with the probe that read the incumbent back.

## 6. The engine move

An engine move measures the host's set on two builds of the engine, in one pass, in this order:

1. **The incumbent build's cells**, on the build the probe shows serving.
2. **The move to the candidate build**, once `image` has read the candidate's image (step 5,
   item 1), through spike-model-engines' `engines` suite, run from the host's clone of it, with
   the candidate's version as its argument (the session's step, no root):

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
- vision: shape A and B (`shape-a.yaml`, `shape-b.yaml`), on the vision purpose's model: the
  anchors' text load, so a build's decode change shows on that model as it does on the agent's; the
  image cells (`vision-a.yaml`, `vision-b.yaml`) are the candidate screen's (step 7);
- transcription (audio): ASR A and B, on the audio purpose's model;
- a purpose with no scenario (embedding) has no cells, and the record says so.

Each cell is one `cell` call, named by its build and cell (`cell b12098-asr-a audio-a
ggml-org/gemma-4-E4B-it-GGUF:Q8_0 google/gemma-4-E4B-it`), each pair after `unload` and `load` of
its model. Each cell's row is as rules.md, "Figures", gives it for two builds. The reasoning check
runs on each build's ASR cells, and the transcripts compare the audio model's ASR B on each build
(rules.md, "Reasoning check", "Transcripts").

Print the pass before it runs. For example, on gb10-1 against its 2026-10-31 report:

```text
Engine move: llama.cpp b11669 -> b12033 (server-cuda13), kernel 7.0.0-1024, one pass.
Each cell: GuideLLM 0.8.1 from this machine, http://gb10-1:8080, timeout 10m, fresh load.
  b11669   1 Anchor A  gpt-oss-120b MXFP4, agent section    1 x 8, 512 / 256
           2 Anchor B  gpt-oss-120b MXFP4, agent section    4 x 32, 512 / 256
           3 Shape A   Gemma 4 26B-A4B QAT Q4_0, vision     1 x 8, 512 / 256, thinking on
           4 Shape B   Gemma 4 26B-A4B QAT Q4_0, vision     4 x 32, 512 / 256, thinking on
           5 ASR A     Gemma 4 E4B Q8_0                     1 x 8 LibriSpeech clips, <=256 out
           6 ASR B     Gemma 4 E4B Q8_0                     4 x 32 clips, <=256 out
  image    image gb10 b12033 (step 5)
  move     ssh gb10-1 'cd <clone> && host/engines llama update b12033; echo "exit $?"'
  gate     gate: every preset section loaded, one at a time (step 5)
  b12033   7-12 the same six cells
Embedding: no cells (no scenario). Verdict: the engine rule (step 8).
```

## 7. The candidate screen

A candidate screen measures one candidate beside the host's set in one session, in two phases:

- **Phase 1** runs on the host's set as served.
- **Phase 2** runs on the candidate's set: the candidate's section serving each purpose it would
  take, with those purposes' models unloaded, and the host's models for its other purposes loaded.

Every cell follows rules.md, "Cells", "Fresh loads", and "Caps". The candidate's agent tiers and
conform share one fresh load of its section; every other cell runs from its own. Each cell is one
`cell` call, each tier one `tier` call, conform one `conform` call ("Step helpers"). The host's set is
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

Every cell, tier and conform run is under the monitor ("During cells"): GPU clocks and throttle
reasons sampled, the memory floor, and readouts every 5 minutes. Each sweep row gives both its
figures ("The sweep's figures").

**The agent tiers**, spike-model-hosting's, run from this machine in its checkout, read-only: its
consumers mise environment, its suites project (Inspect AI and inspect_evals' stock BFCL task), and
its seeded tier lists, with every output and cache in this project's ignored `.state/`, so the
checkout is never written. At the router's defaults (the card's sampling, the template's default
reasoning), with parallel tool calls allowed, 4 requests in flight, the count the floors were
measured at. A tier runs its whole list: no `--bar`, so no early stop. A new tool's first walk is
the architect's (rules.md, "Who runs what"); after it, the session runs them, each through its
helper ("Step helpers"), `tier <name> bfcl-<single|multi> <section>` and
`conform <name> <class>`, which run these commands under the monitor (the checkout is
`MEASURE_HOSTING`, `~/experiments/spike-model-hosting` by default):

```sh
cd <spike-model-hosting checkout>/evaluation && S=<project>/.state/measure/<host> && PYTHONDONTWRITEBYTECODE=1 UV_PROJECT_ENVIRONMENT=$S/../suites-venv HF_HOME=$S/../cache/huggingface INSPECT_EVALS_CACHE_DIR=$S/../cache/inspect_evals MISE_ENV=consumers timeout 15m mise exec -- uv run --project suites --locked --no-python-downloads python suites/agent_quality.py eval --router http://<host>:<port> --model <section> --tier bfcl-<single|multi> --list tiers/agent-bfcl-<single|multi>.txt --slots 4 --output $S/bfcl-<single|multi>
cd <spike-model-hosting checkout>/evaluation && MISE_ENV=consumers timeout 10m mise exec -- go run ./cmd/evaluate conform -router http://<host>:<port> -profile <project>/bench/conform/<class>.toml -consumers pi -k 5 -state <project>/.state/measure/<host>/conform
```

A tier's figure is its accuracy over its whole list, read from the Inspect JSON log the tier leaves
under its output directory. Conform's figure is its table: each capability's trials passed of 5,
and the invalid requests. A tier whose request carries no token cap can run on; a reply past the
tier's cap is a cap hit (rules.md, "Caps", "A tier's token cap"), and `summarize` gives the
tier's largest reply and its cap hits.

**The local-only checks**, each recorded with its command as run:

- **Cold start**: `load <section>` for the candidate's section from unloaded, which prints the
  time until `/models` reads it loaded (the session, no root), as spike-model-engines' setup times
  a load.
- **Memory**, read warmed after each set's long B cell, with the set still loaded, by `memory`:
  on a GB10, MemAvailable; on a Strix Halo, the GTT free (`mem_info_gtt_total` less
  `mem_info_gtt_used`). The set's use is the probed ceiling less that figure.
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

## A settings check

A settings check measures one served section with and without a set of keys, on one build, in
one session: the keys a decision gave the host unmeasured (through the shared preset), or a
configuration review's verify item. It runs after any engine move, on the build that stays, and
changes no key: the keys stay as the preset has them, and a worse reading is a finding.

**Selecting each arm.** A router loads a section with the arguments its preset gives it, and its
`/models/load` takes the section's name alone (llama.cpp's server README, "POST /models/load",
read 2026-11-06), so an arm is a preset state, not a load option. The two arms are the host's
clone of spike-model-engines at two commits whose presets differ only by the keys: the commit
before the keys and the one with them. The record first gives the clone's branch and commit as
found, from the probe's `preset clone` line. Where the clone as found is one arm (it is behind
the keys, or already has them), that arm runs on the clone as found; the other arm is that commit
detached after a fetch. The clone is moved with the router restarted, the session's steps, no
root, and `load` reads each arm's keys back from the instance's arguments, so the record shows
which arm each load ran:

```sh
ssh <host> 'cd <clone> && git log --oneline -1 && git status --short | head'    # as found
ssh <host> 'cd <clone> && git fetch -q origin && git checkout -q --detach <commit> && git log --oneline -1'
ssh <host> docker restart llama
```

After a restart the router lists every section unloaded; wait for `/health`, then load the arm's
set. Where no commit holds the section without the keys, the arm is a temporary section on a
branch, as a candidate's is (step 4), named in the brief. The pass ends with the clone restored as
found, `git checkout -q <branch as found>`, its `git log --oneline -1` reading the commit found,
then the router restarted and the host's set reloaded (step 9). The fetch moves only the clone's
remote-tracking refs; its branch stays where it was found. Moving that branch forward (pulling the
keys onto it) is a change to the host's configuration, a later decision with its own brief, not
part of the check.

**The pass**, in one session, the routing check (`routing`) and `tailscale ping` first:

1. **The anchors' repeats**: anchors A and B on the anchor section, twice, each pair from its own
   fresh load (`unload`, `load`, `cell <n>-anchor-a anchor-a`, `cell <n>-anchor-b anchor-b`, for
   n = 1, 2). They are the first anchors beside the host's earlier readings (across-days), and
   their spread between the two loads is a within-session reading (rules.md, "Figures", "Run
   noise").
2. **Each arm**, default first, then the keys: the clone at the arm's commit, the router
   restarted, the arm's set loaded from fresh, then the arm's cells on its section from that one
   load: an agent section's is BFCL multi-turn's first 4 samples
   (`tier <arm>-bfcl-multi bfcl-multi <section> 4`), the 4-sample list gb10-1's check ran
   (`docs/screens/gb10-1/2026-11-05.md`, "Cells"), under the cap the brief agrees.

**The settings rule.** The keys are confirmed when, on the arm with them against the default arm:
as many samples pass or more; the sum of sample times is no longer than the default's by more than
the within-session spread; the long replies' decode mean (`readout`'s replies of 90 tokens or
more, for the whole run) is no lower by more than that spread; and the keys' arm hit neither its
cap nor the memory floor. Otherwise the keys did worse: a finding, with the figures, and an item for
the host's next survey; this measure changes no key. The record gives both arms' figures, the
readouts' idle-slot saves and checkpoints, and each arm's loaded arguments.

For example, framework's owed check of set A's no-cache keys (the screen's merge gave them to
framework unmeasured on Vulkan b11960; goal record, Decisions, 2026-11-06):

```text
Settings check: framework, llama.cpp b11960 (server-vulkan), gpt-oss-120b-MXFP4-set-a,
cache-ram = 0 and cache-idle-slots = false. One session, the session; MEASURE_FLOOR_GIB=11.2.
Clone as found: ~/repos/spike-model-engines on main at dfc1d3d, never pulled (the probe's
preset clone line). Arms: dfc1d3d (before the keys), the clone as found, and 933ec0f (with them,
origin's main), detached after a fetch; their presets differ only by these two keys in set A's
section.
  1 Anchors, load 1   ggml-org/gpt-oss-120b-GGUF:MXFP4 *    cell r1-anchor-a anchor-a; cell r1-anchor-b anchor-b
  2 Anchors, load 2   the same, unloaded and loaded again   cell r2-anchor-a anchor-a; cell r2-anchor-b anchor-b
  3 Default arm       the clone as found, dfc1d3d on main, router restarted; E4B, the Gemma 4
                      26B-A4B vision section and granite loaded, then set A's section
                      (load reads no --cache-ram 0, no --no-cache-idle-slots)
                      MEASURE_TIER_CAP=10m tier default-bfcl-multi bfcl-multi gpt-oss-120b-MXFP4-set-a 4
  4 No-cache arm      git fetch -q origin && git checkout -q --detach 933ec0f, router restarted;
                      the same loads (load reads --cache-ram 0 --no-cache-idle-slots)
                      MEASURE_TIER_CAP=10m tier nocache-bfcl-multi bfcl-multi gpt-oss-120b-MXFP4-set-a 4
  * set A's agent unloaded meanwhile (one gpt-oss section at a time).
End state: git checkout -q main, reading dfc1d3d as found; router restarted; set A reloaded, read
back by /models and the probe. The clone's main stays unpulled: moving it is a later decision.
Spreads: the repeats set framework's within-session and across-days spreads (rules.md, "Figures").
Verdict: the settings rule.
```

## 8. The verdict

Each rule states what it gave on each condition, with its figures, then the outcome; the architect
may overrule it, and the record gives the overrule and its reason beside what the rule gave. "Run
noise" below is the descriptor's within-session spread (rules.md, "Figures", "Run noise"): every
comparison these rules make is within one session.

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
for the pass returns to the branch and commit it was found at, with the router restarted, unless a
keep leaves the branch's pull request open; the brief says which. Pulling the clone forward is a
host change for a later decision, not part of the pass.

## 10. Write the record

The record is measure's own write: a dated record at `docs/measures/<host>/<YYYY-MM-DD>.md`
(rules.md, "Dated records"). Beside it, measure updates only the blocker register's entries
for this host in place (step 1, item 5). It is written once, when the measure ends (after the
end state is read back, or when the architect stops it, saying where it stopped), and never
edited. A measure stopped before any decision writes no record unless the architect asks for
one. It writes nothing else: not the survey, the pool, the descriptor, the policy, the skill,
or its conform profiles, and nothing on the host beyond the steps the record gives as run.

The descriptor's run noise is the one exception the record leads to: when the measure repeated
cells, the record states each spread the repeats give and the descriptor's figures they set
(rules.md, "Figures", "Run noise"), and the session writes them into the descriptor after the
record, citing it.

**Commands as run** come from the command log ("The command log"), never from memory: the record
names the log's path and quotes its lines for each step, in order, the calls the session or the
architect made (the lines with no helper's name) and, under each, the commands a helper ran that
changed or loaded the host (its `curl` to `/models/load` or `/models/unload`, its GuideLLM or tier
command, an `ssh`), with their times. Polls and the monitor's samples are left out, as the log
leaves them. Each figure the record gives is `summarize`'s, for the cell it names, quoted from the
log's `= ` lines, as are a load's time and arguments, a readout's, a memory read-out, and the
routing check's result. A step run without the helpers sourced is not in the log, and the record
says so beside it.

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

## Commands as run
The command log's path (`.state/measure/<host>/<YYYY-MM-DD>.log`), the helpers' commit (the
project's, at the run), and the log's lines for every step in order, as "Commands as run" above
gives them, each with who ran it.

## Run noise
The descriptor's within-session and across-days spreads the verdicts used, with their sources;
each comparison that read one, and whether it moved beyond it. When the measure repeated cells:
each repeated cell's readings and spread, the first anchors against the host's earlier readings
on the same build and kernel, and the spreads the descriptor takes from them.

## Engine move: <engine> <incumbent build> to <candidate build>
The candidate and why (rules.md, "Default rules", item 1: the builds passed over, with the
reads that showed them unimaged or failing). The build gate (step 5): its image row, one
row per section it loaded, and the rollback as run when it failed. The pass's routing check
(`routing`), its kernel and host stack, and `tailscale ping -c 1`. Every command exactly as
run: the incumbent build's cells, the move through the suite with its output and the build
read back, the candidate build's cells. One row per cell, as rules.md, "Figures", gives it
for two builds. A purpose with no cells, named with its reason.

## Candidate screen: <candidate>, <section>
The routing check (`routing`), the engine build and host stack, and `tailscale ping -c 1`. Every
command exactly as run, in order, with who ran it. Phase 1's cells, then phase 2's, each row as
rules.md, "Figures", gives it, with the earlier claims beside it. Each agent tier's command
as run, its accuracy on its whole list against its floor, and its time; conform's table,
invalid requests, and fit. The local-only checks: cold start, each set's memory read-out,
each slot's context as the router reports it, the API surface, and whether each feature works,
each with its command as run.

## Settings check: <section>, <keys>
The two arms, each by its clone commit and its loaded arguments as `load` read them; the anchors'
repeats; each arm's tier as run, with samples done and passing, the sample times and their sum,
the readouts (idle-slot saves, checkpoints, the long replies' decode), the largest reply, the cap
hits, the lowest memory available, and the GPU readings; then the settings rule's conditions with
their figures.

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
For each pass, its rule (the engine rule, the keep rule, or the settings rule), what it gave
on each condition with its figures, the outcome (adopt or roll back; keep or drop), and any
overrule by the architect with its reason beside what the rule gave. On an engine adopt,
the rollback exactly as printed; on roll back, the update as run and the probe reading the
incumbent back. On a candidate's adoption, the architect's decision with its date.

## The claim beside the anchors
The published claim the survey cited for each measured item, with its source, beside what this
host measured, and how far the source held. The first anchors beside the host's last earlier
readings, and any move beyond the across-days spread, named as a finding.

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
