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
