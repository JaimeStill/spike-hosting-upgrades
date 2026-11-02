# goal · experiment.hosting.spike-hosting-upgrades

- **State:** building
- **Task:** verify-framework
- **Branch:** verify-framework

## Tasks

1. [x] skill
2. [ ] verify-framework
3. [ ] verify-gb10
4. [ ] screen
5. [ ] answer

## Task brief · verify-framework

```
Problem       framework's 2026-10-30-2 report ranks one verify item, Gemma 4 E4B
              QAT Q4_0 as the audio model, and ten hold items, but nothing has
              been measured or applied. The skill finds and ranks upgrades, and
              has no way to take one to a decision, so a verified upgrade leaves
              no record. The answer task's convention needs that record: what
              was measured, against what claim, and what each item came to. This
              task gives the skill a verification mode and uses it on framework.
              It verifies E4B QAT with anchors A and B and settles every hold.

Behaviors
  The verify mode
  1.  `/hosting-upgrades verify <host>` reads the host's last report (the
      newest date, and within that date the highest -N). It stops, saying
      why, when the host has no descriptor or no report, or the project has
      no policy.
  2.  It runs the readiness check and the read-only probe first. It names
      every report item whose state the probe shows has moved since the
      report, such as an update now on the host's channel.
  3.  It lists every verify, take, and hold item in the report. For each, it
      asks for the architect's decision (apply, remove, or close with a
      reason) and records the decision with its date.
  4.  For each item to apply or remove, it prints:
      - the exact commands
      - which steps need root, which are the architect's, and which the
        session may run without root
      - the rollback, and whether a reboot is needed
      The mode itself runs nothing that changes the host. An offered update
      with no known rollback, such as a firmware update fwupd lists, is an
      escalation. Once approved, it gets a reboot of its own, after the
      host's other changes have booted cleanly.
  5.  Before the verify item is measured, the mode re-checks the item's gates
      under the current policy: origin, artifact integrity (the
      chat-template check included), the quantization floor, and fit. If a
      gate fails, it stops and names that gate.
  6.  It prints the agreed cells:
      - anchors A and B before and after the change, on one engine build and
        one kernel
      - the item's cells beside its role's incumbent, at the same shapes
      Each run has a 10-minute cap. Every pass records the engine version,
      the host stack, and `tailscale ping`. The first anchors are set beside
      the host's last earlier readings, and a move beyond run noise is a
      finding.
  7.  The verdict rule. Adopt only when all three hold:
      - anchors A and B after the change are within 1.4% of before
      - no candidate cell is behind the incumbent by more than 1.4%
      - for a transcription purpose, the candidate's word differences from
        the references are within the incumbent's total plus 1.4% of the
        reference words
      Otherwise roll back. The finding states what the rule gave, and any
      overrule by the architect.
  8.  It writes one dated verification finding per host. The finding holds:
      - every command, exactly as run
      - each item's decision and its outcome
      - the published claim beside the anchors
      - on adoption, a "where <retired model> still lives" table of every
        place the mode didn't change, addressed to whatever comes to own
        the host tooling
  9.  `setup` prints the verify mode's readiness rules beside the run's. A
      report run is unchanged and stays read-only. The verify mode is the
      skill's only change.
  framework
  10. Host stack, with no anchors:
      - The architect refreshes fwupd's metadata. This is fwupdmgr's first
        walk, and fwupdmgr is the task's one new tool. The get-updates
        result is recorded.
      - The boot-order sysctl is set to 1 before the reboot.
      - `omarchy update` brings linux-omarchy to 7.2.15-1.
      - After one reboot, the probe shows the new kernel running and llama
        up, with its tailnet port published.
  11. Mesa 26.2.6, linux-firmware 20261019, the TTM ceiling, and the two
      gpt-oss measurement sections are closed with no action. The finding
      gives each one's reason: not on the host's channel; not on the host's
      channel; headroom met; measurement sections that no agent loads.
  12. The model pass, all on 7.2.15:
      - anchors A and B before the swap, on gpt-oss-120b's 4-slot section
      - E4B Q8_0 and E4B QAT, each at shape A, shape B, ASR A, and ASR B
      - the ASR B transcripts of both, paired with their LibriSpeech
        references and compared by word differences
      - anchors A and B after the swap
      The verdict follows behavior 7.
  13. On adopt, framework's router serves E4B QAT as the audio model and
      Q8_0 is unloaded. The architect refreshes Pi's model list. The Q8_0
      files leave the store only after the walkthrough confirms QAT. On
      roll back, Q8_0 is served again and QAT is unloaded.
  14. The vLLM container and its images are removed through the `engines`
      suite. The six unused safetensors snapshots are removed, after a dry
      run. The docker build cache is cleared in full. The probe reads back
      all three as gone.
  15. The shape and ASR scenarios are copied into the spike's bench
      scenarios beside anchors A and B.

Test seams    One: `/hosting-upgrades verify <host>` and the finding it writes.
              The host's end state is read back by the skill's own probe. The
              project check covers the scenarios and links (shellcheck, link
              resolution).

Slices
  1. The verify mode and the bench copies (behaviors 1-9, 15): the verify
     mode, its readiness rules in `setup`, the finding's layout, and the four
     copied scenarios.
     Demo: `/hosting-upgrades verify framework`:
     - lists the report's eleven items with their recommended actions
     - names linux-omarchy 7.2.15-1 as moved since the report
     - re-checks E4B QAT's gates, the chat-template check included
     - changes nothing on the host
     The project check passes.
  2. The host stack (behaviors 10, 11; the architect's root steps, and the
     session's no-root steps in the architect's view):
     - fwupd refresh and get-updates (fwupdmgr's first walk); any offer is
       an escalation
     - the sysctl
     - `omarchy update`
     - the reboot
     - a probe
     - the four closures
     Demo: the finding's stack section, and the probe showing 7.2.15-1
     running with llama's port published.
  3. The model pass (behaviors 12-14; the session, in the architect's view):
     - anchors A+B before
     - the eight cells
     - the transcripts
     - adopt or roll back
     - anchors A+B after
     - on adopt, QAT served and the "where Q8_0 still lives" table
     - the vLLM, snapshot, and build-cache removals
     Demo: the finding's model section, with the claim beside the anchors
     and the verdict.
  4. Walkthrough (the architect), from the finding:
     - rerun anchor A and ASR A on the end state
     - check what the router serves
     - refresh Pi's model list
     - review each closure and removal
     - then remove the Q8_0 files from framework's store with `hf cache rm`,
       dry run first

Out of scope  - A fresh report run (the answer task's second report).
              - gb10-1 and its holds (verify-gb10).
              - The pool screen, BFCL, and tool reliability (screen).
              - Mesa or linux-firmware from outside the host's channel.
              - A firmware update that isn't approved at its escalation.
              - Any edit to a reference repository: spike-model-engines'
                preset and guides, spike-harness-driver, personal-agents,
                spike-model-hosting, spike-ai-pipeline.
              - Q8_0 on gb10-1 and gb10-2.
              - Changing the gpt-oss sections.
              - The future owner of the host scripts (a pending edit).

Door          two-way:
              - The kernel rolls back from the cache or the fallback kernel.
              - The sysctl rolls back by removing its file.
              - The audio swap rolls back by a section load. After the Q8_0
                removal, it rolls back by an 8.1G download.
              - The vLLM, snapshot, and cache removals roll back by re-pull,
                re-download, or rebuild.
              Only a firmware update approved at its escalation would be
              one-way, and none is planned. Nothing is released.
```

### Revision 1 · routing, approved 2026-11-02 (escalation in slice 3)

```
Added         framework stops sending its hostname in DHCP (IPv4 and IPv6) on
              its LAN connections, so the LAN router stops publishing
              framework.lan and the bare name `framework` resolves only
              through MagicDNS (the architect's root step, rollback: the same
              with `yes`). Before each pass, the verify mode checks that the
              target name resolves to the tailnet address only and connects
              in the path's time; a failed check is a pause.
Changed       The model pass is discarded and runs again once routing is
              settled, against `http://framework:8080`: anchors before, the
              eight cells, transcripts, anchors after, verdict. The removals
              stand. Slice 4's walkthrough follows the new pass.
Unchanged     Every other behavior, slice, and the door.
```

## Progress

slices 3/4 committed (204d418, 0bc44f4, slice 3 rerun below) · standards — · spec — · editor —
Next: slice 4, the architect's walkthrough, after a routing check (the router is being sysupgraded to OpenWrt 25.12.6). Run 3 of the model pass counts: E4B QAT rolled back by the rule (ASR B −5.0%, from 2 of 32 unprompted reasoning replies; the other cells lead), architect applied the rule. Routing settled: framework sends no DHCP hostname; the router's leases cleared. Spec review: the verify mode's step 6 gains the two cell rules and the routing check (framework.lan has no records; 50 connects, none failed or slow); the chat_template.jinja reading.

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

## Pending edits

- coordinator · `context/ai-hosting.md`, "spike-host-admin": add the architect's question
  (2026-11-02). spike-model-engines' `host/` scripts (the `engines` suite, the llama.cpp and vLLM
  scripts, the preset) have outlived the spike that wrote them; every later spike runs them
  read-only, and none may tune them. Should they become a sustainable package that no spike owns,
  adjustable as the workstations are tuned and reusable without friction? The lean: one repository
  that adapts to its host through an explicit host-class profile (strix-halo, gb10), checked
  against what the host detects, with the per-platform parts kept to those profiles. It matches
  this note's rule for scripted install and setup, and dotfiles' `platforms/<class>/` pattern.
  verify-framework's "where Q8_0 still lives" table is addressed to that owner.
- coordinator · `context/roadmap.toml`, experiment.hosting: a `plan experiment.hosting` session
  decides whether spike-host-admin widens to cover the repository's shape and the scripts' interim
  owner, and whether it moves earlier than last in the experiment.
- coordinator · `context/ai-hosting.md`, beside the host-tooling question: dual-stack serving
  (the router published on tailnet IPv4 and IPv6, `net.ipv6.ip_nonlocal_bind = 1` beside the
  IPv4 key, on framework and the GB10s), to take up once MagicDNS serves AAAA records for
  dual-stack nodes (tailscale#1152, open); until then the hosts keep their bare names
  tailnet-only by sending no hostname in DHCP (architect, 2026-11-02).
