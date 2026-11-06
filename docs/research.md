# Research cache

What the hosting-upgrades skill's surveys read, one entry per source, updated in place
([survey.md](../.claude/skills/hosting-upgrades/survey.md), "Research cache"). Each entry gives
the source's URL, the time it was read, the hosts and subject it concerns, its tier, and what it
said. A read time is a UTC timestamp, `YYYY-MM-DDTHH:MMZ`, so an upstream update on the day of the
read is placed before or after it; an entry that gives only a date counts as read at 00:00Z that
day. A survey cites an entry, with its read time, instead of reading the source again, until the
entry is 14 days old or its subject has changed; then it reads the source and replaces the entry.
An entry holds what a source said about its subject (an issue's comments, a release's notes, a
model's card), never which release or model is newest, which a survey reads fresh every run. Each
model a survey judges has one entry for its card and origin chain, under "Model cards and origin
chains", so the next survey cites the chain instead of rebuilding it. An entry whose subject no
longer concerns any host (a model no host serves or screens, a build no host runs or is held at
and two images behind the newest, a closed register entry) is deleted. Git keeps the old text.

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
- **Read:** 2026-11-06 (gb10-1 survey; updated upstream 2026-11-05T13:55, the day of the last read)
- **Concerns:** gb10-1 and framework: every section with more than 8 slots (the embedding
  section's 16), and the engine choice at a load target past 8 concurrent sessions.
- **Tier:** a lead: the commenter, am17an, is marked CONTRIBUTOR, not MEMBER, OWNER or
  COLLABORATOR (sources.md, "Reading a source"); the issue itself primary.
- **Said:** open, "CUDA decode fragmentation with non-unified KV and 32 variable-length requests".
  am17an, 2026-11-05T08:16: "we have improved quite a bit the unified kv-cache performance via
  #29510 which is available in llama v0.9.0"; 13:55: "Are you swtiching off checkpointing?
  `-cram 0 -ctxcp 0`, also llama.cpp mostly optimizes upto 8 parallel sequences at the moment. Upto
  16/32 sequences is on the roadmap. Also please don't use BF16 KV, it falls to the CPU on CUDA
  AFAIK. Use F16". A user on an RTX 5070, Qwen3-0.6B, v0.9.0: kv_rows cut 193.909 s to 165.632 s;
  vLLM 46.896 s.

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
- **Read:** 2026-11-06T18:54Z (gb10-1's second survey; updated upstream 2026-11-06T16:16:53Z, no
  comment since)
- **Concerns:** gb10-1 and framework: set A's agent section's prompt cache, and the split-KV Gemma
  sections' default cache; the register's prompt-cache entry.
- **Tier:** primary (the issue); its commenters (authorAssociation NONE) leads.
- **Said:** open; the RAM-backed prompt cache (`--cache-ram`, `--cache-idle-slots`) restores
  content from an unrelated conversation into a fresh slot under concurrent load. elchic00
  (2026-08-22): with `kv_unified = true` either flag fixes it; with `kv_unified = false` "closing it
  needs `--no-cache-idle-slots` on top of `--cache-ram 0`". darrellberry (2026-10-10): a
  reproduction on Metal, "(every report so far has been AMD iGPU)". cashcropper4life
  (2026-11-06T03:21Z), llama-server under Ollama 0.32.14 with a Qwen MoE at the default
  `--cache-ram` and `--cache-idle-slots`: in "2 of 60" control pairs a response carried the other
  request's canary; with `LLAMA_ARG_CACHE_RAM=0`, "0/100 controls and 0/300 tests", and a one-week
  soak "468 requests, 0 leaks"; "We did not separately disable `--cache-idle-slots`." No MEMBER,
  OWNER or COLLABORATOR comment. huornlmj (2026-11-06T16:16Z): "Has this not
  been logged as a CVE?". Its fix #27624 open (updated 2026-10-10).

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
- **Read:** 2026-11-06T18:21Z (framework survey; the pull request was updated 2026-11-05T10:02Z,
  after the 2026-11-05 read)
- **Concerns:** gb10-1 and framework: `ctx-checkpoints` on a section with no prompt cache; the
  register's unbounded-checkpoints entry.
- **Tier:** primary.
- **Said:** "llama-server: Use reference-counted checkpoints instead of deep-copies", merged
  2026-11-05T10:02:36Z (e152332), after b12098: `std::shared_ptr` checkpoints "allowing cheap
  (ref-counted) copies", zero-initialization skipped, broken requests rejected before the prompt
  cache; "This applies mainly to the host-side copies. The effects become larger as context
  grows." It names no bound on the checkpoints' count or memory.

### `common.h`, `server.cpp` and the server README at b12098, the defaults

- **URL:** <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/common/common.h>,
  <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/tools/server/server.cpp>,
  <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/tools/server/README.md>
- **Read:** 2026-11-06 (gb10-1 survey); the README re-read 2026-11-06T18:50Z (gb10-1's second
  survey) for the router's autoload
- **Concerns:** gb10-1, which runs b12098: every section's unset keys, and whether an unloaded
  section serves.
- **Tier:** primary (the build's own argument defaults).
- **Said:** `n_batch = 2048`, `n_ubatch = 512`, flash attention `AUTO`, `cache_type_k`/`_v` F16,
  `kv_unified = false`, `n_parallel` -1 (auto), `cache_ram_mib = 8192`, `cache_idle_slots = true`,
  `n_ctx_checkpoints = 32`, `checkpoint_min_step = 8192`, `swa_full = false`, `models_max = 4`,
  `load_mode` auto. `server_prepare_params()`: with `n_parallel` auto the server uses 4 slots and
  `kv_unified = true` (not for the router role), so a section that sets `parallel` runs split KV
  unless it sets `kv-unified`. README: `-kvu` "(default: enabled if number of slots is auto)",
  `--cache-idle-slots` "(default: enabled, requires cache-ram)". README: `--models-autoload,
  --no-models-autoload` "for router server, whether to automatically load models (default:
  enabled)"; `--models-max` "(default: 4, 0 = unlimited)"; `--models-memory-margin` unloads "LRU
  models until a new one fits".

### `docs/docker.md` at b12098, the container's run flags

- **URL:** <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/docs/docker.md>
- **Read:** 2026-11-06T18:54Z (gb10-1's second survey)
- **Concerns:** gb10-1: the `llama` container's run flags.
- **Tier:** primary.
- **Said:** the CUDA example: "docker run --gpus all -v /path/to/models:/models
  local/llama.cpp:server-cuda -m /models/7B/ggml-model-q4_0.gguf --port 8080 --host 0.0.0.0 -n 512
  --n-gpu-layers 1"; "`ghcr.io/ggml-org/llama.cpp:server-cuda13`: Same as `server` but compiled
  with CUDA 13 support." No `--ipc`, `--shm-size`, ulimit or library-path guidance.

### llama.cpp b12098 to b12169, the cuda13 images, #31788 and #31806

- **URL:** <https://api.github.com/repos/ggml-org/llama.cpp/compare/b12098...b12169>,
  <https://api.github.com/repos/ggml-org/llama.cpp/compare/b12167...b12169>,
  <https://github.com/ggml-org/llama.cpp/pull/31788>, <https://github.com/ggml-org/llama.cpp/pull/31806>,
  <https://github.com/ggml-org/llama.cpp/pkgs/container/llama.cpp/versions?filters%5Bversion_type%5D=tagged>
- **Read:** 2026-11-06T18:52Z to 18:54Z (gb10-1's second survey)
- **Concerns:** gb10-1: what a move past b12098 brings on CUDA, and the image's CUDA.
- **Tier:** primary.
- **Said:** b12098…b12169, 71 commits. CUDA: #31296 (NVFP4 MMQ fusion), #31047 "CUDA: linearize
  MoE data layout for MMQ/MMF" (2026-11-05T10:33Z), #31679 "CUDA: use highest compiled arch in
  get_mmvq_mmid_max_batch", #31005 "ggml-cuda: sanitize post-bias NaNs in MoE selection", #31787
  "CUDA: fix Maxwell build", #30541. Server: #30137, #31632, #31714. `-hf`: #31620, #31639, #31730
  "common : restrict HF token to huggingface.co hosts". Gemma 4: #31635. No gpt-oss commit. b12169
  is two commits past b12167: #31757 (BoringSSL) and "ci : bump CUDA 13 release builds to 13.5
  (#31788)" (merged 2026-11-06T08:52:48Z), which moves the cuda13 Docker build's `"cuda_version"`
  from "13.4.1" to "13.5.0" (amd64 and arm64): "13.5 rows drop GGML_CUDA_CCCL_VERSION, because CUDA
  13.5 ships CCCL 3.5.0". #31806 "docker: add explicit /usr/local/nvidia search path" (merged
  2026-11-06T17:53:05Z, after b12177): the image "only sets /usr/local/cuda/lib64 causing `no
  usable GPU found` on HF inference endpoint". (Which build or image is newest is not cached.)

### llama.cpp tracker since b12098: `-hf` tags, GB10 regressions, open CUDA and server work

- **URL:** `gh search issues` / `gh search prs --repo ggml-org/llama.cpp` ("qat", "q4_0-it", "tag
  matching", "hf tag", "quant name", "GB10", "SM121", "DGX Spark", "cuda13", "CUDA 13.5");
  <https://github.com/ggml-org/llama.cpp/pull/31533>, `/pull/31802`, `/pull/30970`, `/pull/30683`,
  `/issues/31077`
- **Read:** 2026-11-06T18:52Z to 18:53Z (gb10-1's second survey)
- **Concerns:** gb10-1: the register's QAT entry; regressions a move past b12098 would cross;
  concurrent-session throughput.
- **Tier:** primary for the absence and the states; authors' claims leads (CONTRIBUTOR).
- **Said:** no issue or pull request after #31639 restores `_` before an `-hf` tag or reports
  Google's QAT names failing. No GB10 or SM121 regression reported against b12099 or later.
  #31533 (open) "CUDA: few-row MMQ for BS 2-24", "Supported: Q8_0, Q3_K, Q4_K, Q5_K, Q6_K, IQ3_S,
  IQ4_NL and IQ4_XS on NVIDIA GPUs from Ampere up to DGX Spark"; ORippler (COLLABORATOR,
  2026-11-06T10:50Z) mentions a separate "cutlass-based, version for NVFP4/FP8". #31802 (open)
  fused q8_0/q4_0 KV dequant in the MMA flash-attention kernels. #30970 (open, 2026-11-06T16:11Z)
  "server : share prompt prefix cells between slots (--slot-attach)". #30683 (open,
  2026-11-06T17:11Z) "Avoids extra copying of existing checkpoints". #31077 (open) Gemma 4 31B with
  draft-mtp: CUDA illegal memory access, none with MTP off.

### ggml-org's DGX Spark benches

- **URL:** <https://github.com/ggml-org/llama.cpp/blob/master/benches/dgx-spark/dgx-spark.md>
  (raw: <https://raw.githubusercontent.com/ggml-org/llama.cpp/master/benches/dgx-spark/dgx-spark.md>);
  its commands in discussion <https://github.com/ggml-org/llama.cpp/discussions/16578>
- **Read:** 2026-11-06 (gb10-1 survey; the file unchanged since 3795cc1, 2026-02-05)
- **Concerns:** gb10-1: the agent section's batch, ubatch, flash attention and mmap, and the
  models the class's own benches run (discovery).
- **Tier:** attributed benchmark, by the architect's ruling of 2026-10-30; the discussion's
  commands primary (ggerganov's), its replies leads.
- **Said:** build 11fb327bf (7941), driver 580.95.05, CUDA 13.0; every row `n_ubatch = 2048`,
  `flash_attn = 1`. gpt-oss-120b batched S_TG at PP 512, B = 1/2/4/8/16/32: 57.14 / 73.27 / 98.51 /
  159.18 / 241.85 / 353.31; at PP 8192: B=1 52.23, B=4 84.71, S_PP 2346.81; llama-bench pp2048
  2443.91, tg32 58.72. gpt-oss-20b at PP 8192: 74.36, 133.82, S_PP 4405.59. Also benched:
  Qwen3-Coder-30B-A3B Q8_0, Qwen2.5-Coder-7B Q8_0, gemma-3-4b-it-qat, GLM-4.7-Flash. No
  2048-against-512 comparison. Discussion #16578: `llama-bench … -fa 1 … -ub 2048 -mmp 0`; the eval
  server `-ub 2048 -b 2048 -np 8 --no-mmap`.

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
- **Read:** 2026-11-06T18:26Z (framework survey: the title's slot count was not in the earlier
  entry)
- **Concerns:** framework: Gemma 4 26B-A4B on Vulkan with several slots, its vision section among
  them; the register's entry.
- **Tier:** primary.
- **Said:** #29221 open (updated 2026-10-28): Gemma 4 26B-A4B "crashes the server on the 2nd
  request with -np 4 on Vulkan", "-np 3 is fine", in prompt_save (`GGML_ASSERT "tensor not
  allocated"`). #25584, "ggml : fix view init skipped after buft max_size split", its fix, open and
  unmerged (updated 2026-10-31).

### #31000, #29655, #29248

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/31000>,
  <https://github.com/ggml-org/llama.cpp/issues/29655>,
  <https://github.com/ggml-org/llama.cpp/issues/29248>
- **Read:** 2026-11-06T18:26Z (framework survey)
- **Concerns:** framework and gb10-1: agent candidates' tool calls (Flint, Gemma 4, Ministral).
- **Tier:** primary.
- **Said:** #31000 open (2026-10-24): Flint NVFP4's tool-call XML remains in its reasoning, on CUDA.
  #29655 open (2026-11-03): Gemma 4's unstable tool calling. #29248 open (2026-11-03): the
  Reasoning Ministral's parser. #30105 closed 2026-10-22.

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
- **Read:** 2026-11-06 (gb10-1 survey; merged since the 2026-10-31 read)
- **Concerns:** gb10-1 and framework: set A's agent section's `kv-unified`, at its load target of
  4 sessions.
- **Tier:** primary; its table attributed, on another class.
- **Said:** "llama + CUDA: flash_attn_ext_rows (fix unified kv for multi-seq)", merged
  2026-11-02T16:13:34Z (1b6935b), in b12098 (compare 1b6935b…b12098 "ahead" by 39) and v0.9.0;
  its follow-up #31570 (ee17f293b) also in b12098. "approximately on par with the non-unified kv
  cache (`-nkvu`) for performance". RTX Pro 6000, `llama-batched-bench -fa on -c 400000 -b 2048
  -ub 2048 -npp 99936 -ntg 64 -npl 4 -kvu`, Gemma-4-26B-A4B Q8_0: S_PP 2982.14 → 8625.75, S_TG
  273.42 → 288.11; Qwen3.8-27B Q8_0: 1106.13 → 2778.22, 90.29 → 102.08.

### llama.cpp v0.9.0, and b12098 to b12124

- **URL:** <https://api.github.com/repos/ggml-org/llama.cpp/releases/tags/v0.9.0>,
  <https://api.github.com/repos/ggml-org/llama.cpp/compare/b12098...b12124>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1 and framework: the engine build.
- **Tier:** primary.
- **Said:** v0.9.0 published 2026-11-04T13:08:06Z, "Nightly build: b12110", listing #29510, #31570,
  #31391. b12098 → b12124: 26 commits, among them #31620/#31639, #31609 (bf16), #30541 (quantized
  KV state copy sizes), #31635 (Gemma4 assistant), #31296 (CUDA NVFP4 MMQ fusion). b12124 released
  2026-11-05T07:08:03Z.

### `docker.yml` and `cuda.Dockerfile` at b12098

- **URL:** <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/.github/workflows/docker.yml>,
  <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/.devops/cuda.Dockerfile>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: what of the host's CUDA stack reaches the engine.
- **Tier:** primary.
- **Said:** the cuda13 entries (amd64, arm64) set `"cuda_version": "13.4.1"`, on
  `nvidia/cuda:13.4.1-{devel,runtime}-ubuntu24.04`.

### `llama-arch.cpp` at b12098

- **URL:** <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/src/llama-arch.cpp>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1 and framework: the engine gate.
- **Tier:** primary.
- **Said:** carries gpt-oss, nemotron_h, nemotron_h_moe, afmoe, gemma4, gemma4-assistant, granite,
  granitehybrid, graniteswitch, mistral3, mistral4, phi3, llama4, lfm2moe, olmo2, muse-glimmer,
  arcee; no olmo3, no apriel.

### #30781, gpt-oss template errors on tool schemas

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/30781>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1 and framework: the gpt-oss agent's tool calls (a watch item).
- **Tier:** primary; the CONTRIBUTOR's comment a lead.
- **Said:** open, updated 2026-10-20: `{%- if param_spec['items'] -%}` raises "Function is not a
  bool value" for an array parameter without `items`; a contributor says a fix with tests exists;
  no pull request found. Workaround: a patched template through `--chat-template-file`.

### #31740, #30224, #30306, #31471, #31257, #30894/#30960

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/31740>,
  <https://github.com/ggml-org/llama.cpp/issues/30224>,
  <https://github.com/ggml-org/llama.cpp/pull/30306>,
  <https://github.com/ggml-org/llama.cpp/pull/31471>,
  <https://github.com/ggml-org/llama.cpp/pull/31257>,
  <https://github.com/ggml-org/llama.cpp/issues/30894>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: the engine gate for candidates, and unified-KV sections.
- **Tier:** primary.
- **Said:** #31740 (open, WIP) throttles unified-KV work at free-cell watermarks, no figures.
  #30224 (open, updated 2026-10-09): Mistral Small 4's CUDA expert down-projections fall back to
  the CPU. #30306 (open): Nemotron-Labs Dory support. #31471 merged 2026-11-03: Nemotron 3.5
  Transcribe in mtmd (`nemotron-transcribe.cpp` at b12098; llama-server needs `--reasoning off`).
  #31257 merged 2026-10-27: LFM3-Audio-2B and LFM3-Omni-2B. #30894 closed 2026-10-22, its fix #30960
  ("use Tekken pre-tokenizer for pixtral") merged 2026-10-22, for Nemotron 3/3.5 GGUFs.

### `common.h`, `arg.cpp`, `server.cpp` and the server README at b11960, the defaults

- **URL:** <https://raw.githubusercontent.com/ggml-org/llama.cpp/b11960/common/common.h>,
  <https://raw.githubusercontent.com/ggml-org/llama.cpp/b11960/common/arg.cpp>,
  <https://raw.githubusercontent.com/ggml-org/llama.cpp/b11960/tools/server/server.cpp>,
  <https://raw.githubusercontent.com/ggml-org/llama.cpp/b11960/tools/server/README.md>
- **Read:** 2026-11-06T18:22Z
- **Concerns:** framework, which runs and is held at b11960: every section's unset keys.
- **Tier:** primary (the build's own defaults).
- **Said:** `n_batch = 2048`, `n_ubatch = 512`, `flash_attn_type` AUTO, `cache_type_k`/`_v` F16, `kv_unified = false`, the server's `n_parallel = -1; // auto by default` (common.h 1), `cache_ram_mib = 8192`, `cache_idle_slots = true`, `n_ctx_checkpoints = 32`, `checkpoint_min_step = 8192`, `swa_full = false`, `models_max = 4`, `load_mode` AUTO ("auto: mmap, unless a device does not support it"; modes none, mmap, mlock, mmap+mlock, dio), `lazy_mode` auto (on for tensors over 4 GiB), `cont_batching = true`, `n_cache_reuse = 0`. `server_prepare_params()`: outside the router role, `n_parallel < 0` gives 4 slots and `kv_unified = true`; an embedding server lowers `n_batch` to `n_ubatch`. README `-kvu` "(default: enabled if number of slots is auto)".

### llama.cpp releases and images, b11960 to b12177

- **URL:** <https://api.github.com/repos/ggml-org/llama.cpp/releases/tags/b11960>, `.../tags/b12098`,
  `.../tags/b12124`, `.../tags/b12169`;
  <https://github.com/ggml-org/llama.cpp/pkgs/container/llama.cpp/versions?filters%5Bversion_type%5D=tagged>
  (pages 1 to 3)
- **Read:** 2026-11-06T18:25Z
- **Concerns:** framework: the engine build and its Vulkan images.
- **Tier:** primary.
- **Said:** b11960 published 2026-10-28T12:45:39Z (8642541b2); b12098 2026-11-04T03:49:39Z (149f5641b); b12124 2026-11-05T07:08:03Z (8bed7cfb9); `releases/tags/b12169` 404. Vulkan images published: `server-vulkan-b12063`, `-b12098` (3 days before the read), `-b12110`, `-b12124`, and `-b12169`, which carries `server-vulkan`. b11960…b12098: 138 commits; b12098…b12169: 71 commits. (Which is newest is not cached.)

### #31266 and #31163, the Vulkan MoE PP fix and regression

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/31266>, <https://github.com/ggml-org/llama.cpp/issues/31163>
- **Read:** 2026-11-06T18:26Z
- **Concerns:** framework: a watch item; the gpt-oss and Gemma MoE sections' prefill on Vulkan.
- **Tier:** primary; #31266's author table a lead (ruled 2026-10-30); #31163's RX 7800 XT tables attributed on another class.
- **Said:** #31266 merged 2026-11-02T11:53:28Z (cb02250b5), after approvals by 0cc4m (marked CONTRIBUTOR) on 10-29 and 10-30. #31163 closed 2026-11-02T11:53:29Z. compare cb02250…b12098 is "ahead" by 49, so it is in b12098, not in b11960. No figure on RDNA 3.5 or Strix Halo in either thread.

### #30146 and #30280, RDNA split-K

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/30146>, <https://github.com/ggml-org/llama.cpp/pull/30280>
- **Read:** 2026-11-06T18:28Z
- **Concerns:** framework: Vulkan matmul on gfx1151.
- **Tier:** primary; #30280's tables attributed on another class (RX 9070 XT, RX 7900 XTX).
- **Said:** #30146 merged 2026-11-02T11:54:10Z (07ec7c8af), in b12098 (ahead 48). "`MUL_MAT_ID` is unaffected. RDNA4 and RDNA3 APUs pass the device gate but remain unmeasured." #30280 "RDNA3/4 Vulkan Large-Tile Split-K Optimization" merged 2026-11-05T12:11:08Z (da3416d80), in b12169 (ahead 21), not in b12098. 9070 XT Gemma 4 E4B Q4_K_M pp512 5621 → 6023 (+7.2%, `llama-bench -p 512 -n 0 -fa 1 -ngl 99`). No APU row.

### #29510's Vulkan side

- **URL:** <https://api.github.com/repos/ggml-org/llama.cpp/commits/1b6935b22>; <https://github.com/ggml-org/llama.cpp/pull/29510>
- **Read:** 2026-11-06T18:26Z
- **Concerns:** framework: set A's unified-KV section on Vulkan; the #28495 watch item.
- **Tier:** primary; am17an's comment a lead.
- **Said:** The 4-line change to `ggml-vulkan.cpp` is in `ggml_backend_vk_device_supports_op`, under `GGML_OP_FLASH_ATTN_EXT`: it returns false when `op->src[5]` (kv_rows) is set, so Vulkan declines `flash_attn_ext_rows`. Kernels exist for CUDA and Metal only. The body: used "when supported by a backend". am17an (2026-10-02): "For vulkan I can see a benefit in decode even if it has a better mask algorithm." No Vulkan port found by search.

### #28495, unified-KV PP drop with several slots

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/28495>
- **Read:** 2026-11-06T18:27Z
- **Concerns:** framework: set A's `kv-unified` (a watch item).
- **Tier:** primary (issue); every comment is NONE, so a lead, except where it names hardware, build and command (DanoPTT, R9700 HIP b10825, attributed on another class).
- **Said:** OPEN, label `stale`, updated 2026-10-27T01:14:42Z. alankila (Strix Halo, no build or method): "disabling KVU gets rid of the problem". DanoPTT: "-kvu" S_PP 885.55 / 792.90 / 644.39 at 1 / 2 / 4 sequences, against "-no-kvu" 857.79 / 847.80 / 833.20. superslor (V100): the mask-skip is never computed with `--kv-unified` in the CUDA FA gate.

### #31356, Gemma 4 graph optimizations

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/31356>
- **Read:** 2026-11-06T18:28Z
- **Concerns:** framework: the audio (E4B) and vision (26B-A4B) sections.
- **Tier:** primary; figures attributed on other classes (M4 Pro Metal and CPU, Snapdragon).
- **Said:** Merged 2026-11-03T18:30:38Z, in b12098 (6cb3e672e…b12098 is ahead by 3). "The layer trimming is support only for the unified-KV"; "none for 26B". M4 Pro Metal, Google QAT E4B Q4_0, pp512 805.91 → 1318.62; tg128 63.39 → 63.62.

### llama.cpp Vulkan, server and model commits since b11960

- **URL:** <https://api.github.com/repos/ggml-org/llama.cpp/commits?path=ggml/src/ggml-vulkan&since=2026-10-27T00:00:00Z>,
  `...?path=tools/server&since=2026-10-28T12:45:00Z`, `...?path=src/llama-kv-cache.cpp&...`, `...?path=src/models&...`
- **Read:** 2026-11-06T18:27Z
- **Concerns:** framework: what a move past b11960 brings on Vulkan.
- **Tier:** primary.
- **Said:** Vulkan in b12098: #31266, #30146, #25051, #31079, #31114, plus #30881 (the batched copy API). Vulkan in b12169 only: #30280, #30487, #31587 (AMD proprietary driver), #29772, #30769. Not in b12169: #31658 (ReBAR). Server: #31350, #30710, #30137 (b12169). KV: #31073, #31570, #31683. Gemma: #31356 (b12098).

### llama.cpp Vulkan issues since b11960

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/31557>, `/31739`, `/31402`, `/24066`, `/25664`, `/20515`
- **Read:** 2026-11-06T18:30Z
- **Concerns:** framework: regressions past b11960 on Vulkan; prompt-cache and flag practice.
- **Tier:** primary (issues); every comment cited is NONE or CONTRIBUTOR, so a lead.
- **Said:** #31557: Intel B60 Vulkan regression (pp512 1117 → 821), Intel only. #31739: "Fused top-k mask: Not supported on Vulkan (Radeon 8060S)", b12154. #31402: 780M DeviceLost since b10369. #24066: RX 6600, `RADV_PERFTEST=nogttspill` mitigates, "still present in b12020". #25664 (Strix Halo, closed stale 2026-11-05): `amdgpu.lockup_timeout` workaround; no reproduction on kernel 7.2.0 and Mesa 26.2.1. #20515 (8060S, closed): Vulkan aborts in `prompt_save` → `ggml_backend_vk_buffer_get_tensor` with ring timeouts, b11370.

### llama.cpp maintainers on Strix Halo flags (a search)

- **URL:** `gh search issues --repo ggml-org/llama.cpp` "Strix Halo", "gfx1151", "8060S" (57 issues), comments filtered by authorAssociation
- **Read:** 2026-11-06T18:30Z
- **Concerns:** framework: the configuration review.
- **Tier:** primary for the absence.
- **Said:** no MEMBER, OWNER or COLLABORATOR comment states practice for ubatch, flash attention, mmap, the KV type, the prompt cache or parallel on Strix Halo. 0cc4m's Vulkan comments are marked CONTRIBUTOR.

### #28211, ROCm wrong logits on gfx1151

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/28211>
- **Read:** 2026-11-06T18:28Z
- **Concerns:** framework: the ROCm image.
- **Tier:** primary.
- **Said:** OPEN, updated 2026-10-26T01:15:23Z: "HIP/ROCm on gfx1151, wrong logits (not a crash), triggered by prompts longer than n_ubatch". Last comment tczank, 2026-09-25: reproduces on gfx1036.

### ggml docker docs at b11960

- **URL:** <https://raw.githubusercontent.com/ggml-org/llama.cpp/b11960/docs/docker.md>
- **Read:** 2026-11-06T18:30Z
- **Concerns:** framework: the container's run flags.
- **Tier:** primary.
- **Said:** no run example for the Vulkan or ROCm images, and no device, group, ipc or shm flags.

### `llama-arch.cpp` at b11960

- **URL:** ARCH. **Read:** 2026-11-06T18:21Z. **Concerns:** framework: the engine gate. **Tier:** primary.
- **Said:** the names listed under "Common reads"; no olmo3, apriel, raon. (New; b12098's entry stays.)

### llama.cpp: LFM3, Nemotron Transcribe, Granite speech support against b11960

- **URL:** <https://github.com/ggml-org/llama.cpp/pull/31252>, `/31257`, `/31386`, `/31471`, `/30628`; `https://api.github.com/repos/ggml-org/llama.cpp/compare/<merge sha>...b11960`; <https://raw.githubusercontent.com/ggml-org/llama.cpp/b11960/src/llama-arch.cpp>; <https://api.github.com/repos/ggml-org/llama.cpp/contents/tools/mtmd/models?ref=b11960>; issues #29780, #24138, #29446
- **Read:** 2026-11-06T18:24-18:36Z
- **Concerns:** framework (b11960): the engine gate for vision and audio candidates.
- **Tier:** primary.
- **Said:** #31252 (19cce69) ahead 22 and #31257 (19ff817) ahead 19: in b11960. #31386 (889f2ec, merged 2026-10-30) behind 53 and #31471 (28b812d, merged 2026-11-03) behind 127: not in b11960. #30628 (e287bd8) ahead 287: in. llama-arch at b11960 has lfm3, gemma4, gemma-embedding2, modern-bert, nomic-bert(-moe), granite, muse-glimmer, mistral3, llama4; no nemotron transcribe. tools/mtmd/models at b11960 has lfm3a, lfm3a-gen, lfm3vl, gemma4a/ua/uv/v, granite-speech, granite4-vision, muse-glimmer, nemotron-omni, pixtral, parakeet, voxtral-rt, whisper-enc; no nemotron-transcribe. #29780 OPEN (updated 2026-11-01); #24138 CLOSED (2026-07-24); #29446 OPEN (2026-10-16).

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

### NVIDIA DGX Spark playbooks

- **URL:** <https://github.com/NVIDIA/dgx-spark-playbooks> (READMEs under `nvidia/<name>/`; commits
  <https://api.github.com/repos/NVIDIA/dgx-spark-playbooks/commits>)
- **Read:** 2026-11-06 (gb10-1 survey; newest commit 3088315, 2026-10-23)
- **Concerns:** gb10-1: the engine's run flags, the engine choice, and discovery.
- **Tier:** primary for what NVIDIA states.
- **Said:** llama-cpp: built from source (`CMAKE_CUDA_ARCHITECTURES=121a-real`),
  `-hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, "For agentic or coding needs you need a minimum
  of 32768 tokens, preferably 100000 or more"; no -ub, -fa, -kvu or -np. vllm:
  `nvcr.io/nvidia/vllm`, `docker run --gpus all`, the "agent-ready" `nvidia/Qwen3.6-35B-A3B-NVFP4`
  with `--max-num-seqs 4 --max-model-len 262144 --gpu-memory-utilization 0.4`; gpt-oss-120b MXFP4
  listed supported. sglang: `lmsysorg/sglang:latest-cu130`, `--mem-fraction-static 0.75`. trt-llm:
  `release:1.3.0rc13`, `--ipc host --ulimit memlock=-1 --ulimit stack=67108864`. multi-agent-chatbot:
  gpt-oss-120B supervisor, gpt-oss-20B the smaller. nemotron: Nemotron 3 Super NVFP4. No figures.

### DGX Spark Porting Guide, optimization

- **URL:** <https://docs.nvidia.com/dgx/dgx-spark-porting-guide/latest/optimization.html>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: the memory ceiling; the display-memory watch item.
- **Tier:** primary.
- **Said:** "UEFI reserves part of system memory for the display. This memory is not available to
  the OS, CUDA, or applications"; default 2 GB; `Auto` or 0.5 GB frees up to 1.5 GB; configurable
  "Starting with OTA2610"; `cudaMemGetInfo` "may be smaller than the actual allocatable memory".

### vLLM releases and its GB10 tracker items

- **URL:** <https://api.github.com/repos/vllm-project/vllm/releases>,
  <https://github.com/vllm-project/vllm/issues/58624>,
  <https://github.com/vllm-project/vllm/issues/50925>,
  <https://github.com/vllm-project/vllm/issues/60847>,
  <https://github.com/vllm-project/vllm/pull/60942>
- **Read:** 2026-11-06T18:53Z (gb10-1's second survey: #58624 and #58989 updated upstream
  2026-11-06T14:24Z and 14:31Z, after the first read); also
  <https://github.com/vllm-project/vllm/pull/58989> and
  <https://api.github.com/repos/vllm-project/vllm/compare/v0.33.0rc3...fe77d0906be0c38c5e2c575cd61b545a2fa687e4>
- **Concerns:** gb10-1: the engine choice; the vLLM NVFP4 and EmbeddingGemma watch items.
- **Tier:** primary; #58624's and #58989's GB10 tables attributed on another model (FP8); #50925
  a lead.
- **Said:** v0.33.0rc3 (2026-11-02, not marked prerelease): "release wheels and images are CUDA
  13.0 only (#62575)". v0.32.0: "OAI Triton MXFP4 MoE on SM12x (#58877)". #58624 (open): MoE decode
  ~15% slower on SM12x since #56876; GB10, Qwen3.6-35B-A3B-FP8, decode step 56.6 → 50.2 ms with a
  patch. #50925 (lead): published builds route NVFP4 MoE to Marlin on sm_121. #60847 closed
  2026-10-27 by #60942 (EmbeddingGemma's Triton prefill OutOfResources), validated on an RTX 5090,
  not in v0.33.0rc3: #60942 merged 2026-10-27T02:00:15Z (fe77d09), and the compare
  v0.33.0rc3…fe77d09 reads "diverged", ahead by 33, behind by 12, merge base 4135590. #58989
  "[Perf][MoE] Prefer Triton for block FP8 MoE on SM120" (open): hclsys on GB10, nightly
  `0.32.1rc1.dev485+gceb01b6dd`, Qwen3-30B-A3B-Instruct-2507-FP8, TP1, 1024 in / 128 out, DeepGEMM
  against Triton: bs1 "2.80 s | 2.41 s | -14%", bs32 "26.70 s | 19.79 s | -26%", throughput "3680
  tok/s | 4040 tok/s | +10%"; "`is_device_capability(120)` only matches 12.0, so GB10 would stay on
  DeepGEMM with this PR."

### vLLM recipes, GPT-OSS

- **URL:** <https://raw.githubusercontent.com/vllm-project/recipes/main/OpenAI/GPT-OSS.md>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: vLLM's fit at the agent target.
- **Tier:** primary.
- **Said:** `--max-num-batched-tokens` "We recommend setting [it] to `8192`"; `--max-num-seqs` at
  the expected concurrency; its H100 eval `--max-model-len 131072 --gpu-memory-utilization 0.85`;
  tool calling with `--tool-call-parser openai --enable-auto-tool-choice`. No GB10.

### SGLang and TensorRT-LLM releases

- **URL:** <https://api.github.com/repos/sgl-project/sglang/releases>,
  <https://api.github.com/repos/NVIDIA/TensorRT-LLM/releases>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: the seed list.
- **Tier:** primary.
- **Said:** SGLang v0.5.23 (2026-11-02), no SM121 line. TensorRT-LLM v1.4.0rc2 (2026-10-28,
  prerelease); v1.4.0rc0's known issues: "GPT-OSS models on SM120 GPUs may fail with attention data
  parallelism".

### NVIDIA forum threads on GB10 engines and models

- **URL:** topics 379766, 379832, 379921, 364890, 370070, 365138, 383406 (DGPP), 367580 under
  <https://forums.developer.nvidia.com/c/accelerated-computing/dgx-spark-gb10/>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: the engine choice, the scan, and candidates' speed.
- **Tier:** lead (user posts; none names build, hardware and command together).
- **Said:** 379766: gpt-oss-120b on vLLM 0.26.1rc1 60.7 tok/s (1x), "116–153" (8x), "±30%
  between runs". 379832: Lightning NVFP4 on vLLM 0.27.1 ~78.5 tok/s. 379921: Lightning NVFP4,
  16 concurrent, 192.96 tok/s. 364890: Nemotron 3 Super Q4_K_M "19 tok/s". 370070: Super NVFP4
  "23.45 tok/s". 365138: Nemotron 3 Nano Q4_K_XL tg 14.7 at ~8K (build 8399). 383406: DGPP, a GB10
  C++/CUDA engine built from source.

### DGPP's repository and releases

- **URL:** <https://github.com/HawkBearPig/dgpp>, its releases
- **Read:** 2026-11-06T18:53Z (gb10-1's second survey)
- **Concerns:** gb10-1: the seed list's DGPP.
- **Tier:** a lead (no measurement against another engine; the repository is primary only for
  what DGPP ships).
- **Said:** latest release "DGPP 0.1.0" (v0.1.0, 2026-10-28T21:21:19Z); last pushed
  2026-11-06T18:16:28Z. Installed from source (`./scripts/setup.sh`, CUDA 13) or a release
  `dgpp-*.tar.zst`; Docker only for an x86 cross-build; no container image. Its model list: GLM,
  Qwen3.x, DeepSeek-V4.x, MiniMax, MiMo, Flint and Dory (NVFP4, FP8, MXFP4); no gpt-oss, GGUF or
  embedding model.

### Gemma 4 vision speed on a DGX Spark

- **URL:** <https://github.com/nabe2030/dense-27b-31b-dgx-spark>,
  <https://dev.classmethod.jp/en/articles/dgx-spark-gemma4-benchmark/>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: the vision candidates' speed.
- **Tier:** nabe2030 attributed (hardware, build b8922, command; driver unnamed); Classmethod a
  lead (output length unstated).
- **Said:** Gemma 4 31B Q4_K_M tg128 10.65, pp512 746.31 tok/s on b8922. Classmethod, Ollama
  0.20.0: average caption E4B BF16 6.8 s, E2B BF16 5.0 s, 26B Q4_K_M 4.0 s, 31B BF16 36.7 s.

### The Gemma 4 tokenizer fixes and ggml-org's reconversions

- **URL:** <https://huggingface.co/api/models/google/gemma-4-E4B-it/commits/main>, <https://huggingface.co/api/models/ggml-org/gemma-4-E4B-it-GGUF>, <https://huggingface.co/api/models/ggml-org/gemma-4-E2B-it-GGUF>, plus the entry's `.src_sha` URLs (not re-read)
- **Read:** 2026-11-06T18:53Z (gb10-1's second survey re-read the E4B GGUF record, its `.src_sha`
  at <https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/raw/main/.src_sha>, its discussions, and
  google's E4B commits; the other reads stay at 18:21Z)
- **Concerns:** gb10-1 and framework: the audio incumbent's file; E2B and 12B candidates.
- **Tier:** primary.
- **Said:** google/gemma-4-E4B-it newest 4ecc2ba6… 2026-11-03T16:13:15Z "Remediate 219 glitch tokens", "No model weights are modified"; ggml-org E4B GGUF sha a69f018d…, lastModified 2026-10-19T10:58:26Z, `.src_sha` `PRIMARY=ee0ef6023621cff504d758262d4e04895a5af4a2` (2026-07-20, the commit before the fix),
  `ASSISTANT=8d0031ea…`, `QAT_Q4_0=27f8d204…`, no discussions and no llama.cpp issue on the fix; google
  `gemma-4-E4B-it-qat-q4_0-gguf` newest commit still 4b4a2c1d… (2026-07-17T21:23:49Z); ggml-org E2B GGUF sha 6938c58e…, lastModified 2026-10-19T10:58:13Z; google E2B-it/E2B/E4B fixed 2026-11-03, 12B 2026-10-30; ggml-org 12B `.src_sha` equals Google's current sha (BF16, Q8_0 reconverted 2026-11-01).

### Model cards, records and files for gb10-1's candidates

- **URL:** each candidate's card, API record, tree listing, `.src_sha` and config on
  <https://huggingface.co/>, as linked in the gb10-1 report of 2026-11-06, "Models"
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: every candidate step 8 gated.
- **Tier:** primary.
- **Said:** gpt-oss-20b MXFP4 11.28 GiB, no BFCL; Nemotron 3.5 Lightning Q8_0 31.28 GiB, no BFCL,
  NVFP4 outside 1% (HLE 11.72 → 10.47); Nemotron 3 Nano "BFCL v4 53.8" (no category); Trinity
  Mini Q8_0, no BFCL in text; LFM2.5-24B "BFCLv4 65.01" (no category); Granite 4.2 "BFCL (v4)"
  52.39/52.41/61.39 (no category); Apriel 1.6 "BFCL v3 only 63.50"; Bolt E4B "BFCL-v3 68.51";
  Super VL Q8_0 119.65 GiB, NVFP4 outside 1% (DeepSWE 24.65 → 18.2); Bolt 74B IQ2-XXS by QAD;
  Mistral Small 4 bartowski Q5_K_M 79.2 GiB; Gemma 4 QAT card: 26B-A4B MMMU Pro 73.8%, 31B 76.9%,
  12B 69.1%; LFM3-Omni-2B English ASR WER 6.36 against E4B 7.82, OCRBench 806; Nemotron 3.5
  Transcribe Open ASR English WER 4.71%; EmbeddingGemma 2 MTEB (eng, v2) 68.46; granite r2
  MTEB-v2 (41 tasks) 62.8. The figures as each row of the report quotes them.

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

### vLLM v0.33.0rc3: ROCm doc, Dockerfile, images, gfx1151 PRs, #21182

- **URL:** <https://api.github.com/repos/vllm-project/vllm/releases>,
  <https://raw.githubusercontent.com/vllm-project/vllm/v0.33.0rc3/docs/getting_started/installation/gpu.rocm.inc.md>,
  <https://raw.githubusercontent.com/vllm-project/vllm/v0.33.0rc3/docker/Dockerfile.rocm_base>,
  <https://hub.docker.com/v2/repositories/vllm/vllm-openai-rocm/tags>, <https://github.com/vllm-project/vllm/issues/21182>
- **Read:** 2026-11-06T18:29Z
- **Concerns:** framework: the seed list and the vLLM watch item.
- **Tier:** primary.
- **Said:** v0.33.0rc3 published 2026-11-02T10:10:05Z, not prerelease; ROCm 10.0 is the default image, with `-rocm72`. No gfx1151 line in its notes. The doc lists "Ryzen AI MAX / AI 300 Series (gfx1151/1150)", "requires ROCm 7.0.2 or above". `PYTORCH_ROCM_ARCH` includes gfx1150 and gfx1151. Images `v0.33.0`, `-rocm100`, `-rocm72` (2026-11-02). #60413 and #60644 are in v0.33.0rc3; #63735 isn't; #65322 (11-03) is in nightlies only. #21182 OPEN, updated 2026-09-27.
- Replaces the 2026-10-30 report's vLLM ROCm reads for framework. It doesn't replace the entry
  "vLLM releases and its GB10 tracker items", which concerns gb10-1; add framework's reads beside it.

### SGLang v0.5.23 and rocm/sgl-dev gfx1151

- **URL:** <https://api.github.com/repos/sgl-project/sglang/releases>, <https://hub.docker.com/v2/repositories/rocm/sgl-dev/tags?name=gfx1151>
- **Read:** 2026-11-06T18:29Z
- **Concerns:** framework: the seed list.
- **Tier:** primary.
- **Said:** v0.5.23 (2026-11-02T22:14:10Z), images for MI35x and MI30x only; daily `v0.5.23-rocm724-gfx1151-<date>`, newest 20261106; 55 gfx1151 tags.
- Extends "SGLang and TensorRT-LLM releases" (gb10-1) with the gfx1151 images.

### ggml-hrx builds and images

- **URL:** <https://api.github.com/repos/ROCm/ggml-staging-automation/releases>,
  <https://github.com/orgs/ROCm/packages?q=hrx>, <https://hub.docker.com/v2/search/repositories/?query=hrx>,
  <https://github.com/ggml-org/llama.cpp/pull/27218>, <https://github.com/ggml-org/llama.cpp/discussions/27219>
- **Read:** 2026-11-06T18:30Z
- **Concerns:** framework: the ggml-hrx watch item.
- **Tier:** primary; discussion replies leads.
- **Said:** hrx-b131 (2026-10-31), a manylinux tarball, "passed on Radeon 8050S (`gfx1151`)", "not a stable distribution channel". No ROCm package and no Docker Hub image. #27218 an OPEN draft, updated 2026-10-08. #27219 since 10-29: no HRX-against-Vulkan figure on gfx1151.

### Lemonade and Ollama pins

- **URL:** <https://raw.githubusercontent.com/lemonade-sdk/lemonade/v2026.45.3/src/cpp/resources/backend_versions.json>,
  the same at `candidate-v2026.46.1`, <https://api.github.com/repos/lemonade-sdk/lemonade/releases/tags/candidate-v2026.46.1>,
  <https://raw.githubusercontent.com/ollama/ollama/v0.40.15/LLAMA_CPP_VERSION>
- **Read:** 2026-11-06T18:30Z
- **Concerns:** framework: packagers; the scan.
- **Tier:** primary.
- **Said:** Lemonade v2026.45.3: vulkan b11846, rocm-stable b11836, rocm-nightly b1353, hrx-b99. The candidate adds container backends for gfx1151: `llamacpp.nathanw` "vulkan-radv-performance@sha256:41018261…", `llamacpp.halobox` "rocm-10.0-strix-llama@…", `rocmfpx`, `halogen` "0.18.22@…", `gufo`, `ds4`. Ollama v0.40.15 pins "b12111".

### kyuz0 toolboxes (llama.cpp and vLLM)

- **URL:** <https://github.com/kyuz0/amd-strix-halo-toolboxes>, <https://github.com/kyuz0/amd-strix-halo-vllm-toolboxes>
- **Read:** 2026-11-06T18:30Z
- **Concerns:** framework: the configuration review.
- **Tier:** lead (advice and unnamed builds).
- **Said:** "Always use flash attention (`-fa 1`) and resident loading (`--load-mode none`) on Strix Halo". Vulkan: `--device /dev/dri --group-add video --security-opt seccomp=unconfined`. ROCm adds `/dev/kfd` and `render`. Results "legacy and are no longer updated". vLLM image `kyuz0/vllm-therock-gfx1151` on ROCm 10.0: "Performance benchmarks have not yet been run for this Ubuntu image."

### Strix Halo leads: Talus, visorcraft, hipEngine

- **URL:** <https://forum.level1techs.com/t/strix-halo-tuned-rust-engine/259719>,
  <https://github.com/visorcraft/strix-halo-llm-perf>,
  <https://community.frame.work/t/hipengine-fast-native-qwen-3-6-inference-for-rdna3-including-strix-halo/82803>
- **Read:** 2026-11-06T18:31Z
- **Concerns:** framework: the scan; configuration practice.
- **Tier:** lead (none names its build, driver and command together).
- **Said:** Talus (2026-10-28): a HIP Rust fork of Strata. visorcraft: "unified KV flags, no-mmap, and batch-size tuning produced negligible gains", no figures. hipEngine (2026-05-29): HIP only.

### Strix Halo community benches (discovery)

- **URL:** <https://forum.level1techs.com/t/strix-halo-llm-inference-notes/249466>, <https://forum.level1techs.com/t/strix-halo-ryzen-ai-max-395-llm-benchmark-results/233796>, <https://community.frame.work/t/ryzen-ai-max-not-so-much/77999>, <https://github.com/visorcraft/strix-halo-llm-perf>, <https://slb350.github.io/strix-benchmarks/>, <https://raw.githubusercontent.com/kyuz0/amd-strix-halo-toolboxes/main/README.md>
- **Read:** 2026-11-06T18:23Z-18:35Z
- **Concerns:** framework: agent discovery and speed leads.
- **Tier:** lead each (SLB a tier question, default lead; Djip's FW-77999 ROCm post attributed on ROCm).
- **Said:** gpt-oss-120b Vulkan tg128 36.46 (apkallu), 54.84 (vdtdg); ROCm tg16 51.81 (Djip, b7123,
  ROCm 6.4.4); gpt-oss-20b Vulkan tg128 50.86 / 77.31; Scout tg128 19.88 / 19.3; Hermes 4 70B 5.26;
  Nemotron 3 Nano MXFP4 server tg 61.5 (VISOR); SLB: Nano Omni tg128 61.1, Mistral Small 4
  UD-Q4_K_XL 40.3 (b9518), Mistral Medium 3.5 2.90, Muse Glimmer Q8_K_XL 7.25 (13.53 DFlash),
  Granite 4.1 30B/8B/3B 11.8/38.6/88.7, Puzzle 75B ROCm 22.66 / RADV 2.69 (port build 10023); SLB
  names Mesa RADV 25.2.3, kernel 6.17.0-29. KYUZ0's README: "legacy and are no longer updated".

### Hermes 4 Technical Report (arXiv 2508.18255v2)

- **Read:** 2026-11-06T18:32Z. **Tier:** primary. **URL:** <https://arxiv.org/pdf/2508.18255v2>. **Concerns:** framework: Hermes 4 (discovery). **Said:** "We can then synthesize a reasoning trace and answer from Deepseek-R1 [15] or Deepseek-R10528 [1]"; on the overlong data, "This answer is generated from the SFT stage-1 model rather than a teacher model"; "For the 14B model, we began with the Qwen3 14B checkpoint". The 70B's base is `meta-llama/Meta-Llama-3.1-70B`.

### allenai/dolci-thinking-sft dataset card

- **URL:** https://huggingface.co/datasets/allenai/dolci-thinking-sft/raw/main/README.md
- **Read:** 2026-11-06T18:41Z. **Tier:** primary. **Said:** "new traces generated by a mix of DeepSeek R1
  and DeepSeek R1 0528" for WildChat 83,054, Aya 98,597 and others; generators of OpenThoughts 3,
  SYNTHETIC-2, the Nemotron code split and new Dolci Think data not named; no QwQ-32B mention.

### Cards, records and trees for framework's agent candidates

- **URL:** each as cited inline in framework's report of 2026-11-06, "Models", "Agent" (Flint, Trinity Nano, Nano Omni, Mistral Small 4 config and siblings,
  granite-switch 8B/30B, granite-4.1-30b tree, Muse Glimmer GGUF, LFM3-1.7B, Mistral Medium 3.5,
  Laguna S 2.1, Puzzle 75B, Ornith, Agents-A1, gpt-oss-safeguard), 2026-11-06T18:26Z-18:40Z, primary.

### `google/gemma-4-E4B-it-qat-q4_0-gguf` commits and record

- **URL:** <https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf/commits/main>, <https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf>
- **Read:** 2026-11-06T18:20Z
- **Concerns:** framework: the E4B QAT watch item.
- **Tier:** primary.
- **Said:** newest commit 4b4a2c1d… 2026-07-17T21:23:49Z "Upload validated QAT GGUF checkpoint (280 sequence length, corrected vocabulary)"; sha 4b4a2c1d…, lastModified 2026-07-17T21:23:49Z.

### Google's Gemma 4 QAT GGUF records

- **URL:** <https://huggingface.co/api/models/google/gemma-4-26B-A4B-it-qat-q4_0-gguf>, `…/gemma-4-31B-it-qat-q4_0-gguf`, `…/gemma-4-12B-it-qat-q4_0-gguf`, <https://huggingface.co/api/models/google/gemma-4-E2B-it-qat-q4_0-gguf/tree/main?expand=true>
- **Read:** 2026-11-06T18:34Z
- **Concerns:** framework: vision incumbent's revision; 31B, 12B, E2B QAT candidates.
- **Tier:** primary.
- **Said:** 26B d1c082be… 2026-07-17T21:25:44Z; 31B 59dde245… 21:26:48Z; 12B 29d09777… 21:24:41Z. E2B QAT: `gemma-4-E2B_q4_0-it.gguf` 3,349,516,256 B "Safe GGUF model" + PAIT-GGUF-100; `gemma-4-E2B-it-mmproj.gguf` 986,833,664 B "Safe GGUF model"; both 2026-07-17 "Upload validated QAT GGUF checkpoint (280 sequence length, corrected vocabulary)".

### LiquidAI LFM3 cards, GGUF trees, and config

- **URL:** <https://huggingface.co/LiquidAI/LFM3-Audio-2B/raw/main/README.md>, <https://huggingface.co/LiquidAI/LFM3-VL-2B/raw/main/README.md>, their API records, the trees of `LiquidAI/LFM3-Audio-2B-GGUF`, `LFM3-Omni-2B-GGUF`, `LFM3-VL-2B-GGUF` (`?expand=true`), <https://huggingface.co/LiquidAI/LFM3-Omni-2B/raw/main/config.json>
- **Read:** 2026-11-06T18:27-18:32Z
- **Concerns:** framework: vision and audio candidates.
- **Tier:** primary (the VL card's Strix Halo chart is a lead: image only, no build).
- **Said:** Audio record 2026-11-03T07:40:58Z, no base_model; "in-house audio encoder and LiquidCodec audio tokenizer"; English ASR WER 6.23 (E4B 7.82), multilingual 6.03 (6.54), MMAR 50.60 (49.10), tool calling 58.50 (72.40). VL record 2026-11-03T21:29:55Z, base LFM3-1.7B-Base, "in-house vision encoder"; MOPD distils "the vision RL model and the Mixed RL model from LFM3-1.7B"; recommends b11960+; MMMU-Pro 45.7, OCRBench v1 86.3, ChartQA 92.7, DocVQA 96.7; Strix Halo prefill/decode in a chart, Q4_0 + F16 mmproj, 512x512 image, 1,024 in, 256 out. Trees: every GGUF "Safe GGUF model", weights PAIT-GGUF-100; F16 mmprojs of 2026-10-27 (Audio 570,846,400 B, Omni 949,841,248 B, VL 378,996,032 B); Audio/Omni BF16/Q8_0/Q4 mmprojs re-made 2026-10-29 "Quantize the codec decoder"; VL adds an NVFP4 GGUF 2026-11-03 (card: b12088). Omni config: 24 layers (13 conv, 6 full attention, 5 sliding at 256), 4 KV heads, head dim 128.

### LiquidAI d1-2B and d1-Omni-2B

- **URL:** <https://huggingface.co/LiquidAI/d1-2B/raw/main/README.md>, <https://huggingface.co/LiquidAI/d1-Omni-2B/raw/main/README.md>, <https://huggingface.co/LiquidAI/d1-2B-GGUF/raw/main/README.md>
- **Read:** 2026-11-06T18:31-18:38Z
- **Concerns:** framework and gb10-1: vision and audio discovery.
- **Tier:** primary.
- **Said:** "a decision model … returns calibrated answers in one forward pass, without generating tokens"; built on LFM3-VL-2B / LFM3-Omni-2B; lfm1.0; no teacher or generator named; llama.cpp from b11960 on `/v1/systemone`, `-b 8192 -ub 8192`, Q8_0.

### IBM Granite Speech 5.0 2B card, GGUF tree and config; 4.1 2B plus GGUF tree

- **URL:** <https://huggingface.co/ibm-granite/granite-speech-5.0-2b/raw/main/README.md>, its `config.json`, <https://huggingface.co/ibm-granite/granite-speech-5.0-2b-GGUF/raw/main/README.md>, the trees of `granite-speech-5.0-2b-GGUF` and `granite-speech-4.1-2b-plus-GGUF`
- **Read:** 2026-11-06T18:31-18:39Z
- **Concerns:** framework and gb10-1: audio candidates.
- **Tier:** primary.
- **Said:** base an intermediate granite-4.0-1b-base; CTC conformer encoder; translations "with Granite-3 and Phi-4", "Phi-4 and MADLAD"; Kokoro-82M TTS; WER only in charts; recommends Q8_0; ignores unfamiliar prompts. Config: granite, 40 layers, 4 KV heads, hidden 2048 / 16 heads, 16,384 positions. GGUF card: build b9768. 5.0 Q8_0 1,956,155,104 B (2026-10-15T20:04Z), mmproj F16 1,159,354,752 B (2026-10-15T19:18Z), "Safe GGUF model". 4.1 plus Q8_0 1,737,793,312 B and mmproj F16 1,167,743,488 B re-uploaded 2026-11-03 with `.sig` files, "Safe GGUF model".

### Model records: Muse-Glimmer-30B, Granite Vision 4.1, mrutkows granite r2 GGUF

- **URL:** <https://huggingface.co/api/models/meta-models/Muse-Glimmer-30B>, <https://huggingface.co/api/models/ibm-granite/granite-vision-4.1-4b>, `…/granite-vision-4.1-4b-GGUF`, <https://huggingface.co/api/models/mrutkows/granite-embedding-english-r2-GGUF>
- **Read:** 2026-11-06T18:33-18:35Z
- **Concerns:** framework: whether cited chains' subjects moved.
- **Tier:** primary.
- **Said:** Muse-Glimmer lastModified 2026-10-22T02:06:52Z, apache-2.0; Granite Vision 2026-07-13 (GGUF 2026-06-24); mrutkows sha f9cb7cf5…, 2026-04-08T20:42:12Z, files bf16 and Q8_0.

### Nemotron 3.5 Transcribe repositories on the Hub

- **URL:** <https://huggingface.co/api/models?search=Nemotron-3.5-Transcribe&limit=40>
- **Read:** 2026-11-06T18:31Z
- **Concerns:** framework and gb10-1: the Transcribe candidate's files.
- **Tier:** primary (a listing).
- **Said:** 34 repositories; NVIDIA's BF16, FP8, NVFP4, DFlash2; GGUFs only from third parties (AtomicChat, maternion IQ, Jmica, prithivMLmods, sakasegawa, AMAImedia BF16).

### Strix Halo discovery for vision, ASR and embedding

- **URL:** <https://local-llm-benchmarks.dev/>, <https://local-llm-benchmarks.dev/data/results.json> (first 100,000 of 7,953,781 characters), <https://github.com/visorcraft/strix-halo-llm-perf>, <https://whylucian.github.io/softab/docker/whisper-cpp/BENCHMARKS.html>
- **Read:** 2026-11-06T18:38-18:40Z
- **Concerns:** framework: discovery (step 8).
- **Tier:** local-llm-benchmarks.dev attributed per run (no vision/ASR/embedding run found; vision suite "Upcoming"); visorcraft text-only; whylucian a lead (whisper base.en, one 11 s clip, no whisper.cpp version or Mesa, updated 2026-02-02).
- **Said:** whisper.cpp base.en on gfx1151: Vulkan RADV 547 ms (20.1x), ROCm 7.2 447 ms (24.6x).

## Model cards and origin chains

One entry per model a survey judged: its repository, the card's `lastModified`, the publisher, the
base chain, the teachers and their roles, the card's reads the gates take, and the origin chain's
verdict inputs ([survey.md](../.claude/skills/hosting-upgrades/survey.md), "Research cache",
"Model entries").

Written by framework's survey of 2026-11-06 ([report](reports/framework/2026-11-06.md), "Models"). "(c)" and a bracketed record mark an input cited from an earlier record rather than re-read: [gb10-1 rpt] is `reports/gb10-1/2026-11-06.md`, [screen 11-04] `screens/framework/2026-11-04.md`, [fw 10-30] `reports/framework/2026-10-30-2.md`, [vf] `findings/verify-framework.md`. Each read time is the report's, 2026-11-06T18:20Z to 18:41Z, unless an entry gives its own.

- **ggml-org/gpt-oss-120b-GGUF** (openai/gpt-oss-120b, 2025-08-26). OpenAI (verified). Base: none.
  Teachers: none named. Gates: native MXFP4; no BFCL; 131,072. Inputs: `.src_sha` = openai sha (c);
  eagle3 level 5 (c); CSL no match. Pass.
- **ggml-org/gpt-oss-20b-GGUF** (openai/gpt-oss-20b, 2025-08-26). OpenAI. Base none; no teacher.
  Native MXFP4, 11.28 GiB, no BFCL. `.src_sha` = openai (c). Pass.
- **ggml-org/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF** (NVIDIA BF16 record ≤2026-10-29). NVIDIA.
  Base: NVIDIA's own. Teachers/generators: GLM-5, MiniMax-M2, DeepSeek-V3/V3.2, Kimi-K2, Qwen3
  (covered by the NVIDIA ruling) (c). Q8_0 path 3; NVFP4 outside 1%; no BFCL. `.src_sha` = NVIDIA (c).
  Pass by policy, 2026-11-06.
- **ggml-org/Flint-GGUF** (RecursiveSI/flint, 2026-10-21T14:24Z). Recursive Superintelligence, Inc.,
  Delaware (c). Base: none ("trained from scratch"). Teachers: none named; SFT generators unstated.
  MoE 39.8B / ~2.5B active, 262,144; Q8_0 path 3; no BFCL; TB 2.1 54.9, SWE-V 74.2. Inputs:
  `.src_sha` = publisher (c); level 6 GLM-style tags (c); CSL no match. Pass.
- **arcee-ai/Trinity-Mini-GGUF** (2026-05-28). Arcee AI, Delaware (c). Base Arcee's own; no teacher.
  Q8_0 path 3; no BFCL in text. Pass.
- **arcee-ai/Trinity-Nano-Preview-GGUF** (2026-05-28). Arcee AI. Base `arcee-ai/Trinity-Nano-Base`
  (record not read); no teacher; data with Datology. 6B-A1B afmoe, 128k; no BFCL. Inputs: CSL no
  match (Arcee, Datology). Reaches the bar on the card's word; base record unread.
- **ggml-org/NVIDIA-Nemotron-3-Nano-30B-A3B-GGUF**. NVIDIA. "Improved using Qwen." (covered) (c). Q8_0;
  "BFCL v4 53.8" uncategorized. Pass by policy.
- **ggml-org/NVIDIA-Nemotron-3-Nano-Omni-30B-A3B-GGUF** (NVIDIA BF16 2026-08-24). NVIDIA. Base
  Nemotron 3 Nano 30B-A3B. Teachers: none read (covered by the ruling). Q8_0 31.28 GiB; no BFCL;
  OSWorld 47.4. `.src_sha` `e5e99324…` = NVIDIA sha. Pass by policy.
- **bartowski/mistralai_Mistral-Small-4-119B-2603-GGUF** (mistralai record 2026-07-15). Mistral AI.
  Base Mistral's own. No teacher named (c). Q5_K_M 79.2 GiB, 3 shards magic GGUF; MLA KV 23,040
  B/token; no BFCL. Inputs: `gguf.total` = unsloth's GGUF Mistral links (c); bartowski CSL no
  match. Pass after research.
- **ibm-granite/granite-switch-4.1-8b-GGUF** (GGUF 2026-11-04; model 2026-10-28). IBM. Base
  granite-4.1-8b (+aLoRAs, TurboCTC encoder). Teachers: none named. Dense 8B, 131,072; no BFCL.
  Inputs: level 4 via TurboCTC/Granary (c, from the 30B); 4.1-8b disclosure unread. Pass on the
  family's reads; 8B disclosure would complete it.
- **ibm-granite/granite-switch-4.1-30b-GGUF** (2026-11-04, revision 4.1.1). IBM. Base granite-4.1-30b.
  Dense 30B; no BFCL. Level 4 recorded (c). Pass.
- **ibm-granite/granite-4.1-30b-GGUF**. IBM. "trained from scratch" (c). Q5_K_M magic GGUF; "BFCL v3"
  73.68 uncategorized (c). Pass.
- **ibm-granite/granite-4.2-{3b,8b,30b}-GGUF** (2026-10-20). IBM. No teacher; dataset sources
  recorded (c). "BFCL (v4)" uncategorized. Pass.
- **ggml-org/Muse-Glimmer-30B-GGUF; meta-models/Muse-Glimmer-30B-GGUF** (model 2026-10-22, GGUF
  2026-10-20). Meta ("Meta Superintelligence Lab"; org "Meta Inc." verified, c). Teacher Muse
  Spark, Meta's own ("distilled from Muse Spark"). Dense ~29.6B, 131,072; no BFCL; publisher Q4_K_XL
  "0.2%" average over 15 unnamed benchmarks. DFlash drafter level 5. Pass.
- **mistralai/Ministral-3-{3B,8B,14B}-Instruct-2512-GGUF; Magistral-Small-2509-GGUF**. Mistral.
  Teachers Mistral's own (c). Pass. **unsloth/Phi-4-mini-instruct-GGUF**: Microsoft; pass after
  research (c). **bartowski Apriel 1.6 15B**: ServiceNow, Delaware; R1-Distill-SFT prompts a
  dataset source (c). Pass. **unsloth Llama-4-Scout Q5_K_M**: Meta; pass after research (c).
  **ggml-org Nemotron-3.5-Bolt-E4B**: NVIDIA on Gemma-4-E4B-it (Google chain passes) (c). Pass.
- **NousResearch/Hermes-4-70B**. Nous Research. Base Meta-Llama-3.1-70B. Generator DeepSeek-R1 /
  R1-0528 ("synthesize a reasoning trace and answer"); the report calls its answer source "a
  teacher model". Excluded, level 2 (subject to the survey's reading of role).
- **ornith-ai/Ornith-1.5-35B-A3B**. Ornith Team. "on top of Qwen3.5 and Gemma4". Excluded, level 1.
- **LiquidAI/LFM3-1.7B(-GGUF)** (2026-11-05). Liquid AI, Delaware (c). Base LFM3-1.7B-Base. Six
  unnamed "specialist RL teachers". Q8_0; "BFCL V4 71.39" uncategorized. Origin unclear.
- **InternScience/Agents-A1**. InternScience (domicile unread). Config Qwen3.5 MoE; base unnamed.
  Origin unclear.
- **poolside/Laguna-S-2.1(-GGUF)** (model created 2026-07-13). Poolside (verified; entity and
  domicile not read). Base/teachers unstated. Q8_0 119.9 GiB; Q4_K_M; 118B-A8B; no BFCL. Not
  settled; fails fit/floor.
- **mistralai/Mistral-Medium-3.5-128B** (2026-07-15). Mistral AI. Base/teachers unstated. Dense 128B;
  KV 360,448 B/token. Not settled; fails fit.
- **nvidia/NVIDIA-Nemotron-Labs-3-Puzzle-75B-A9B-BF16** (created 2026-06-24). NVIDIA; derived from
  Nemotron-3-Super-120B-A12B. Pass by policy; no publisher or ggml-org GGUF.
- **LiquidAI/LFM2.5-24B-A2B-GGUF** (2026-11-06T03:22:24Z, commit 7be3a8c7… "Add
  LFM2.5-24B-A2B-Q4_0.gguf"; read 2026-11-06T18:53Z, gb10-1's second survey). Liquid AI. Base
  card `LiquidAI/LFM2.5-24B-A2B` unchanged (3dc4cd09…, 2026-11-03T18:09:25Z). Teachers: "teacher
  specialization, two multi-domain on-policy distillation stages", none named ([gb10-1 rpt]). The
  new Q4_0 is a post-training 4-bit file, path 3. Origin unclear.

gb10-1's second survey (2026-11-06T18:53Z) re-read the records of the incumbents and the top
candidates (gpt-oss-120b and -20b GGUFs, Lightning GGUF and NVIDIA's BF16, Trinity Mini, Google's
26B-A4B, 31B and E4B QAT, ggml-org's E4B, LFM3-Omni-2B, Granite Speech 5.0, granite r2,
EmbeddingGemma 2): every `lastModified` equals the one its entry reads, so no chain was rebuilt.
Form: repository · lastModified (as read) · publisher · base chain · teachers (role) · gate reads · origin inputs → result.

- **google/gemma-4-26B-A4B-it-qat-q4_0-gguf** · 2026-07-17 · Google · QAT release of gemma-4-26B-A4B-it · Gemma 3 "large IT teacher" (policy 2026-11-04, own pipeline) · QAT path 1; mmproj 16-bit (est.); MMMU Pro 73.8% · Gemma 4 ruling; Google screened, no match (18:27Z) → pass.
- **google/gemma-4-31B-it-qat-q4_0-gguf** · 2026-07-17 · Google · as above · as above · QAT; MMMU Pro 76.9%, OmniDocBench 0.131 · → pass.
- **google/gemma-4-12B-it-qat-q4_0-gguf** · 2026-07-17 · Google · as above · QAT; MMMU Pro 69.1% · → pass.
- **google/gemma-4-E4B-it-qat-q4_0-gguf** · 2026-07-17 · Google · QAT · as above · QAT; reasoning fault [vf] · → pass (closed by the architect).
- **google/gemma-4-E2B-it-qat-q4_0-gguf** · 2026-07-17 · Google · QAT · as above · QAT; MMMU Pro 44.2%, CoVoST 33.47 · → pass.
- **ggml-org/gemma-4-E4B-it-GGUF** · 2026-10-19 · Google (ggml-org converter) · `.src_sha` ee0ef602… on google/gemma-4-E4B-it · as Gemma 4 · Q8_0 path 3; CoVoST 35.54; USM-based audio encoder · → pass (item 4).
- **ggml-org/gemma-4-E2B-it-GGUF** · 2026-10-19 · Google (ggml-org) · `.src_sha` on google/gemma-4-E2B-it [screen 11-04] · → pass.
- **LiquidAI/LFM3-VL-2B(-GGUF)** · 2026-11-03 · Liquid AI, Inc. · LFM3-1.7B-Base · MOPD from Liquid's vision RL model and LFM3-1.7B Mixed RL (own pipeline) · Q8_0 path 3; in-house encoder; MMMU-Pro 45.7, OCRBench 86.3 · converter is publisher; screened no match → pass.
- **LiquidAI/LFM3-Audio-2B(-GGUF)** · 2026-11-03 · Liquid AI · LFM3 backbone, no base_model · none named · in-house encoder, LiquidCodec; WER 6.23 · → pass.
- **LiquidAI/LFM3-Omni-2B(-GGUF)** and **ggml-org/LFM3-Omni-2B-GGUF** · 2026-11-03 / 2026-11-01 · Liquid AI · LFM3; `.src_sha` `5797d07c…` (gb10-1) · none named · WER 6.36, OCRBench 806 · → pass (cited, [gb10-1 rpt]).
- **LiquidAI/d1-2B(-GGUF)**, **LiquidAI/d1-Omni-2B(-GGUF)** · 2026-11-04 / 2026-11-03 (GGUF) · Liquid AI · LFM3-VL-2B / LFM3-Omni-2B · none named · decision models, `/v1/systemone` · → pass; purpose mismatch.
- **meta-models/Muse-Glimmer-30B** via **ggml-org/Muse-Glimmer-30B-GGUF** · 2026-10-22 / 2026-10-25 · Meta · — · Muse Spark (Meta's own teacher); DFlash drafter level 5 · Q8_0 + BF16 mmproj; MMMU Pro 74 · Meta Platforms screened no match → pass ([screen 11-04]).
- **ibm-granite/granite-vision-4.1-4b(-GGUF)** · 2026-07-13 / 2026-06-24 · IBM · Granite · dataset source SYNTHETIC-1 (one of 100+) · Q8_0 + F16 mmproj · → pass ([screen 11-04]).
- **ibm-granite/granite-speech-5.0-2b(-GGUF)** · 2026-11-03 / 2026-10-26 · IBM · granite-4.0-1b-base (intermediate) · none; level 4: Phi-4, MADLAD, Granite-3 translations, Kokoro-82M TTS, Granary · Q8_0 + F16 mmproj; WER in charts · → pass.
- **ibm-granite/granite-speech-4.1-2b(-plus)(-GGUF)** · 2026-10-26 / 2026-11-04 · IBM · granite-4.0-1b · level 4 Granary Qwen labeler · Q8_0 + F16 mmproj · → pass ([screen 11-04]; plus [gb10-1 rpt]).
- **mrutkows/granite-embedding-english-r2-GGUF** (BF16; Q8_0) · 2026-04-08 · IBM (uploader Matt Rutkowski, IBM) · ibm-granite/granite-embedding-english-r2 (total 149,014,272 equal) · Mistral teachers/generators (arXiv 2508.21085) · MTEB-v2 (41) 62.8 · → pass after research (policy example).
- **mrutkows/granite-embedding-small-english-r2-GGUF** · — · IBM · small-r2 · as r2 · BF16 · → pass ([screen 11-04]).
- **ggml-org/embeddinggemma-2-GGUF** · 2026-11-01 · Google · `.src_sha` f9972ac2… = Google's · teacher Gemini Embedding 2 (Google) · MTEB (eng, v2) 68.46 · → pass.
- **ggml-org/embeddinggemma-300M-GGUF** · — · Google · → pass after research ([screen 11-04]).
- **nomic-ai/nomic-embed-text-v1.5-GGUF**, **ggml-org/Nomic-Embed-Text-V2-GGUF** · nomic 2026-04-07 · Nomic AI · — · level 4: gte-base / BGE M3 hard-negative mining · → pass ([screen 11-04]).
- **mistralai/Ministral-3-*-Instruct-2512-GGUF** · — · Mistral AI · teacher Mistral Small 3.1 (own) · → pass ([screen 11-04]).
- **unsloth/Llama-4-Scout-17B-16E-Instruct-GGUF** · — · Meta (unsloth converter) · → pass after research ([screen 11-04]).
- **Nemotron 3.5 Transcribe community GGUFs** · — · NVIDIA weights unconfirmed · → not settled, failing engine at b11960.
- **Nemotron 3.5 Embed 1B/8B, mradermacher GGUFs** · — · → origin unclear (conversion) ([gb10-1 rpt]).
- **ggml-org/Voxtral-Mini-4B-Realtime-2602-GGUF** · — · Mistral · Ministral-3-3B base · → pass ([screen 11-04]); Arabic variant's community GGUF not settled.

## The host stack

### DGX Spark release notes

- **URL:** <https://docs.nvidia.com/dgx/dgx-spark/release-notes.html>
- **Read:** 2026-11-06T18:51Z (gb10-1's second survey)
- **Concerns:** gb10-1: the OS image, kernel, driver; the display-memory watch item.
- **Tier:** primary.
- **Said:** newest section "October 2026 Release": "This update supports the Linux 7.0 kernel
  (previously 6.17)"; current versions (Founders Edition only): DGX OS 7.6.0, kernel 7.0.0-1019,
  driver 580.178.04, CUDA 13.0.3. Names "Dynamic Display Reserved Memory" (October) and "Adjustable
  Display Reserved Memory" (July). No 7.0.0-1025, no OTA past 7.6.0, nothing on initcall.

### DGX OS 7 release notes

- **URL:** <https://docs.nvidia.com/dgx/dgx-os-7-user-guide/release_notes.html>
- **Read:** 2026-11-06T18:51Z (gb10-1's second survey)
- **Concerns:** gb10-1: the OS image.
- **Tier:** primary.
- **Said:** newest section "DGX OS 7.6.0", "Release Date: September 14, 2026"; DGX Spark kernel
  "7.0.0-1018-nvidia", driver "580.173.02". Nothing past 7.6.0; DGX OS 8 named only as "the latest
  DGX OS 8 release".

### Launchpad: linux-nvidia-7.0, linux, sqlite3, the 580 driver, linux-firmware; USNs

- **URL:** <https://launchpad.net/ubuntu/+source/linux-nvidia-7.0/+publishinghistory>,
  <https://launchpad.net/ubuntu/+source/linux-nvidia-7.0/7.0.0-1025.26~24.04.1>,
  <https://launchpad.net/ubuntu/+source/linux/6.8.0-149.149>,
  <https://launchpad.net/ubuntu/+source/sqlite3/3.45.1-1ubuntu2.9>,
  <https://launchpad.net/ubuntu/+source/nvidia-graphics-drivers-580/+publishinghistory>,
  <https://launchpad.net/ubuntu/+source/linux-firmware/+publishinghistory>,
  <https://ubuntu.com/security/notices/USN-9003-1>, <https://ubuntu.com/security/notices/USN-9001-1>, and
  <https://launchpad.net/ubuntu/+source/ca-certificates/+publishinghistory>,
  <https://launchpad.net/ubuntu/+source/ca-certificates-java/+publishinghistory>,
  <https://launchpad.net/ubuntu/+source/sqlite3/+publishinghistory>,
  <https://launchpad.net/ubuntu/+source/linux/+publishinghistory>
- **Read:** 2026-11-06T18:52Z (gb10-1's second survey; the version pages and USN-9003-1 at the
  first survey's read)
- **Concerns:** gb10-1: the packages upgraded today, the kernel, the driver, linux-firmware.
- **Tier:** primary.
- **Said:** linux-nvidia-7.0's newest noble version "7.0.0-1025.26~24.04.1": proposed 2026-11-05
  20:20:29, updates 2026-11-06 01:14:45, no security entry; 1024.25 in security since 2026-11-02;
  nothing newer in any pocket. nvidia-graphics-drivers-580's newest "580.178.04-0ubuntu0.24.04.1"
  (updates 2026-09-15, security 2026-10-08), nothing newer, proposed included. linux-firmware's
  newest "20240318.git3b128b60.0ubuntu3.1" (updates 2026-09-03). ca-certificates
  "20260816ubuntu0.24.04.2" and ca-certificates-java "20240118ubuntu0.24.04.1" in security and
  updates (2026-11-05); sqlite3 "3.45.1-1ubuntu2.9" updates only (2026-11-04); linux
  "6.8.0-149.149" updates and proposed only. USN-9001-1 (5 November 2026) fixes the two
  ca-certificates packages on noble, no CVE: "CA certificates removed from the system bundle not
  being removed from the JKS keystore". From the first read: 1025's one change ("ipv4: free
  inet_opt and ireq_opt after an RCU grace period", LP #2172774); USN-9003-1 lists 1024.25 for
  24.04. linux 6.8.0-149.149 updates only. sqlite3 2.9: a segfault fix (LP #2087772), no CVE.
  USN-9001-1: ca-certificates and -java, JKS keystore, no CVE. Driver 580.178.04 the newest for
  noble. linux-firmware 20240318.git3b128b60.0ubuntu3.1 the newest.

### NVIDIA forum 387397, reboots on 7.0.0-1024-nvidia, and the 1025 reports

- **URL:** <https://forums.developer.nvidia.com/t/dgx-spark-repeatedly-rebooting-after-most-recent-update/387397>
  (read as `/t/387397.json`, `/27.json`, `/53.json`), <https://forums.developer.nvidia.com/t/388215.json>,
  <https://forums.developer.nvidia.com/t/388090.json>, <https://forums.developer.nvidia.com/t/386495.json>,
  <https://forums.developer.nvidia.com/search.json?q=1025%20after%3A2026-11-04>
- **Read:** 2026-11-06T18:52Z (gb10-1's second survey: the host now runs 1025, which the first
  read didn't cover)
- **Concerns:** gb10-1: the reboot watch item, on 7.0.0-1025-nvidia.
- **Tier:** staff posts primary; users leads.
- **Said:** 387397: reboot loops on 1024 with 580.178.04, mostly with HDMI; one on a Dell FCM1253.
  Staff (zneill): post 40, "nvidia-spark-initcall-bl version 1.0-2 … (initcall_blacklist=power_wrap_init)";
  post 52 (2026-11-04T17:20Z), "the fix for this issue is available as an update for all users";
  post 53, "This particular fix was for the very specific reboot issue experienced after recent
  upgrade." Post 35 (user158576, a lead): "tegra234_cbb_init should be already there. Just need to
  add power_wrap_init". Posts 23, 24, 29-31 (leads): "Booting 1019 resolves the issue". Highest
  post 53 (2026-11-04T23:16Z); no post names 1025. 388215 (alex.zare99, 2026-11-06T17:53Z, one
  post, no reply): "DGX Spark: kernel 7.0.0-1025-nvidia memory corruption and system freezes",
  seven Oopses, eight linked-list corruptions, fourteen soft-lockups, driver 580.178.04,
  `nvidia-spark-initcall-bl` "1.0-1" with power_wrap_init not blacklisted, rolled back to 1019, the
  cause "unproven"; it gives the OS as "Ubuntu 26.04.1 LTS". 388090 (hoesing, accepted): "1025
  seems to just have one change: ipv4: free inet_opt and ireq_opt after an RCU grace period (LP:
  #2172774)"; jv14 ties it to a CVE through a third-party site. 386495 post 13
  (2026-11-06T08:23Z): "things came back without the HDMI connected … maybe it's fixed?", no
  kernel named. A web search for "7.0.0-1025-nvidia" found nothing more.

### Dell KB 000379162; the NVIDIA Container Toolkit; LP #1991502

- **URL:** <https://www.dell.com/support/kbdoc/en-us/000379162/how-to-upgrade-the-bios-and-the-firmware-on-a-dell-pro-max-with-the-grace-blackwell-system>,
  <https://api.github.com/repos/NVIDIA/nvidia-container-toolkit/releases>,
  <https://bugs.launchpad.net/ubuntu/+source/update-notifier/+bug/1991502>
  <https://www.dell.com/support/home/en-us/product-support/product/dell-pro-max-fcm1253-micro/drivers>,
  <https://fwupd.org/lvfs/search?value=GB10>
- **Read:** 2026-11-06 (gb10-1 survey); the toolkit's releases, Dell's drivers page and LVFS
  2026-11-06T18:51Z to 18:53Z (gb10-1's second survey)
- **Concerns:** gb10-1: BIOS channel, container runtime, the failed user unit.
- **Tier:** primary (LP's report itself a user's).
- **Said:** Dell: updates through the DGX Dashboard or apt plus `fwupdmgr`, no version named.
  Toolkit v1.20.1 (2026-09-19T00:01:48Z) the newest release, stable or not (v1.20.0 2026-08-13;
  newest prerelease v1.20.0-rc.1). Dell's drivers page needs a sign-in ("Get full access"); LVFS's
  search answered HTTP 403; one web search found no Dell BIOS note past 5.36 and no source on the
  Dell UEFI's display reservation. LP #1991502: `update-notifier-crash` calls
  apport-gtk and exits 127 where it is missing, leaving the user manager degraded.

### omarchy-pkgs commits, linux-omarchy

- **URL:** <https://api.github.com/repos/omacom-io/omarchy-pkgs/commits?path=pkgbuilds/linux-omarchy>; <https://api.github.com/repos/omacom-io/omarchy-pkgs/commits/bffb8bf>
- **Read:** 2026-11-06T18:22Z
- **Concerns:** framework: kernel.
- **Tier:** primary.
- **Said:**
  - 5973b1f (2026-11-01) "Update Linux kernel release to v7.2.15-1 ..."
  - 326470e (2026-11-02) "restore pkgbase=linux-omarchy"
  - bffb8bf (2026-11-03) "Ship NVIDIA's open modules prebuilt with linux-omarchy (#2056)",
    pkgrel 1→2, an NVIDIA-only change
  - `pkgs.omarchy.org/stable/x86_64/` answers 404

### Omarchy releases

- **URL:** <https://api.github.com/repos/basecamp/omarchy/releases>
- **Read:** 2026-11-06T18:22Z
- **Concerns:** framework: OS image.
- **Tier:** primary.
- **Said:**
  - v4.5.0 stable 2026-11-05: an introduction only.
  - v4.5.0-rc3 2026-11-02: a kernel switch menu (#15966), kernel-migration and root= fixes, a 32-bit
    Vulkan driver fix for Lutris/Battle.net (#16046).
  - No GPU-compute items.

### Omarchy pacman templates at v4.5.0 and v4.0.6

- **URL:** <https://raw.githubusercontent.com/omacom/omarchy/v4.5.0/default/pacman/pacman-stable.conf>, `.../mirrorlist-stable`, <https://raw.githubusercontent.com/basecamp/omarchy/v4.0.6/default/pacman/pacman-stable.conf>
- **Read:** 2026-11-06T18:26Z
- **Concerns:** framework: the channel and its template.
- **Tier:** primary.
- **Said:** `[options]` Color, ILoveCandy, VerbosePkgLists, `HoldPkg = pacman glibc`, `Architecture = auto`, CheckSpace, `ParallelDownloads = 5`, `DownloadUser = alpm`, `SigLevel = Required DatabaseOptional`, `LocalFileSigLevel = Optional`; `[omarchy]` `Server = https://pkgs.omarchy.org/stable/$arch`; `[core]`, `[extra]`, `[multilib]` each `Include = /etc/pacman.d/mirrorlist`; `mirrorlist-stable` `Server = https://stable-mirror.omarchy.org/$repo/os/$arch`. The same at v4.0.6 and v4.5.0. The repository
  is now served from `omacom/omarchy`.

### gregkh/linux amd commits at v7.2.15 and v7.3.1

- **URL:** <https://api.github.com/repos/gregkh/linux/commits?sha=v7.2.15&path=drivers/gpu/drm/amd&per_page=40>; same with `sha=v7.3.1`
- **Read:** 2026-11-06T18:25Z
- **Concerns:** framework: kernel.
- **Tier:** primary (the architect's ruling).
- **Said:**
  - At v7.2.15 the newest amd commit is committed 2026-10-26: "drm/amdgpu: free the userptr ranges
    when a CS fails after parser_bos". There is none after 10-29.
  - None names gfx11/GC 11.5/gfx1151/MES/PSP 14.0.1/DCN 3.5/VCN 4.0.6.
  - v7.3.1 carries the same backports (to 10-15).
  - `sha=v7.3.2` returned `[]`, not readable yet.

### linux-firmware tags and commits since 20260916; diffs 7a4a30b0, f61bad71

- **URL:** <https://gitlab.com/api/v4/projects/kernel-firmware%2Flinux-firmware/repository/tags>; `.../repository/commits?since=...`; `.../commits/<sha>/diff`
- **Read:** 2026-11-06T18:23Z–18:24Z
- **Concerns:** framework: GPU firmware.
- **Tier:** primary.
- **Said:**
  - The newest tag is 20261019 (10-17).
  - Inside it: GC 11.5.1 (7a4a30b0, `gc_11_5_1_mes_2.bin` only, no version), PSP 14.0.1
    (2012998a), VCN 4.0.6 (347dcaed).
  - The only revert is GC 11.0.0's.
  - After the tag: f61bad71 (10-30) DMCUB for `dcn_3_5_1`/`dcn_3_5`/`dcn_3_6`, and 9ca5128f
    (DCN42).
  - No GC 11.5.1/PSP 14.0.1/MES change after the tag.

### Mesa release notes, 26.2.6, and the index

- **URL:** <https://docs.mesa3d.org/relnotes/26.2.6.html>; <https://docs.mesa3d.org/relnotes.html>
- **Read:** 2026-11-06T18:22Z
- **Concerns:** framework: host Mesa.
- **Tier:** primary.
- **Said:**
  - 26.2.6 was released 2026-10-28 and is the newest on the index.
  - It fixes the ACO s_bitset0/VCC 26.2 regression (RADV, RDNA2–RDNA4), plus the RADV VMA heap,
    BO-list leak and rt stack-size fixes.
  - The only regression listed is Intel Meteor Lake.

### Framework Desktop BIOS downloads and BIOS announcements

- **URL:** <https://resources.frame.work/downloads/desktop/amd-ryzen-ai-max-300>; <https://community.frame.work/tag/bios-announcement.json>
- **Read:** 2026-11-06T18:24Z
- **Concerns:** framework: BIOS.
- **Tier:** primary.
- **Said:**
  - 3.06 (2026-08-03, "Stable, Latest"), with no Beta.
  - The only Desktop topic is "BIOS 3.06 Release STABLE", last post 2026-09-30.

### TheRock releases

- **URL:** <https://api.github.com/repos/ROCm/TheRock/releases>
- **Read:** 2026-11-06T18:24Z
- **Concerns:** framework: host ROCm.
- **Tier:** primary.
- **Said:** therock-10.1 (2026-10-05) is the newest; then 7.14.1 (08-31) and 10.0 (08-26). No body
  mentions gfx1151.

### ROCm RDNA3.5 system optimization

- **URL:** <https://rocm.docs.amd.com/en/latest/reference/system-optimization/rdna3-5.html>
- **Read:** 2026-11-06T18:26Z
- **Concerns:** framework: the TTM/GTT ceiling, minimum kernel.
- **Tier:** primary.
- **Said:**
  - The banner reads "AMD ROCm 10.1.0".
  - GTT defaults to "approximately 50 percent of total system RAM".
  - It recommends a small BIOS VRAM reservation "(for example, 0.5 GB)" and raising TTM/GTT.
  - `pages_limit` is in pages, with no maximum stated.
  - The minimum kernel is 6.18.4 (other distributions).
  - It doesn't mention lockup_timeout.

### ROCm/TheRock #9271 (MES fault, gfx1151)

- **URL:** <https://github.com/ROCm/TheRock/issues/9271>
- **Read:** 2026-11-06T18:24Z (updatedAt 2026-10-27T19:55Z)
- **Concerns:** framework: firmware (MES), kernel.
- **Tier:** primary tracker. The replies are leads: the last is an AMD-named CONTRIBUTOR (lead by
  ruling).
- **Said:**
  - OPEN, with 3 comments.
  - Reports on ROCm 7.1.1/7.2.1, HIP, MES 0x80. The `amd_iommu=off` workaround is mentioned.
  - The 2026-10-27 reply asks for a retest on the latest gfx1151 nightly with the MES version.
  - No fixed version is named.

### ROCm/TheRock #9247 (mmap > 64 GB on gfx1151) and #2151

- **URL:** <https://github.com/ROCm/TheRock/issues/9247>; <https://github.com/ROCm/TheRock/issues/2151>
- **Read:** 2026-11-06T18:24Z
- **Concerns:** framework: host ROCm (not the Vulkan router).
- **Tier:** primary tracker, with leads (users).
- **Said:**
  - #9247: OPEN, HIP only ("Vulkan/RADV works fine"). A user says ROCm/rocm-systems#10962 fixes it
    and that the fix is not in 10.1.0; another report came 11-05 on bundled ROCm 7.2.4.
  - #2151: closed stale 2026-11-06 by a MEMBER.

### llama.cpp #25664, Vulkan device loss on Linux 7.x (RADV_STRIXHALO)

- **URL:** <https://github.com/ggml-org/llama.cpp/issues/25664>
- **Read:** 2026-11-06T18:25Z (updatedAt 2026-11-05T12:42Z)
- **Concerns:** framework: kernel (amdgpu lockup_timeout), Vulkan serving.
- **Tier:** primary tracker. All replies are leads (CONTRIBUTOR/NONE).
- **Said:**
  - The reporter, on a Framework Desktop, attributes vk::DeviceLostError to the compute
    `lockup_timeout` default changing "from 60s to 2s" on 7.x. The workaround is
    `amdgpu.lockup_timeout=10000,60000,10000,10000`.
  - One user says the workaround didn't help (7.1.8, Mesa 26.1.7).
  - One user has no reproduction on 7.2.0 with Mesa 26.2.1 at 113k context.
  - Closed NOT_PLANNED by the stale bot on 2026-11-05.

### Framework SoftwareFirmwareIssueTracker #209 and #237

- **URL:** <https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues/209>; <https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues/237>
- **Read:** 2026-11-06T18:24Z
- **Concerns:** framework: firmware updates via fwupd.
- **Tier:** lead (users).
- **Said:**
  - #209 is OPEN, "Desktop update via fwupdmgr - not possible", updated 2026-07-28.
  - #237 is OPEN, "efivars out of space - framework desktop". A user on BIOS 03.06 gives a
    workaround (2026-11-04).

### llama.cpp vulkan.Dockerfile at b11960 and b12169, and its history

- **URL:** <https://raw.githubusercontent.com/ggml-org/llama.cpp/b11960/.devops/vulkan.Dockerfile>; `.../b12169/...`; <https://api.github.com/repos/ggml-org/llama.cpp/commits?path=.devops/vulkan.Dockerfile>
- **Read:** 2026-11-06T18:26Z
- **Concerns:** framework: the router's Mesa.
- **Tier:** primary.
- **Said:**
  - Both use `UBUNTU_VERSION=26.04`, the base `docker.io/ubuntu`, and `apt-get install ...
    libvulkan1 mesa-vulkan-drivers` with no PPA.
  - The last change to the file is 23deec0 (2026-10-14).

### Ubuntu mesa-vulkan-drivers (packages.ubuntu.com) and Launchpad mesa publishing history

- **URL:** <https://packages.ubuntu.com/search?keywords=mesa-vulkan-drivers&searchon=names&exact=1&suite=all&section=all>; <https://launchpad.net/ubuntu/+source/mesa/+publishinghistory>
- **Read:** 2026-11-06T18:26Z
- **Concerns:** framework: the router's Mesa.
- **Tier:** primary.
- **Said:**
  - resolute release 26.0.3-1ubuntu1.
  - resolute-updates 26.0.8-1ubuntu0.3, published 2026-08-19.
  - Nothing newer in resolute-proposed.
  - stonking (26.10) 26.2.4-1ubuntu1.

### moby releases

- **URL:** <https://api.github.com/repos/moby/moby/releases>
- **Read:** 2026-11-06T18:26Z
- **Concerns:** framework: docker.
- **Tier:** primary.
- **Said:**
  - docker-v29.9.3 (2026-11-03): fixes the daemon hanging under API load, and the Swarm overlay
    protections after a firewalld flush.
  - docker-v29.10.0-rc.1 (2026-11-06, prerelease): "Fix a container starting with no networking
    after an earlier start failed with a network error".

### Arch news feed

- **URL:** <https://archlinux.org/feeds/news/>
- **Read:** 2026-11-06T18:23Z
- **Concerns:** framework: manual interventions.
- **Tier:** primary.
- **Said:**
  - There is no item after 2026-10-21.
  - On 2026-10-21: php ≥ 8.5.12 (RCE); "Update to ca-certificates-mozilla ≥ 3.131.1-1 to prevent
    man-in-the-middle attacks".
