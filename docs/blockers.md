# Blocker register

What blocks this project's hosts from an upgrade, one entry per blocker, read and kept by the
hosting-upgrades skill ([survey.md](../.claude/skills/hosting-upgrades/survey.md), "Blocker
register"). A survey checks every entry's upstream state with `gh` each run; a measure re-checks
the entries naming its host before its first load
([measure.md](../.claude/skills/hosting-upgrades/measure.md), step 1). Each check updates the
entry in place: its state, its upstream line, and its last-checked date. Git keeps the old text.

An entry names the hosts it affects, what it blocks, its measured cost with the record behind it,
the upstream issue or pull request, when it clears, the workaround, what reopens it, its state,
and when it was last checked. The states, in order:

- **open**: no fix is merged upstream.
- **fix merged**: a fix is merged, and no build with an image for the hosts' class carries it
  yet (`scripts/fix-in-image.sh`).
- **fix in an image build**: the newest build with an image for the class carries the fix; the
  survey makes it an upgrade item for each host it names.
- **cleared on the host**: a host runs a build with the fix and its measure record shows the
  blocked thing working; the entry says which hosts.

An entry is deleted once it is cleared on every host it names. A watch item that names a possible
upgrade, not something blocking one, stays in the host's descriptor (`docs/hosts/<host>.md`).

Where the records behind an entry don't state a field, the field says so; such an entry starts
open, last checked on the date of the record it came from.

## Google's QAT GGUFs don't resolve on llama.cpp b12100 and later

- **Hosts:** gb10-1 (held by it). framework too, once its build passes b12100: it serves the same
  Google QAT vision section from the shared preset ([framework.md](hosts/framework.md),
  "Purposes"), and its pin is b11960.
- **Blocks:** any llama.cpp build past b12098 on the gb10 class. llama.cpp
  [#31620](https://github.com/ggml-org/llama.cpp/pull/31620) and
  [#31639](https://github.com/ggml-org/llama.cpp/pull/31639) (b12100 and later) match an `-hf`
  quantization tag only after `-`, `.` or `/`, and Google's 26B-A4B, 31B and E4B QAT GGUFs put
  `_` before it (`gemma-4-26B_q4_0-it.gguf`), so the vision section and every other section on
  those files fail to load. The 12B QAT file puts `-` there and still resolves.
- **Measured cost:** gb10-1's move to b12124 on 2026-11-05: the vision section couldn't load, no
  vision cell ran, and the engine rule rolled the host back
  ([gb10-1 screen, 2026-11-05](screens/gb10-1/2026-11-05.md), "Cells", "The engine move"). One
  pass and one escalation.
- **Upstream:** #31620 merged 2026-11-04T07:22:54Z (4b29d02); #31639 merged 2026-11-04T08:32:46Z
  (4c4ca5b). They are the change that breaks, not a fix: no issue or pull request that restores
  `_` is named in the records.
- **Clears when:** Google renames its QAT GGUFs, or llama.cpp accepts `_` before an `-hf` tag, in
  a build with an image for the class.
- **Workaround:** gb10's pin held at b12098, the 2026-11-04 nightly, in spike-model-engines'
  `host/llama.env` (`LLAMA_BUILD_GB10`). Rejected by the architect: b12124 with every Google QAT
  section renamed to the router's derived `:IT` tag (2026-11-05).
- **Reopens it:** a later build that narrows tag matching again, or a new Google QAT file that
  puts `_` before its tag.
- **State:** open.
- **Last checked:** 2026-11-06T18:18Z, [framework survey, 2026-11-06](reports/framework/2026-11-06.md) (`gh pr view 31620`, `31639`:
  merged as above; no change that restores `_` found). The newest strix-halo image,
  `server-vulkan-b12169`, is past b12100 too, as are `-b12110` and `-b12124`; `server-vulkan-b12098`
  is the newest Vulkan image before it. framework still runs b11960.

## Gemma 4 26B-A4B aborts on Vulkan with several slots

- **Hosts:** framework.
- **Blocks:** Gemma 4 26B-A4B QAT's agent section on Vulkan, and with it framework's Gemma
  re-screen. llama.cpp [#29221](https://github.com/ggml-org/llama.cpp/issues/29221): the second
  request aborts the server in prompt_save with `GGML_ASSERT(tensor->data != NULL && "tensor not
  allocated")`.
- **Measured cost:** framework's screen on b11960, 2026-11-04: the 15-slot agent section completed
  shape A 1 of 8, shape B 0 of 32, long A 0 of 4, long B 0 of 16, and the candidate dropped at
  Gate 3 ([framework screen, 2026-11-04](screens/framework/2026-11-04.md), "Cells" and
  "Verdict").
- **Upstream:** issue #29221 open; its fix
  [#25584](https://github.com/ggml-org/llama.cpp/pull/25584), "ggml : fix view init skipped after
  buft max_size split", open and unmerged.
- **Clears when:** #25584 merges and a `server-vulkan` image carries it; framework's Gemma
  re-screen also waits on the batched tensor copy entry below (the architect, 2026-11-05).
- **Workaround:** Gemma 4 26B-A4B QAT serves vision only, on its own 4 × 32,768 section; set A's
  gpt-oss-120b serves agent.
- **Reopens it:** the abort recurring on a later build at several slots.
- **State:** open.
- **Last checked:** 2026-11-06T18:18Z, [framework survey, 2026-11-06](reports/framework/2026-11-06.md) (`gh issue view 29221`: open,
  updated 2026-10-28, its title now naming `-np 4` on Vulkan, "-np 3 is fine"; `gh pr view 25584`:
  open, updated 2026-10-31).

## Vulkan's batched tensor copy API

- **Hosts:** framework.
- **Blocks:** framework's Gemma re-screen, with the entry above (the architect, 2026-11-05). llama.cpp
  [#31418](https://github.com/ggml-org/llama.cpp/pull/31418), "vulkan: support batched tensor copy
  API", cuts the multi-slot unified-KV prompt-save time.
- **Measured cost:** not measured on this project's hosts. The pull request's own figure, a lead
  (no Mesa version or command): on an 8060S, Llama-3.1-8B Q6_K's prompt save from 576–594 ms to
  21–38 ms ([framework report, 2026-10-30-2](reports/framework/2026-10-30-2.md), "Engines").
- **Upstream:** pull request #31418 open.
- **Clears when:** #31418 merges and a `server-vulkan` image carries it.
- **Workaround:** none needed for set A; the re-screen waits.
- **Reopens it:** the records state none.
- **State:** open.
- **Last checked:** 2026-11-06T18:18Z, [framework survey, 2026-11-06](reports/framework/2026-11-06.md) (`gh pr view 31418`: open,
  updated 2026-10-30). Its base, "ggml : add batched tensor copy API (#30881)", is in b12098; the
  Vulkan side is not.

## The prompt cache with a unified KV cache

- **Hosts:** gb10-1, framework: set A's agent section, `gpt-oss-120b-MXFP4-set-a`, runs
  `kv-unified = true` on both ([gb10-1.md](hosts/gb10-1.md), [framework.md](hosts/framework.md),
  "Purposes").
- **Blocks:** llama.cpp's host-side prompt cache (`cache-ram`, idle-slot caching) on that section.
  [#30961](https://github.com/ggml-org/llama.cpp/issues/30961): a cached prompt is restored before
  idle slots are cleared, so the restore fails with a unified KV cache.
  [#27148](https://github.com/ggml-org/llama.cpp/issues/27148): the RAM-backed prompt cache
  restores content from an unrelated conversation into a fresh slot under concurrent load.
- **Measured cost:** neither bug was reproduced here. gb10-1 measured the section without the
  cache from fresh loads and it did as well or better
  ([gb10-1 screen, 2026-11-05](screens/gb10-1/2026-11-05.md), "Cells"); framework's check of the
  same keys is owed (the skill-revision task's measure).
- **Upstream:** #30961 open (updated 2026-11-03), with no fix named in the records; #27148 open
  (updated 2026-11-06: a new reproduction, and a reply, a lead, that a split-KV section needs
  `--no-cache-idle-slots` on top of `--cache-ram 0`), its fix
  [#27624](https://github.com/ggml-org/llama.cpp/pull/27624) open (updated 2026-10-10).
- **Clears when:** a fix for each merges and an image for the host's class carries it.
- **Workaround:** `cache-ram = 0` and `cache-idle-slots = false` on set A's section, in the shared
  preset (spike-model-engines `host/llama-preset/models.ini` at 933ec0f); served on both hosts,
  on framework since its clone was pulled to 933ec0f on 2026-11-06 (the architect's decision).
- **Reopens it:** turning the prompt cache back on for a unified-KV section.
- **State:** open.
- **Last checked:** 2026-11-06T18:18Z, [framework survey, 2026-11-06](reports/framework/2026-11-06.md) (`gh issue view 30961`: open, updated
  2026-11-03; `27148`: open, updated 2026-11-06T16:16Z, a commenter asking whether it is a CVE;
  `gh pr view 27624`: open, updated 2026-10-10). The probe reads `--cache-ram 0
  --no-cache-idle-slots` on set A's section on framework, the clone at 933ec0f.

## Context checkpoints unbounded with no prompt cache

- **Hosts:** gb10-1 (measured). framework's set A section serves the same no-cache keys (its
  clone at 933ec0f since 2026-11-06), at the 4.5 MiB checkpoints the preset's comment gives, not measured there.
- **Blocks:** a section with no prompt cache, many slots, and large checkpoints at the default
  `ctx-checkpoints` (32 at b12098, `common.h`): with no prompt cache nothing evicts a slot's
  checkpoints. It blocked Gemma 4 26B-A4B's 16-slot agent section until its checkpoints were
  capped.
- **Measured cost:** on gb10-1 at b12098, Gemma's 16-slot section without the cache held 32
  checkpoints of 200 MiB a slot, and free memory fell to 0.69 GiB; two checkpoints a slot removed
  it, memory steady at 38.4 GiB ([gb10-1 screen, 2026-11-05](screens/gb10-1/2026-11-05.md),
  "Findings" and "Cells", "The configuration on b12098").
- **Upstream:** [#30137](https://github.com/ggml-org/llama.cpp/pull/30137), "Use reference-counted
  checkpoints instead of deep-copies", merged 2026-11-05T10:02:36Z (e152332), after b12098, so
  b12098 deep-copies each checkpoint. `fix-in-image.sh`, reading ghcr's tags since c463da3, on
  2026-11-06T16:22Z: the newest gb10 image is `server-cuda13-b12169`, ahead of the merge by 28,
  behind by 0, so the fix is in an image build. (Its earlier reads walked GitHub releases and
  found b12124, behind by 17; b12169 has an image but no release.)
- **Clears when:** an image for the class carries #30137, the host can move to it (on gb10-1,
  once the QAT entry above clears), and a measure shows the section's memory bounded at the
  default `ctx-checkpoints`. Whether #30137 bounds the memory, rather than only the copies, is
  unmeasured.
- **Workaround:** `ctx-checkpoints = 2` on a no-cache section with large checkpoints.
- **Reopens it:** a no-cache section losing its checkpoint cap on a build without the fix.
- **State:** fix in an image build (b12169, gb10 and strix-halo).
- **Last checked:** 2026-11-06T18:18Z, [framework survey, 2026-11-06](reports/framework/2026-11-06.md) (`gh pr view 30137`: merged;
  `fix-in-image.sh` for strix-halo: "newest imaged build: b12169 … compare e152332a1598...b12169:
  ahead (ahead by 28, behind by 0) … in image: yes"). For framework it is an upgrade item, the move
  to b12169, which crosses the open QAT entry, so skip until that entry clears (the report,
  "Engines").

## Gemma 4's multi-turn gap on llama.cpp

- **Hosts:** gb10-1 (measured).
- **Blocks:** Gemma 4 26B-A4B QAT as the agent model: the keep rule's capability condition fails on
  BFCL multi-turn.
- **Measured cost:** 5 passing of 19 done at the 45-minute cap (about 0.26; at most 0.30 on the
  whole list) against the floor's 0.325, at b12098, so the screen dropped it
  ([gb10-1 screen, 2026-11-05](screens/gb10-1/2026-11-05.md), "Verdict"). Red Hat measures the
  same model's BFCL v4 multi-turn at 62.13% on vLLM, for BF16 and NVFP4 alike
  ([RedHatAI/gemma-4-26B-A4B-it-NVFP4](https://huggingface.co/RedHatAI/gemma-4-26B-A4B-it-NVFP4),
  read 2026-11-05), with another harness and sample list.
- **Upstream:** none named. The suspected cause, unverified, is llama.cpp's Gemma 4 chat template
  or tool parser taking prior reasoning back as `reasoning_content` differently from vLLM.
- **Clears when:** the template and parser check (proposed as its own task) finds the cause and a
  fix reaches an image, or Gemma's multi-turn on the host clears the floor.
- **Workaround:** gpt-oss-120b stays the agent model; Gemma serves vision.
- **Reopens it:** the records state none.
- **State:** open.
- **Last checked:** 2026-11-06, [framework survey, 2026-11-06](reports/framework/2026-11-06.md) (nothing upstream to check).

## Idle-slot saves stall decode on CUDA

- **Hosts:** gb10-1 (measured). Its vision and audio sections run the prompt cache at the defaults
  (`cache-ram` 8192, idle-slot saves on; `common.h` at b12098), so they are exposed, unmeasured
  ([gb10-1 report, 2026-11-06](reports/gb10-1/2026-11-06.md), "Configuration review", rows 1-2).
- **Blocks:** llama.cpp's host-side prompt cache with idle-slot saves (`cache-ram`,
  `cache-idle-slots`) on a multi-slot section on CUDA.
  [#30252](https://github.com/ggml-org/llama.cpp/issues/30252): saving idle slots to the prompt
  cache stalls all requests for seconds with interleaved KV cells.
- **Measured cost:** on gb10-1 at b12098, Gemma 4 26B-A4B QAT's 16-slot agent section with the
  default cache made 3,271 idle-slot saves in a 45-minute BFCL multi-turn run, and its long replies
  decoded at 8-9 tok/s; with `cache-ram 0`, `cache-idle-slots false` and `ctx-checkpoints 2`, no
  saves and 21.3 tok/s ([gb10-1 screen, 2026-11-05](screens/gb10-1/2026-11-05.md), "Cells", "The
  configuration on b12098").
- **Upstream:** #30252 closed 2026-11-04T02:18:07Z; its CUDA fix
  [#31391](https://github.com/ggml-org/llama.cpp/pull/31391) merged 2026-11-03T10:01:50Z, in b12080
  and later, which b12098 carries: the stall was measured on a build with the fix, so no fix that
  clears it on this host is named.
- **Clears when:** a fix that removes the stall under multi-slot load reaches an image for the
  class the host can run, and a measure shows a multi-slot section's decode with the cache on at
  the rate it holds without it.
- **Workaround:** `cache-ram = 0`, `cache-idle-slots = false`, with `ctx-checkpoints = 2` where the
  checkpoints are large (the entry above), as set A's agent section and Gemma's final agent section
  took them.
- **Reopens it:** turning the prompt cache back on for a multi-slot section on CUDA.
- **State:** open.
- **Last checked:** 2026-11-06T18:18Z, [framework survey, 2026-11-06](reports/framework/2026-11-06.md) (`gh issue view 30252`: closed;
  `gh pr view 31391`: merged).
