# Standards

The judgement calls the check can't enforce, one line each, for the standards-reviewer. What
`mise run check` enforces is never restated here.

The architecture pages that apply, in the architecture repository:

- `principles/minimal-footprint.md`
- `principles/rolling-currency.md`
- `principles/validation-first.md`

## The skill

- The skill is project-local, under `.claude/skills/`, and encodes judgement; a procedure it
  repeats the same way every run is a candidate script, not prose.
- Every claim a report makes cites its source with the URL and the date it was read.

## Scripts

- Only a step that must be idempotent is scripted, beside step helpers a session sources and calls
  one step at a time in the architect's view, each command logged with its time so the records
  quote the log; a helper never runs a benchmark on its own (the experiment's scripting rule,
  2026-11-06). Engine changes on a host run spike-model-engines' `engines` suite read-only from
  its clone. The skill's bundled scripts only read, except measure's step helpers
  (`scripts/measure-lib.sh`), which change a host only by loading and unloading models through
  the router's API.
- No Python is authored, and a mise task runs one script or one command.

## Hosts

- A host serves one model per declared purpose at a time. To load a candidate for a purpose,
  first unload the model serving that purpose, wait until the router reports it unloaded, and
  only then load the candidate; never load beside it. A session leaves the host serving its set
  as it found it, or as an adoption changed it. A router that holds a cap on loaded models
  (llama.cpp's `--models-max`, 4 by default, exactly set A's size) evicts the least recently used
  model when a load arrives before an unload has finished, so a load sent too soon can take
  another purpose's model down unseen.

## Docs

- A report is per host and dated, `docs/reports/<host>/<YYYY-MM-DD>.md`, or `<YYYY-MM-DD>-N.md`
  (`-2`, `-3`, ...) for a later run on a date that already has one, and is never edited once
  written; a later run writes a new report.
- A measure record, the measure mode's, is per host and dated the same way,
  `docs/measures/<host>/<YYYY-MM-DD>.md` or `<YYYY-MM-DD>-N.md`, and is never edited once written;
  a later measure writes a new record. Its commands as run are quoted from the helpers' command
  log.
- The screen records the retired screen mode wrote, `docs/screens/<host>/<YYYY-MM-DD>.md`, are
  history: never edited, and read as the host's earlier readings.
- A finding, under `docs/findings/<task>.md` (or the retired verify mode's `verify-<host>.md`, now
  history), says what was measured, when, on which engine version, host stack, and network path,
  and stays dated.
- The research cache, `docs/research.md`, and the blocker register, `docs/blockers.md`, are one
  file each for the project, updated in place by the skill's runs; git keeps the old text. The
  cache holds what a source said, never a verdict or a register state.
- Every command a session or the architect runs appears in its record or finding exactly as run.
  No tailnet identifier is committed, neither an address nor the MagicDNS suffix; hosts go by
  short name, such as `gb10-1`.
- No LAN identifier is committed either: a Wi-Fi network's name (a connection named for it), a
  LAN address other than the router's well-known gateway, or a MAC address. A command that ran
  with one is recorded with a placeholder in its place, such as `<Wi-Fi connection>`, and a note
  saying what the placeholder stands for.
