# goal · experiment.hosting.spike-hosting-upgrades

- **State:** handoff
- **Task:** screen
- **Branch:** screen

## Tasks

1. [x] skill
2. [x] verify-framework
3. [x] verify-gb10
4. [ ] screen
5. [ ] answer

## Task brief · screen

```
Problem       spike-model-hosting's pool document lists 47 open-weight
              models for the four purposes. It is a paper survey of
              2026-10-19 for Strix Halo at b11734, judged by an origin
              rule that has since been replaced and by speed floors our
              policy doesn't state. Nothing in it is judged for GB10. The
              skill can't read it, since its report and verify modes take
              no other spike's pool.
              The one agent candidate faster than gpt-oss-120b on both
              hosts, Gemma 4 26B-A4B QAT, is on hold for both hosts'
              reports: no card gives it a BFCL figure for the floors'
              categories, and the tool-reliability check has never run
              on it. Its only section gives a session 8,192 tokens.
              Already the vision model, it could serve agent and vision
              as one model, with gpt-oss-120b unloaded. That frees most
              of the memory pool and gives more sessions, each with the
              full context. It is a win if it performs nearly as well as
              an agent, even if it is not faster.
              This task gives the skill a screen mode. The mode gates the
              pool for each host class under today's policy, with the
              pool's speed floors added as a gate. On each host it then
              weighs Gemma serving both roles against set A in one
              session: capability, speed against floors, capacity, and
              memory. Each host keeps only what both the sources and its
              own checks support. No served set changes.
              One new tool: spike-model-hosting's agent tiers, run
              read-only from its clone.
              - What it is: BFCL through Inspect AI 0.3.281 and
                inspect_evals 0.24.0's stock task, plus clutch's conform
                through Pi 1.3.0.
              - What it provides: the agent bar's BFCL samples (100
                single-turn and 20 multi-turn, Gorilla dac44e7, seed
                20261016) and its harness-fit check (pass^5).
              - How it is set up: spike-model-hosting's consumers mise
                environment and its synced suites project, with outputs
                and state directed into this spike's ignored state.
              The architect walks it first, on framework.

Behaviors
  The screen mode
  1.  `/hosting-upgrades screen <host>` reads the host's descriptor, the
      policy, and the pool its descriptor's new Pool section names (a
      reference key and a path, as Measurements does). It runs the
      readiness check and the read-only probe as a run does, and changes
      nothing on the host itself.
  2.  For each pool row, the mode names the exact repository, file, and
      projector the host would load today. It then gates the row for the
      host's class by the skill's model gates, in order:
      - origin, artifact integrity, and the quantization floor, under
        the policy as it reads today
      - fit in the probed memory
      - the host's engine and build
      - for the agent purpose, the agent bar
      - the speed floor (behavior 4)
      Each row ends kept-candidate, hold (naming the measurement that
      would place it), or drop (naming the gate and its source). Every
      claim is cited with its URL and read date. A row the pool excluded
      on the old origin rule is judged again under today's.
  3.  The mode lists the agent candidates left at "needs measurement" by
      name, each with what it needs (Muse-Glimmer-30B, Flint,
      granite-switch-4.1-30b, Gemma 4 31B QAT, LFM2.5-24B-A2B, if any
      reach that gate). Only 26B-A4B QAT is measured in this task.
  4.  The policy gains the pool's role speed floors as a gate, which runs
      apply too:
      - agent: single-stream decode of 20 tok/s; 8k prefill of 500 tok/s
        with TTFT of 20 s; each of N agentic streams at 10 tok/s
      - vision: an image question in 10 s, alone and each of N
      - audio: RTFx of 5
      - embedding: 4,300 tok/s
      A measured or attributed figure under a floor drops the row. A
      paper estimate alone holds it. The skill's model gates state the
      gate and point to the policy.
  5.  The mode cites the verify mode's cell rules rather than restating
      them:
      - one model per purpose: unload, wait until unloaded, then load
      - fresh loads
      - full request counts
      - the probe, the build, and `tailscale ping`, with the routing
        check before the pass
      It prints every cell with its command, who runs it, and its cap
      before any load.
  6.  The mode writes one dated screen record per host, in a directory of
      its own. A later screen the same day writes `-N`, and a record is
      never edited. STANDARDS names the record beside the report form,
      and README's Capabilities point to it. The record holds:
      - the gated pool
      - every command exactly as run
      - the cells, with earlier published or measured claims beside them
      - BFCL and conform
      - the memory read-outs
      - the verdict, condition by condition, with any overrule by the
        architect beside what the rule gave
  The instruments
  7.  Two conform profiles are committed in this spike, one per host:
      strix-halo for framework and nvidia-cuda for gb10-1. Each names its
      router's model IDs: chat and vision on 26B-A4B QAT's agent section,
      audio on E4B Q8_0, embedding on granite BF16. spike-model-hosting's
      profile loader validates both, run from its clone (session, no
      root).
  8.  The scenarios:
      - spike-model-engines' vision A and B and its concurrency sweep
        (1, 4, 16 and 32 streams, 512 / 256, 60 s a level), copied into
        this spike
      - a new long-prompt scenario, 8,192 in and 512 out, at 1 stream × 4
        requests and 4 streams × 16
  9.  spike-model-engines' preset gains a 26B-A4B QAT agent section on a
      branch: 15 slots of 131,072 tokens each, KV not unified
      (c 1,966,080; 16 slots aborted on Vulkan, Decisions), card sampling (temperature 1.0, top-p 0.95,
      top-k 64, min-p 0).
      - The session pushes the branch straight to each host's clone over
        ssh and restarts the llama container so the router reads it (no
        root).
      - The pull request merges only if a host keeps the candidate, and
        it cites the record.
      - Otherwise the branch is dropped, and both clones return to main
        and are restarted.
  The pass, per host
  10. Before any load, the session re-checks 26B-A4B QAT's gates under
      today's policy, the chat-template check included. A failed gate
      stops the pass.
  11. Common to every cell:
      - tool: GuideLLM 0.8.1 from this machine, against the host's router
      - caps: `timeout 10m` for every cell, 15 minutes for each BFCL tier
      - builds: framework strix-halo b11960 (Vulkan), gb10-1 gb10 b12063
        (CUDA)
      - set A as served: agent gpt-oss-120b, vision 26B-A4B QAT's vision
        section, audio E4B Q8_0, embedding granite BF16
      - each section's cells run from a fresh load, except that BFCL
        single, BFCL multi, and conform share one
      Phase 1 runs on set A. Phase 2 runs on the Gemma set: the agent
      section serving agent and vision, with gpt-oss-120b and the vision
      section unloaded, and E4B Q8_0 and granite loaded. Set A is
      restored at the end.
      | Cell        | Model, section           | Load                 | ~Time  | Informs                  |
      | Phase 1, set A                                                                                |
      | Anchor A    | gpt-oss, the host's      | 1 × 8, 512 / 256     | 1 min  | incumbent decode, TTFT   |
      |             |   anchor section *       |                      |        |                          |
      | Anchor B    | the same                 | 4 × 32, 512 / 256    | 2 min  | incumbent concurrency    |
      | Long A      | gpt-oss, set A's section | 1 × 4, 8,192 / 512   | 2 min  | prefill, TTFT beside     |
      |             |                          |                      |        |   Gemma's                |
      | Long B      | the same, set loaded     | 4 × 16, 8,192 / 512  | 5 min  | streams at agent prompt  |
      |             |                          |                      |        |   size; set A's memory   |
      |             |                          |                      |        |   read after             |
      | Sweep       | gpt-oss, 16-slot section | 1/4/16/32 streams,   | 5 min  | capacity [R5-2]          |
      |             |                          |   60 s a level       |        |                          |
      | Vision A, B | 26B-A4B QAT, vision      | 1 × 8 / 4 × 32,      | 2 min  | reasoning count; vision  |
      |             |   section                |   720p + 200 / 64    |        |   baseline [R5-4]        |
      | Phase 2, the Gemma set                                                                        |
      | Cold start  | 26B-A4B QAT, agent       | API load from        | <1 min | local-only               |
      |             |   section                |   unloaded, timed    |        |                          |
      | Shape A, B  | the same                 | 1 × 8 / 4 × 32,      | 2 min  | decode floor [R5-1];     |
      |             |                          |   512 / 256,         |        |   beside anchors A and B |
      |             |                          |   thinking on        |        |                          |
      | Long A      | the same                 | 1 × 4, 8,192 / 512   | 2 min  | prefill, TTFT floors     |
      |             |                          |                      |        |   [R5-1]                 |
      | Long B      | the same, set loaded     | 4 × 16, 8,192 / 512  | 3 min  | stream floor [R5-1];     |
      |             |                          |                      |        |   memory read after      |
      |             |                          |                      |        |   [R5-3]                 |
      | Sweep       | the same                 | 1/4/16/32 streams,   | 5 min  | capacity [R5-2]          |
      |             |                          |   60 s a level       |        |                          |
      | Vision A, B | the same                 | 1 × 8 / 4 × 32,      | 2 min  | vision floor, reasoning  |
      |             |                          |   720p + 200 / 64    |        |   [R5-4]                 |
      | BFCL single | the same, one fresh load | 100 samples,         | 7 min  | floor 0.630              |
      |             |                          |   4 in flight [R5-6] |        |                          |
      | BFCL multi  | the same load            | 20 samples,          | 11 min | floor 0.325              |
      |             |                          |   4 in flight        |        |                          |
      | Conform     | the same load            | Pi, k = 5,           | 5 min  | tool reliability, API    |
      |             |                          |   9 capabilities     |        |   surface                |
      Per host: about 55 minutes of cells plus about 10 minutes of loads,
      so about 65 minutes. The caps bound it at about 2 h 35 min.
      * framework: the 4-slot section, with set A's agent unloaded
        meanwhile. gb10-1: set A's section. Each is the section the
        host's earlier anchors used. framework's 4-slot section can't
        hold an 8,192-token prompt, so the long cells run on set A's
        section on both hosts.
      BFCL and conform run at the router's defaults (the card's sampling,
      the template's default reasoning) with parallel tool calls allowed.
      gpt-oss-120b's BFCL doesn't run.
  12. The local-only checks, each recorded with its command:
      - cold start, as in the cell above
      - each set's memory, read warmed after its 4-stream long-prompt
        cell: MemAvailable on gb10-1, GTT on framework
      - each Gemma slot's context, read back from the router
      - API surface: chat completions with tools under `tool_choice`
        `required`, `response_format` `json_schema`, and image input each
        answer without error, read from conform's recordings and one
        request each
      - whether a feature works: images on the agent section, and
        replies with no unprompted reasoning
  13. The reasoning check runs on all four vision cells. It counts the
      replies that reasoned in the thought channel and in the text.
  14. The keep rule, for Gemma serving agent and vision with gpt-oss-120b
      unloaded. Keep only when every condition holds [R5-5]; otherwise
      drop. The record states what the rule gave on each condition, and
      any overrule by the architect beside it.
      - Gates: every gate passes, and no open tracker report has the
        engine's parser rejecting the model's tool calls.
      - Capability: BFCL single-turn at least 0.630 and multi-turn at
        least 0.325, each on its whole list.
      - Tool reliability: conform through Pi passes every applicable
        capability 5 of 5, with 0 invalid requests.
      - Completeness: every cell holds its full request count.
      - Speed [R5-1]:
        - shape A at least 20 output tok/s
        - long A prefill at least 500 tok/s, with TTFT median at most
          20 s
        - long B ITL median at most 100 ms (each stream at least
          10 tok/s)
        gpt-oss's same-session figures go beside them.
      - Capacity [R5-2]: the highest sweep level where Gemma's ITL median
        stays at 100 ms or less is at least gpt-oss's, and every Gemma
        slot holds 131,072 tokens.
      - Memory [R5-3]: the Gemma set leaves the policy's headroom and
        uses no more than set A's same-session reading.
      - Vision [R5-4]: on the agent section, every vision A and B request
        is answered within 10 s, and no more replies reasoned than on
        the vision section.
  15. A keep is recorded, not adopted. The session leaves the host
      serving set A as it found it, read back by the router's `/models`
      and the probe. A BFCL tier that hits 15 minutes, or any other cell
      that hits 10, is an escalation.
  Closures
  16. Closed with no action, each with its reason in the record:
      - E4B QAT's logit-bias ban on `<|channel>`: its reasoning was in
        plain text, and Google has published no revision
      - 12B QAT and 31B QAT's reasoning check: neither serves a purpose
        nor is a measured candidate
  Who runs what
  17. The architect runs every root step: the session-start host
      updates, and any reboot (with the probe after it). The architect
      also runs the first walk of BFCL (both tiers) and of conform, on
      framework.
      The session runs everything else, without root, in the
      architect's view:
      - the probe, the routing check, the branch push, and the container
        restart
      - loads, unloads, readiness waits, and the cells
      - the memory reads
      - gb10-1's BFCL and conform
  19. The prompt-cache stall (added 2026-11-04, Decisions): a bounded A/B on
      gb10-1 diagnoses why multi-turn traffic decodes at 7-8 tok/s a slot.
      BFCL multi-turn's first 4 samples (about 10 minutes a run) run on
      Gemma's section and on set A's gpt-oss section, each with the default
      prompt cache and with --cache-ram 0; the router's idle-slot saves,
      checkpoints, and decode rate are read from its log. The winning
      setting lands in spike-model-engines' preset through the screen
      branch's PR, whatever Gemma's verdict; BFCL multi-turn (45-minute cap)
      and conform (45-minute cap) then rerun on it. Single-turn's 0.800
      stands.
  20. The engine move on gb10-1 (revised 2026-11-05, Decisions): ASR A and
      B run on b12063, then the engines suite moves gb10-1 to b12125
      (`host/engines llama update b12125`, the session's step, no root),
      and set A's cells (anchors A and B, vision A and B, ASR A and B)
      rerun on b12125. The verify mode's engine rule judges the move,
      with its rollback printed. The gb10 class pin moves to b12125 on
      spike-model-engines' screen branch, and its currency command
      compares each class's pin with the newest bNNNNN release.
      Framework stays on b11960 until its next session's host update,
      reported as behind.
  21. The configuration on b12125: the maintainers' design (cache-ram
      8192, idle-slot caching on, slot-prompt-similarity 0) against
      cache-ram 0 with cache-idle-slots = false, each on BFCL
      multi-turn's whole list for Gemma's 16-slot section (45-minute
      cap, the router's decode and saves read every 5 minutes). The
      faster setting without a stall wins, its run is the keep rule's
      multi-turn figure, and both agent sections take it. Then phases 1
      and 2 rerun whole on b12125 with the winner, then BFCL single and
      conform, and the keep rule judges gb10-1 on b12125.
  18. Currency: both repositories report only held items, and so do
      spike-model-engines' after its pull request. Both projects' checks
      pass, and so does spike-model-hosting's profile validation of the
      two profiles.

Test seams    One: `/hosting-upgrades screen <host>` and the dated
              record it writes, with the host's end state read back by
              the skill's probe and the router's `/models`. Around it:
              - spike-model-hosting's profile loader passes both conform
                profiles
              - spike-model-engines' check passes on its branch
              - both projects' checks pass (shellcheck, links)

Slices
  1. The screen mode and its instruments (behaviors 1-9, 16):
     - the mode, the Pool sections and the template
     - the policy's speed floors and the skill's gate
     - the two conform profiles, validated
     - the copied vision and sweep scenarios, and the new long-prompt
       scenario
     - the 15 × 131,072 agent-section branch in spike-model-engines
     - the closures
     Demo:
     - `/hosting-upgrades screen framework` and `screen gb10-1` print the
       gated pool for each class, the "needs measurement" list, and the
       cells with their caps, then stop before any load, changing
       nothing
     - both profiles validate
     - both checks pass
  2. framework's pass (behaviors 10-15, 17). The architect runs the root
     host updates and the first walk of both BFCL tiers and conform; the
     session runs the rest in the architect's view:
     - the branch pushed and the router restarted
     - the gate re-check
     - phase 1 on set A, then phase 2 on the Gemma set, and the memory
       reads
     - the keep rule, and set A restored
     - framework's dated screen record
     Demo: the record's gated pool, the two phases' cells, BFCL, conform,
     the memory read-outs and the verdict, condition by condition; the
     probe and `/models` reading set A.
  3. gb10-1's pass, the same, with the session running BFCL and conform
     (behaviors 10-15, 17, 18):
     - on a keep on either host, spike-model-engines' pull request cites
       the records; otherwise the branch is dropped
     - both clones return to main and are restarted
     - gb10-1's dated screen record
     Demo: the record; set A read back; spike-model-engines' currency
     showing only held items.
  4. Walkthrough (the architect), from the two records:
     - the routing check on each host
     - on one host, rerun anchor A, and shape A on Gemma's agent section
       with gpt-oss and the vision section unloaded, each from a fresh
       load
     - rerun BFCL single-turn on the agent section, against the pass's
       figure
     - restore set A and read `/models`
     - validate both profiles
     - `/hosting-upgrades screen gb10-1` up to its cells
     - review each condition's outcome, each row's verdict, the
       closures, and the hold list

Out of scope  - Changing any served set or adopting a kept candidate
                (the answer task's report ranks it); Pi's model list.
              - Measuring any other agent candidate locally;
                gpt-oss-120b's BFCL; re-baselining the floors.
              - Harness fit through Claude Code or OpenCode.
              - E4B QAT, 12B QAT and 31B QAT cells.
              - Engine moves: framework stays on b11960 and gb10-1 on
                b12063.
              - Edits to spike-model-hosting (pool, pins, profiles) and
                its `evaluate sweep`.
              - A GB10 pool document; embedding cells.
              - gb10-2.
              - The engine rule's audio margin, the second report, and
                the cadence (answer).

Door          two-way:
              - The skill, policy, descriptor, profile, and scenario
                changes revert.
              - spike-model-engines' branch is dropped, or its pull
                request reverts, and the clones return to main with a
                restart.
              - Every load is undone by section loads, and set A is
                restored as found.
              Nothing is removed or released. Root is limited to the
              routine host updates.
```

## Progress

- Slice 1 committed (spike-hosting-upgrades edacd60, spike-model-engines b020ed2): the screen mode, the Pool sections, the speed floors, two conform profiles (both valid), the scenarios, the 16 × 131,072 agent section on spike-model-engines' `screen` branch, and the closures. Its demo, the screen run up to its cells on both hosts, is next.
- Slice 1 demo, 2026-11-04: both hosts probed (set A served on each; framework b11960, gb10-1 b12063, 6 apt updates pending and a reboot pending for gnome-shell). The pool's research is in ignored `.state/screen/research-{agent,other,origin}.md`. The demo's escalation (Gemma 4's unnamed teacher, and five rule edges) was answered at its recs on 2026-11-04 (Decisions).
- Slice 1 demo done: the gated pool for each host is in ignored `.state/screen/<host>/gated-pool.md`. Neither host keeps a candidate. The outcomes match on both hosts: agent 17 hold, 14 drop; vision 10 hold, 7 drop; audio 5 hold, 7 drop; embedding 5 hold, 12 drop. Seventeen agents need measurement. The session settled the assembler's open points by the policy as written: probes set the incumbents, a kept candidate must be measured, reward models, judges and hard-negative miners aren't teachers (their outputs aren't reproduced), and dataset sizes aren't mixture weights. The skill's hardcoded needs-measurement names were removed (d145c30). Slice 2, framework's pass, is next and needs the architect.
- Slice 2, framework, 2026-11-04: the architect approved running over DERP(nyc), since the routing check failed only its 50 ms test. The session pushed spike-model-engines' `screen` branch to framework's clone and restarted the router, the profile validated, and the gates passed (chat template identical, sha d1c082be). Phase 1 ran in full: anchors A 43.8 and B 75.9 tok/s; long A 26.1 tok/s with TTFT 8.8 s; long B 36.4 tok/s, TTFT 25.1 s, ITL 61.4 ms; GTT 92.22 GiB; the sweep's highest level at ITL ≤100 ms was 4 streams; vision A 23.0 and B 39.2 tok/s. The results are in ignored `.state/screen/framework/`. Phase 2 stopped at cold start: the agent section's instance aborted in llama.cpp's auto-fit, "pre-allocated tensor (cache_k_l5) in a buffer (Vulkan0) that cannot run the operation (NONE)" (cf. #29082). Set A is restored. The escalation was answered: 15 slots (Decisions).
- Slice 2, framework phase 2, 2026-11-04: the 15-slot section loaded (cold start 10.8 s; the router reports 15 slots, n_ctx 131,072; KV 38,400 MiB). Its second request aborted the instance with GGML_ASSERT "tensor not allocated" in prompt_save, which matches llama.cpp #29221 (Gemma 4 26B-A4B on Vulkan, second request, open); its fix, #25584 ("view init skipped after buft max_size split"), is unmerged. Shape A completed 1 of 8 (37.8 tok/s); shape B, long A, and long B completed none. Set A is restored. The second escalation was answered: a Gate 3 drop on framework (Decisions).
- Slice 2 done: framework's record, `docs/screens/framework/2026-11-04.md` (a60bfd5). Framework's clone stays on `screen` at 31b00eb until slice 3 decides the merge. Slice 3, gb10-1: the architect is running its apt upgrade (the six expected packages, no kernel or driver); the gnome-shell reboot is deferred, since the architect is remote and the kernel already runs 1024. For the session brief's proposals: a watch item on framework's descriptor for llama.cpp #25584 and #29221, whose merge re-opens framework's screen.
- Slice 3, gb10-1, 2026-11-04: the architect upgraded the six packages and regenerated the CDI spec; the probe read 0 pending (the gnome-shell reboot is deferred). The screen branch went to gb10-1's clone, the router restarted, and the CUDA profile validated. The routing check failed only its 50 ms test (DERP, nyc, 57 ms); the architect approved DERP. A 15-slot smoke test served 3 requests. Phase 1 ran in full: anchors A 48.3 and B 79.3 tok/s; long A 34.7 tok/s, TTFT 4.7 s; long B 51.6 tok/s, TTFT 15.0 s, ITL 50.1 ms; set A's memory MemAvailable 16.29 of 121.6 GiB; the sweep's highest level at ITL ≤100 ms was 4 (102.4 ms at 16); vision A 33.5, B 62.3 tok/s, max latency 4.84 s, every reply reasoned in the channel. The architect then returned the section to 16 slots (spike-model-engines eed8a33).
- Slice 3 phase 2, 16 slots: cold start 8.4 s, 16 slots of n_ctx 131,072, smoke test 3/3. Shape A 67.3 and B 137.2 tok/s; long A 49.3 tok/s, TTFT 2.85 s; long B 78.7 tok/s, TTFT 10.0 s, ITL 30.9 ms; the Gemma set's MemAvailable 28.56 GiB (set A's 16.29); the sweep's ITL stays ≤100 ms at all four levels (57.4 ms at 16, 62.4 ms at 32, where TTFT is 23 s); vision A 34.1, B 61.4 tok/s, max latency 4.83 s, reasoning 8/8 and 32/32 in the channel. Next: the architect's first walk of BFCL (single, multi) and conform, on one fresh load.
- The architect's first walk: BFCL single-turn 0.800 on 100 (floor 0.630), 10:05; BFCL multi-turn exit 124 at its cap (8/20, 5 passing). An escalation set its rerun (Decisions). Conform's first walk hit its 10-minute cap after one clean trial. Both reruns are decided (Decisions) and run in the background: BFCL multi into `bfcl-multi-2/`, conform into `conform-2/`.
- Multi-turn rerun: 16 of 20 at its 45-minute cap (6 passing), about 2.9 minutes a sample. The router's log over 3 minutes showed 150 idle-slot saves to the prompt cache (290-370 MiB each, about 1.7 s apart), 26 context checkpoints of 200 MiB, and decode swinging between 4.6 and 22.6 tok/s. The architect judged 7-8 tok/s unacceptable for any agent and chose to diagnose and fix (Decisions). The job was stopped (conform had begun, and its partial is in `conform-2/`). gb10-1 serves set A again; its clone is on `screen` at eed8a33 (16 slots); framework's clone is on `screen` at 31b00eb.
- Resumed 2026-11-04 after the architect's root steps on gb10-1: 8 security updates (apt, libsnmp, python3-pil, python3-twisted, linux-firmware-amd-graphics) and the deferred reboot (booted 16:02; kernel 1024, driver 580.178.04, b12063; the two SQLite updates were held back by phasing). The A/B's temporary sections are on spike-model-engines' screen at 4f40b62 (cram0 for both agents, plus a third arm the session added, Gemma with --no-cache-idle-slots), and the router's arguments read them back. The five-arm A/B runs in the background (`.state/screen/gb10-1/ab.sh`, its output in `ab.out`).
- The A/B after the reboot reproduced no stall: Gemma took 219 s with the default, 232 s with cram0, and 194 s with noidle; set A took 88 s with both, on BFCL multi-turn's first 4 samples. Research (2026-11-05) found the cause, llama.cpp #30252 (idle-slot saves stall the server thread; the CUDA fix #31391 is in b12080 and later, while gb10-1 runs b12063). The architect redirected: move to the newest build in this task, optimize the configuration, and rerun (Decisions; brief behaviors 20 and 21).
- Resumed 2026-11-05: the probe read b12063, kernel 1024, the two SQLite updates still phased; the routing check passed whole on the direct path (1 ms). ASR on b12063: A 13.82, B 23.84 audio s/s. b12125 has no server-cuda13 image (escalation answered: b12124, Decisions). On b12124 the anchors (48.73, 82.35 tok/s) and ASR (13.77, 24.43; word differences 43 of 568 against b12063's 48; no reasoning) held, but the vision section can't load: #31620 and #31639 (b12100 and later) match an -hf tag only after `-`, `.` or `/`, and Google's 26B-A4B, 31B and E4B QAT files put `_` before it (`gemma-4-26B_q4_0-it.gguf`), so their sections, Gemma's agent section included, fail to resolve; the 12B QAT file (`gemma-4-12b-it-qat-q4_0.gguf`) keeps `-` and resolves. The engine rule rolled b12124 back to b12063, and the architect chose b12098 (Decisions). Results in ignored `.state/screen/gb10-1/engine/`.
- Engine pass 2, 2026-11-05: b12063's six cells, then b12098's (`.state/screen/gb10-1/engine/pass2/`); the rule rolled b12098 back on four cells, and the architect overruled it (Decisions). gb10-1 serves b12098. spike-model-engines `screen`: 28afaa6 (currency against the newest build with the class's image), 5062c6b (the two cache arms), ba5c161 (a temporary set A nocache section), 231d92c (set A without the prompt cache); gb10-1's clone is at 231d92c.
- Behavior 21 on b12098 (`.state/screen/gb10-1/cache/`, `cache.out`): the cache arm (cache-ram 8192, idle-slot caching, -sps 0) reached 15 of 20 at its 45-minute cap, 8 passing, 3,271 idle-slot saves, long replies decoding at 8-9 tok/s, MemAvailable 20.0 GiB at the end; the nocache arm (cache-ram 0, cache-idle-slots false) reached 18 of 20 at its cap, 4 passing, no saves, long replies at about 21 tok/s, two runaway generations (no max_tokens sent; 9,027 output tokens in one sample), and MemAvailable 0.69 GiB at the end: with no prompt cache nothing evicts a slot's context checkpoints (32 a slot at 200 MiB on Gemma's section, about 100 GiB across 16 slots; b12098's server-context.cpp and server-task.cpp). gpt-oss's check (`gptoss/`): with the nocache keys set A ran BFCL multi-turn's first 4 in 262 s against 272 s (0 of 4 passing on both), long replies 24.6 against 22.6 tok/s, anchors A 49.80 against 48.27 and B 78.65 against 79.45; its checkpoints are 4.5 MiB, so set A keeps the keys (231d92c). Gemma's checkpoint bound went to the architect (Decisions).
- Phase 1 on b12098 (`.state/screen/gb10-1/b12098/`, `b12098-p1.out`), set A with the nocache keys: anchors A 50.66 and B 78.06 tok/s; long A errored one request of 4 (GuideLLM's JSONDecodeError on a streamed chunk) and its retry from a fresh load ran 4/4, 34.80 tok/s, TTFT 4.49 s; long B 51.22 tok/s, TTFT 9.98 s, ITL 60.0 ms; set A's MemAvailable 21.70 GiB after long B; the sweep's highest level at ITL ≤100 ms is 4 (104.7 ms at 16); vision A 36.97, B 64.67 tok/s, max latency 4.64 s, reasoning 8/8 and 32/32 in the channel.
- Gemma's final section on gb10-1 (spike-model-engines 4d5e114: cache-ram 0, cache-idle-slots false, ctx-checkpoints 2, shown by the router as --swa-checkpoints 2; b616c25, 986e738 pin b12098, 4d5e114 docs) on one fresh load beside E4B and granite (`.state/screen/gb10-1/b12098/`, `b12098-agent.out`): BFCL multi-turn 19 of 20 at its 45-minute cap, 5 passing (under the 0.325 floor at any finish: 6/20 = 0.30), no idle-slot saves, 711 checkpoints, long replies 21.3 tok/s mean (min 14.3), MemAvailable steady at 38.4 GiB (43.67 loaded); the last sample a runaway generation (23,306 output tokens; BFCL sends no max_tokens). BFCL single 78 of 100 (0.780), 10.6 minutes. Conform through Pi, k = 5: fits, 8 applicable capabilities at 5/5, 0 invalid (dropped-image n/a), 2m55s (about 35 s a trial, against about 8 minutes on b12063 with the prompt cache). The keep rule's capability condition fails on multi-turn, so Gemma drops on gb10-1. Research (2026-11-05) for the record: Red Hat measures Gemma 4 26B-A4B's BFCL v4 multi-turn at 62.13% on vLLM with thinking on (BF16 and NVFP4), so the low figure here points at llama.cpp's template or tool parser; Inspect sends reasoning back as reasoning_content. The sweep's per-level output figure counts only requests completed in its 60 s window (68.27 = 16 x 256 / 60), so earlier records' "flat 68 tok/s" is that artifact.
- Phase 2 on b12098 (`b12098-p2.out`): cold start 6.1 s, 16 slots of n_ctx 131,072; shape A 70.20, B 140.13 tok/s; long A 50.14 tok/s, TTFT 2.58 s; long B 85.12 tok/s, TTFT 5.21 s, ITL 37.1 ms; the Gemma set's MemAvailable 36.94 GiB after long B (set A's 21.70); the sweep's ITL ≤100 ms at all four levels (62.1 ms at 32; all-requests output 67.5/137.0/210.5/206.8 tok/s); vision A 38.36, B 65.86 tok/s on the agent section, max latency 4.70 s, reasoning 8/8 and 32/32 in the channel (the vision section's the same). The keep rule: drop, on BFCL multi-turn alone; every other condition holds. Set A restored; the end probe reads b12098 with set A loaded, no reboot pending, 4 apt updates pending (ca-certificates and ca-certificates-java, security, new; the two phased SQLite), and the user unit update-notifier-crash.service failed at 12:36 UTC, before the move (/var/crash empty). The probe is `.state/screen/gb10-1/b12098/probe-end.txt`. One preset file serves both hosts, so the merge would give framework's set A the no-cache keys unmeasured (a proposal for the brief).
- Reviews, 2026-11-05: gb10-1's record ebb315e and gb10-1's #31620 watch item abc9123; the standards review's fixes 5574340 (here) and 5c25996 (spike-model-engines), and the record's commands as run, d2c8a7b, 055317e, 6c441ec and ab8f17e. The spec review's gaps: the 2026-11-04 b12063 work and A/B in no record, behavior 12's three requests unsent, framework's #25584/#31418 watch items missing, strix-halo's currency item with no hold reason, the multi-turn cap hit not escalated (it goes to the session brief), and a stale Handoff and pending edit. The session sent behavior 12's three requests (`.state/screen/gb10-1/api.sh`; tools, json_schema and image, each HTTP 200 and correct) and restored set A, and returned framework's clone to main (dfc1d3d) with a restart and set A reloaded (b11960). The rest closed in a94b30f (the b12063 pass, behavior 12's requests and the cap escalation in gb10-1's record) and 5b06668 (framework's #25584 and #31418 watch items) here, and in spike-model-engines 928771f (strix-halo's hold reason), 51d144c (the five held pins listed) and 861d50e (Gemma's agent section removed for the PR); gb10-1's clone stays at 4d5e114, with the section, for the walkthrough.

## Handoff

- **Next move:** slice 4, the architect's walkthrough, from `docs/screens/framework/2026-11-04.md` and `docs/screens/gb10-1/2026-11-05.md` (brief, "Slices", 4). BUILD is done through slice 3 except its end steps, which follow the walkthrough.
- **Branch state:** spike-model-engines `screen` is at 861d50e: the gb10 pin at b12098, the currency rule (each class's pin against the newest build with its server image), set A's no-cache keys, strix-halo's hold reason, and Gemma's agent section removed for the pull request. spike-hosting-upgrades `screen` holds both records and the descriptors' watch items.
- **Host state:** gb10-1 serves set A on b12098, its clone on spike-model-engines `screen` at 4d5e114, which keeps Gemma's agent section for the walkthrough. framework serves set A on b11960, its clone back on main at dfc1d3d.
- **After the walkthrough:** once spike-model-engines' pull request merges, return gb10-1's clone to main, restart the llama container, and read set A back by `/models` and the probe.
- **Waiting on the architect:** the walkthrough, and these questions for the session brief:
  - BFCL multi-turn hit its 45-minute cap on gb10-1 (19 of 20, 5 passing).
  - framework's set A would take the no-cache keys unmeasured once the shared preset merges.
  - the record's proposals (`docs/screens/gb10-1/2026-11-05.md`, "Proposals").

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

## Pending edits

- Coordinator roadmap, `experiment.hosting.spike-model-layout`'s summary: weigh hosting the agent model alone on vLLM for concurrent-session throughput, with gb10-1's figures (gpt-oss-120b on vLLM v0.32.0: 34.0 vs llama.cpp's 50.0 tok/s at 1 stream, 168.2 vs 129.0 at 16; gb10-1 report 2026-10-31), the screen's finding that llama.cpp's idle-slot saves stalled multi-turn load before b12080, a published vLLM figure for an NVFP4 Gemma 4 26B-A4B on a DGX Spark of 303 tok/s aggregate at 16 concurrent (a lead) beside llama.cpp's 210.5 for Gemma's QAT section in gb10-1's sweep, and a llama.cpp maintainer's note that it "mostly optimizes upto 8 parallel sequences at the moment" (#31711) (screen, Decisions; `docs/screens/gb10-1/2026-11-05.md`, "Research read 2026-11-05").
