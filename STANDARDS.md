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

- Only a step that must be idempotent is scripted. Engine changes on a host run spike-model-engines'
  `engines` suite read-only from its clone; this spike adds no script that changes a host, and
  the skill's read-only probe is its one host script.
- No Python is authored, and a mise task runs one script or one command.

## Hosts

- A host serves one model per declared purpose at a time. To load a candidate for a purpose,
  first unload the model serving that purpose, never load beside it; a session leaves the host
  serving its set as it found it, or as an adoption changed it. A router that holds a cap on
  loaded models evicts the least recently used one, so loading beside an incumbent can take
  another purpose's model down unseen.

## Docs

- A report is per host and dated, `docs/reports/<host>/<YYYY-MM-DD>.md`, or `<YYYY-MM-DD>-N.md`
  (`-2`, `-3`, ...) for a later run on a date that already has one, and is never edited once
  written; a later run writes a new report.
- A finding, under `docs/findings/<task>.md`, says what was measured, when, on which engine
  version, host stack, and network path, and stays dated.
- Every command a session or the architect runs appears in a finding exactly as run. No tailnet
  identifier is committed, neither an address nor the MagicDNS suffix; hosts go by short name,
  such as `gb10-1`.
