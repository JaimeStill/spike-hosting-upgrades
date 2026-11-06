# framework

The Framework desktop's host descriptor, read by the hosting-upgrades skill
(`.claude/skills/hosting-upgrades/`). It records only what the skill needs to reach the host and
judge what it finds there; every other fact (its hardware, OS, kernel, engines, served and stored
models) comes from the probe a run takes.

## SSH short name

`framework`

## Purposes

The purposes the host serves today, each with its load target: the concurrent sessions or
requests it is sized for, and the context each reaches. Today the host serves model set A, as its
screen record's end state reads it back (`docs/screens/framework/2026-11-04.md`, "End state"),
reloaded when its clone returned to main at dfc1d3d (`docs/screens/gb10-1/2026-11-05.md`, "End
state"), from the shared preset, spike-model-engines `host/llama-preset/models.ini`, whose
sections give each target. The figures below are main's at 933ec0f (read 2026-11-06), whose
sections differ from dfc1d3d's only by set A's cache keys, not by slots or context. Which purposes
this host serves, and at what load, is spike-model-layout's to decide; a change there changes this
list.

- **agent**: the main chat and tool-calling model the consumers' agent sessions run on. Load
  target: 4 concurrent sessions sharing one 131,072-token context pool (a unified KV cache), so
  one session reaches up to 131,072 tokens and each of four full sessions 32,768. From the
  `gpt-oss-120b-MXFP4-set-a` section: `c = 131072`, `parallel = 4`, `kv-unified = true`.
- **vision**: image input beside text. Load target: 4 concurrent requests of 8,192 tokens each.
  From the `google/gemma-4-26B-A4B-it-qat-q4_0-gguf:Q4_0` section: `c = 32768`, `parallel = 4`,
  split evenly across the slots (the preset's comment on its Gemma 4 sections).
- **audio**: speech and audio input beside text. Load target: 4 concurrent requests of 8,192
  tokens each. From the `ggml-org/gemma-4-E4B-it-GGUF:Q8_0` section: `c = 32768`,
  `parallel = 4`, split the same way.
- **embedding**: text embeddings for retrieval. Load target: 16 concurrent requests of 8,192
  tokens each. From the `mrutkows/granite-embedding-english-r2-GGUF:BF16` section:
  `c = 131072`, `parallel = 16`.

## Watch items

Named things every run checks, beside its own scan.

- vLLM support for Vulkan or ROCm on Strix Halo (gfx1151)
- llama.cpp concurrent-session (parallel slots, continuous batching) throughput
- llama.cpp Vulkan MoE prompt-processing regression
  ([#31163](https://github.com/ggml-org/llama.cpp/issues/31163)) and its fix
  ([#31266](https://github.com/ggml-org/llama.cpp/pull/31266))
- AMD's HRX backend for llama.cpp (ggml-hrx): a published container image
- Mesa in the llama.cpp Vulkan image, which the router runs instead of the host's
- llama.cpp unified-KV prompt-processing drop with several slots
  ([#28495](https://github.com/ggml-org/llama.cpp/issues/28495)) and its fix
  ([#29510](https://github.com/ggml-org/llama.cpp/pull/29510))
- The Omarchy stable mirror's snapshot date (what the host can update to)
- A revision of `google/gemma-4-E4B-it-qat-q4_0-gguf` that fixes its unprompted reasoning, which
  rolled E4B QAT back as the audio model (`docs/findings/verify-framework.md`, "Verdict")
- llama.cpp Vulkan "tensor not allocated" abort on Gemma 4 26B-A4B's second request with several
  slots ([#29221](https://github.com/ggml-org/llama.cpp/issues/29221), fix
  [#25584](https://github.com/ggml-org/llama.cpp/pull/25584)), which dropped Gemma's agent
  section at Gate 3 (`docs/screens/framework/2026-11-04.md`); with #31418, its merge re-opens
  Gemma's screen here
- llama.cpp Vulkan support for the batched tensor copy API
  ([#31418](https://github.com/ggml-org/llama.cpp/pull/31418)), which cuts the multi-slot
  prompt-save time; with #25584, its merge re-opens Gemma's screen here

## Measurements

The workspace's own dated findings on this host, which a run counts as attributed benchmarks on
it. Each is the reference name (the coordinator's `references.toml`) plus its path.

- spike-model-engines `docs/findings/llama-strix-rocm.md`
- spike-model-engines `docs/findings/vllm-strix.md`

## Pool

The model pool whose rows the survey (`/hosting-upgrades survey`) gates as candidates for this
host's class, as the reference name (the coordinator's `references.toml`) plus its path.

- spike-model-hosting `docs/pool.md`
