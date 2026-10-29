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
  `engines` suite read-only from its clone; this spike adds no host scripts.
- No Python is authored, and a mise task runs one script or one command.

## Docs

- A report is dated, `docs/reports/<YYYY-MM-DD>.md`, and is never edited after its date; a later
  run writes a new report.
- A finding, under `docs/findings/<task>.md`, says what was measured, when, on which engine
  version, host stack, and network path, and stays dated.
- Every command a session or the architect runs appears in a finding exactly as run. No tailnet
  identifier is committed, neither an address nor the MagicDNS suffix; hosts go by short name,
  such as `gb10-1`.
