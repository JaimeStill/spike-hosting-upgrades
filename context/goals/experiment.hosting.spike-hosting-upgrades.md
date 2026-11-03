# goal · experiment.hosting.spike-hosting-upgrades

- **State:** building
- **Task:** verify-gb10
- **Branch:** verify-gb10 (spike-hosting-upgrades, spike-model-engines)

## Tasks

1. [x] skill
2. [x] verify-framework
3. [ ] verify-gb10
4. [ ] screen
5. [ ] answer

## Task brief · verify-gb10

```
Problem       gb10-1's 2026-10-31 report has one verify item: llama.cpp
              b11669 → a newer cuda13 server image. Two attributed GB10
              prefill gains (+17.2% MoE, +7.1% dense) and a Gemma 4 memory
              fix back it. The report also has three hardware holds and ten
              debt holds, and nothing has been measured or applied. The
              verify mode can only measure a model swap on one engine build.
              It has no rule for a change of build, so an engine upgrade
              leaves no record. Since the report, framework has found that
              E4B QAT, gb10-1's declared audio model, writes its reasoning
              into its replies.
              This task does four things. It gives the verify mode an
              engine item and uses it on gb10-1. It settles every gb10-1
              item and carries out the decided removals. It gives the gb10
              host class its own llama.cpp pin in spike-model-engines.
              Finally, it writes gb10-2's alignment steps as a report for
              spike-ai-pipeline, which applies them.
              No new tool: GuideLLM 0.8.1, the engines suite, hf, nmcli,
              and fwupdmgr have all been walked before.

Behaviors
  The verify mode's engine item
  1.  When the item `/hosting-upgrades verify <host>` names is an
      engine build, the mode prints one pass across two builds:
      - the incumbent build's cells
      - the move to the candidate build through the engines suite,
        with the version as its argument
      - the same cells on the candidate build
      Every cell runs on one kernel. A kernel change partway, or a
      third build, restarts the pass.
  2.  The engine verdict rule. Adopt only when all four hold:
      - every cell on the candidate is within 1.4% of the same cell on
        the incumbent, or ahead of it (output tok/s, or audio seconds
        a second for an ASR cell)
      - every cell holds its full request count
      - the ASR B word differences on the candidate are within the
        incumbent's total plus 1.4% of the reference words
      - the reasoning check on the candidate's ASR cells counts no more
        replies than on the incumbent's
      Otherwise roll back. A gain needn't exceed run noise, since
      engines stay current. The finding states what the rule gave on
      each condition, and any overrule by the architect.
  3.  The published claim is set beside each cell's TTFT median: 512
      prompt tokens for the anchors and the vision cells. Output
      tok/s goes beside it.
  4.  After an adopted engine move, the mode prints the rollback
      exactly: the suite's update to the earlier build, which pulls
      that build's images again, since the update removes every other
      build's images.
  gb10-1, the host stack
  5.  The session reads back the architect's apt state of 2026-11-02:
      - 0 upgraded: kernel 7.0.0-1024, driver 580.178.04
      - autoremove took three 6.17.0-1008 packages
      - the CDI spec was regenerated (spec 0.7.0)
      The finding records each command as it was run.
  6.  The architect refreshes fwupd's metadata, and the get-updates
      result is recorded. Any offered update is an escalation, with a
      reboot of its own if it is approved.
  7.  gb10-1 stops sending its hostname in DHCP (IPv4 and IPv6) on each
      of its NetworkManager connections, and the connections come up
      again. This is the architect's root step. Its rollback is the
      same command with `yes`. If the LAN publishes `gb10-1.lan`, the
      architect clears the router's lease names. Afterwards the
      routing check passes:
      - no `gb10-1.lan` A or AAAA record
      - the bare name resolves to the tailnet address only
      - 50 connects to `/health`, none failed, none over 50 ms
  8.  gb10-1's spike-model-engines clone is brought to main (no root),
      so its preset carries set A's agent section. The probe then reads
      the preset's sections.
  9.  gb10-1's set becomes:
      - agent: set A's gpt-oss-120b section (4 slots sharing 131,072
        tokens, so a session can reach 131,072)
      - vision: Gemma 4 26B-A4B QAT Q4_0
      - audio: E4B Q8_0, following framework's finding
      - embedding: granite BF16
      E4B QAT's files stay in the store until Google publishes a
      revision that fixes its reasoning.
  10. Seven items close with no action, each with its reason:
      - kernel 1024: no symptom on gb10-1, and a hold would stop the
        every-session update. 1019 stays installed. An unexpected boot
        seen at the session start's probe is an escalation.
      - display reserved memory: it frees memory, not speed, the set
        leaves headroom, and Dell's support is untested.
      - driver 580.196.07: not on the host's channel.
      - the boot-order remedy: present for IPv4. IPv6 waits on
        tailscale#1152.
      - the preset's sections beyond the set: shared with framework,
        and they cost nothing while unloaded.
      - Docker 29.9.2: not on the host's channel.
      - the 8,192-token gpt-oss sections: measurement sections that no
        agent loads.
      The report's engine candidates (`--cache-ram 0`, vLLM, SGLang,
      TensorRT-LLM) are listed by name as left for later.
  11. The failed user unit update-notifier-crash: the session reads
      its cause from the user journal and the /var/crash listing (no
      root), then resets it (no root). A crash in the kernel, the
      driver, or the engine is an escalation. Reading a root process's
      crash report is the architect's step.
  gb10-1, the engine pass
  12. Before any run, the mode re-checks that each model the cells
      load is gated under today's policy, chat-template check included:
      gpt-oss-120b MXFP4, 26B-A4B QAT, and E4B Q8_0.
      It then prints the agreed cells and runs them a step at a time,
      in the architect's view.
      Common to every cell:
      - tool: GuideLLM 0.8.1, from this machine, targeting
        `http://gb10-1:8080`
      - each run is capped at 10 minutes
      - one model per purpose; each model's cells run once from a fresh
        load
      - the pass records the probe, the build, and `tailscale ping`
      The six cells, run on b11669 and then on the candidate build
      (the newest cuda13 server image at session start; b12033 when
      planned):
      | Cell     | Model, configuration       | Load                 | ~Time | Informs                     |
      | Anchor A | gpt-oss-120b MXFP4, 4-slot | 1 stream × 8,        | 1 min | agent decode, TTFT          |
      |          | section                    | 512 in / 256 out     |       |   (prefill claim)           |
      | Anchor B | gpt-oss-120b MXFP4, 4-slot | 4 streams × 32,      | 2 min | agent concurrency           |
      |          | section                    | 512 / 256            |       |                             |
      | Vision A | 26B-A4B QAT Q4_0, its      | 1 × 8, 512 / 256,    | 1 min | MoE prefill (#31188), TTFT; |
      |          | section                    |   thinking on        |       |   Gemma 4 fix (#31394)      |
      | Vision B | 26B-A4B QAT Q4_0           | 4 × 32, 512 / 256    | 1 min | the same, under concurrency |
      | ASR A    | E4B Q8_0, its section      | 1 × 8 LibriSpeech    | 1 min | audio speed, #31394         |
      |          |                            |   clips, ≤256 out    |       |                             |
      | ASR B    | E4B Q8_0                   | 4 × 32 clips,        | 1 min | audio speed, transcripts    |
      |          |                            |   ≤256 out           |       |   (word differences),       |
      |          |                            |                      |       |   reasoning check           |
      The first anchors are set beside gb10-1's earlier readings
      (A 50.0, B 80.9 tok/s, b11669, 2026-10-26). A move beyond 1.4%
      is a finding. The verdict follows behavior 2.
  13. On adopt, gb10-1 runs the candidate build, and the walkthrough
      loads set A on it. On roll back, the suite returns gb10-1 to
      b11669, set A as above, and nothing changes in spike-model-engines.
  14. Removals, each read back by the probe as gone:
      - the vllm container, every vLLM image, and the compile cache,
        through the suite (session, no root). Rollback: the suite's
        install.
      - both bare-metal units, llama-router and vllm-server:
        - the suite's two native uninstalls (session, no root)
        - then the architect removes the unit files, /opt/llama.cpp,
          /opt/vllm, and their sudoers rules, as the uninstall guides
          give them (root)
        - rollback: the native installs plus the guides' root steps
      - the six unused snapshots (~146G: openai gpt-oss-120b, both
        NVFP4 Gemmas, gemma-4-E4B-it, both w4a16-ct), dry run first,
        shown to the architect (session). ibm-granite's safetensors
        and ggml-org's E4B Q8_0 stay. Rollback: `hf download`.
      - hello-world:latest (session, no root). Rollback: a pull.
      - the 6.17.0-1008 kernel image and modules (the architect, root,
        apt; the packages are confirmed at session start). 1019 stays.
        Rollback: reinstall.
      b11669's full image leaves with the suite's update on adopt.
  spike-model-engines
  15. Its currency reports only held items: huggingface_hub 2.4.0 is
      taken; bench python 3.14.10, vLLM v0.32.0, and native vLLM's
      Python 3.12 are held (Decisions). On adopt, the engines suite
      pins llama.cpp per host class:
      - gb10 (cuda13) at the adopted build
      - strix-halo (rocm, vulkan) at b11960, so framework doesn't move
      With no version given, install and update take the host class's
      pin. The currency command reports a class's pin only when it is
      behind the newest release's build. The pull request cites the
      finding.
  The record
  16. One dated verification finding for gb10-1, in the verify mode's
      layout:
      - every command exactly as run
      - each item's decision and outcome
      - the claim beside the TTFT and tok/s figures
      - the verdict
  17. A dated report addressed to spike-ai-pipeline's agent, with
      gb10-2's alignment steps exactly as that spike would run them.
      For each step it gives who runs it (root is the architect's),
      the rollback, and the routing check:
      - the DHCP hostname setting, and the lease clearing if needed
      - on adopt, moving its own llama.cpp pin from b11669 to the
        adopted build through its host-update
      It also names:
      - what already matches gb10-1: the IPv4 sysctl and audio Q8_0
      - what gb10-2 doesn't take: E4B QAT, and gb10-1's debt
      - that any change to gb10-2's model configuration stays an
        escalation in that spike
      It changes nothing on gb10-2.

Test seams    Two. In spike-hosting-upgrades, `/hosting-upgrades verify
              gb10-1` and the finding it writes, with the host's end state
              read back by the skill's probe. In spike-model-engines, the
              suite's `llama update` with no version on a gb10 host (reads
              "already runs" the adopted build) and its currency command
              (only held items). Both projects' checks pass (shellcheck,
              links).

Slices
  1. Upgrade and the engine item (behaviors 1-4, and 15's currency
     part):
     - spike-model-engines takes huggingface_hub 2.4.0 and logs its
       three holds
     - the verify mode gains the engine item
     Demo:
     - spike-model-engines' currency reports only held items, and its
       check passes
     - `/hosting-upgrades verify gb10-1`:
       - lists every report item with its decision
       - names what moved (the apt state, autoremove)
       - re-checks the three models' gates
       - prints the 12 cells and the engine rule
       - changes nothing on the host
     The project check passes.
  2. The host stack and the set (behaviors 5-11). The architect runs
     the root steps; the session runs the rest in the architect's view:
     - the apt read-back
     - fwupd refresh and get-updates (any offer is an escalation)
     - the DHCP hostname setting and the routing check
     - the clone pulled to main
     - the failed unit read and reset
     - the seven closures
     Demo: the finding's stack section; the probe reads the set A
     section and no failed unit; the routing check passes.
  3. The engine pass (behaviors 12-14, 15's pin, 16, 17), the session
     in the architect's view:
     - six cells on b11669, the move, six cells on the candidate
     - the verdict, then adopt or roll back
     - the removals, with the snapshots' dry run first and the
       architect's root steps
     - on adopt, the per-class pin and currency-check pull request
     - the gb10-2 report
     Demo: the finding's engine section, with the claim beside the
     TTFT figures and the verdict; the probe showing the removals gone;
     the gb10-2 report.
  4. Walkthrough (the architect), from the finding:
     - the routing check
     - load set A one model per purpose on the end-state build, waiting
       for each unload, and read `/models`
     - rerun anchor A and ASR A
     - `engines llama update` with no version
     - spike-model-engines' currency (only held items)
     - review each closure and removal
     - read the gb10-2 report

Out of scope  - Any change on gb10-2 (spike-ai-pipeline applies the report).
              - Edits to spike-ai-pipeline's pins or scripts.
              - framework: it stays on b11960.
              - E4B QAT on gb10-1 (revisited on Google's revision, or in
                screen), and deleting its files.
              - The pool screen and BFCL (screen); a fresh report run
                (answer).
              - The engine candidates: `--cache-ram 0`, vLLM, SGLang,
                TensorRT-LLM; removing vLLM's pins from spike-model-engines.
              - llama-bench, and embedding cells.
              - Changing the 4-slot or 16-slot sections.
              - Dual-stack serving.
              - Kernel-argument workarounds; a display-memory change.
              - The host tooling's later repository.

Door          two-way:
              - The build rolls back by the suite's update to b11669 (a
                pull).
              - The pin pull request reverts.
              - The DHCP setting rolls back with `yes`.
              - The set changes roll back by section loads.
              - The removals roll back by re-pull, re-download,
                reinstall, or the native installs with their root steps.
              Only a firmware update approved at its escalation would be
              one-way, and none is planned. Nothing is released.
```

## Progress

- slice 1 committed: spike-model-engines 34ac38c (huggingface_hub 2.4.0; the three holds' reasons in their pin comments, currency.sh and context/README.md), spike-hosting-upgrades aadf6ce (the verify mode's engine item: steps 1-3 and 5-9 of SKILL.md). Both checks pass; engines currency reports only the three held pins. Gap closed in 5c32f8d: the routing check's awk read numbered fields, which Claude Code replaces with the skill's arguments at load; it now reads `cut` and `$NF`; the three verify-mode readiness rules committed.
- slice 1 demo shown (2026-11-02): 14 items with their decisions, what moved, the three models' gates all passing (templates byte-identical to their publishers'), the 12 cells and the engine rule; nothing changed on the host. Slice 2 next.
- slice 2 in progress (2026-11-03): update-notifier-crash read (whoopsie absent, so the helper's `set -e` exits 1 at `which whoopsie` whenever /var/crash changes; no kernel, driver, or engine crash since 2026-10-19) and reset by the session; the clone fast-forwarded to a89afc5 (set A's section in the preset); the architect upgraded tailscale to 1.104.5, set `Wired connection 1` (the only DHCP connection; the ConnectX-7 netplan connections are manual) to send no hostname and brought it up (07:18:42), and cleared gb10-1 from the router's odhcpd and dnsmasq leases; the routing check passes (no gb10-1.lan record, bare name tailnet, 50/0/0, max 5.9 ms); the probe reads no failed unit. The session restarted the llama container on b11669 so the router lists set A's section (agreed at the escalation). The architect upgraded nvidia-spark-initcall-bl to 1.0-2 (it adds `power_wrap_init` to `initcall_blacklist`), ran update-grub, and rebooted (boot 2026-11-03 07:25:38); the probe reads kernel 7.0.0-1024, both blacklisted initcalls, no failed unit, llama b11669 healthy and published, 0 pending; the routing check passes again (max 6.6 ms). Slice 2 committed: bd1e793 and fd060d4, gb10-1's finding `docs/findings/verify-gb10-1.md` through Host stack and the engine pass's Gates (all three models pass; templates byte-identical). b12063's server-cuda13 image is published on ghcr.io. Slice 3 next: the engine pass b11669 to b12063, anchors on the set A section.
- slice 3 in progress (2026-11-03): pass 1 on boot 2026-11-03 07:25:38, kernel 7.0.0-1024, b11669-620d2225c; results in .state/verify/gb10-1/pass1/; helpers in the session's scratchpad pass.sh (agent/vision/audio functions, fresh load each). Done: b11669 anchor A (set A section) 8/8, 48.94 tok/s, TTFT median 414 ms, ITL 18.8 ms; anchor B 32/32, 80.78 tok/s, TTFT 1,837 ms, ITL 43.8 ms (12:33Z). Against 2026-10-26's readings (A 50.0, B 80.9, b11669, on the 32,768-token 4-slot section): A -2.1% (beyond 1.4%, a finding; the section, the boot, and the initcall blacklist differ), B -0.15%. Paused by the architect after the anchors; set A left loaded. Next: vision (shape A, B) and audio (ASR A, B) on b11669, then the move to b12063 and its six cells. A reboot before the pass ends restarts it.
- slice 3, pass 2 (2026-11-03): from the office, this machine reaches gb10-1 only through DERP(iad), 51-65 ms, no direct connection; the routing check failed its latency condition (50 connects, 0 failed, 50 over 50 ms, max 248 ms). The architect overruled it: pass 2 restarts from the anchors, all 12 cells over the relayed path, recorded; pass 1's two direct-path anchors stand as a record only. Helpers now at .state/verify/gb10-1/pass.sh (the scratchpad was cleared).
- slice 3, pass 2 complete (2026-11-03, 17:35Z-17:58Z, boot 07:25:38, kernel 7.0.0-1024, DERP(iad)): every cell full. b11669-620d2225c / b12063-2cbca389f, figure (TTFT median ms): anchor A 48.74 (499) / 48.14 (495), -1.2%; anchor B 80.84 (1,858) / 79.33 (1,847), -1.9%; shape A 65.25 (384) / 68.06 (373), +4.3%; shape B 140.08 (1,028) / 140.47 (995), +0.3%; ASR A 7.016 (970) / 6.751 (1,021) audio s/s, -3.8%; ASR B 16.103 (964) / 14.321 (1,188), -11.1%. ASR B word differences 46 / 45 of 568 reference words (limit 46 + 7.95). Reasoning check 0/0 channel and text on both builds' ASR cells. The engine rule: condition 1 fails (anchor B, ASR A, ASR B beyond 1.4% behind); conditions 2-4 hold; so roll back. The architect overruled it: adopt b12063. The move ran 17:42:37Z, exit 0, and removed b11669's server and full images; gb10-1 serves b12063. Research on the regression: no issue since b11669 reports slower audio, gpt-oss, or CUDA; ASR B's loss is TTFT (964 to 1,188 ms) with ITL unchanged, anchor B's is ITL (+1.8%), both only under 4 streams; candidates by inference #30804 and #29510, not attributed. Proposed: a descriptor watch item for audio TTFT under concurrency from b12063. Next: load the set on b12063, the removals, the per-class pin PR, the gb10-2 report.

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
- verify-gb10: spike-model-engines joins the goal's repos with a `[workspace.paths]` entry, and verify-gb10 branches there; experiment.hosting owns its `host/` until the intake (Decisions :642) (architect, 2026-11-02).
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

## Pending edits

(none)
