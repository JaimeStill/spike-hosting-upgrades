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

- The convention: [`docs/convention.md`](docs/convention.md), when the skill runs, what sends an
  item to the host's own cells, and the record an adoption leaves.

## The answer

**Question:** What convention evaluates an upgrade to the hosting stack (a host's hardware
configuration, its model host, or its models) from what others publish rather than benchmarks of
our own?

**Answer:** A skill surveys each host weekly and on events, ranking every upgrade from cited
public sources against the host's load targets; the host measures only what no source settles,
and an adoption leaves a chain of dated records.

1. **The skill.** One project-local Claude Code skill,
   [`.claude/skills/hosting-upgrades/`](.claude/skills/hosting-upgrades/SKILL.md), has three
   modes: `setup`, `survey <host>`, and `measure <host>`. It reads the host descriptors and the
   policy, probes each host read-only and without root, and cites every source with its URL and
   read time. It prints the permission rules it needs and never writes settings. Proven by its
   runs: the probes of both hosts ([`docs/findings/skill.md`](docs/findings/skill.md)), the
   reports below, and framework's measure record.
2. **Dated reports of ranked upgrades per host.** framework's
   [2026-10-30](docs/reports/framework/2026-10-30.md),
   [2026-10-30-2](docs/reports/framework/2026-10-30-2.md), and
   [2026-11-06](docs/reports/framework/2026-11-06.md), and gb10-1's
   [2026-10-30](docs/reports/gb10-1/2026-10-30.md),
   [2026-10-31](docs/reports/gb10-1/2026-10-31.md),
   [2026-11-06](docs/reports/gb10-1/2026-11-06.md), and
   [2026-11-06-2](docs/reports/gb10-1/2026-11-06-2.md). Each item carries its sources, its
   claimed gain, its risk, and a verdict. The two second surveys, of 2026-11-06, each state what
   moved since the host's last report. Both researched in full, because the host stack had moved
   on both. They also give the research cache's counts and every register entry's state as
   checked upstream. Proven by the reports themselves.
3. **Each host's top upgrade, verified before and after on the host.** On framework, Gemma 4 E4B
   QAT as the audio model: rolled back on ASR B (−5.0%), anchors steady within 0.5%
   ([`docs/findings/verify-framework.md`](docs/findings/verify-framework.md), "Verdict"). On
   gb10-1, llama.cpp b11669 to b12063: the engine rule gave roll back (ASR B −11.07%), and the
   architect overruled it to stay current
   ([`docs/findings/verify-gb10-1.md`](docs/findings/verify-gb10-1.md), "Verdict"). Under the
   revised skill, framework's measure confirmed set A's no-cache keys (20.1% less time, 19.2%
   faster long-reply decode), and the host now serves them
   ([`docs/measures/framework/2026-11-06.md`](docs/measures/framework/2026-11-06.md)). Proven by
   measured runs on each host.
4. **The pool's candidates, screened per host class.** The gates ran on every candidate in the
   pool. One candidate was measured: Gemma 4 26B-A4B QAT, serving agent and vision, beside
   gpt-oss-120b. It was dropped on both
   hosts: on framework at the engine gate, since b11960's Vulkan backend aborts with several slots
   ([`docs/screens/framework/2026-11-04.md`](docs/screens/framework/2026-11-04.md)), and on gb10-1
   on BFCL multi-turn's floor
   ([`docs/screens/gb10-1/2026-11-05.md`](docs/screens/gb10-1/2026-11-05.md)). Each host keeps set
   A. The other candidates are hold until measured, and are listed under each second survey's
   "Needs measurement". Proven by measured runs on each host.
5. **The published claim beside our anchors.** This item is thin: three published claims were set
   beside our cells, all in the verify findings. framework's claim for E4B QAT, +56.6% at shape A,
   came from spike-model-engines' own measurement, not a third party's. It held within about a
   point (+55.4%), but it said nothing of the model's unprompted reasoning, which cost ASR B its
   lead ([verify-framework](docs/findings/verify-framework.md), "The claim beside the anchors"). On
   gb10-1, #31188's +17.2% MoE prefill held in direction only: TTFT fell 0.6% to 3.2%. #29948's
   +7.1% dense prefill didn't show: TTFT rose 5.2% and 23.3%
   ([verify-gb10-1](docs/findings/verify-gb10-1.md), "Cells"). The screens set no published
   claim beside their cells. Their "Earlier claims" are this project's own earlier readings, and
   gb10-1's move to b12098 had no prefill claim to test
   ([gb10-1 screen](docs/screens/gb10-1/2026-11-05.md), "The engine move"). The measure's claim
   was gb10-1's own check of the keys (−3.7% time, +8.8% decode), which framework exceeded
   ([measure](docs/measures/framework/2026-11-06.md), "The claim beside the anchors"). So far the
   sources predicted the direction of a gain more often than its size, and a speed claim on fixed
   text missed a behavior that changes the length of a reply.
6. **The convention and its cadence.** [`docs/convention.md`](docs/convention.md) states it, each
   statement citing its record:
   - when survey runs: weekly per host, and on a host update, a register entry's fix reaching an
     image, a changed purpose or load target, and before any change to the host;
   - what triggers a measure: a verify item or a "Needs measurement" entry, one a session, with
     its cells agreed in the plan round;
   - the record an adoption leaves: the report, the measure record quoting its command log, then
     the descriptor, the pin, and the register's state;
   - how proposals are settled between surveys;
   - the blocker register's four states and the research cache's 14-day rule;
   - per-host load targets, which spike-model-layout owns;
   - what stays with `model-evaluation`.

   Proven by the two second surveys and the records the convention cites. It also names what the
   record doesn't show yet: no survey has yet run on an unmoved stack, and no register entry has
   been cleared.
