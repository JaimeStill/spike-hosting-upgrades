# framework

The Framework desktop's host descriptor, read by the hosting-upgrades skill
(`.claude/skills/hosting-upgrades/`). It records only what the skill needs to reach the host and
judge what it finds there; every other fact (its hardware, OS, kernel, engines, served and stored
models) comes from the probe a run takes.

## SSH short name

`framework`

## Purposes

The purposes the host serves, each with its load target: the concurrent sessions or requests it
is sized for, and the context each reaches. Which purposes this host serves, and at what load, is
spike-model-layout's to decide; a change there changes this list. The host serves model set A from
the shared preset, spike-model-engines `host/llama-preset/models.ini`, as its screen record's end
state reads it back (`docs/screens/framework/2026-11-04.md`, "End state"), reloaded when its clone
returned to main at dfc1d3d (`docs/screens/gb10-1/2026-11-05.md`, "End state"). Each target below
comes from the preset's sections on main at 933ec0f (read 2026-11-06), which differ from
dfc1d3d's only by set A's cache keys, not by slots or context.

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

## Run noise

Each spread is the widest relative spread, (highest − lowest) / lowest, between readings of one
cell on one engine build and one kernel (the skill's `rules.md`, "Figures", "Run noise"). Both
are **set**, by framework's measure of 2026-11-06, which repeated anchors A and B from fresh loads
([measure record](../measures/framework/2026-11-06.md), "Run noise"); a set spread widens when a
later same-build spread exceeds it and never narrows by one quiet run.

- **Within-session**: 1.1%, set 2026-11-06. Anchor B on b11960-8642541b2, kernel 7.2.15-1-omarchy,
  in verify-framework's 2026-11-02 session (runs 3 and 4): 77.14, 77.31, 76.73 and 76.46 tok/s
  ([verify-framework](../findings/verify-framework.md), "Cells" and "Run 4: E4B QAT with reasoning
  off"). The measure's repeats on the same build and kernel, each from a fresh load, spread less:
  anchor A 43.87 and 43.70 (0.39%), anchor B 75.43 and 75.65 (0.29%)
  ([measure record](../measures/framework/2026-11-06.md), "Run noise").
- **Across-days**: 2.8%, set 2026-11-06. Anchor A on the same build and kernel: 44.91 at most on
  2026-11-02 (verify-framework), 43.79 on 2026-11-04
  ([framework's screen record](../screens/framework/2026-11-04.md), "Cells", phase 1), and 43.87
  and 43.70 on 2026-11-06 (the measure record), 2.8% from 44.91 to 43.70; anchor B 77.31, 75.94,
  and 75.43 and 75.65, 2.5%. The 2026-11-04 and 2026-11-06 readings ran over DERP, the
  2026-11-02 ones over the direct path.

## Watch items

Every run checks these by name, beside its own scan. What blocks this host from an upgrade is in
the blocker register, [blockers.md](../blockers.md), which every survey checks upstream. The
register's entries for this host are Gemma 4 26B-A4B's Vulkan abort with several slots (#29221,
its fix #25584) and Vulkan's batched tensor copy (#31418), which reopen Gemma's screen here when
they reach a `server-vulkan` image; the prompt-cache bugs with a unified KV cache (#30961,
#27148); and Google's QAT GGUFs on b12100 and later (#31620, #31639), which this host meets when
its build passes b12100.

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

## Measurements

The workspace's own dated findings on this host, which a run counts as attributed benchmarks on
it. Each is the reference name (the coordinator's `references.toml`) plus its path.

- spike-model-engines `docs/findings/llama-strix-rocm.md`
- spike-model-engines `docs/findings/vllm-strix.md`

## Pool

The model pool whose rows the survey (`/hosting-upgrades survey`) gates as candidates for this
host's class, as the reference name (the coordinator's `references.toml`) plus its path.

- spike-model-hosting `docs/pool.md`
