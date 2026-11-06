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
- **Read:** 2026-11-06 (gb10-1 survey; updated upstream 2026-11-06)
- **Concerns:** gb10-1 and framework: set A's agent section's prompt cache, and the split-KV Gemma
  sections' default cache; the register's prompt-cache entry.
- **Tier:** primary (the issue); its commenters (authorAssociation NONE) leads.
- **Said:** open; the RAM-backed prompt cache (`--cache-ram`, `--cache-idle-slots`) restores
  content from an unrelated conversation into a fresh slot under concurrent load. elchic00
  (2026-08-22): with `kv_unified = true` either flag fixes it; with `kv_unified = false` "closing it
  needs `--no-cache-idle-slots` on top of `--cache-ram 0`". A new reproduction 2026-11-06 at the
  default flags. Its fix #27624 open (updated 2026-10-10).

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

### `common.h`, `server.cpp` and the server README at b12098, the defaults

- **URL:** <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/common/common.h>,
  <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/tools/server/server.cpp>,
  <https://raw.githubusercontent.com/ggml-org/llama.cpp/b12098/tools/server/README.md>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1, which runs b12098: every section's unset keys.
- **Tier:** primary (the build's own argument defaults).
- **Said:** `n_batch = 2048`, `n_ubatch = 512`, flash attention `AUTO`, `cache_type_k`/`_v` F16,
  `kv_unified = false`, `n_parallel` -1 (auto), `cache_ram_mib = 8192`, `cache_idle_slots = true`,
  `n_ctx_checkpoints = 32`, `checkpoint_min_step = 8192`, `swa_full = false`, `models_max = 4`,
  `load_mode` auto. `server_prepare_params()`: with `n_parallel` auto the server uses 4 slots and
  `kv_unified = true` (not for the router role), so a section that sets `parallel` runs split KV
  unless it sets `kv-unified`. README: `-kvu` "(default: enabled if number of slots is auto)",
  `--cache-idle-slots` "(default: enabled, requires cache-ram)".

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
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: the engine choice; the vLLM NVFP4 and EmbeddingGemma watch items.
- **Tier:** primary; #58624's GB10 table attributed (another model, FP8); #50925 a lead.
- **Said:** v0.33.0rc3 (2026-11-02, not marked prerelease): "release wheels and images are CUDA
  13.0 only (#62575)". v0.32.0: "OAI Triton MXFP4 MoE on SM12x (#58877)". #58624 (open): MoE decode
  ~15% slower on SM12x since #56876; GB10, Qwen3.6-35B-A3B-FP8, decode step 56.6 → 50.2 ms with a
  patch. #50925 (lead): published builds route NVFP4 MoE to Marlin on sm_121. #60847 closed
  2026-10-27 by #60942 (EmbeddingGemma's Triton prefill OutOfResources), validated on an RTX 5090,
  not in v0.33.0rc3.

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

- **URL:** <https://huggingface.co/google/gemma-4-E4B-it/discussions/50>,
  <https://huggingface.co/api/models/google/gemma-4-E4B-it/commits/main>,
  <https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/raw/main/.src_sha>,
  <https://huggingface.co/ggml-org/gemma-4-12B-it-GGUF/raw/main/.src_sha>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: the audio incumbent's file and the 12B candidates.
- **Tier:** primary.
- **Said:** google/gemma-4-E4B-it, 2026-11-03: "Remediate 219 glitch tokens in tokenizer.json",
  "No model weights are modified"; ggml-org's E4B GGUF still pins `PRIMARY=ee0ef602…` (July).
  google/gemma-4-12B-it fixed 210 on 2026-10-30; ggml-org's 12B `.src_sha` `PRIMARY=43c9d014…`
  equals Google's current sha (BF16 and Q8_0 reconverted 2026-11-01; Q4_0 not).

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

## The host stack

### DGX Spark release notes

- **URL:** <https://docs.nvidia.com/dgx/dgx-spark/release-notes.html>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: the OS image, kernel, driver.
- **Tier:** primary.
- **Said:** newest section "October 2026" ("Linux 7.0 (previously 6.17)"); current versions
  (Founders Edition only): DGX OS 7.6.0, kernel 7.0.0-1019, driver 580.178.04, CUDA 13.0.3.

### Launchpad: linux-nvidia-7.0, linux, sqlite3, the 580 driver, linux-firmware; USNs

- **URL:** <https://launchpad.net/ubuntu/+source/linux-nvidia-7.0/+publishinghistory>,
  <https://launchpad.net/ubuntu/+source/linux-nvidia-7.0/7.0.0-1025.26~24.04.1>,
  <https://launchpad.net/ubuntu/+source/linux/6.8.0-149.149>,
  <https://launchpad.net/ubuntu/+source/sqlite3/3.45.1-1ubuntu2.9>,
  <https://launchpad.net/ubuntu/+source/nvidia-graphics-drivers-580/+publishinghistory>,
  <https://launchpad.net/ubuntu/+source/linux-firmware/+publishinghistory>,
  <https://ubuntu.com/security/notices/USN-9003-1>, <https://ubuntu.com/security/notices/USN-9001-1>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: the pending updates, the kernel, the driver.
- **Tier:** primary.
- **Said:** linux-nvidia 7.0.0-1025.26~24.04.1 in noble-updates 2026-11-06, one change ("ipv4: free
  inet_opt and ireq_opt after an RCU grace period", LP #2172774); USN-9003-1 lists 1024.25 for
  24.04. linux 6.8.0-149.149 updates only. sqlite3 2.9: a segfault fix (LP #2087772), no CVE.
  USN-9001-1: ca-certificates and -java, JKS keystore, no CVE. Driver 580.178.04 the newest for
  noble. linux-firmware 20240318.git3b128b60.0ubuntu3.1 the newest.

### NVIDIA forum 387397, reboots on 7.0.0-1024-nvidia

- **URL:** <https://forums.developer.nvidia.com/t/dgx-spark-repeatedly-rebooting-after-most-recent-update/387397>
- **Read:** 2026-11-06 (gb10-1 survey; posts 21-33 unread)
- **Concerns:** gb10-1: the reboot watch item.
- **Tier:** staff posts primary; users leads.
- **Said:** reboot loops on 1024 with 580.178.04, mostly with HDMI; one on a Dell FCM1253. Staff,
  2026-11-03: "A fix for the reboot loop on kernel 7.0.0-1024-nvidia is now available",
  `nvidia-spark-initcall-bl` 1.0-2 (`initcall_blacklist=power_wrap_init`), for all users; thermal
  reports remain open. 1025 not named.

### Dell KB 000379162; the NVIDIA Container Toolkit; LP #1991502

- **URL:** <https://www.dell.com/support/kbdoc/en-us/000379162/how-to-upgrade-the-bios-and-the-firmware-on-a-dell-pro-max-with-the-grace-blackwell-system>,
  <https://api.github.com/repos/NVIDIA/nvidia-container-toolkit/releases>,
  <https://bugs.launchpad.net/ubuntu/+source/update-notifier/+bug/1991502>
- **Read:** 2026-11-06 (gb10-1 survey)
- **Concerns:** gb10-1: BIOS channel, container runtime, the failed user unit.
- **Tier:** primary (LP's report itself a user's).
- **Said:** Dell: updates through the DGX Dashboard or apt plus `fwupdmgr`, no version named.
  Toolkit v1.20.1 (2026-09-19) the newest stable. LP #1991502: `update-notifier-crash` calls
  apport-gtk and exits 127 where it is missing, leaving the user manager degraded.
