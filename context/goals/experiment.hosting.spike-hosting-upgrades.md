# goal · experiment.hosting.spike-hosting-upgrades

- **State:** brief ready
- **Task:** answer
- **Branch:** answer

## Tasks

1. [x] skill
2. [x] verify-framework
3. [x] verify-gb10
4. [x] screen
5. [x] skill-revision
6. [ ] answer

## Task brief · answer

```
Problem       The spike has a revised skill but has not shown the skill
              repeating itself, and its convention is unwritten. framework
              has no report from the revised survey; its last is the old
              skill's 2026-10-30-2. gb10-1's only revised survey, of
              2026-11-06, researched in full, so the research cache and
              "only what moved" have never been tested on a repeat run.
              The skill's entry file says survey runs "on a cadence", and
              nothing defines that cadence. gb10-1's 2026-11-06 proposals
              were never settled. README "The answer" is empty, and the
              experiment's intake needs this spike's answer section. This
              task runs the second survey on each host, writes the
              convention and its cadence from what the two surveys show,
              and gives the spike's answer. No new tool and no local cells.

Behaviors
  Hosts current, proposals settled
  1.  Before either survey, the architect brings framework and
      gb10-1 up to date with root, from the exact commands the plan
      agreed. Each command appears in the record as run, with what it
      changed and its rollback. A reboot happens only when the kernel
      or firmware changed, and the probe then reads back the running
      kernel and that the router serves its set.
  2.  Before gb10-1's survey, each of its 2026-11-06 proposals is
      settled one at a time: the four descriptor watch-item changes,
      the four trusted sources, the blocklist entry, and the DGPP
      engine seed. The architect accepts or rejects each one. The
      session applies the accepted ones, and each decision is logged.
      The policy proposals, already decided on 2026-11-06, are read as
      settled.

  The second surveys
  3.  A revised survey of framework, run on the day BUILD starts,
      writes that day's dated report (named -2 when the day already has
      one). Its Inventory compares the probe with 2026-10-30-2 and
      states what moved. Among the moves it reads are the no-cache keys
      on the agent section (clone at 933ec0f), the host update, and the
      descriptor's load targets. It also states whether it researched
      in full or only what moved.
  4.  A revised survey of gb10-1, run on the same day, writes its dated
      report the same way. It compares with 2026-11-06, reads the
      descriptor as behavior 2 left it, and states what moved since
      then.
  5.  Each report gives its research-cache counts: entries cited, read
      fresh, and deleted. It also gives each blocker register entry's
      state as checked upstream with gh, and its Verify next and Needs
      measurement lists. The register and the cache are updated in
      place. Neither survey applies anything, and no cell runs.

  The convention and its cadence
  6.  One convention document states:
      - when survey runs: weekly per host, and on these event triggers:
        a host update, a register entry reaching "fix in an image
        build", a change to the descriptor's purposes or load targets,
        and before any change to the host;
      - what triggers a measure: a survey's verify item or Needs
        measurement entry; one measure per session; its cells agreed
        in that task's plan round;
      - the record an adoption leaves: the report, then the measure
        record quoting its command log, then the descriptor, the pin,
        and the register entry's state;
      - how proposals are settled between surveys;
      - the blocker register and its four states;
      - the research cache and its 14-day rule;
      - per-host load targets, and spike-model-layout's ownership of
        them;
      - what stays with the backlog goal model-evaluation: workloads
        only we can measure, our agents and our role sets under our own
        sessions, and tuning at scale.
      Each statement cites the record that shows it, the two second
      surveys among them. The skill's entry file points to the
      document for its cadence.
  7.  README "The answer" states the question, a one-line answer, and
      evidence 1 to 6, each item naming where it is proven. It links
      the convention document.
  8.  The goal record's pending edits gain this spike's answer section
      for the coordinator's ai-hosting.md, in the "Answer section"
      form: Question, Answer, numbered evidence, gaps, and
      "Requirements for the intake to route", which carries BFCL's
      max_tokens per tier for spike-model-hosting's agent-tier harness.
      The two existing pending edits stay. The project's context notes
      name the convention among the capabilities and mark the Path's
      last task done.

Test seams    the skill's survey verb, run by the session; the check
              (shellcheck, links); each report's Inventory against the
              host's previous report

Slices
  1.  Hosts current, proposals settled (behaviors 1, 2). The
      architect: the root updates on both hosts, plus a reboot only
      when the kernel or firmware changed, and a decision on each of
      gb10-1's proposals. The session: records the commands as run,
      reads back with the probe, applies the accepted proposals, and
      runs setup. Demo: the probe's read-back on both hosts; the
      descriptor, sources and blocklist changed; check passes.
  2.  The second surveys (behaviors 3–5). The session runs survey
      framework, then survey gb10-1: probes over Tailscale SSH with no
      root, the research, and the reports, register and cache. The
      architect answers any pause and reads out any fact that needs
      root. Demo: two dated reports, each stating what moved and its
      cache counts; check passes.
  3.  The convention and the answer (behaviors 6–8), written by the
      session. Demo: the convention document, README "The answer", the
      answer section and the Sync list in the record; check passes.
  4.  Walkthrough, the architect's: from the convention document, run
      setup; read one host's "what moved" against its previous report;
      read one register entry back against gh; read one cached
      citation's read date against the 14-day rule; review the answer
      section and the Sync list.

Out of scope  any local cell or measure; an engine move on either host
              (framework stays on b11960 and gb10-1 on b12098); applying
              a survey's take or verify items beyond the system updates
              of behavior 1; changing any served set, preset or load
              target; spike-model-engines' host/; the coordinator, beyond
              the pending edits the Sync carries

Door          two-way: the reports, convention, README, register, cache
              and descriptors are this repository's files. The system
              updates roll back by booting the previous kernel and
              downgrading packages from the pacman cache on framework, or
              by pinning the apt version on gb10-1.
```

Release: none.

## Progress

- Slice 1, host updates (architect, root, 2026-11-06), read back by the probe (`.state/answer/probe-<host>.txt`):
  - framework: `sudo fwupdmgr refresh --force`; `fwupdmgr get-updates` listed no update, and its
    "System Firmware 0.0.3.5 -> 0.0.3.6 updated successfully" is history (BIOS 03.06 dated
    07/13/2026 already running, booted 2026-11-02). `omarchy update`: mise-bin 2026.11.1-1 ->
    2026.11.2-1, pnpm 12.16.1 -> 12.18.0 (mise), 3 cached packages pruned, a snapper snapshot
    taken. No reboot (kernel 7.2.15-1-omarchy and firmware unchanged). Rollback: the snapshot from
    Limine, or `pacman -U` mise-bin 2026.11.1-1. Probe: 0 pending, no failed units, router on
    b11960 with set A's no-cache keys.
  - gb10-1: `sudo apt update && sudo apt upgrade`: 12 upgraded, 8 new; kernel 7.0.0-1024 ->
    7.0.0-1025-nvidia (image, modules, nvidia-580-open, nvidia-fs, headers, tools), ca-certificates
    20260816ubuntu0.24.04.2, ca-certificates-java 20240118ubuntu0.24.04.1, sqlite3/libsqlite3-0
    3.45.1-1ubuntu2.9, linux-crashdump/libc-dev/tools-common 6.8.0-149 (2 LTS security updates).
    `sudo apt autoremove`: kernel 7.0.0-1019 removed. `fwupdmgr get-updates`: none. No driver or
    container-toolkit change, so no CDI regenerate. `sudo reboot`. Rollback: boot 7.0.0-1024 from
    GRUB's Advanced options (still installed), packages by `apt install <pkg>=<version>`. Probe:
    running 7.0.0-1025-nvidia, booted 13:13:14, driver 580.178.04, `initcall_blacklist` on the
    command line, 0 pending, no failed units, router healthy on b12098 with its set listed.
- Slice 1 done: the host updates above (`e52aee9`), and gb10-1's ten 2026-11-06 proposals
  accepted and applied (`2c507cc`).
- Slice 2 done: framework's second survey, 2026-11-06 (`d5d9825`), with its four pauses settled
  (`1fc8aee`); gb10-1's, 2026-11-06-2 (`6859a30`), with its one pause settled (`acfb0b8`,
  `2746fec`).
- Slice 3 done: `docs/convention.md`, README "The answer", the answer section in Pending edits,
  and the 0cc4m, slb350 and Liquid tier rulings in sources.md (`b977791`).
- Standards review fixed in `0e8d7ed`: the one-line answer, citations that hold, and prose form.
  Spec review fixed in `b24dc85` (hclsys's tier ruling in sources.md; the cadence stated without
  a due date) and in the edit pass after it (the second surveys' open proposals listed item by
  item; citations for "one measure a session" and the workloads only we can measure).
- Next: slice 4, the architect's walkthrough.
- Slice 4, the architect's walkthrough, done (2026-11-09). Session brief written; State brief ready.

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
- skill: the origin rule is refined (architect, 2026-10-30, during the gb10-1 validation run). A
  level excludes by how much control it gives an adversary's model over the served behavior:
  weights (publisher, base chain, merges), behavioral training signal (a teacher, a generator of
  the responses, traces, or preferences trained on), and components in the inference path
  (encoders, projector, tokenizer) exclude. Narrow transformations (punctuation restoration,
  translation, filtering, quantization calibration), components outside the output path (a
  speculative-decoding drafter), and conventions are recorded, not excluded. The data rule narrows
  to the behavioral signal. Compliance (an adversarial publisher or uploader) is its own gate, and
  a new artifact-integrity gate passes GGUF and safetensors and fails code-running checkpoints.
  Rejected "any contact at any level", which the gb10-1 research showed caught a drafter,
  calibration data, and a punctuation labeler, none of which can steer output, and which excluded
  the publishers that disclose their data. Amends behavior 3 and revision 2's data rule. A local
  behavioral probe for adversary-aligned output is proposed, not adopted.
- skill: the gb10-1 validation run's findings and refinements are consolidated in a session
  report at the end of the session (architect, 2026-10-30).

- skill: revision 3 (architect, 2026-10-30, rounds 6 and 7): the 12 improvements from the gb10-1
  validation land in this task, as slice 7 (R1-R12), then fresh runs on both hosts (slice 8)
  before SHIP. A same-model, same-bit-width speed figure stands in for sorting, never for verify;
  cross-card evals compare only on the same suite version and tasks; accepted code is a policy
  list the architect edits; a loaded adversary-origin drafter is a configuration fault, not an
  exclusion; the minimum agent session context is 32,768 tokens; a later same-day report is
  <date>-2.md. Eight slices, a third exception the architect approved.
- skill: a later run on a host that already has that date's report writes `<date>-2.md`, then -3,
  and so on, and never edits or replaces the earlier report. This supersedes "a run asks before
  replacing a report that already carries today's date."
- skill: a host's last report is the one with the newest date and, within that date, the highest
  -N (SKILL.md step 11). R8's unchanged-host run cites that report.
- skill: slice 7's standards review fixes: drafters() never prints a silent "none", so a key with
  no value prints "(value unread)", a trailing slash is dropped, and a shell-form command is read
  word by word; the finding records the source reads exactly as they were run.
- skill: artifact integrity reads the per-file record first: the Hub's tree listing, with each
  file's security scan and pickle imports (decided by the session within R11). It counts as "the
  HF record's file metadata", because the repository-level gguf record doesn't settle each file in
  a repository that holds several quantizations.
- skill: on vLLM, a session's context is `--max-model-len`, which caps each request; it isn't
  divided across `--max-num-seqs`.
- skill: serving_flags() reads a shell-form command word by word, as drafters() does.

- skill: framework's fresh run (architect, 2026-10-30, report 5560087): a per-file Hub scan still
  "queued" is settled by the architect's no-root read, on the host, of each stored GGUF's first 4
  bytes; all 12 stored files read `GGUF`.
- skill: Protect AI's PAIT-GGUF-100 message under an overall "safe" status is recorded in the
  row and doesn't fail the file (architect, framework's fresh run).
- skill: a QAD (Quantization-Aware Distillation) Q4_0 is not a trained-in format; it takes floor
  path 3 and fails, so the rows name the Q8_0 or Q5_K_M file (architect, framework's fresh run).
- skill: framework's fresh run keeps the default source tiers (architect): vLLM #60413's table and
  llama.cpp #31266's author table are leads, the gregkh/linux stable mirror is primary, and
  AMD-named CONTRIBUTOR accounts on ROCm/TheRock are leads.
- skill: gb10-1's fresh run (architect, 2026-10-31, report 26b6c37): 2026-10-30's answers stand.
  The valid set is gpt-oss-120b MXFP4 (agent), Gemma 4 QAT Q4_0 26B-A4B or 31B (vision), Gemma 4
  E4B QAT Q4_0 (audio), and granite BF16 (embedding); vLLM stays down, and the vLLM container and
  both bare-metal units are to be removed.
- skill: NVIDIA's Local AI Inference Recipes figure for GB10 is a lead (architect, gb10-1's fresh
  run): it measures vLLM in a community nightly image, with MTP, from a repository that says it
  was created with AI assistance.
- skill: Granite 4.1 30B's origin (architect, 2026-10-31, reconciling the fresh runs): gb10-1's
  exclusion stands, since IBM's disclosure file lists SYNTHETIC-1, which is DeepSeek-R1 reasoning
  traces (level 2). It supersedes framework's pass, which read only the card, and the same holds
  for granite-switch-4.1-30b, which shares the lineage. A run reads a publisher's disclosure file
  whenever the card points to one. granite-speech-5.0-2b still passes: it uses SYNTHETIC-1 only
  as seed problems, with responses regenerated by Phi-4-reasoning.
- skill: a distillation teacher the card doesn't name passes only when the publisher's own
  documents say it is a checkpoint from their own pipeline; otherwise the model is origin unclear
  (architect, 2026-10-31). So LFM2.5-24B-A2B is origin unclear, as gb10-1 found, superseding
  framework's pass; LFM3-VL-2B passes, since its card's caption names Liquid's own vision-RL and
  Mixed RL models as the teachers.
- skill: a "queued" Hub scan, combined rule (architect, 2026-10-31). A file stored on the host is
  settled by the on-host magic read. A candidate not yet stored is settled by the Hub's per-file
  "Safe GGUF model". While that scan is queued, the repository-level parsed GGUF header settles
  it only when the repository holds no `.bin`, `.pt`, or pickle weight files and the host engine
  is llama.cpp, with the magic read repeated on download. llama.cpp's loader rejects a non-GGUF
  file rather than executing it; the vLLM and transformers paths, where pickle runs, keep the
  strict rule. The probe taking the magic read itself is proposed for a later task, not built.
- skill: open, for the architect to accept or reject: for agent candidates, an adversary-family
  convention (Flint's GLM-style tool tags, say) together with a publisher silent on its SFT and
  RL generators removes the benefit of the doubt, so the model gets further research before it
  can pass.
- skill: open, for the architect to accept or reject: a check that compares a GGUF's embedded
  chat template with the publisher's `tokenizer_config.json` template, since the engine's
  template renderer executes templates.
- skill: the next run reads IBM's disclosure file, if one exists, for
  `ibm-granite/granite-embedding-english-r2`, the embedding incumbent on both hosts, which both
  fresh runs pass on IBM's paper alone.

- skill: Revision 4, round 1 (architect, 2026-10-31). Accepted:
  - the chat-template check (a template adding text the model sees fails integrity)
  - PAIT-GGUF-100 passing by name only
  - the two policy items (granite clause, headroom held by sizing)
  - the two models.md items (second identity link, xet 302 "read not made")
  - sources a-h
  - the probe's channel and mirror, and the no-root package ask
  - framework's and gb10-1's watch items
  - screen's BFCL pending edit
  - the gb10-1 removals going to verify-gb10
  Rejected: sources i (SiliconBench and forum posts as Known-leads rows), since no ruling made
  them leads. Deferred: the project's granite-embedding conversion.
- skill: the origin bar, in the architect's words (2026-10-31): "the origin of the model, and any
  models it is directly trained on, are not adversarial and have been deemed safe for use."
  - Excluding: the publisher or uploader, the weights chain, distillation teachers (read by role,
    including an adversary model whose outputs are the principal post-training corpus), and
    inference-path components.
  - Recorded as dataset sources: adversary-generated data in a training mix.
  - Rejected: the 2026-10-30 level-2 data clause, and the silent-publisher tightening. They would
    limit the pool drastically, and some adversary-origin research is nearly unavoidable in open
    weights. This supersedes the 2026-10-31 granite exclusion.
- skill: watch items are of any kind (hardware, system, engine), answered in their kind's section
  (architect, 2026-10-31).
- skill: scripts/magic.sh reads a Hugging Face file's first 4 bytes by ranged curl, from a
  repository and file name, never a URL, under its own exact rule; setup prints nine rules. It
  replaces the repository-level GGUF header fallback (architect, 2026-10-31).
- skill: the Hub's per-file scan settles a safetensors file, since its format marker sits past
  the first 4 bytes, which hold only its header length's low bytes; the first 4 bytes settle GGUF,
  a pickle, or a zip (revision 4, slice 9).
- skill: a Hub scan still "queued" names no format and settles nothing, so magic.sh reads the file
  (revision 4, slice 9).
- skill: the probe works out the Omarchy channel from which channel's template each pacman file
  still matches, since omarchy-channel-set copies the templates and stores no channel; it prints
  each pacman.conf repository's Server or Include line (revision 4, slice 10).
- skill: the probe prints `magic` lines for GGUF files in a plain store as well as in a Hugging
  Face cache (revision 4, slice 10).
- skill: magic.sh is hardened beyond the brief: curl's `-f`, https only for the request and its
  redirects, `--max-filesize 64` against a server that ignores the range, `LC_ALL=C` so the
  allowlist is ASCII only, and `-q` so no `~/.curlrc` adds options (revision 4, slice 10 and the
  standards review).
- skill: the no-root package ask covers apt hosts too, with `ssh <host> dpkg-query -W <package>`
  (revision 4, slice 10).
- skill: sources.md gains an Ubuntu table (the Launchpad publishing history and
  packages.ubuntu.com), and its Known leads table gains a "Ruled" column with each ruling's date
  (revision 4, slice 11).
- skill: the model parts (3 and 4), not only the origin part, may run magic.sh, since they check
  each file's artifact integrity (revision 4, the spec review's one gap, closed in 476299e).
- skill: a card points to a disclosure file when it links the file, or the publisher's repository
  or GitHub organization that holds it; the run looks for a `disclosures/` path there (architect,
  2026-10-31, walkthrough).
- skill: a stored file that isn't GGUF (a safetensors snapshot) gets no probe `magic` line and is
  settled as any other file, by the Hub's per-file scan or magic.sh (architect, 2026-10-31,
  walkthrough).
- skill: left for a later pass: the probe's older `compgen -G "$store/models--*"` check reads glob
  characters in a store's name as a pattern. It is outside revision 4's diff.
- plan: the five coordinator pending edits (skill's summary; verify-framework's and verify-gb10's
  take and verify items, with rollbacks, and verify-gb10's decided removals; screen's BFCL samples
  and tool-reliability check; spike-model-layout's role-split idea) landed early through this
  goal's plan, standards-lab PR #110 (architect, 2026-10-31). verify-framework's next brief is
  left to `start`.
- verify-framework: the task verifies Gemma 4 E4B QAT Q4_0 as framework's audio model, the
  2026-10-30-2 report's Verify next, with no fresh run; its gates are re-checked under today's
  policy, the chat-template check included (architect, 2026-11-02).
- verify-framework: every hold item in the 2026-10-30-2 report is settled in this task: applied,
  removed, or closed with its reason (architect, 2026-11-02).
- verify-framework: the skill's verification step is a second mode, `/hosting-upgrades verify
  <host>`; a report run stays read-only, and the verify mode is the skill's only change in this
  task (architect, 2026-11-02).
- verify-framework: the verdict rule is to adopt only when anchors A and B after the change are
  within 1.4% of before and no candidate cell is behind the incumbent by more than 1.4%;
  otherwise roll back. 1.4% is the widest run noise the workspace recorded (architect,
  2026-11-02).
- verify-framework: anchors A and B run on gpt-oss-120b's 4-slot section, the one every earlier
  framework anchor used, with set A's agent section unloaded meanwhile (architect, 2026-11-02).
- verify-framework: linux-omarchy 7.2.15-1 is applied through `omarchy update`, a root step for
  the architect, then a reboot. Rollback is to boot Arch linux 7.2.11, then `sudo pacman -U` the
  cached 7.2.8-9 linux-omarchy and headers (architect, 2026-11-02).
- verify-framework: no anchor pass runs before the kernel upgrade. The kernel goes first, then
  anchors A+B before and after the E4B swap, both on 7.2.15 (architect, 2026-11-02).
- verify-framework: the boot-order sysctl (`net.ipv4.ip_nonlocal_bind = 1` in
  /etc/sysctl.d/60-tailnet-bind.conf) is set before the reboot, so the reboot shows llama's port
  published. Rollback is to remove the file, then `sysctl -w net.ipv4.ip_nonlocal_bind=0`
  (architect, 2026-11-02).
- verify-framework: Mesa 26.2.6 is closed with no action: it isn't on framework's Omarchy mirror
  (snapshot 2026-10-22), and the router runs its image's Mesa (architect, 2026-11-02).
- verify-framework: linux-firmware 20261019 is closed with no action: it reached Arch core on
  2026-11-01, but not framework's Omarchy mirror (architect, 2026-11-02).
- verify-framework: the TTM ceiling (112 GiB) is closed with no action: the recommended set leaves
  20.5 GiB, more than the 11.2 GiB headroom (architect, 2026-11-02).
- verify-framework: the two gpt-oss sections at 8,192 tokens per session are closed with no
  action: they are the anchors' and the sweep's measurement sections, which no agent loads, and
  changing the 4-slot section would break anchor comparisons (architect, 2026-11-02).
- verify-framework: framework's vllm container and every vLLM image are removed with
  spike-model-engines' `host/engines vllm uninstall`. Rollback is `host/engines vllm install`
  (architect, 2026-11-02).
- verify-framework: the six unused safetensors snapshots (~168G) are removed with `hf cache rm`,
  dry run first; ibm-granite's weights stay for the deferred conversion. Rollback is `hf download`
  (architect, 2026-11-02).
- verify-framework: the docker build cache is cleared in full with `docker builder prune -a`
  (47.01 GB, none in use) (architect, 2026-11-02).
- verify-framework: fwupd's metadata is refreshed by the architect; fwupdmgr is the task's one new
  tool, and its first walk is the architect's (architect, 2026-11-02).
- verify-framework: E4B Q8_0 and QAT each run shape A, shape B, ASR A, and ASR B in one session on
  one build and kernel, each under `timeout 10m` (architect, 2026-11-02).
- verify-framework: the shape-a, shape-b, audio-a, and audio-b scenarios are copied from
  spike-model-engines into `bench/`, as setup copied the anchors (architect, 2026-11-02).
- verify-framework: transcription quality is compared on ASR B's 32 replies, each paired with its
  LibriSpeech reference (read as JSON with curl and jq), lower-cased with punctuation stripped. QAT
  is adopted only if its word differences are within Q8_0's plus 1.4% of the reference words; no
  new tool (architect, 2026-11-02).
- verify-framework: the verify mode covers every verify, take, and hold item in the host's last
  report, and records each decision and outcome in `docs/findings/verify-<host>.md`
  (architect, 2026-11-02).
- verify-framework: any update fwupd offers is an escalation. An approved one gets its own reboot
  after the kernel boots cleanly, since none has a known rollback (architect, 2026-11-02).
- verify-framework: on adoption, Q8_0 is retired within framework and this spike. The router
  unloads Q8_0 and serves QAT, and the architect refreshes Pi's model list. Every repository still
  naming Q8_0 is listed in the finding as "where Q8_0 still lives", addressed to whatever comes to
  own the host tooling, and no reference repository is edited (architect, 2026-11-02).
- verify-framework: the Q8_0 files leave framework's store after the walkthrough confirms QAT,
  with `hf cache rm`, dry run first. Rollback is to `hf download` its two files (~8.1G) and load
  the section, which stays in the preset (architect, 2026-11-02).
- verify-framework: the future of spike-model-engines' host/ scripts goes to the coordinator as a
  pending edit for a `plan experiment.hosting` session (architect, 2026-11-02).
- verify-framework: a cell counts only with its full request count, and each model's cells run
  once each from a fresh load, never rerun within one load (GuideLLM's synthetic prompts hit the
  router's prompt cache); Q8_0's first cells were redone from a fresh load (architect, escalation,
  2026-11-02).
- verify-framework: the bare name `framework` resolved IPv4 from MagicDNS and IPv6 from the LAN
  router (framework.lan, a DHCPv6 lease), where ufw drops port 8080, so a new connection could
  spend GuideLLM's 5 s connect timeout there. MagicDNS serves no AAAA for dual-stack nodes
  (tailscale#1152). The fix is at the source: framework stops sending its hostname in DHCP on its
  LAN connections, so `http://framework:8080` resolves only to the tailnet IPv4, over the direct
  LAN path; rejected: a URL computed from the MagicDNS suffix, refusing instead of dropping on the
  LAN, and dropping the `lan` search domain on every client (architect, 2026-11-02).
- verify-framework: the GB10s take the same host setting; gb10-1 in verify-gb10's brief, and
  gb10-2 as a note for spike-ai-pipeline (architect, 2026-11-02).
- verify-framework: the first model pass is discarded and runs again once routing is settled; the
  removals stand (architect, 2026-11-02).
- verify-framework: the verify mode's step 6 gains a routing check before each pass, beside the
  two cell rules, at the spec review (architect, 2026-11-02).
- verify-framework: run 3 rolled E4B QAT back by the rule (ASR B −5.0%, from 2 of 32 replies
  that reasoned unprompted; shape A +55.4%, shape B +44.2%, ASR A +34.9%; transcripts within the
  bound); the architect applied the rule, then asked to fix the reasoning before discarding the
  promotion: QAT is wanted as the Gemma baseline for its size (architect, 2026-11-02).
- verify-framework: Gemma 4's template already defaults thinking off, so QAT's thought blocks are
  its own; the fix is llama.cpp's reasoning budget at 0 (b11960 forces the end tag at once), sent
  per request in run 4 and set in the preset on adoption; rejected: the template switch (already
  off), consumers sending the field, and a second fix in this task (a logit-bias ban on
  `<|channel>` goes to screen if budget 0 fails) (architect, 2026-11-02).
- verify-framework: experiment.hosting owns spike-model-engines for as long as the experiment
  runs: its spikes change the repository's `host/` (scripts and presets) through pull requests,
  each citing the finding behind it, so the host tooling stays in step with the findings; after
  the intake, the de facto management repository is established in `~/architecture`. Rejected:
  extracting `host/` into a new repository now, which the intake would only move again
  (architect, 2026-11-02).
- verify-framework: QAT as the Gemma baseline is checked one model at a time: E4B in this task;
  the other Gemma QAT sections, vision's 26B-A4B included, get the same reasoning check (replies
  that reasoned, per purpose) in the screen task (architect, 2026-11-02).
- verify-framework: a host serves one model per declared purpose at a time: a candidate loads
  only after the purpose's incumbent is unloaded. Run 4's smoke check loaded E4B QAT beside set A,
  and the router evicted the agent section (`gpt-oss-120b-MXFP4-set-a`) unseen; set A was
  restored. The rule is a standard (`STANDARDS.md`, "Hosts"), and the verify mode states it at the
  spec review (architect, 2026-11-02).
- verify-framework: run 4 (reasoning budget 0) closed every thought block, but QAT wrote its
  reasoning into 2 of 40 replies as plain text ("The user wants me to transcribe ..."), and ASR A
  trailed by 11.0%; rolled back by the rule and by revision 2's stop condition. No preset change,
  so spike-model-engines isn't touched by this task. E4B QAT's unprompted reasoning goes to the
  screen task, with a check on reply text, not only the thought channel (2026-11-02).
- verify-framework: E4B Q8_0 stays framework's audio model. E4B QAT Q4_0 is revisited only when
  Google publishes a revision that fixes its unprompted reasoning (a report run's watch on the
  repository's revisions, or the screen task); E2B QAT and 12B QAT are not screened as audio
  (E2B's audio evals are below E4B's, 12B is slower than Q8_0). Rejected: a reasoning screen of
  E2B and 12B QAT in this task (architect, 2026-11-02).
- verify-framework: run 4 sent reasoning budget 0 only on the ASR cells, since the shape
  scenarios ask for thinking by design; both models ran the same settings in every cell. The
  session's decision, told to the architect before the run (2026-11-02).
- verify-framework: the `chat_template.jinja` reading changes the shared artifact-integrity check
  in `models.md`, so a report run's gate reads the publisher's `.jinja` file too; it fixes the gap
  the verify mode's gate re-check found. Slice 1 shortened the skill's frontmatter description to
  fit Claude Code's 1,024-character limit, dropping "reconciles the probe with the project's host
  descriptor and policy". The session's decision; behavior 9's "only change" is read as "the only
  new mode" (2026-11-02).
- verify-framework: the Wi-Fi connection name is redacted from the finding as `<Wi-Fi
  connection>`, and the Docs standard extends to LAN identifiers (`STANDARDS.md`, "Docs"). The
  branch history is rewritten before publishing, so no commit holds the name (architect,
  2026-11-02).
- verify-gb10: gb10-2 is brought in line with gb10-1 by spike-ai-pipeline, from a dated report verify-gb10 writes to that spike's agent with the exact gb10-2 steps; verify-gb10 borrows no gb10-2 time (architect, 2026-11-02).
- verify-gb10: the three coordinator pending edits (verify-gb10's summary, experiment.hosting owning spike-model-engines' `host/`, dual-stack deferred) land now through the plan pull request; the catalog is the coordinator's root `references.toml` (architect, 2026-11-02).
- verify-gb10: the verify item is the newest llama.cpp cuda13 server image at session start (b12033 when planned); any build from b12019 on carries #31188, #29948 and #31394 (architect, 2026-11-02).
- verify-gb10: the engine verdict rule adopts when no cell on the candidate trails the same cell on b11669 by more than 1.4%, all cells are full, ASR B's word differences are within the incumbent's plus 1.4%, and the reasoning check counts no more replies; a gain needn't exceed noise. The verify mode gains this engine item (architect, 2026-11-02).
- verify-gb10: the engine pass is 12 cells (anchors A and B, vision shape A and B on 26B-A4B QAT, ASR A and B on the audio model), each on both builds under `timeout 10m`; no embedding cells (architect, 2026-11-02).
- verify-gb10: the prefill claims sit beside the cells' TTFT medians; no llama-bench cell (architect, 2026-11-02).
- verify-gb10: on adopt, spike-model-engines pins llama.cpp per host class (gb10 at the adopted build, strix-halo at b11960) through a pull request citing the finding, which also makes its currency check report a class only when its pin is behind; framework stays on b11960 (architect, 2026-11-02).
- verify-gb10: gb10-1's audio model becomes E4B Q8_0, following framework's finding; E4B QAT's files stay until Google publishes a fix (architect, 2026-11-02).
- verify-gb10: gb10-1's agent purpose is served by set A's section once its spike-model-engines clone is pulled to main; the 8,192-token sections close as measurement sections (architect, 2026-11-02).
- verify-gb10: kernel 7.0.0-1024 stays and its hold closes; 1019 stays installed; an unexpected boot at session start is an escalation (architect, 2026-11-02).
- verify-gb10: five items close with no action: display memory, driver 580.196.07, the boot-order remedy, the preset's extra sections, and Docker 29.9.2, each for its reason in the brief (architect, 2026-11-02).
- verify-gb10: the six unused snapshots (~146G) are removed with `hf cache rm`, dry run first, keeping ibm-granite's safetensors and ggml-org's E4B Q8_0; rollback is `hf download` (architect, 2026-11-02).
- verify-gb10: hello-world:latest is removed by the session, and the 6.17.0-1008 kernel image and modules by the architect (root, apt); autoremove already took three 6.17.0-1008 packages on 2026-11-02 (architect, 2026-11-02).
- verify-gb10: the session reads update-notifier-crash's cause without root, then runs `systemctl --user reset-failed`; a crash in the kernel, driver or engine is an escalation (architect, 2026-11-02).
- verify-gb10: spike-model-engines joins the goal's repos with a `[workspace.paths]` entry, and verify-gb10 branches there; experiment.hosting owns its `host/` until the intake (verify-framework's decision) (architect, 2026-11-02).
- verify-gb10: held python at 3.14.10 in spike-model-engines' bench environment: torchcodec 0.17.0 has no cp315 wheel (architect, 2026-11-02).
- verify-gb10: held vLLM at v0.32.0: v0.33.0rc3 is a release candidate, and vLLM is being removed from both hosts (architect, 2026-11-02).
- verify-gb10: held native vLLM's Python at 3.12: native vLLM is retired on both hosts (architect, 2026-11-02).
- verify-gb10: spike-model-engines' upgrade work folds into slice 1, keeping four slices (architect, 2026-11-02).
- verify-gb10: the candidate build is b12063, the newest llama.cpp release at session start (published 2026-11-03 01:39 UTC), by the newest-build decision (architect, 2026-11-02).
- verify-gb10: tailscale 1.104.4 to 1.104.5, new on the channel since the report, is applied with the session's apt step before the engine pass; rollback `apt install tailscale=1.104.4` (architect, 2026-11-02).
- verify-gb10: fwupd refreshed by the architect on 2026-11-02; get-updates offers no update, so no firmware escalation; the "updated successfully" lines are the history of the earlier BIOS 5.36_2.1.0 to 5.36_4.1.0 capsules (architect, 2026-11-02).
- verify-gb10: nvidia-spark-initcall-bl 1.0-2, newly pending on 2026-11-03 (it adds `power_wrap_init` to the kernel's `initcall_blacklist`), is applied by the architect with a reboot of its own before the engine pass; rollback is 1.0-1, update-grub, and a reboot; rejected closing it for the task (architect, 2026-11-03).
- verify-gb10: the session restarts the llama container on b11669 so the router reads set A's section before the incumbent build's anchors (architect, 2026-11-03).
- verify-gb10: the DHCP hostname setting goes on `Wired connection 1` only, gb10-1's one DHCP connection; the ConnectX-7 netplan connections are manual and send no hostname, and the GB10s have no Wi-Fi (architect, 2026-11-03).
- verify-gb10: the engine pass runs from the office over the DERP-relayed path; the routing check's latency condition is overruled, and the pass restarts from the anchors so all 12 cells share one path; rejected waiting for the direct LAN path (architect, 2026-11-03).
- verify-gb10: the architect overrules the engine rule's roll back and adopts b12063: outside legitimately broken behavior, hosts stay on the latest version; the rule's figures (anchor B -1.9%, ASR A -3.8%, ASR B -11.1%) stand beside the overrule in the finding (architect, 2026-11-03).
- verify-gb10: the 20 noble-security updates newly pending after the pass (bind9, gnome-shell, gvfs, libsoup, libpcre2, libmspack; apt lists 2026-11-03 12:25:59) are applied by the architect with `apt-get upgrade`, no reboot, before the walkthrough (architect, 2026-11-03).
- verify-gb10: uv 0.13.6 to 0.13.7 (released 2026-11-03, bug fixes only), new in both repositories' currency mid-task, is taken in spike-hosting-upgrades' mise.bench.toml and spike-model-engines' mise.bench.toml and mise.host.toml; rejected holding it (architect, 2026-11-03).
- verify-gb10: spike-model-engines' currency keeps comparing each class's llama.cpp pin with the build the newest semver release names (v0.8.0 = b11960 today), so gb10 at b12063 reads current until a semver release passes it; the skill's runs find newer builds per host; whether currency should compare with the newest build goes to the intake; rejected changing it in this task (architect, 2026-11-03).
- verify-gb10: gb10-1's finding keeps the verify mode's name, `docs/findings/verify-gb10-1.md`, and STANDARDS.md names it beside `<task>.md`; rejected renaming it to verify-gb10.md (architect, 2026-11-03).
- verify-gb10: the gb10-2 alignment report lives at `docs/findings/gb10-2-upgrade.md`, not under `docs/reports/gb10-2/`, which holds the skill's runs (architect, 2026-11-03).
- verify-gb10: the six snapshots are removed by the exclusive-blob method of spike-model-engines' docs/engines/vllm/uninstall.md, not `hf cache rm` (superseding the method of the 2026-11-02 decision above), since every repository in /srv/models links into the shared /srv/models/blobs and `hf cache rm` would free almost nothing; the session's dry run (27 files, 143.9 GiB, none shared with the 8 kept) was shown, and the architect ran the removal on the host (architect, 2026-11-03).
- verify-gb10: for the walkthrough, the session pushes spike-model-engines' verify-gb10 branch straight to gb10-1's clone over ssh (no GitHub push) and checks it out there, so `engines llama update` with no version reads the per-class pin; the clone returns to main and pulls once the pull request merges; rejected running the update only after the merge (architect, 2026-11-03).
- verify-gb10: the walkthrough runs over the relayed path from the office; the overrule of the routing check's latency condition extends to it, recorded in the finding; rejected waiting for the LAN (architect, 2026-11-03).
- verify-gb10: the gb10-2 report reaches spike-ai-pipeline by the architect pointing that spike at `docs/findings/gb10-2-upgrade.md`; no coordinator note; rejected a roadmap pending edit (architect, 2026-11-03).
- screen: the pool is screened by a new skill mode, `/hosting-upgrades screen <host>`, which takes spike-model-hosting's pool document as its candidate list, runs the skill's gates under today's policy per host class, and leaves a record of its own; "no other spike's pool is an input" is narrowed to the report and verify modes; rejected a report run with the pool's rows added, and the session judging by hand (architect, 2026-11-04).
- screen: the one new tool is spike-model-hosting's agent tiers run read-only from its clone (BFCL single 100 and multi 20 through agent_quality.py on Inspect AI 0.3.281, inspect_evals 0.24.0, its seeded tier lists, Gorilla dac44e7; and `evaluate conform -consumers pi -k 5`), with outputs and state in this spike's ignored `.state`; its first walk is the architect's; rejected pinning Inspect AI and inspect_evals here, a second new tool beside conform (architect, 2026-11-04).
- screen: 26B-A4B QAT's BFCL and tool-reliability check run on both framework and gb10-1, since the check is "on the host's engine" and the hosts differ in build and backend; rejected gb10-1 alone (architect, 2026-11-04).
- screen: 26B-A4B QAT is measured as an agent on a new spike-model-engines preset section, planned in the brief so it is no escalation (its shape is round 4's); rejected the 4 × 8,192 vision section, under the 32,768-token minimum (architect, 2026-11-04).
- screen: each BFCL tier runs its whole list under a 15-minute cap (gpt-oss multi-turn took 10m26s on framework at b11715); every other cell keeps 10 minutes; rejected 10 minutes with a cap hit as an escalation (architect, 2026-11-04).
- screen: BFCL is judged against the policy's fixed floors (0.630, 0.325) with no same-session gpt-oss-120b baseline; rejected a same-session baseline (architect, 2026-11-04).
- screen: only 26B-A4B QAT is measured locally as an agent; the screened pool names what each other agent candidate needs (Muse-Glimmer-30B, Flint, granite-switch-4.1-30b, Gemma 4 31B QAT, LFM2.5-24B-A2B); rejected measuring every "needs measurement" candidate (architect, 2026-11-04).
- screen: cold start is a router API load from unloaded, timed until loaded (the session's step, no root); rejected a timed router restart (architect, 2026-11-04).
- screen: a candidate both the sources and the local checks support is recorded as kept in the screened pool, and no served set changes; the answer task's report ranks it; rejected serving it in place of its incumbent (architect, 2026-11-04).
- screen: the pool's four role speed floors become a policy gate for screens and runs: a measured or attributed figure under a floor fails, a paper estimate alone holds; rejected speed as a sort only (architect, 2026-11-04).
- screen: the logit-bias ban on `<|channel>` for E4B QAT is closed with no action: its reasoning showed in plain text, which a channel-token ban can't reach, and E4B QAT is revisited only on a Google revision, none published (sha 4b4a2c1d, 2026-07-17) (architect, 2026-11-04).
- screen: the Gemma QAT reasoning check runs on 26B-A4B QAT alone, on vision A and B copied from spike-model-engines into `bench/`; 12B and 31B QAT are named as not checked (architect, 2026-11-04).
- screen: the screen mode carries the local measurement too, citing the verify mode's cell rules rather than restating them; the verify mode is untouched; rejected an agent-bar step in the verify mode (architect, 2026-11-04).
- screen: the screen record is dated per host, `docs/screens/<host>/<YYYY-MM-DD>.md` (`-N` the same day), never edited; STANDARDS.md "Docs" names it and README Capabilities point to it; rejected `docs/findings/screen-<host>.md` (architect, 2026-11-04).
- screen: the screen mode finds the pool through a new "Pool" section in each host descriptor and the template, as Measurements does; rejected a fixed reference path in the skill (architect, 2026-11-04).
- screen: conform's profiles are committed here, one per host (strix-halo, nvidia-cuda), naming each router's model IDs, validated by spike-model-hosting's profile loader before any pass; rejected profiles in ignored state (architect, 2026-11-04).
- screen: in the conform profiles, 26B-A4B QAT's agent section serves chat and vision, as a keep would; rejected keeping the vision section loaded for vision (architect, 2026-11-04).
- screen: framework's pass runs first, with the architect's first walk of BFCL and conform there; rejected gb10-1 first (architect, 2026-11-04).
- screen: the 26B-A4B agent section reaches each host's clone on a branch pushed over ssh, and its pull request merges only on a keep, citing the record; otherwise the branch is dropped and the clones return to main; rejected merging an unloaded section anyway (architect, 2026-11-04).
- screen: vision A and B run on both of 26B-A4B QAT's sections, the agent section and the vision section (the incumbent), each from a fresh load (architect, 2026-11-04).
- screen: the keep rule weighs capability, the memory pool, capacity (more concurrent sessions at the same or a larger context each), and speed, with Gemma serving agent and vision and gpt-oss-120b unloaded; rejected the verify mode's 1.4% speed margin (the architect's redirect) (architect, 2026-11-04).
- screen: BFCL single, BFCL multi, and conform share one fresh load of the agent section; every other cell runs from its own (architect, 2026-11-04).
- screen: the walkthrough reruns BFCL single-turn on the agent section against the pass's figure (architect, 2026-11-04).
- screen: Gemma's agent section is 16 slots of 131,072 tokens each, KV not unified (c 2,097,152, about 59 GiB estimated), so every concurrent session holds gpt-oss-120b's full trained context; it supersedes round 1's set A shape; rejected set A's shape and 8 slots (architect, 2026-11-04).
- screen: capacity is measured by spike-model-engines' concurrency sweep (1/4/16/32 streams, 512 / 256, 60 s a level), copied into `bench/` and run in one session on gpt-oss-120b's 16-slot section and on Gemma's section; rejected spike-model-hosting's `evaluate sweep`, which rewrites a host's preset (architect, 2026-11-04).
- screen: long-prompt cells of 8,192 in / 512 out at 1 × 4 and 4 × 16 run on both models, from a new scenario in `bench/`; rejected 512-token cells alone (architect, 2026-11-04).
- screen: "nearly as well as gpt-oss-120b" means the fixed BFCL floors, gpt-oss's own two runs less their spread; rejected a margin against its recorded 0.65 and 0.40, and a same-session baseline (architect, 2026-11-04).
- screen: the keep rule's speed condition is the pool's absolute agent floors read on Gemma's own cells (shape A at least 20 tok/s; long A prefill at least 500 tok/s with TTFT median at most 20 s; long B ITL median at most 100 ms), with gpt-oss-120b's same-session figures beside them; rejected aggregate output at 16 streams, and parity within a margin (architect, 2026-11-04).
- screen: the capacity condition: Gemma's highest sweep level with ITL median at most 100 ms is at least gpt-oss-120b's, and every Gemma slot holds 131,072 tokens as the router reports; rejected aggregate output at 32 streams, and capacity recorded with no condition (architect, 2026-11-04).
- screen: the memory condition: the Gemma set, read warmed after its long B cell, leaves the policy's headroom and uses no more than set A read the same way in the same session; rejected headroom alone (architect, 2026-11-04).
- screen: the vision condition on the agent section: every vision A and B request answered within 10 s, and no more replies reasoned than on the vision section; rejected 1.4% of the vision section's tok/s (architect, 2026-11-04).
- screen: a keep needs every condition, any failure is a drop, and an overrule by the architect is recorded beside what the rule gave; rejected a table weighed each time (architect, 2026-11-04).
- screen: Gemma's BFCL tiers run 4 requests in flight, the count the floors were measured at; rejected 16 (architect, 2026-11-04).
- screen: gpt-oss-120b's long-prompt cells run on set A's section on both hosts (framework's 4-slot section gives 8,192 tokens a slot), and each set's memory is read after its long B cell (approved with the brief) (architect, 2026-11-04).
- screen: Gemma 4's unnamed teacher (Gemma 3's "large IT teacher", adopted by reference) is placed in Google's pipeline by Google's own technical reports, with no source naming an outside model, so every Gemma 4 model passes origin; the reading is added to the policy's "Finding the teachers"; rejected the strict reading, which would leave every Gemma 4 generative model origin unclear (architect, 2026-11-04).
- screen: LFM2.5-24B-A2B stays origin unclear: the 2.6B blog's "branch from the same SFT checkpoint" settles only the 2.6B, and the 24B's own documents only imply it; added to the policy (architect, 2026-11-04).
- screen: a model whose repository needs `trust_remote_code` passes artifact integrity when the host loads a GGUF its engine loads with none of that code; added to the policy (architect, 2026-11-04).
- screen: llama.cpp #29655 (Gemma 4 tool calling, bug-unconfirmed, stale, filed at b11258, not reproduced on master) doesn't count under the keep rule's parser condition; conform through Pi tests tool calls at today's builds, and the record cites the issue (architect, 2026-11-04).
- screen: Gemma 4 31B QAT drops at the speed floor on its measured decode, 11.6 and 11.8 tok/s at b11669, under 60% of the floor of 20 (architect, 2026-11-04).
- screen: an Unsloth Dynamic quant (UD-Q5_K_M) is a format the floor doesn't name: the row names a uniform Q5_K_M or Q8_0 if one exists, and otherwise drops at the floor (architect, 2026-11-04).
- screen: Gemma's agent section is 15 slots of 131,072 tokens each (c 1,966,080, about 56 GiB estimated), on both hosts so their records compare one configuration, falling back to 8 slots if 15 fails to load: at 16 slots (c 2,097,152) each full-attention layer's K tensor is exactly 4 GiB, and the load aborted on framework's Vulkan backend at b11960 ("pre-allocated tensor (cache_k_l5) in a buffer (Vulkan0) that cannot run the operation (NONE)", cf. llama.cpp #29082); supersedes round 4's 16 slots; rejected 8 slots at once, and 16 slots with a q8_0 KV cache (architect, 2026-11-04).
- screen: framework drops Gemma 4 26B-A4B QAT serving agent and vision at Gate 3: b11960's Vulkan backend can't serve the 15-slot section (its second request aborts with "tensor not allocated", llama.cpp #29221, whose fix #25584 is unmerged), so the trade of more sessions at full context can't hold there; revisited when #25584 merges. Framework's record is written from phase 1 and the drop, and the architect's first walk of BFCL and conform moves to gb10-1's pass; rejected a framework-only 3-slot section, which fails capacity by construction (architect, 2026-11-04).
- screen: gb10-1's agent section returns to 16 slots of 131,072 (c 2,097,152, about 59 GiB), CUDA only, smoke-tested before phase 2: the 15-slot reason (one configuration across both hosts) fell away with framework's Gate 3 drop; 16 matches gpt-oss-120b's 16-slot section, and the sweep's 16-stream level doesn't queue; framework's clone stays at 31b00eb (15 slots), which its record cites; rejected keeping 15 (architect, 2026-11-04).
- screen: BFCL multi-turn, which hit its 15-minute cap on gb10-1 with 8 of 20 samples (5 passing), reruns once on its whole list from a fresh load under a 45-minute cap; the record reports the slow multi-turn decode (7-8 tok/s a slot with 4 in flight, against long B's ~32, with a 200 MiB context checkpoint each turn) as a finding beside the speed conditions; rejected diagnosing first with --cache-ram 0, and recording the tier unmeasured (architect, 2026-11-04).
- screen: conform through Pi, which hit its 10-minute cap on gb10-1 after one clean trial (9 capabilities, 59 requests, all HTTP 200; about 8 minutes a trial, the time in Pi's turns, with the router decoding at about 70 tok/s), reruns whole at k = 5 under a 45-minute cap on the same fresh load right after the BFCL multi-turn rerun, both run by the session in the background; rejected a smaller k, which pass^5 can't judge (architect, 2026-11-04).
- screen: the prompt-cache stall is diagnosed and fixed within this task: a bounded A/B on gb10-1 (BFCL multi-turn's first 4 samples, on Gemma's section and set A's gpt-oss section, each with the default prompt cache and with --cache-ram 0, saves and decode read from the router's log), the winning setting landing in spike-model-engines' preset through the screen branch's PR whatever Gemma's verdict, then multi-turn and conform rerun on it; single-turn's 0.800 stands; rejected ending the task at Gemma's drop with the diagnosis as a task of its own (architect, 2026-11-04).
- screen: the background job was stopped as multi-turn reached its cap (16 of 20, 6 passing), before conform's rerun ran, so gb10-1 is free for the A/B and conform runs once on the setting that stays; rejected letting conform finish on the current setting (architect, 2026-11-04).
- screen: gb10-1 moves to the newest llama.cpp build within this task, b12125 (#31391's CUDA fix for the idle-slot stall, #30252, is in b12080 and later); ASR A and B run on b12063 first, so the verify mode's engine rule judges the move on set A's cells on both builds; rejected finishing on b12063 with a separate engine-currency task (architect, 2026-11-05).
- screen: on b12125 the maintainers' cache design (cache-ram 8192, idle-slot caching, -sps 0 per #22083) and cache-ram 0 with cache-idle-slots = false each run BFCL multi-turn's whole list on Gemma's section with 5-minute readouts; the faster setting without a stall wins, and its run is the keep rule's multi-turn figure; both agent sections take it; phases 1 and 2, BFCL single, and conform rerun on b12125 (architect, 2026-11-05).
- screen: spike-model-engines' currency compares each host class's llama.cpp pin with the newest bNNNNN release, not the newest semver release, implemented in the screen branch's PR beside the gb10 pin; supersedes the pending edit that left it to the intake (architect, 2026-11-05).
- screen: whether to host the agent model alone on vLLM for concurrent sessions goes to spike-model-layout as a question, with gb10-1's vLLM figures (gpt-oss-120b 34.0 vs 50.0 tok/s at 1 stream, 168.2 vs 129.0 at 16, 2026-10-31 report) (architect, 2026-11-05).
- screen: framework's Gemma re-screen waits on watch items in its descriptor for llama.cpp #25584 and #31418, run when both merge; framework stays on b11960 until its next session's host update, its currency item held with that reason (architect, 2026-11-05).
- screen: gb10-1 moves to b12124 and the gb10 pin becomes b12124, in place of b12125: llama.cpp publishes its Docker images nightly (04:17 UTC) and on manual runs, not every build, so b12125 has no server-cuda13 image (`engines llama update b12125` exit 1, "not found"); b12124 is today's nightly, differs from b12125 only by #31694 (OpenCL, Adreno X2), and carries #31391; rejected waiting for tomorrow's nightly (architect, 2026-11-05).
- screen: spike-model-engines' currency compares each host class's llama.cpp pin with the newest bNNNNN that has the class's image tag on ghcr (server-cuda13-bNNNNN for gb10, server-vulkan-bNNNNN for strix-halo), not the newest release, which the suite's update can't always pull; supersedes the 2026-11-05 "newest bNNNNN release" wording (architect, 2026-11-05).
- screen: b12124 rolled back by the engine rule (the vision section can't load: llama.cpp #31620 and #31639, b12100 and later, match an -hf tag only after `-`, `.` or `/`, and Google's QAT GGUFs put `_` before it [the 26B-A4B, 31B and E4B QAT files; the 12B QAT file keeps `-` and resolves]); gb10-1 moves to b12098 instead (the 2026-11-04 nightly, with #31391 and before #31620), in a new pass from b12063's six cells in this session; the gb10 pin becomes b12098, currency's b12124 item held with that reason, and gb10-1's descriptor gains a watch item on Google renaming its QAT GGUFs or llama.cpp accepting `_`; rejected b12124 with every Google QAT section renamed to the router's derived `:IT` tag (architect, 2026-11-05).
- screen: the #31620 break is a finding in gb10-1's record and a comment on the gb10 pin in spike-model-engines' `host/llama.env`, through the screen branch's PR; no coordinator pending edit (architect, 2026-11-05).
- screen: the engine rule rolled b12098 back on gb10-1 (anchor A −2.1%, vision A −2.7%, ASR A −4.2%, ASR B −4.3% against b12063 in one session; every cell held its requests, the transcripts and reasoning held); the architect overruled it and adopted b12098: the deficits are the size of the session's same-build spread (b12063's ASR A 13.82 then 13.52, −2.2%), b12124, a superset of b12098, held every one of those cells against the same b12063, and a roll back would leave behavior 21 nothing to test; the record states what the rule gave beside the overrule (architect, 2026-11-05).
- screen: if both cache arms still decode long multi-turn replies at about 8-9 tok/s, the pass continues on the faster arm by mean sample time, and the slow decode is a finding beside the speed conditions, first in the session brief; rejected stopping for the architect (architect, 2026-11-05).
- screen: if the nocache arm wins, gpt-oss-120b's set A section is measured with those keys before it takes them: BFCL multi-turn's first 4 samples (the 2026-11-04 A/B's list) on set A's section with the default cache and with the nocache keys, beside phase 1's anchors; the section keeps the keys if it performs as well or better, and otherwise the session judges the convention and records why (architect, 2026-11-05).
- screen: a failure the session can fix (a load timeout, an errored GuideLLM run) is retried once from a fresh load and recorded; a second failure, or anything outside the brief, is an escalation (architect, 2026-11-05).
- screen: Gemma's agent section takes cache-ram 0, cache-idle-slots false, and ctx-checkpoints 2: with no prompt cache nothing evicts a slot's context checkpoints (32 a slot, 200 MiB each on Gemma 4's SWA layers; the nocache arm ended at 0.69 GiB available), and 2 a slot bounds them at 6.4 GiB across 16 slots, inside the headroom and set A's memory; BFCL multi-turn's whole list reruns on it (45-minute cap, memory read every 5 minutes, stopped under 12.2 GiB), and that run is the keep rule's multi-turn figure; then phase 2, BFCL single, and conform; rejected ctx-checkpoints 4 (its worst case breaks the memory condition) and the cache arm (8-9 tok/s) (architect, 2026-11-05).
- screen: the walkthrough closes on the routing pings, anchor A, shape A on the agent section, and set A restored; the BFCL single rerun (it can't change the multi-turn drop), the routing check's three tests, the profile validation, and `/hosting-upgrades screen gb10-1` up to its cells (it re-reads the whole pool's research, about an hour, from a skill the next task revises) are skipped; rejected the full walkthrough (architect, 2026-11-06).
- screen: the skill's revision is the next task, planned with `plan` before `answer`, seeded by the session's evaluation: a short SKILL.md with one reference per mode and shared rules defined once; a build gate before any engine move (the image exists, every preset section loads); a configuration review against published practice for the host class and engine; a blocker register (one per project, entries naming the hosts they affect, upstream state checked each run, four states); a dated research cache; default rules for what this task escalated; run noise measured per host; the sweep counting every token; memory guards and clock logs during cells; shipped helpers whose command log the records quote; rejected changing the skill within `screen` (architect, 2026-11-06).
- screen: the merge gives framework's set A cache-ram 0 and cache-idle-slots false through the shared preset, unmeasured on Vulkan b11960; framework's next host update verifies it with the anchors and the 4-sample BFCL A/B, as gb10-1's check did; rejected measuring on framework before the merge (architect, 2026-11-06).
- screen: BFCL multi-turn's cap hit on gb10-1 (19 of 20, 5 passing) is accepted and the drop stands as recorded (6/20 = 0.30 < 0.325 at any finish); rejected a rerun (architect, 2026-11-06).
- skill-revision: added before `answer` by `plan`, seeded by the screen's evaluation (screen, 2026-11-06); a redesign, not a patch (architect, 2026-11-06).
- skill-revision: the modes merge into `survey <host>` (the public record: debt, hardware, model host, models, configuration review, discovery) and `measure <host>` (engine moves and candidate screens under one harness, judged by the engine rule or the keep rule); `setup` stays; rejected keeping report, verify and screen (architect, 2026-11-06).
- skill-revision: a short entry file (about 150 lines), one reference per mode loaded only when it runs, shared rules defined once; models.md and sources.md stay; rejected one SKILL.md (architect, 2026-11-06).
- skill-revision: the configuration review runs every survey, flag by flag against published practice for the class and engine, re-reading only stale sources, and covers section arguments, the engine choice at the host's load target, and the container's run flags; it only proposes; rejected running it only before engine moves (architect, 2026-11-06).
- skill-revision: discovery of models others run on the host class runs every survey, through every gate (architect, 2026-11-06).
- skill-revision: the blocker register is a committed `docs/blockers.md`, four states (open, fix merged, fix in an image build, cleared on the host), an entry deleted once cleared on every host it names; rejected GitHub issues and the skill directory (architect, 2026-11-06).
- skill-revision: survey checks every open register entry upstream with gh each run; measure re-checks its host's entries before its first load; a bundled script, granted by its own readiness rule, reads whether a merged fix is in an imaged build (architect, 2026-11-06).
- skill-revision: the research cache is one committed file updated in place; an entry is replaced when re-read (after 14 days or when its subject changed) and deleted when its subject concerns no host, git keeping the old text; rejected dated entries and ignored state (architect, 2026-11-06).
- skill-revision: default rules replace screen's escalations: the newest imaged build passing the build gate, one retry from a fresh load, a cap hit recorded and continued (architect, 2026-11-06).
- skill-revision: the build gate checks the class's image exists, then after the move loads every preset section before any cell and rolls back on a failed load; rejected a second container on a spare port (it competes for unified memory) (architect, 2026-11-06).
- skill-revision: each descriptor keeps two noise figures, within-session (engine and keep rules) and across-days (rerun anchors against an earlier task), from existing same-build readings (gb10-1 2.2% and 5.0%) plus the walkthrough's repeat; the fixed 1.4% goes; rejected a dedicated noise run (architect, 2026-11-06).
- skill-revision: shipped bash step helpers, sourced and called one step at a time in the architect's view, every command logged by xtrace with a timestamped PS4 into ignored state, records quoting the log; ai-hosting.md's scripting rule now states this reading (coordinator PR #120) (architect, 2026-11-06).
- skill-revision: cells sample GPU clocks and throttle reasons, a memory floor stops long runs, and the sweep reports completed-request and every-token figures (architect, 2026-11-06).
- skill-revision: descriptors' Purposes list only the purposes a host serves, each with a load target (concurrent sessions or requests, context per session), and no rule assumes set A's four roles on every host; spike-model-layout decides the assignment; raised by the architect (architect, 2026-11-06).
- skill-revision: one dated measure record per run per host; verify findings and screen records stay as history (architect, 2026-11-06).
- skill-revision: BFCL's missing max_tokens goes to the coordinator as a pending edit for spike-model-hosting's harness, and measure treats a runaway as a cap hit; rejected n_predict in the presets (a host configuration change) (architect, 2026-11-06).
- skill-revision: verified by a paper survey of gb10-1 that must surface the screen's configuration findings, and a measure on framework discharging its owed no-cache check (anchors A and B twice each from fresh loads; BFCL multi-turn's first 4 samples on default cache and no-cache keys, 10-minute cap each); no new tool (architect, 2026-11-06).
- skill-revision: `answer`'s roadmap entry sharpened now (coordinator PR #120): its second report is the revised survey on both hosts, and it gained a proof line (architect, 2026-11-06).
- skill-revision: currency on start reported only python 3.14.10 -> 3.15.2 in mise.bench.toml, still held: torchcodec 0.17.0, its latest, publishes no cp315 wheel (PyPI, 2026-11-06); no round opened, the approved brief stood (architect, 2026-11-06).
- skill-revision: any model NVIDIA publishes, Nemotron or not, passes the origin gate, even when its documents name an adversary-origin teacher; a conversion passes when its weights are shown to be NVIDIA's; uploader compliance, models others derive from NVIDIA weights, and every later gate still apply. In the architect's words: "Nemotron models are acceptable by origin for any platform that can run them" and "NVIDIA models in general should be seen as credible"; `docs/policy.md`, Model origin (architect, 2026-11-06).
- skill-revision: the NVIDIA origin pass follows the weights: an NVIDIA quantization or republication of another publisher's weights (Qwen3.6-35B-A3B-NVFP4, DeepSeek-V4.1-Flash NVFP4, Cosmos-Reason2-8B) is judged by its base, so adversary-origin bases are excluded at level 1; rejected covering anything NVIDIA publishes (architect, 2026-11-06).
- skill-revision: a QAD build stays on the floor's path 3 even when its publisher calls it "native" (Nemotron 3.5 Bolt 74B's IQ2-XXS fails the floor) (architect, 2026-11-06).
- skill-revision: an uploader's membership in a Hugging Face organization, adversary-linked included, doesn't bear on the compliance gate; the gate stays the lists, the conversion check guards the weights; rejected a membership check (architect, 2026-11-06).
- skill-revision: only the publisher's own card's BFCL figure counts against the agent bar; a third party's card is a lead that can rank a candidate for measurement (architect, 2026-11-06).
- skill-revision: the session ran two no-root reads on gb10-1 for the survey's open asks (`dpkg-query -W nvidia-spark-initcall-bl`, the user journal for update-notifier-crash.service), plus `/proc/cmdline` and `/var/crash`; answers in the gb10-1 report of 2026-11-06 (architect, 2026-11-06).
- skill-revision: framework's settings check ran with the clone at dfc1d3d (the keys never pulled there) as the default arm and 933ec0f detached as the no-cache arm; the clone was restored to dfc1d3d, since a host configuration change is out of scope; pulling it to 933ec0f is an item for the next survey or measure (session, 2026-11-06).
- skill-revision: framework's settings check, run over the DERP relay with its routing check run late, stands: keys confirmed (303 vs 379 s, 21.7 vs 18.2 tok/s), the relay recorded (architect, 2026-11-06).
- skill-revision: the routing check records a DERP-relayed path and goes on for comparisons within one session; a LAN record, a bare name off the tailnet, a failed connect, or over 50 ms on a direct path stays a pause; rejected keeping every slow connect a pause (architect, 2026-11-06).
- skill-revision: a measure run writes one dated record per host, `docs/measures/<host>/<YYYY-MM-DD>.md` (`<YYYY-MM-DD>-N.md` for a later run the same day), as reports and screen records are dated (session, 2026-11-06).
- skill-revision: the research cache deletes a build's entries only when no host runs or is held at the build and it is two images behind the newest for every class it names, so a held build keeps its entries; refines behavior 7 (session, 2026-11-06).
- skill-revision: a survey adds a register entry only when a record of this project measured what the blocker costs, linked from the entry; a public report alone is a watch item or a configuration finding (session, 2026-11-06).
- skill-revision: `fix-in-image.sh` takes the newest imaged build from ghcr.io's tag list, not GitHub's releases, so an image built without a release (b12169) counts (session, 2026-11-06).
- skill-revision: the step helpers' printed output goes to the command log as `= ` lines among xtrace's `+` lines, and sourcing with `MEASURE_LOG=off` opens no log and refuses the helpers that load the host (session, 2026-11-06).
- skill-revision: a settings check selects each arm by the preset clone's commit, since a router load takes only a section name; one arm is the clone as found, the other arm the other commit, detached after a fetch, and the pass restores the clone to the branch and commit it was found at (session, 2026-11-06).
- skill-revision: an engine move's vision cells are shape A and B, named so, as the verify mode ran them (session, 2026-11-06).
- skill-revision: framework's run noise is 1.1% within a session and 2.8% across days, set by its 2026-11-06 measure from the repeated anchors and the earlier same-build readings, no longer provisional (session, 2026-11-06).
- skill-revision, after ship: framework's spike-model-engines clone pulled from dfc1d3d to 933ec0f and the router restarted, so set A's section serves the confirmed no-cache keys (`--cache-ram 0 --no-cache-idle-slots`, read back by the probe); the strix-halo pin and image (b11960) unchanged. framework's DERP relay is the laptop's network, not the host: the laptop's netcheck reads MappingVariesByDestIP true (a hard NAT), framework's false with UPnP and PCP, so nothing on framework to fix (architect's direction, 2026-11-06).
- answer: the second report is a new revised survey of both hosts on the day BUILD starts: framework against 2026-10-30-2, gb10-1 against 2026-11-06, named -2 when the day already has a report; rejected counting gb10-1's 2026-11-06 paper survey (architect, 2026-11-06).
- answer: the architect brings both hosts up to date with root before the surveys, as the experiment rule requires every session to; rejected surveying first and ranking the updates as take items (architect, 2026-11-06).
- answer: no local cells. The task runs no measure; both surveys are on paper (architect, 2026-11-06).
- answer: held llama.cpp strix-halo at b11960: an engine move is a measure, and builds past b12098 break Google's QAT vision section (#31620) (architect, 2026-11-06).
- answer: gb10-1's 2026-11-06 proposals are settled one at a time before its second survey: the architect decides each and the session applies the accepted ones; rejected leaving them for the walkthrough (architect, 2026-11-06).
- answer: survey runs weekly per host, plus event triggers; rejected triggers only (architect, 2026-11-06).
- answer: the convention is its own document, `docs/convention.md`, linked from README "The answer", the answer section and the skill's entry file; rejected writing it only into the README (architect, 2026-11-06).
- answer: BFCL's max_tokens per tier goes under the answer section's "Requirements for the intake to route", which settles where that pending edit lands; rejected a line in model-evaluation's roadmap summary (architect, 2026-11-06).
- answer: currency on start reported python 3.14.10 -> 3.15.2 (mise.bench.toml), still held: torchcodec 0.17.0 has no cp315 wheel (PyPI, 2026-11-06) (session, 2026-11-06).
- answer: gb10-1's 2026-11-06 proposals all accepted: watch items for the Gemma 4 E4B tokenizer fix and reconversion, NVIDIA's reboot fix (folded into the reboot item), and vLLM's EmbeddingGemma fix on SM121 (#60942); #29510 retired; trusted sources Ubuntu security notices, ghcr.io's llama.cpp container versions, vLLM's GPT-OSS recipe, and Launchpad bug pages; site-one-liart-13.vercel.app blocklisted; DGPP seeded as an engine. Its own-conversion and embedding-scenario proposals are new work and go to the answer's gaps (architect, 2026-11-06).

- answer: framework's survey pauses 1 and 2 settled by the session's no-root reads: ca-certificates-mozilla 3.131.1-1 meets Arch's notice, and /etc/pacman.conf holds no IgnorePkg, so "0 pending" stands (session, 2026-11-06).
- answer: 0cc4m's statements are primary for Vulkan practice although the tracker marks him CONTRIBUTOR; slb350's Strix Halo benchmarks and Liquid's LFM3-VL Strix Halo chart stay leads (architect, 2026-11-06).
- answer: a publisher's GGUF whose card gives only an averaged loss across its evals fails the floor's path 2, which asks each eval within the margin: Meta's own Muse Glimmer GGUFs fail, and ggml-org's Q8_0 stays the host file; rejected accepting an average within the margin (architect, 2026-11-06).
- answer: a CONTRIBUTOR's measurement in a tracker comment that names hardware, version and method is an attributed benchmark (hclsys's GB10 FP8 table, vLLM #58989); rejected ruling it a lead (architect, 2026-11-06).

## Pending edits

- Coordinator roadmap, `experiment.hosting.spike-model-layout`'s summary: weigh hosting the agent model alone on vLLM for concurrent-session throughput, with gb10-1's figures (gpt-oss-120b on vLLM v0.32.0: 34.0 vs llama.cpp's 50.0 tok/s at 1 stream, 168.2 vs 129.0 at 16; gb10-1 report 2026-10-31), the screen's finding that llama.cpp's idle-slot saves stalled multi-turn load before b12080, a published vLLM figure for an NVFP4 Gemma 4 26B-A4B on a DGX Spark of 303 tok/s aggregate at 16 concurrent (a lead) beside llama.cpp's 210.5 for Gemma's QAT section in gb10-1's sweep, and a llama.cpp maintainer's note that it "mostly optimizes upto 8 parallel sequences at the moment" (#31711) (screen, Decisions; `docs/screens/gb10-1/2026-11-05.md`, "Research read 2026-11-05").
- Coordinator, for spike-model-hosting's agent-tier harness (`evaluation/suites/agent_quality.py`): propose that the harness set a `max_tokens` cap per tier, recorded with the tier's list, so a runaway reply is a counted cap hit rather than a lost sample. BFCL sends no `max_tokens` today, so a runaway reply runs until the model stops or the section's context ends it, and the tier's time cap is the only bound. On gb10-1 one BFCL multi-turn sample generated 23,306 output tokens over 21 calls, one reply of 7,326 tokens, in 1,049 s, and the tier hit its 45-minute cap at 19 of 20 samples; on the no-prompt-cache arm one sample generated 9,027 (`docs/screens/gb10-1/2026-11-05.md`, "BFCL and conform" and "Cells"). Until then, hosting-upgrades' measure mode counts a reply that stops at the context limit as a cap hit and reports each tier's largest reply (`rules.md`, "Caps") (skill-revision, Decisions, 2026-11-06).
- Coordinator, `ai-hosting.md`, "### spike-hosting-upgrades": end the paragraph with "The spike has answered: "Answer · experiment.hosting.spike-hosting-upgrades", under "Answers · experiment.hosting" below.", as spike-model-engines' paragraph does (answer, 2026-11-06).
- Coordinator, `ai-hosting.md`, under "## Answers · experiment.hosting", after spike-model-engines' answer: this spike's answer section (answer, behavior 8, 2026-11-06):

  ```markdown
  ### Answer · experiment.hosting.spike-hosting-upgrades

  **Question:** What convention evaluates an upgrade to the hosting stack (a host's hardware
  configuration, its model host, or its models) from what others publish rather than benchmarks
  of our own?

  **Answer:** A skill surveys each host weekly and on events, ranking every upgrade from cited
  public sources against the host's load targets; the host measures only what no source settles,
  and an adoption leaves a chain of dated records.

  The answer is drawn from two hosts, framework (Strix Halo, llama.cpp Vulkan b11960) and gb10-1
  (GB10, llama.cpp CUDA b12098). No figure is compared across sessions, and two builds are
  compared only within one session.

  1. The skill: one project-local Claude Code skill, `hosting-upgrades`, with three modes. `setup`
     prints the permission rules it needs and never writes settings. `survey <host>` probes the
     host read-only and without root and applies nothing. `measure <host>` runs local cells under
     one harness, the engine rule for an engine move and the keep rule for a candidate. The skill
     reads the host descriptors and the policy and cites every source with its URL and read time.
     Proven by its runs: the probes
     ([findings/skill.md](https://github.com/JaimeStill/spike-hosting-upgrades/blob/main/docs/findings/skill.md)),
     seven dated reports, and one measure record
     ([skill](https://github.com/JaimeStill/spike-hosting-upgrades/tree/main/.claude/skills/hosting-upgrades)).
  2. Dated, cited reports of ranked upgrades per host, each item given verify, take, hold, or
     skip. Each covers four kinds: hardware configuration, system updates and debt, the engine,
     and the models, with a flag-by-flag configuration review and model discovery. The two second
     surveys of 2026-11-06 state what moved since the host's last report. Both researched in full,
     because the host stack had moved. gb10-1's cited 23 sources and 29 model entries from the
     cache and read only 14 fresh. Proven by the reports:
     [framework 2026-11-06](https://github.com/JaimeStill/spike-hosting-upgrades/blob/main/docs/reports/framework/2026-11-06.md)
     and
     [gb10-1 2026-11-06-2](https://github.com/JaimeStill/spike-hosting-upgrades/blob/main/docs/reports/gb10-1/2026-11-06-2.md),
     with the earlier reports beside them.
  3. Each host's top upgrade, verified by anchors A and B before and after, then adopted or
     rolled back. framework's E4B QAT as the audio model was rolled back on ASR B (−5.0%).
     gb10-1's move from b11669 to b12063 was adopted on the architect's overrule of the engine
     rule (ASR B −11.07%), to stay current. Under the revised skill, framework's settings check
     confirmed set A's no-cache keys (20.1% less time, 19.2% faster long-reply decode), and the
     host now serves them. Proven by measured runs:
     [verify-framework](https://github.com/JaimeStill/spike-hosting-upgrades/blob/main/docs/findings/verify-framework.md)
     (b11960, 2026-11-02),
     [verify-gb10-1](https://github.com/JaimeStill/spike-hosting-upgrades/blob/main/docs/findings/verify-gb10-1.md)
     (b11669 and b12063, 2026-11-03), and
     [framework's measure](https://github.com/JaimeStill/spike-hosting-upgrades/blob/main/docs/measures/framework/2026-11-06.md)
     (b11960, 2026-11-06).
  4. The pool screened per host class. The gates ran on every candidate. Gemma 4 26B-A4B QAT,
     serving agent and vision, was measured beside gpt-oss-120b and dropped on both hosts: on
     framework at the engine gate (b11960's Vulkan backend aborts with several slots), and on
     gb10-1 on BFCL multi-turn's floor. Each host keeps set A, and the other candidates are hold
     until measured. Proven by measured runs:
     [framework's screen](https://github.com/JaimeStill/spike-hosting-upgrades/blob/main/docs/screens/framework/2026-11-04.md)
     (b11960, 2026-11-04) and
     [gb10-1's screen](https://github.com/JaimeStill/spike-hosting-upgrades/blob/main/docs/screens/gb10-1/2026-11-05.md)
     (b12098, 2026-11-05).
  5. The published claim beside our anchors, thin: three claims, all in the verify findings.
     spike-model-engines' +56.6% for E4B QAT held within a point (+55.4%), but it said nothing of
     the model's unprompted reasoning, which cost ASR B its lead. llama.cpp #31188's +17.2% MoE
     prefill held in direction only (TTFT −0.6% to −3.2%). #29948's +7.1% dense prefill didn't
     show (TTFT +5.2% and +23.3%). The screens set no published claim beside their cells. Sources
     predicted a gain's direction more often than its size. Proven by measured runs: the verify
     findings' "The claim beside the anchors" and "Cells".
  6. The convention and its cadence, each statement citing its record. It states when survey
     runs (weekly per host, and on a host update, a register entry's fix reaching an image, a
     changed purpose or load target, and before any change to the host), what triggers a
     measure (a verify item or a "Needs measurement" entry, one measure a session, its cells
     agreed in the plan round), and the record an adoption leaves: the report,
     the measure record quoting its command log, then the descriptor, the pin, and the register
     entry's state. It also covers how proposals are settled between surveys, the blocker
     register's four states, the research cache's 14-day rule, per-host load targets, which
     spike-model-layout owns, and what stays with model-evaluation. Proven by the two second
     surveys and the records it cites:
     [docs/convention.md](https://github.com/JaimeStill/spike-hosting-upgrades/blob/main/docs/convention.md).

  Gaps in the answer:

  - No repeat survey has run on an unmoved stack. Both second surveys researched in full, because
    the host stack had moved, so "only what moved" is shown by the research cache's reuse, not by
    a run that skipped research. The weekly cadence was decided on 2026-11-06 and hasn't run yet.
  - No embedding scenario in `bench/`, so no embedding candidate can be measured on either host.
  - The project's own conversions aren't built: Nemotron 3.5 Transcribe to Q8_0 (no publisher or
    ggml-org GGUF), and granite-embedding-english-r2 from IBM's stored safetensors.
  - The engines are held. framework is on b11960 and gb10-1 on b12098, behind the newest imaged
    build, b12169, because builds from b12100 don't resolve Google's QAT GGUFs (#31620, #31639,
    open in the register). #30137's fix is in b12169, and its move is skip until that clears.
  - The vision section's prompt-cache keys (`cache-ram 0`, `cache-idle-slots false`,
    `ctx-checkpoints 2`) are still to verify on both hosts, the one verify item of each second
    survey.
  - The measure mode has run once, as a settings check. No engine move or candidate screen has run
    under it, and no register entry has reached "cleared on the host".
  - The published claims beside our anchors are three, from two sessions (evidence 5).

  Requirements for the intake to route:

  - spike-model-hosting's agent-tier harness (`evaluation/suites/agent_quality.py`): a `max_tokens`
    cap per tier, recorded with the tier's list, so a runaway reply is a counted cap hit, not a
    lost sample. BFCL sends none today. On gb10-1 one multi-turn sample generated 23,306 output
    tokens, and the tier hit its 45-minute cap at 19 of 20 samples (this goal's pending edit for
    the harness, and gb10-1's screen of 2026-11-05).
  - spike-model-engines' `scripts/currency.sh`: name the newest imaged build from ghcr.io's tag
    list, as this spike's `fix-in-image.sh` does. Walking GitHub's releases list, it names b12124
    and can't see b12169, an image built with no release (framework's report of 2026-11-06,
    "Blockers").
  - The skill's plugin form, routed to claude-plugins. The spike kept it project-local and left
    the plugin to the intake.
  - spike-model-layout: the descriptors' purposes and load targets follow its layout, and a change
    there changes them. It also weighs hosting the agent model alone on vLLM for concurrent
    sessions, this goal's other pending edit.
  - model-evaluation: workloads only we can measure (our agents, and our role sets under our own
    sessions), and tuning at scale. That includes the candidate backlog, which one screen a session
    can't clear: framework's second survey lists over twenty agent candidates as needing
    measurement.

  [The answer](https://github.com/JaimeStill/spike-hosting-upgrades#the-answer) ·
  [spike-hosting-upgrades](https://github.com/JaimeStill/spike-hosting-upgrades)
  ```
