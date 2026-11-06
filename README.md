# spike-hosting-upgrades

What convention evaluates an upgrade to the hosting stack (a host's hardware configuration, its
model host, or its models) from what others publish, rather than from benchmarks of our own? This
spike builds a project-local Claude Code skill that gathers the public record for each host class,
engine, and model, cites it, and writes a dated report of ranked upgrades per host, then verifies
the top upgrades on our hosts with anchor cells A and B. Its answer is evidence for standards-lab's
`experiment.hosting` intake, which decides the upgrade-evaluation convention and cadence
`v1.ai.hosting` specifies.

- The skill: `.claude/skills/hosting-upgrades/`. It runs on one host at a time, reading the
  project's host descriptors (`docs/hosts/`, each purpose with its load target) and policy
  (`docs/policy.md`). `/hosting-upgrades setup` prints the permission rules the workspace needs and
  never writes settings.
- The survey mode: `/hosting-upgrades survey <host>` probes the host read-only and without root,
  ranks upgrades and what the host has fallen behind on, such as pending system updates and failed
  units, from what others publish, and applies nothing. It writes a dated report,
  `docs/reports/<host>/<YYYY-MM-DD>.md`, or `<YYYY-MM-DD>-N.md` for a later run the same day.
- The measure mode: `/hosting-upgrades measure <host>` settles the last survey's items on the host
  with local cells (an engine move under the engine rule, a candidate model under the keep rule)
  and writes a dated record, `docs/measures/<host>/<YYYY-MM-DD>.md`.
- The verify and screen modes, which the measure mode replaced, left their records as history: the
  verification findings, `docs/findings/verify-<host>.md`, such as
  [framework's](docs/findings/verify-framework.md), and the screen records,
  `docs/screens/<host>/<YYYY-MM-DD>.md`, such as [framework's](docs/screens/framework/2026-11-04.md)
  and [gb10-1's](docs/screens/gb10-1/2026-11-05.md).

## The answer

Not answered yet. The spike's `answer` task writes it here.
