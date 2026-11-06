# Research cache

What the hosting-upgrades skill's surveys read, one entry per source, updated in place
([survey.md](../.claude/skills/hosting-upgrades/survey.md), "Research cache"). Each entry gives
the source's URL, the date it was read, the hosts and subject it concerns, its tier, and what it
said. A survey cites an entry, with its read date, instead of reading the source again, until the
entry is 14 days old or its subject has changed; then it reads the source and replaces the entry.
An entry whose subject no longer concerns any host (a model no host serves or screens, a build two
images behind the newest, a closed register entry) is deleted. Git keeps the old text.

The register's upstream states are not cached here: a survey checks them with `gh` every run
([blockers.md](blockers.md)).

Seeded 2026-11-06 from the records that read each source, at their original read dates: gb10-1's
screen of 2026-11-05 ("Research read 2026-11-05" and "Sources"), framework's screen of 2026-11-04,
and the last reports of both hosts.

## llama.cpp

### #30252, idle-slot saves stall the server

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/30252>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Cells")
- **Concerns:** gb10-1 and framework: every section's prompt-cache keys (`cache-ram`,
  `cache-idle-slots`), set A's agent section first.
- **Tier:** primary.
- **Said:** saving idle slots to the prompt cache stalls all requests for seconds with interleaved
  KV cells. Its CUDA fix is #31391 (below). On b12098, which carries #31391, gb10-1 still measured
  the stall on Gemma's 16-slot section (3,271 idle-slot saves, long replies at 8-9 tok/s), and no
  prompt cache removed it.

### #31391, the CUDA fix for the idle-slot stall

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/31391>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Cells")
- **Concerns:** gb10-1: the prompt cache on CUDA, at b12098.
- **Tier:** primary.
- **Said:** merged 2026-11-03, in b12080 and later; it gathers batched tensor reads into mapped
  host memory, the fix offered for #30252's stall on CUDA.

### #31711, CUDA decode fragmentation with many sequences

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/31711>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Research read
  2026-11-05")
- **Concerns:** gb10-1 and framework: every section with more than 8 slots (the embedding
  section's 16), and the engine choice at a load target past 8 concurrent sessions.
- **Tier:** primary (a maintainer's comment).
- **Said:** open, "CUDA decode fragmentation with non-unified KV and 32 variable-length requests".
  A maintainer (am17an, 2026-11-05): "Are you swtiching off checkpointing? `-cram 0 -ctxcp 0`,
  also llama.cpp mostly optimizes upto 8 parallel sequences at the moment. Upto 16/32 sequences is
  on the roadmap."

### #30961, a cached prompt restored before idle slots are cleared

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/30961>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Research read
  2026-11-05")
- **Concerns:** gb10-1 and framework: set A's unified-KV agent section's prompt cache; the
  register's prompt-cache entry.
- **Tier:** primary.
- **Said:** open; a cached prompt is restored before idle slots are cleared, so the restore fails
  with a unified KV cache (`-kvu`), which set A's section uses.

### #27148, the RAM prompt cache restores another conversation

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/27148>; its fix
  <https://github.com/ggml-org/llama.cpp/pull/27624>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Research read
  2026-11-05"); #27624 2026-10-31 ([gb10-1 report](reports/gb10-1/2026-10-31.md), "Engines")
- **Concerns:** gb10-1 and framework: set A's agent section's prompt cache; the register's
  prompt-cache entry.
- **Tier:** primary.
- **Said:** open; the RAM-backed prompt cache (`--cache-ram`, `--cache-idle-slots`) restores
  content from an unrelated conversation into a fresh slot under concurrent load. Its fix #27624
  ("server: clear stale state when reusing LRU-selected slots") was open.

### #24265, a Gemma SWA server hangs near its memory limit

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/24265>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Research read
  2026-11-05")
- **Concerns:** gb10-1 and framework: the Gemma 4 sections (vision, audio) with the prompt cache
  and context checkpoints near the memory limit.
- **Tier:** primary.
- **Said:** closed; "llama-server hard-hangs system with Gemma GGUF (SWA/hybrid) when prompt cache
  + context checkpoints near RAM limit", on a DGX Spark: the state gb10-1's no-cache arm reached at
  0.69 GiB free.

### #30137, reference-counted context checkpoints

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/30137>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Research read
  2026-11-05")
- **Concerns:** gb10-1 (and framework's no-cache section): `ctx-checkpoints` on a section with no
  prompt cache; the register's unbounded-checkpoints entry.
- **Tier:** primary.
- **Said:** "Use reference-counted checkpoints instead of deep-copies", merged 2026-11-05, after
  b12098, so b12098 deep-copies each checkpoint.

### `common.h` at b12098, the checkpoint default

- **URL:** <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/common/common.h>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Sources")
- **Concerns:** gb10-1, which runs b12098: every section's default `ctx-checkpoints`.
- **Tier:** primary (the build's own argument defaults).
- **Said:** `n_ctx_checkpoints = 32`, the default a section that sets no `ctx-checkpoints` runs.

### ggml-org's DGX Spark benches

- **URL:** <https://github.com/ggml-org/llama.cpp/blob/master/benches/dgx-spark/dgx-spark.md>
  (raw: <https://raw.githubusercontent.com/ggml-org/llama.cpp/master/benches/dgx-spark/dgx-spark.md>)
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Research read
  2026-11-05"; also 2026-11-04)
- **Concerns:** gb10-1: the agent section's batch and ubatch (`-ub`), and the models the class's
  own benches run (discovery).
- **Tier:** attributed benchmark, by the architect's ruling of 2026-10-30.
- **Said:** at build 11fb327bf (7941), gpt-oss-120b batched S_TG 57 tok/s at B=1 and 98.5 at B=4,
  run with `-ub 2048`. gb10-1's anchors, at the router's default ubatch, read 50.66 and 78.06
  tok/s on b12098: a different measure, so not a gain until measured.

### #31620 and #31639, `-hf` tag matching

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/31620>,
  <https://github.com/ggml-org/llama.cpp/pull/31639>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Cells", "The engine
  move")
- **Concerns:** gb10-1 and framework: every Google QAT section; the register's QAT entry.
- **Tier:** primary.
- **Said:** "common : fix -hf tag matching inside longer quant names" and "common : do not allow
  `_` in sidecar separator", both merged 2026-11-04, in b12100 and later: an `-hf` tag matches
  only after `-`, `.` or `/`.

### #29221 and its fix #25584, Vulkan's "tensor not allocated"

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/29221>,
  <https://github.com/ggml-org/llama.cpp/pull/25584>
- **Read:** #29221 2026-11-04 ([framework screen](screens/framework/2026-11-04.md), "Cells");
  #25584 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Sources")
- **Concerns:** framework: Gemma 4 26B-A4B on Vulkan with several slots; the register's entry.
- **Tier:** primary.
- **Said:** #29221 open: Gemma 4 26B-A4B crashes the server on the second request with several
  slots on Vulkan (`GGML_ASSERT "tensor not allocated"`). #25584, "ggml : fix view init skipped
  after buft max_size split", its fix, open and unmerged.

### #31418, Vulkan's batched tensor copy API

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/31418>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Sources"); its figures
  2026-10-30 ([framework report](reports/framework/2026-10-30-2.md), "Engines")
- **Concerns:** framework: multi-slot prompt saves on Vulkan; the register's entry.
- **Tier:** primary; its figure a lead.
- **Said:** open; "vulkan: support batched tensor copy API". It measures the multi-slot
  unified-KV prompt-save time, not throughput: on an 8060S, Llama-3.1-8B Q6_K from 576–594 ms to
  21–38 ms, with no Mesa version or command (a lead).

### #29510, unified-KV multi-sequence attention

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/29510>
- **Read:** 2026-10-31 ([gb10-1 report](reports/gb10-1/2026-10-31.md), "Engines")
- **Concerns:** gb10-1 and framework: set A's agent section's `kv-unified`, at its load target of
  4 sessions.
- **Tier:** primary; its table attributed, on another class.
- **Said:** open. On an RTX PRO 6000 Blackwell (`llama-batched-bench -fa on -b 2048 -ub 512`,
  Gemma 4 26B-A4B Q8_0, 16384 × npl), TG at npl 1: unified 165.7, split 199.6; at npl 4: unified
  466.4, split 501.9. The author: "the current head of the PR only seems to have an effect on
  prefill, the decode improvements are completely gone."

## Engine choice and models

### spike-model-engines `docs/findings/bench-gb10-container.md`, vLLM against llama.cpp on gb10-1

- **URL:** spike-model-engines `docs/findings/bench-gb10-container.md` (a descriptor measurement
  of gb10-1)
- **Read:** 2026-11-04 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Sources"); as the
  2026-10-31 report reads it ([gb10-1 report](reports/gb10-1/2026-10-31.md), "Engines")
- **Concerns:** gb10-1: the engine choice for the agent and embedding purposes at their load
  targets, and vLLM's fit there.
- **Tier:** attributed benchmark, on this host.
- **Said:** on 2026-10-26, b11669 against vLLM v0.32.0, GuideLLM 0.8.1, 512 tokens in and 256 out,
  gpt-oss-120b output tok/s: 1 stream 50.0 (llama.cpp, 4 slots) against 34.0 (vLLM, 16
  sequences); 4 streams 80.9 against 86.7; 16 streams 129.0 against 168.2; 32 streams 126.2
  against 168.7; cold load 48 s against 577 s. The `vllm` container the 2026-10-31 probe read
  (exited) carries `--max-num-seqs 4 --max-model-len 8192 --gpu-memory-utilization 0.80
  --kv-cache-dtype bfloat16`: a context far under the agent target's 131,072-token pool, and a
  reservation of 80% of the device for one model, where the set's other purposes need their own
  process and reservation. The 2026-10-31 report held vLLM on that reservation model and its slow
  NVFP4 decode; no record measures vLLM at the agent's load target.

### vLLM with an NVFP4 Gemma 4 26B-A4B on a DGX Spark

- **URL:** <https://github.com/nabe2030/gemma4-vllm-nvfp4-dgx-spark>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Research read
  2026-11-05")
- **Concerns:** gb10-1: the engine choice for a Gemma 4 section at 16 concurrent sessions.
- **Tier:** lead.
- **Said:** 303 tok/s aggregate at 16 concurrent, beside gb10-1's sweep of 210.5 (all requests)
  for Gemma's QAT section on llama.cpp at 16: another engine and quantization.

### Red Hat's Gemma 4 26B-A4B NVFP4 card

- **URL:** <https://huggingface.co/RedHatAI/gemma-4-26B-A4B-it-NVFP4>
- **Read:** 2026-11-05 ([gb10-1 screen](screens/gb10-1/2026-11-05.md), "Research read
  2026-11-05")
- **Concerns:** gb10-1: Gemma 4 26B-A4B as an agent candidate; the register's multi-turn entry.
- **Tier:** primary for its own measurement.
- **Said:** BFCL v4 multi-turn 62.13%, for BF16 and its NVFP4 quantization alike, on vLLM with
  thinking on. Neither its harness nor its sample list is the screen's.
