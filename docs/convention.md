# The convention and its cadence

How this project evaluates an upgrade to a host's serving stack (its hardware configuration, its
engine, or its models): when the hosting-upgrades skill
([SKILL.md](../.claude/skills/hosting-upgrades/SKILL.md)) runs, what sends an item to the host's
own cells, the record an adoption leaves, and what stays with the backlog goal `model-evaluation`.
Each statement cites the record that shows it. Where the record doesn't show a statement yet, the
statement says so, and "What the record doesn't show yet" collects those gaps.

The decisions cited as "Decisions" are in the goal record,
[`context/goals/experiment.hosting.spike-hosting-upgrades.md`](../context/goals/experiment.hosting.spike-hosting-upgrades.md),
"Decisions", by their task prefix. The two second surveys, both of 2026-11-06, are framework's
[2026-11-06](reports/framework/2026-11-06.md) and gb10-1's
[2026-11-06-2](reports/gb10-1/2026-11-06-2.md).

## When survey runs

`/hosting-upgrades survey <host>` runs on one host at a time, read-only and without root, and
applies nothing ([SKILL.md](../.claude/skills/hosting-upgrades/SKILL.md), "Modes").

- **Weekly, per host.** Each host is surveyed at least once a week, whether or not anything
  triggered it. The architect chose a weekly run plus event triggers and rejected triggers alone
  (Decisions, "answer: survey runs weekly per host, plus event triggers"). A weekly run catches
  what moves outside the host: new engine builds, new models, and a register entry's upstream
  state. Both second surveys found such moves with no event behind them: the newest Vulkan and
  cuda13 image moved to b12169, a build with no GitHub release, and gb10-1's research found
  `LiquidAI/LFM2.5-24B-A2B-GGUF`'s Q4_0, added that day
  ([framework](reports/framework/2026-11-06.md), "Blockers";
  [gb10-1](reports/gb10-1/2026-11-06-2.md), "The research"). A host is due a week after its
  last dated report, which `docs/reports/<host>/` shows.
- **On a host update.** A host update changes the host stack, which is one of the three things
  the survey compares with the last report (survey.md, step 3, "When the inventory hasn't
  moved"). On 2026-11-06 the architect updated both hosts before their surveys (goal record,
  "Progress"): framework took mise-bin 2026.11.2-1 and pnpm 12.18.0 with no reboot, and gb10-1
  took 12 upgraded and 8 new packages, among them kernel 7.0.0-1025-nvidia, then rebooted. Each
  survey read the update back in its Inventory, under "What moved"
  ([framework](reports/framework/2026-11-06.md), item 3;
  [gb10-1](reports/gb10-1/2026-11-06-2.md), "Host stack: moved").
- **When a register entry reaches "fix in an image build".** At that state the survey makes the
  entry an upgrade item for each host it names ([blockers.md](blockers.md)). #30137, unbounded
  context checkpoints with no prompt cache, reached it on 2026-11-06, once `fix-in-image.sh` read
  ghcr.io's tag list and named b12169 ([gb10-1, 2026-11-06](reports/gb10-1/2026-11-06.md),
  "Pauses", 2). Both second surveys then gave the move to b12169 as an upgrade item, and both
  gave it skip, because b12169 is past b12100 and crosses the open entry for Google's QAT GGUFs
  ([framework](reports/framework/2026-11-06.md) and [gb10-1](reports/gb10-1/2026-11-06-2.md),
  "Blockers").
- **When a descriptor's purposes or load targets change.** The survey judges every item against
  the load targets in the host's descriptor ([rules.md](../.claude/skills/hosting-upgrades/rules.md),
  "Load targets"), so a changed target changes the verdicts. framework's descriptor gained its
  load targets and run noise after its last report, and its second survey read them as moved
  ([framework](reports/framework/2026-11-06.md), "What moved", item 2).
- **Before any change to the host.** A measure works from the last survey
  ([measure.md](../.claude/skills/hosting-upgrades/measure.md), "2. What this measure runs"), and
  the skill runs survey "before any change to the host" ([SKILL.md](../.claude/skills/hosting-upgrades/SKILL.md),
  "Modes"). One change comes first: the experiment's rule that every session starts by bringing
  its hosts up to date. The architect ran the updates before the surveys and rejected surveying
  first and ranking the updates as take items (Decisions, "answer: the architect brings both
  hosts up to date with root before the surveys"). So a session that changes a host runs in this
  order: the update, then the survey, then any measure.

A survey researches in full when the engine builds, the models, or the host stack differ from the
host's last report. When none of the three differs, it researches only what moved and what it
always reads (survey.md, step 3). Both second surveys researched in full, because the hosts' stacks
had moved: framework's since 2026-10-30-2 (Omarchy 4.0.6 to 4.5.0-3, kernel 7.2.8-9 to
7.2.15-1-omarchy, the no-cache keys on the agent section, the vLLM container and six snapshots
removed), and gb10-1's since its first survey that day (kernel 7.0.0-1024 to 7.0.0-1025-nvidia, 12
pending updates to 0) ([framework](reports/framework/2026-11-06.md), "What moved since 2026-10-30-2";
[gb10-1](reports/gb10-1/2026-11-06-2.md), "What moved since 2026-11-06").

## What triggers a measure

`/hosting-upgrades measure <host>` takes the last survey to local cells
([measure.md](../.claude/skills/hosting-upgrades/measure.md)).

- **A survey's verify item or Needs measurement entry.** A measure runs the host's items, an
  engine move the survey's engine conclusion or "Verify next" names, one candidate from "Needs
  measurement" or "Verify next", and a settings check of keys a decision left owed or the
  configuration review ranks verify (measure.md, "2. What this measure runs"). Today both
  surveys' "Verify next" names one item, the vision section's prompt-cache keys, and their
  "Needs measurement" lists the candidates no card settles
  ([framework](reports/framework/2026-11-06.md) and [gb10-1](reports/gb10-1/2026-11-06-2.md),
  "Needs measurement" and "Verify next").
- **One measure a session.** A run writes one dated record per host
  (Decisions, "skill-revision: one dated measure record per run per host"), and runs at most one
  engine move, one candidate screen, and a settings check, each its own pass on one state
  ([SKILL.md](../.claude/skills/hosting-upgrades/SKILL.md), "A host's cycle", step 3). The one
  measure so far is framework's of 2026-11-06, a settings check alone
  ([measure](measures/framework/2026-11-06.md)).
- **Its cells agreed in that task's plan round.** Every benchmark is agreed with the architect in
  the task's plan round, and BUILD runs none the brief doesn't name (the experiment's rules,
  `standards-lab/context/ai-hosting.md`, "Experiment: experiment.hosting"). framework's measure
  ran "from the commands the skill-revision brief agreed"
  ([measure](measures/framework/2026-11-06.md), its opening), with each arm capped at 10 minutes
  (Decisions, "skill-revision: verified by a paper survey of gb10-1 … and a measure on
  framework").

A take item needs no measurement. It is applied with the next host update (survey.md,
"Verdicts"). A hold item is measured only when it is one of the host's items, which a measure
takes to a decision, or a candidate that "Needs measurement" lists because no card places it
(measure.md, "2. What this measure runs").

## The record an adoption leaves

An adoption leaves a chain of records. Each link cites the one before it:

1. **The report** that ranks the item, `docs/reports/<host>/<YYYY-MM-DD>.md`.
2. **The measure record** that settles it, `docs/measures/<host>/<YYYY-MM-DD>.md`, whose
   "Commands as run" quotes the step helpers' command log, never memory
   ([measure.md](../.claude/skills/hosting-upgrades/measure.md), "10. Write the record").
3. **The descriptor, the pin, and the register entry's state**: the descriptor's run noise when
   the measure repeated cells; the host class's engine pin in spike-model-engines'
   `host/llama.env`, changed by a pull request citing the finding; and the state of each register
   entry the change clears.

The record shows the chain once, under the revised skill: framework's no-cache keys on set A's
agent section.

- The measure of 2026-11-06 settled the keys from framework's report 2026-10-30-2. It quotes
  `.state/measure/framework/2026-11-06.log`, 1,820 lines, and confirmed the keys: 20.1% less time
  and 19.2% faster long-reply decode ([measure](measures/framework/2026-11-06.md), "Commands as
  run" and "Verdict").
- It set the descriptor's run noise, 1.1% within a session and 2.8% across days
  ([framework.md](hosts/framework.md), "Run noise").
- The architect pulled the clone to 933ec0f and restarted the router (Decisions,
  "skill-revision, after ship"; commit `8dd4f58`).
- The next survey read the keys back as served ([framework](reports/framework/2026-11-06.md),
  "What moved", item 1).
- The register entry for the prompt cache with a unified KV cache stays open, since its fix is
  unmerged. Its workaround is now in effect on framework ([framework](reports/framework/2026-11-06.md),
  "Blockers").

The pin was last moved by the screen, before the revision: the gb10 pin became b12098 through the
screen branch's pull request ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Findings"). No
adoption has yet taken a register entry to "cleared on the host".

## How proposals are settled

A survey proposes changes to the documents it reads and applies none of them. Its "Proposed
changes" has five lists: the descriptor, the trusted sources, the blocklist, the engine seed list,
and the policy with the model gates (survey.md, "12. Proposed changes"). A pause it couldn't put
to the architect during the run is written into the report with its default and settled after
the run (rules.md, "Pause").

The architect accepts or rejects each proposal, one at a time, at the start of the next session
and before the host's next survey. The session applies the accepted ones and logs each decision.
Today showed this twice:

- gb10-1's ten proposals of 2026-11-06 were all accepted and applied before its second survey
  (Decisions, "answer: gb10-1's 2026-11-06 proposals all accepted"; commit `2c507cc`). The
  second survey read the descriptor as they left it ([gb10-1](reports/gb10-1/2026-11-06-2.md),
  "What moved since 2026-11-06", "The descriptor and the skill").
- framework's four pauses were settled after its survey: two by the session's no-root reads, and
  two by the architect (commit `1fc8aee`; [framework](reports/framework/2026-11-06.md),
  "Pauses"). One of the architect's rulings, 0cc4m's statements as primary for Vulkan practice,
  is now in [sources.md](../.claude/skills/hosting-upgrades/sources.md). gb10-1's one pause was
  settled by the architect (commit `acfb0b8`; [gb10-1](reports/gb10-1/2026-11-06-2.md),
  "Pauses"), and its ruling, that a contributor's measurement naming hardware, version and
  method is an attributed benchmark, is in sources.md too.

The second surveys' own proposals are open, for the next session's start: framework's six
descriptor changes, its two source notes and its policy items, and gb10-1's two descriptor watch
items, two sources, and one probe change
([framework](reports/framework/2026-11-06.md) and [gb10-1](reports/gb10-1/2026-11-06-2.md),
"Proposed changes").

## The blocker register

[`docs/blockers.md`](blockers.md) holds one entry per blocker, with the hosts it affects, what it
blocks, its measured cost and the record behind it, its upstream issue or pull request, its
workaround, and its state. Its four states, in order:

- **open**: no fix is merged upstream.
- **fix merged**: a fix is merged, and no build with an image for the hosts' class carries it.
- **fix in an image build**: the newest imaged build for the class carries the fix, and the
  survey makes the entry an upgrade item.
- **cleared on the host**: a host runs a build with the fix, and its measure record shows the
  blocked thing working.

An entry is deleted once it is cleared on every host it names. A survey adds an entry only when
one of this project's records measured what the blocker costs (Decisions, "skill-revision: a
survey adds a register entry only when a record of this project measured what the blocker
costs"). Every survey checks every entry upstream with `gh`, and `scripts/fix-in-image.sh` reads
whether a merged fix is in the class's newest imaged build (survey.md, "Blocker register").

Both second surveys checked all seven entries, framework's at about 18:18Z and gb10-1's at
18:49Z, and **no entry changed state** ([framework](reports/framework/2026-11-06.md) and
[gb10-1](reports/gb10-1/2026-11-06-2.md), "Blockers"). Six entries are open. #30137 is at "fix in
an image build", where it moved that day when gb10-1's first survey's Pause 2 was settled. No
entry has reached "cleared on the host", and none has been deleted.

## The research cache

[`docs/research.md`](research.md) holds one entry per source a survey read: its URL, its read
time, the hosts and subject it concerns, its tier, and what it said. It is one file, updated in
place, and every host's surveys share it (survey.md, "Research cache"). The 14-day rule: a survey
cites an entry with its read time until the entry is 14 days old or its subject has changed; then
it reads the source fresh and replaces the entry. An entry whose subject no longer concerns any
host is deleted. A held build keeps its entries (Decisions, "skill-revision: the research cache
deletes a build's entries only when no host runs or is held at the build"). Which release or model
is newest is never cached. Each survey reads that fresh, along with the register's states.

The second surveys' counts:

| Survey | Cited from the cache | Read fresh | Replaced | New | Deleted |
|---|---|---|---|---|---|
| [framework, 2026-11-06](reports/framework/2026-11-06.md) | 13 source entries (of 34) | 54 source entries | 4 | 50, and 47 model entries, the cache's first | 0 |
| [gb10-1, 2026-11-06-2](reports/gb10-1/2026-11-06-2.md) | 23 source and 29 model entries | 14 | 8 | 6 | 0 |

gb10-1's survey ran about half an hour after framework's, so it cited what framework's had just
read or refreshed. It read 14 entries fresh, against framework's 54 and the 18 new entries
gb10-1's own first survey wrote that morning ([gb10-1, 2026-11-06](reports/gb10-1/2026-11-06.md),
"The research"). No entry was deleted, because every entry's subject still concerns a host: gb10-1
runs b12098, and b12124 is one image behind the newest
([gb10-1](reports/gb10-1/2026-11-06-2.md), "The research").

**What this shows of "only what moved", and what it doesn't.** Both second surveys researched in
full, because the host stack had moved on both hosts. So no run has yet skipped the research for
an unmoved inventory. Today's evidence for "only what moved" is the cache's reuse: framework cited
13 entries instead of re-reading them, and gb10-1 cited 23 sources and 29 model entries and read
only 14 fresh. A repeat survey of a host whose stack, builds, and models haven't moved is still
to run.

## Per-host load targets

Each purpose in a host's descriptor carries a load target: the concurrent sessions (for the agent
purpose) or concurrent requests (for any other) it is sized for, and the context each reaches.
Each figure cites where it comes from. A survey judges configuration, engine fit, capacity, and a
set's memory at those targets ([rules.md](../.claude/skills/hosting-upgrades/rules.md), "Load
targets"). Today both descriptors take their targets from spike-model-engines' shared preset at
933ec0f: agent, 4 sessions sharing one 131,072-token pool; vision and audio, 4 requests of 8,192
tokens each; embedding, 16 requests of 8,192 tokens each ([framework.md](hosts/framework.md) and
[gb10-1.md](hosts/gb10-1.md), "Purposes").

spike-model-layout decides which purposes a host serves and at what load. No rule assumes set A's
four purposes on every host, and a change there changes the descriptor (Decisions,
"skill-revision: descriptors' Purposes list only the purposes a host serves"; each descriptor's
"Purposes"). The skill judges against what the descriptor lists and never sets a target itself. A
purpose listed without a target is a pause (rules.md, "Load targets").

## What stays with model-evaluation

The backlog goal `model-evaluation` (`standards-lab/context/roadmap.toml`, `[goals.model-evaluation]`)
builds on this convention. It keeps:

- **Workloads only we can measure.** No publisher can measure these, so no survey can read them.
- **Our agents, and our role sets under our own sessions.** A measure screens one candidate beside
  the host's set, on fixed BFCL samples, conform, and anchors A and B. It doesn't run our own
  agents or a whole role set under concurrent sessions. The screens show where those tiers reach
  their limit. On gb10-1, BFCL multi-turn hit its 45-minute cap at 19 of 20 samples
  ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Verdict"). Each host's "Needs measurement"
  lists more candidates than one screen a session can clear: framework's names over twenty agent
  candidates ([framework](reports/framework/2026-11-06.md), "Needs measurement").
- **Tuning at scale.** Slots and context tuned per model, workload, and host is
  model-evaluation's and spike-model-layout's, as spike-model-engines' answer routes it
  (`standards-lab/context/ai-hosting.md`, "Answer · experiment.hosting.spike-model-engines").

## What the record doesn't show yet

- **No repeat survey with an unmoved stack.** "Only what moved" is shown by the cache's reuse, not
  by a run that skipped research ("The research cache").
- **The weekly cadence hasn't run.** It was decided on 2026-11-06, the day of both second surveys.
- **No register entry has been cleared or deleted.** The register's last state and its deletion
  rule haven't been exercised ("The blocker register").
- **The measure mode has run once, as a settings check.** No engine move or candidate screen has
  run under it ([measure](measures/framework/2026-11-06.md), its opening). The engine moves and
  screens on record ran under the verify and screen modes it replaced.
- **No embedding scenario.** `bench/` has no embedding scenario, so no embedding candidate can be
  measured ([framework](reports/framework/2026-11-06.md) and
  [gb10-1](reports/gb10-1/2026-11-06-2.md), "Needs measurement").
