# goal · experiment.hosting.spike-hosting-upgrades

- **State:** building
- **Task:** skill
- **Branch:** skill

## Tasks

1. [ ] skill
2. [ ] verify-framework
3. [ ] verify-gb10
4. [ ] screen
5. [ ] answer

## Task brief · skill

```
Problem       Upgrades to the hosting stack (a host's hardware configuration, its engine,
              its models) are judged today from our own benchmarks or from memory, and
              the inventory they rest on is scattered across other spikes' findings.
              gb10-1's state is recorded nowhere. The spike needs one interactive,
              environment-agnostic Claude Code skill. Pointed at one workstation, it
              probes the host as it is now, gathers and cites what others publish, and
              writes a dated report. The verify tasks then take one named upgrade from
              that report, and the intake can move the skill into a plugin unchanged.

Behaviors
  Inputs
  1.  The skill runs on one host a run, named by its SSH short name. It stops,
      saying why, when the host isn't in the project's host descriptors or the
      project has no policy document.
  2.  A host descriptor holds only the short name, the declared model purposes
      (agent, vision, audio, embedding), and optional engine watch items. Every
      other fact comes from probing.
  3.  The policy document states the model-origin rule (every model of Chinese
      origin excluded outright, a fine-tune taking its base's origin), the
      quantization floor in ai-hosting.md's wording, and the memory headroom a model
      set must leave. When the policy lacks a value a step needs, the skill asks.
  Probe
  4.  One bundled, read-only probe runs over `ssh <host>` with no root. It reports
      the OS and its release, the kernel (running, installed, reboot pending), the
      firmware and BIOS version, the GPU and its driver or Mesa stack, memory (total,
      available, the GPU-reachable ceiling), the container runtime, every engine
      container or unit and its state, each running engine's build and served models
      from its HTTP endpoints, and the models in the host's local store. It skips a
      probe whose command is absent and says so.
  5.  The probe never calls sudo and reads no network address. Its output contains
      no tailnet address or MagicDNS suffix, so it can be committed as is.
  Interaction
  6.  When a fact needs root, the skill prints the exact command, asks the architect
      to run it and paste the output, and continues from that output.
  7.  The skill pauses and asks instead of guessing or failing in four cases: the
      probe contradicts the descriptor (say, a served model whose purpose isn't
      declared), sources conflict on a claim, a policy question arises, or a source's
      tier is unclear.
  Sources
  8.  The skill carries trusted sources keyed by kind and vendor, in three tiers:
      primary (vendor and publisher release notes, docs, model cards, upstream
      trackers), attributed benchmarks (naming the hardware, the version, and the
      method), and leads (unattributed posts, never a verify verdict on their own).
      It never cites a blocklisted source, and each blocklist entry gives its reason.
  9.  Every claim in a report cites its source with the URL and the date it was
      read. A paper estimate is marked as an estimate and names its method.
  The report
  10. The report opens with the probed inventory and the descriptor it read. When
      nothing is serving, the inventory says so and the sections rank against the
      installed engines and models.
  11. Hardware configuration: recommended adjustments (kernel, firmware, BIOS, OS
      image, driver or Mesa, memory ceiling). Each gives its sources, the gain they
      claim, its risk, and a verdict: verify, hold, or skip.
  12. Engines:
      - It weighs the incumbent engine and its configuration against the skill's
        seed list (llama.cpp, vLLM, SGLang, and TensorRT-LLM on NVIDIA), filtered
        to what the probed backend supports, and judges a packager by the engine it
        embeds.
      - It scans each run for emerging capabilities and engines, and weighs a
        newly found engine in that run.
      - It answers each watch item by name.
      - It concludes with the most effective engine platform and configuration to
        date for the host, as either an adjustment to the incumbent or a migration.
  13. Models: grouped by declared purpose and sorted by viability, new models
      included.
      - The gates come first: policy (origin, quantization floor), fit in probed
        memory, and the host's engine serving the architecture on its backend.
      - Models that pass then sort by published speed on the same hardware class,
        then by the card's evals for the purpose.
      - A model that fails a gate is listed with the gate it failed. A model of
        Chinese origin is listed under "excluded on origin" and never reaches a
        verdict.
  14. Model set: weighs combinations of one model per declared purpose.
      - The candidates per purpose are the top three that pass the gates, plus the
        incumbent. At most four per purpose is a bound the report states.
      - It keeps the sets that fit the host together within the policy's headroom,
        and that the chosen engine can serve side by side (one process holding
        several models, or one process per model and its memory reservation).
      - It recommends the most effective set, with its estimated memory, why it
        wins, and the runner-up.
  15. "Verify next" names one item across the sections: the highest verify-verdict
      item, lowest risk first among equal claimed gains on the agent purpose, with a
      one-line reason. Within each section, items are ordered verify, hold, skip.
  16. "Proposed changes" lists additions to the watch items, the trusted sources,
      the blocklist, and the engine seed list, each with its reason. A run writes
      nothing except its report.
  17. A report is per host and dated, and is never edited after its date. A later
      run writes a new one. The project's report standard says so.

Test seams    One: the skill run on a host, `/<skill> <host>`, and the report it writes.
              The probe's output, read in that report's inventory, is checked by the
              project check (shellcheck) and by a run on each host.

Slices
  1. Descriptors, policy, and the probe. Framework's and gb10-1's descriptors, the
     policy document, and the bundled probe; the skill's skeleton loads its inputs,
     probes, and pauses on discrepancies and sudo facts (behaviors 1-7). The bench
     Python pin's comment is corrected to name torchcodec. Demo: the session runs the
     probe read-only on framework and gb10-1, shows the inventory with no tailnet
     identifier, and shows one discrepancy prompt.
  2. Sources, hardware configuration, and engines. The tiered sources, the
     blocklist seeded with a reason per entry, and the report's inventory, hardware,
     and engines sections, with the engines conclusion. The report standard becomes
     per host (behaviors 8-12, 17). Demo: an untracked scratch report for framework,
     every claim cited.
  3. Models, the model set, Verify next, and Proposed changes (behaviors 13-16).
     Demo: an untracked scratch report for gb10-1 with all sections, the bound
     stated, and one Verify next item.
  4. Walkthrough (the architect). In a fresh session the architect runs the skill
     on framework, then gb10-1, and commits the two dated reports. For each report
     the architect checks 6 sampled claims (one per kind per host class, across
     both) and each top upgrade's sources in full, then reviews the seeded blocklist,
     striking or keeping each entry.

Out of scope  Any change to a host: no install, no upgrade, no benchmark, no anchor
              run. Verifying or adopting an upgrade (verify-framework, verify-gb10).
              Same-session anchors beside incumbents (screen). The cadence and
              convention (answer). Plugin packaging, and Pi or OpenCode support.
              Reading other spikes' findings, pins, pool, or currency as inputs.

Door          two-way: the task adds a skill, project documents, and reports to the
              spike; its host step only reads, with no root; nothing is released.
```

## Progress

slices 2/3 committed · standards — · spec — · editor — · walkthrough (architect) —

## Decisions

- setup: evidence is six items (the skill; the dated ranked report; top upgrade verified per host
  by anchors A and B; the pool screened; claim beside anchors; the convention and cadence).
- setup: the skill is project-local Claude Code (`.claude/skills/`); rejected a plugin in the
  spike, since the intake can route a plugin to claude-plugins; rejected Pi and OpenCode support
  for the spike.
- setup: kind context; check shellchecks tracked scripts and resolves relative Markdown links;
  currency over mise tools (mise.toml and the bench environment); no gate, no CI; public remote.
- setup: engine changes run spike-model-engines' `engines` suite read-only with the version as its
  argument; rejected copying the suite and presets, which would fork what the intake takes from
  spike-model-engines. A candidate needing its own preset arguments is an escalation.
- setup: a candidate model's anchors use the same shape (A 1×8, B 4×32, 512 in, 256 out) beside
  its role's incumbent in the same session; rejected gpt-oss-120b's anchors alone, which can't
  show another model's speed.
- setup: references spike-model-engines, spike-model-hosting, claude-plugins, dotfiles,
  spike-harness-driver; personal-agents left out as superseded.
- setup: hosts are framework and gb10-1; gb10-2 stays reserved for spike-ai-pipeline.
- setup: GuideLLM 0.8.1 bench environment copied from spike-model-engines so the anchors stay
  comparable; anchor scenarios copied into `bench/`.
- skill: held python at 3.14.10: torchcodec 0.17.0, which GuideLLM 0.8.1's audio extra needs, has
  no cp315 wheel or sdist; 3.14.10 carries 3.15.2's security fix; the pin's comment is corrected
  to name torchcodec.
- skill: the inventory comes from probing each host, with no external artifacts; a descriptor
  records just enough to reach and probe it.
- skill: a host's incumbent is what the probe finds; when nothing serves (gb10-1 since
  2026-10-27), the report says so and ranks against the installed engines and models.
- skill: engines are judged objectively for a better default engine or configuration on the
  hardware, against a seed list filtered by backend plus a scan each run for emerging capabilities
  and engines; watch items supplement that judgement; the section concludes with the most
  effective platform and configuration to date.
- skill: models are judged by compatibility with the host, new models included; viability gates
  on policy, memory fit, and engine support, then sorts by published speed on the hardware class,
  then by card evals.
- skill: a model-set section weighs one model per purpose, from the top three gate-passing
  candidates plus the incumbent, and recommends the most effective set that fits together.
- skill: one host a run; sections cover hardware configuration, engines, models by purpose, the
  model set, Verify next, and Proposed changes.
- skill: verdicts as round 1 stated them: verify takes an attributed, same-class measured gain and
  no reported regression; hold is release notes only, another class, or a root step with no
  rollback; skip is no gain, a regression, or a broken rule.
- skill: unattributed posts are leads; trusted sources (three tiers) and a blocklist live in the
  skill, keyed by kind and vendor; the session seeds the blocklist with reasons and the architect
  reviews it in the walkthrough.
- skill: tooling lives in the skill; no other spike's currency, findings, or pool is an input.
- skill: host descriptors (short name, purposes, watch items) and a policy document (origin,
  quantization floor, headroom) live in the project, outside the skill.
- skill: the policy excludes every Chinese-origin model outright, a fine-tune taking its base's
  origin.
- skill: a run proposes changes to the watch items, sources, blocklist, and seed list in its
  report, and writes nothing else.
- skill: the probe is one read-only, no-root shell script in the skill, run over ssh, reading no
  addresses; rejected fastfetch (DGX hosts only; reads no GTT, container, or engine state).
- skill: the skill is interactive: it prints exact sudo commands and asks for their output, and
  pauses on discrepancies, conflicting sources, and policy questions.
- skill: the session runs the read-only probe on both hosts during build; the skill's first full
  run is the architect's walkthrough, which commits both hosts' reports, checks 6 sampled claims
  and each top upgrade's sources.
- skill: reports are per host and dated, at docs/reports/<host>/<YYYY-MM-DD>.md; STANDARDS.md's
  report rule changes in this task.

## Pending edits

- coordinator · roadmap: task `skill`'s summary, "with no host step" becomes "with read-only, no-root host probes".
