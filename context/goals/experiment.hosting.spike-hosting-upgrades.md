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

### Revision · redirect at BRIEF, approved 2026-10-30

Problem, Test seams, Out of scope, and Door are unchanged. These behaviors are amended or added, and
the slices continue as below (an exception to the four-slice limit, approved with this revision):

```
Behaviors (amended)
  3.  The policy document also states two readings:
      - The floor's "card evals within about 1% of BF16" means every eval the
        card reports for the checkpoint is within about 1%, relative.
      - A model whose base can't be established from its card, its API record,
        or its publisher's repository or paper is held out as "origin unclear",
        without a pause. It is listed beside "excluded on origin" with what the
        run checked.
  4.  The probe is run by its project-relative path, the same literal path the
      readiness check's ssh rules name.
  5.  The probe prints no network address: it reads only ports and drops the
      address.
  7.  The origin pause narrows to conflicting origin evidence. Undocumented
      origin no longer pauses (behavior 3).
  8.  The skill reads sources with WebSearch and WebFetch, GitHub included
      (release pages, api.github.com JSON, raw files), and runs no curl. It
      searches GitHub with `gh search`. A prompted `gh api` call is only the
      fallback when unauthenticated API reads run out.

Behaviors (added)
  18. A readiness check, run after the inputs load at the start of every run:
      - It works out the permission rules this workspace needs: one exact ssh
        probe rule per host in the descriptors, `gh search issues` and
        `gh search prs`, WebSearch, WebFetch, and edits under the reports
        directory.
      - It reads the project's .claude/settings.json and
        .claude/settings.local.json.
      - It prints the exact JSON for every missing rule and the file it belongs
        in: settings.json for a skill inside the project, settings.local.json
        for one installed outside it.
      - It then asks whether to continue with prompts or wait while the
        architect adds the rules.
      - It never writes a settings file, and it prints no rule for `gh api`.
  19. `/hosting-upgrades setup` runs the readiness check alone and prints the
      full rule set, for a new workspace or a new host, without starting a run.
  20. The skill's frontmatter grants no tools. A frontmatter grant clears at the
      first pause, so the durable rules come from the readiness check.

Slices
  1-3. (committed)
  4. Readiness check and policy readings (behaviors 3, 4, 5, 7, 8, 18-20): the
     check and `setup`; the frontmatter without allowed-tools; the probe run
     by its project-relative path; sources.md's GitHub and curl reads moved to
     WebFetch; the policy's two readings; the narrowed origin pause; the
     finding gains gb10-1's 2026-10-30 probe after its kernel update. Demo:
     `setup`'s printed rules for framework and gb10-1, checked against the
     current settings files (nothing is written), and a scratch run's
     Inventory showing the check's output.
  5. Walkthrough (the architect), as slice 4 was. It starts with
     `/hosting-upgrades setup`: the architect adds the printed rules to
     .claude/settings.json and commits them on `skill`, then runs framework
     and gb10-1. Pause 3c: the gb10-1 run resolves VibeVoice-ASR-Streaming-7B's
     base from Microsoft's VibeVoice repository or paper.
```

### Revision 2 · after the framework walkthrough, approved 2026-10-30

```
Amended
  3.  Policy: the floor's three paths (D1). Origin: any involvement of an
      adversarial entity at any level (D2), with judges, labelers, and
      translators among the levels. Conventions aren't involvement (D3), and
      components are judged as shipped (D4). Data: only data an
      adversary-origin model generated, labelled, judged, or translated
      excludes a model, subsets included. Human-made datasets are recorded as
      dataset sources, and subsets that can't be told apart make the model
      origin unclear. Research comes before "origin unclear".
  8.  Sources:
      - the "Origin and build checks" table (eCFR 791.4 by its renderer API,
        the screening list by screen.sh, HF records and organization overviews,
        ggml-org's .src_sha)
      - the run's 11 accepted sources and the tracker stand-ins
      - an attributed Vulkan benchmark must name its Mesa or driver version
      - the workspace's own same-host measurements count as attributed when a
        host's descriptor lists them; only same-session cells compare
      - curl appears only inside screen.sh and the probe
  11. Verdicts become verify, take, hold, skip:
      - "take" is a version update with no claim and no reported regression,
        applied with the next host update.
      - "Measured slower, but ahead on evals" is hold.
      - Every section orders verify, take, hold, skip, and Verify next names a
        verify item only.
  13. The agent purpose is gated on the policy's agent quality bar (named
      evals with floors, and the tool-reliability check). Speed sorts only
      among the candidates that clear it; one with no comparable evals is
      hold, "needs measurement". Model rows name the exact repository and
      file, the build, and the projector with its precision. The floor path
      comes from the build, not the label.
  14. The model set places each incumbent in step 7's order. A model serving
      two purposes is estimated at the more demanding purpose's
      configuration.
  16. Proposed changes gains a fifth list, "Policy and the model gates".

Added
  21. The skill's frame: it finds and ranks everything a workstation has
      fallen behind on. A "System updates and debt" section covers:
      - pending package updates (apt's cached lists with their age; Arch's
        checkupdates)
      - firmware updates (fwupdmgr get-updates)
      - failed units, and units a descriptor or container implies should run
      - container images behind their tag's latest release
      - unused images and models taking disk
      - configuration that differs from the descriptor
      - the existing kernel, reboot-pending, and boot-order checks
      Each item gets a verdict, and the probe skips any read whose command is
      absent. Hardware asks which components reach the engine (a container
      carries its own Mesa and ROCm, cited from the image's Dockerfile or
      labels).
  22. The probe prints the router preset's serving keys, filtered like the
      flags lines, read without root from its mounted path.
  23. A "Research" section defines the partition (hardware and system,
      engines, agent models, other models, origin) and the tools each part
      may use: WebSearch, WebFetch, gh search, screen.sh.
  24. screen.sh: a bundled script that downloads trade.gov's public CSL JSON
      once a day into .state/ and matches normalized names with jq. A miss is
      "no match". The readiness check prints its exact rule.

Out of scope (amended): applying any fix stays out of this task. The skill
finds and ranks; verify-framework and verify-gb10 apply the take and verify
items, with rollbacks.

Slices
  1-4. (committed)
  5. Tuning: behaviors 3, 8, 11, 13, 14, 16, 21-24. Also:
     - the wording "origin" for who was involved and "build" for how a file
       was made, with "provenance" gone
     - the granite example corrected: the served conversion stays origin
       unclear, as the run found
     - the root-command example in its `ssh -t <host> sudo` form
     - D5's leads
     - the accepted blocklist entry, seed engine, and framework watch items
     - the agent quality bar in docs/policy.md, its floors proposed from
       spike-model-hosting's pool.md for the architect to confirm in the
       validation run
     Demo: setup prints eight rules; the probe's new reads run read-only on
     both hosts; screen.sh matches a known listed entity and misses a known
     clean one.
  6. Validation walkthrough (the architect): /hosting-upgrades gb10-1 with the
     tuned skill. Commit framework's report, the gb10-1 report, and the
     settings rules (now eight).
```


## Progress

slices 5/5 committed · standards ✓ (3 fixes) · spec ✓ (editor gaps only) · editor ✓ · validation (architect, slice 6) —

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
- skill: the skill is named `hosting-upgrades`, at `.claude/skills/hosting-upgrades/`.
- skill: the inputs live at `docs/hosts/<host>.md` and `docs/policy.md`.
- skill: the policy's memory headroom is a placeholder, 10% of the GPU-reachable ceiling, for the
  architect to adjust.
- skill: the watch items are seeded from the architect's examples and the open items of
  spike-model-engines' answer.
- skill: when a host port fails, the probe reads the engine's endpoints from inside its container
  on localhost.
- skill: the probe's redaction also covers tailnet IPv6 and uppercase forms; it drops DGX serial
  numbers.
- skill: the probe prints no network address: it reads listening ports and drops the address,
  reading behavior 5's "reads no network address" as "prints none".
- skill: when nothing serves, each purpose's incumbent is the stored model that ranks first under
  the skill's step 7 gates.
- skill: a run asks before replacing a report that already carries today's date.
- skill: the probe reads no engine settings set by environment variables or preset files; a later
  task takes them up.
- skill: the base_model origin trace and the same-day report check stay prose in the skill, not
  scripts.
- skill: a group row in a report's Sources never replaces an inline citation, and a search summary
  is never the cited source.
- skill: `docs/findings/skill.md` records the probe runs.
- skill: the skill reads its permission rules and prints what's missing; it never writes
  settings; rejected a setup that writes them, since a checked-in skill editing its own allow
  rules is a self-granting path that a later edit or an injected page could widen.
- skill: the readiness check runs at the start of every run and as `/hosting-upgrades setup`;
  its JSON points to settings.json for a skill in the project and to settings.local.json for
  one installed outside it.
- skill: one exact ssh probe rule per described host; rejected a wildcard host, which lets ssh
  options such as ProxyCommand ride along.
- skill: no `gh api` rule, since settings.json applies to every agent in the workspace,
  including their git and gh writes; GitHub reads go through WebFetch; rejected deny rules on
  write flags, which would block other agents' writes.
- skill: WebSearch and WebFetch on every domain; the curl reads move to WebFetch; edits under
  docs/reports/ are allowed.
- skill: the frontmatter drops allowed-tools, whose grant clears at an interactive skill's
  first pause.
- skill: the floor's "within about 1%" means every reported eval, relative; Nemotron 3.5 Super
  VL NVFP4 fails it (WebVoyager -14.7%).
- skill: undocumented origin is held out without a pause; the walkthrough resolves
  VibeVoice-ASR-Streaming-7B's base.
- skill: the task runs five slices, an exception to the experiment's limit of four, which the
  architect approved with the revised brief.
- skill: gb10-1 took a system update on 2026-10-30 (kernel 7.0.0-1019 to 1024), by the
  architect; the walkthrough's fresh probe judges the new kernel.
- skill: the readiness check is a section run at the end of step 1, not a numbered step, so
  references to steps 2-11 stay valid; its default answer is "wait".
- skill: a rule counts as present only when it matches a string in either project settings file
  exactly, so a broader rule shows as missing.
- skill: the probe runs with no `timeout` and no output redirect, so it matches its exact rule;
  the walkthrough first tests whether Claude Code's matcher accepts the rule's `<` redirect.
- skill: the floor's "evals mostly within the margin" pause is gone, since the policy's reading
  of "within about 1%" decides it; a format the floor doesn't name still pauses.
- skill: the probe reports `ip_nonlocal_bind` for IPv4 and IPv6, and classes each engine
  container's published ports and configured binds as tailnet4, tailnet6, all, loopback, or
  other, never printing the address; the architect decided this after gb10-1's boot-order failure
  of 2026-10-30.
- skill: the hardware step's boot-order check flags a tailnet bind whose family's
  `ip_nonlocal_bind` is 0, and a running container that publishes nothing though it has
  configured binds.
- skill: the boot-order recovery is `docker network connect bridge` for a container on no
  network, and `docker restart` for one on a network that failed to bind; the rollback removes the
  sysctl file, then runs `sysctl -w <key>=0` or reboots.
- skill: the probe's `curl` calls stay: they read engines on 127.0.0.1, from the host or inside
  an engine's container, not sources.
- skill: the probe classes an IPv4-mapped IPv6 address by its IPv4 part.

- skill: the floor reads as three paths (architect, 2026-10-30): trained-in formats (native, QAT) pass
  by name when the publisher releases them; publisher post-training checkpoints pass only with every
  reported eval within about 1% relative; everything else meets Q5_K_M/FP8, and embedding, ASR, and
  dense models under 8B effective meet Q8_0/FP8. This amends behavior 3's floor reading.
- skill: a file's floor path comes from its provenance (the publisher's repo and card, the GGUF or
  card base_model), never its label; ggml-org's Gemma 4 26B-A4B Q4_0 is post-training and fails,
  Google's QAT passes (from gb10-2's finding, 2026-10-30). Rows name the exact repo, file, and
  projector with its precision.
- skill: origin excludes any involvement of a Chinese AI lab or other entity adversarial to the USA,
  at any level (architect, 2026-10-30): 15 CFR 791.4 countries, entities domiciled in or controlled
  from them, the Consolidated Screening List; levels are publisher and uploader, the base chain, a
  distillation teacher, a synthetic-data generator, and components. A pass means no disclosed or
  detected involvement. Stricter than ai-strategy.md and than the brief's first rule.
- skill: "origin unclear" first triggers further research (uploader identity and affiliation, the
  conversion against the publisher's weights, the publisher's channels); only what research can't
  settle is held out, with no pause (architect, 2026-10-30). Amends behaviors 3 and 7.
- skill: origin is never a pause; a file whose floor path provenance doesn't settle pauses, defaulting
  to "fails the floor".
- skill: the Consolidated Screening List's downloads exceed WebFetch's 10 MiB and its search API needs
  a key, so a run writes "screening list not read" until the architect decides; eCFR is read through
  its renderer API.

- skill: the Consolidated Screening List is read by a second bundled script that downloads trade.gov's
  public CSL JSON once a day into .state/ and matches normalized names with jq (architect, 2026-10-30);
  rejected a developer.trade.gov key and dropping the list. A miss is "no match", never clean. It is
  behavior 8's one curl exception, and the readiness check prints its exact rule. Built in the tuning
  pass after the walkthrough.
- skill: revision 2 (architect, 2026-10-30), after the framework walkthrough. Data: only data an
  adversary-origin model generated, labelled, judged, or translated excludes a model; human-made
  datasets are recorded as dataset sources (rejected excluding any adversary-authored dataset, which
  punishes disclosure, and a disclosure bar, which makes gpt-oss and Gemma 4 origin unclear).
- skill: the agent purpose is gated on a quality bar that docs/policy.md states; speed sorts only
  among candidates that clear it.
- skill: a fourth verdict, "take", for an update with no claim and no reported regression.
- skill: the workspace's own same-host measurements count as attributed when a host's descriptor
  lists them; this partly reverses round 1's "no prior artifacts" for sources a project points to.
- skill: SKILL.md defines the research partition and its tools; curl only inside screen.sh and the probe.
- skill: the probe prints the router preset's serving keys; attributed Vulkan benchmarks name their
  Mesa or driver version; the walkthrough's Proposed changes are accepted.
- skill: the skill finds and ranks a workstation's accumulated tech debt (system updates, firmware,
  failed units, stale images, unused disk, configuration drift); applying fixes goes to
  verify-framework and verify-gb10.
- skill: the wording is "origin" (who was involved) and "build" (how a file was made), not
  "provenance", which the team wouldn't readily understand.
- skill: the task runs six slices, a second exception the architect approved with revision 2.
- skill: revision 2's D labels: D1 is the floor's three paths; D2 is origin, any involvement of an
  adversarial entity at any level; D3 is that conventions aren't involvement; D4 is that components
  are judged as shipped; D5 is the five sources the architect ruled leads in the framework run of
  2026-10-30; D6 is the evidence chain for origin.
- skill: revision 2's behavior 22 supersedes "the probe reads no engine settings set by ... preset
  files"; the probe still reads no engine settings set by environment variables.
- skill: take needs a known rollback; a root step with no rollback is hold; an engine build is
  never take.
- skill: the probe prints the remote user's home as `~`; container-side paths such as /home/vllm
  stay.
- skill: slice 5's standards review fixes: the checkupdates warning lines are guarded; the preset
  file has a size bound, and a path-named section prints as a file name; screen.sh validates its
  download, uses https only, and passes names after `--`; normalization drops dotted abbreviations
  and more company suffixes, after "Samata" missed "SAMATA S.A.".
- skill: the agent bar (architect, 2026-10-30): a card's published BFCL figures for the matching
  categories count against the floors, with the gap stated; tool reliability is always "needs
  measurement", so a candidate that clears the floors is hold, never verify, until measured locally.
- skill: the framework walkthrough (architect, 2026-10-30): its report and the seven rules are
  committed as 12067db; its six sampled claims and the blocklist review are done. It ran in auto
  mode, so whether the exact ssh rule matches outside auto mode is untested.

## Pending edits

- coordinator · roadmap: task `skill`'s summary, "with no host step" becomes "with read-only, no-root host probes".
- coordinator · roadmap: verify-framework's and verify-gb10's summaries gain "applies the run's take and verify items, with rollbacks".
