# spike-hosting-upgrades

What convention evaluates an upgrade to the hosting stack (a host's hardware configuration, its
model host, or its models) from what others publish, rather than from benchmarks of our own? This
spike builds a project-local Claude Code skill that gathers the public record for each host class,
engine, and model, cites it, and writes a dated report of ranked upgrades per host, then verifies
the top upgrades on our hosts with anchor cells A and B. Its answer is evidence for standards-lab's
`experiment.hosting` intake, which decides the upgrade-evaluation convention and cadence
`v1.ai.hosting` specifies.

- The skill: `.claude/skills/hosting-upgrades/`. It probes one host a run, read-only and
  without root, and reads the project's host descriptors (`docs/hosts/`) and policy
  (`docs/policy.md`). Beside the upgrades, it finds and ranks what the host has fallen behind on,
  such as pending system updates and failed units, and applies nothing. Before each run, its readiness check prints the permission rules the
  workspace needs and never writes settings; `/hosting-upgrades setup` runs the check alone.
- The dated reports: `docs/reports/<host>/<YYYY-MM-DD>.md`, or `<YYYY-MM-DD>-N.md` for a later run
  the same day.
- The verification findings: `docs/findings/`.

## The answer

Not answered yet. The spike's `answer` task writes it here.
