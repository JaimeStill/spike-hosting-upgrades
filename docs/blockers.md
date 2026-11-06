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
- **Last checked:** 2026-11-06 (`gh pr view`, both merged as above).

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
- **Last checked:** 2026-11-06 (`gh issue view 29221`, `gh pr view 25584`: both open).

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
- **Last checked:** 2026-11-06 (`gh pr view 31418`: open).

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
- **Upstream:** #30961 open, with no fix named in the records; #27148 open, its fix
  [#27624](https://github.com/ggml-org/llama.cpp/pull/27624) open.
- **Clears when:** a fix for each merges and an image for the host's class carries it.
- **Workaround:** `cache-ram = 0` and `cache-idle-slots = false` on set A's section, in the shared
  preset (spike-model-engines `host/llama-preset/models.ini` at 933ec0f).
- **Reopens it:** turning the prompt cache back on for a unified-KV section.
- **State:** open.
- **Last checked:** 2026-11-06 (`gh issue view 30961`, `27148`, `gh pr view 27624`: all open).

## Context checkpoints unbounded with no prompt cache

- **Hosts:** gb10-1 (measured). framework's set A section takes the same no-cache keys, at the
  4.5 MiB checkpoints the preset's comment gives, not measured there.
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
  b12098 deep-copies each checkpoint. `fix-in-image.sh` on 2026-11-06: the newest gb10 image,
  `server-cuda13-b12124`, is behind the merge (ahead by 0, behind by 17), so no imaged build
  carries it.
- **Clears when:** an image for the class carries #30137, the host can move to it (on gb10-1,
  once the QAT entry above clears), and a measure shows the section's memory bounded at the
  default `ctx-checkpoints`. Whether #30137 bounds the memory, rather than only the copies, is
  unmeasured.
- **Workaround:** `ctx-checkpoints = 2` on a no-cache section with large checkpoints.
- **Reopens it:** a no-cache section losing its checkpoint cap on a build without the fix.
- **State:** fix merged.
- **Last checked:** 2026-11-06 (`gh pr view 30137`; `fix-in-image.sh` for gb10).

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
- **Last checked:** 2026-11-05 (the screen's record; nothing upstream to check).
