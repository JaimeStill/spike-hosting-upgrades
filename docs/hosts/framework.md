# framework

The Framework desktop's host descriptor, read by the hosting-upgrades skill
(`.claude/skills/hosting-upgrades/`). It records only what the skill needs to reach the host and
judge what it finds there; every other fact (its hardware, OS, kernel, engines, served and stored
models) comes from the probe a run takes.

## SSH short name

`framework`

## Purposes

The model purposes the host serves, seeded from model set A's roles (`ai-hosting.md`, "The
existing setup: personal-agents").

- **agent**: the main chat and tool-calling model the consumers' agent sessions run on.
- **vision**: image input beside text.
- **audio**: speech and audio input beside text.
- **embedding**: text embeddings for retrieval.

## Watch items

Named things every run checks, beside its own scan.

- vLLM support for Vulkan or ROCm on Strix Halo (gfx1151)
- llama.cpp concurrent-session (parallel slots, continuous batching) throughput
- llama.cpp Vulkan MoE prompt-processing regression
  ([#31163](https://github.com/ggml-org/llama.cpp/issues/31163)) and its fix
  ([#31266](https://github.com/ggml-org/llama.cpp/pull/31266))
- AMD's HRX backend for llama.cpp (ggml-hrx): a published container image
- Mesa in the llama.cpp Vulkan image, which the router runs instead of the host's

## Measurements

The workspace's own dated findings on this host, which a run counts as attributed benchmarks on
it. Each is the reference name (the coordinator's `references.toml`) plus its path.

- spike-model-engines `docs/findings/llama-strix-rocm.md`
- spike-model-engines `docs/findings/vllm-strix.md`
