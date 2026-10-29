# spike-hosting-upgrades

What convention evaluates an upgrade to the hosting stack (a host's hardware configuration, its
model host, or its models) from what others publish, rather than from benchmarks of our own? This
spike builds a project-local Claude Code skill that gathers the public record for each host class,
engine, and model, cites it, and writes a dated report of ranked upgrades, then verifies the top
upgrades on our hosts with anchor cells A and B. Its answer is evidence for standards-lab's
`experiment.hosting` intake, which decides the upgrade-evaluation convention and cadence
`v1.ai.hosting` specifies.

- The skill: `.claude/skills/` (written by the `skill` task).
- The dated reports: `docs/reports/`.
- The verification findings: `docs/findings/`.

## The answer

Not answered yet. The spike's `answer` task writes it here.
