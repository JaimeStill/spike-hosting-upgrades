# Models: gates, sort, and memory

How steps 7 and 8 of [SKILL.md](SKILL.md) judge a model. Every value a gate compares against
comes from the project's `docs/policy.md` or from the probe, never from this page; this page says
how to read the sources that settle each gate. A gate that needs a value the policy doesn't state
is a pause (SKILL.md, "When to pause"), and the run never fills the value in itself.

## Gate 1: the policy

Checked first, because a model the policy excludes isn't weighed further.

### Origin

1. Read the model's Hugging Face API record, `https://huggingface.co/api/models/<org>/<name>`,
   for its author and `cardData.base_model`.
2. Follow `base_model` until a record names none. The origin is that root model's publisher.
   A quantization, a conversion (`ggml-org`, `unsloth`, an NVIDIA NVFP4 checkpoint), a drafter,
   and a fine-tune all take the root's origin, whoever published them.
3. Where the record names no base, read the card for the backbone it was "initialized from" or
   "built on", and the config's `architectures` and chat template.
4. An origin the policy excludes puts the model in the section's "excluded on origin" list, with
   the record that shows it. It never reaches a verdict or the model set.
5. **Origin unclear** (no base in the record or the card, and a config or template that points to
   another family) is a pause. The default the run takes is to hold the model out of the ranking
   under "origin unclear" until the architect answers.

### Quantization floor

1. Read the format from the files (`siblings`: a GGUF's quant type in its name, a
   `quantization_config` in `config.json`) or from the probe's stored model.
2. A format the publisher evaluated passes if the policy accepts it. "Evaluated" means the
   checkpoint's own card publishes evals for that format beside full precision. A quantized
   checkpoint whose card only points to the base model's card has not been evaluated.
3. Otherwise apply the policy's floor, including any higher floor it sets for a kind of model or
   a size.
4. **A rule's edge** is a pause: a format the floor doesn't name, or card evals that are mostly
   within the policy's margin but not all of them. Name the evals outside the margin, especially
   those for the purpose. The default is that the model fails the floor until the architect
   answers. The report still shows the gates it would otherwise pass, so the architect sees what
   the answer decides.

## Gate 2: fit

A model fits when its memory estimate leaves the policy's headroom of the probed ceiling free
with that model alone. Step 8 checks the set together.

### Memory estimate

Always marked **estimate**, naming this method:

- **Weights**: the snapshot size the probe's `== models ==` reports for a stored model, or the sum
  of the format's file sizes from the API (`?blobs=true`, `siblings[].size`) for one not stored.
  Include any projector (`mmproj`) or drafter the purpose needs.
- **KV cache**: 2 x layers x KV heads x head dimension x bytes per element x tokens, from
  `config.json`, for the configured context and slots. Count only the window for sliding-window
  layers, and nothing for recurrent (Mamba) layers beyond their fixed state. When no configuration
  is known, use the purpose's working context: the incumbent's, or the engine's default.
- **Engine reservation**: on vLLM, `--gpu-memory-utilization` x the ceiling, which replaces the
  sum above, because vLLM claims that share whatever the model needs. On llama.cpp, the weights
  and KV cache plus a compute buffer, about 1 to 2 GiB per loaded model (estimate).

## Gate 3: the engine

The host's engine, which is the incumbent or the conclusion of step 6, must serve the
architecture on the probed backend:

- **llama.cpp**: the architecture is in the release notes' "New models" at or before the build,
  or in `src/llama-arch.cpp` at the build. A GGUF of it exists, and a multimodal purpose has its
  `mmproj` support in `mtmd`.
- **vLLM**: the architecture is in the release notes or the supported-models docs at the tag. The
  format has a kernel on the backend (NVFP4 and MXFP4 MoE backends on the probed compute
  capability). An open tracker report that the format crashes or corrupts output on the backend
  fails the gate, cited.

## Sort

Models that pass all three gates sort by:

1. **Published speed on the same hardware class**: decode and prefill from an attributed
   benchmark (sources.md, "Tiers"), at a concurrency that fits the purpose. A model with no
   published speed on the class sorts after every model that has one.
2. **The card's evals for the purpose**, compared only on the same benchmark and version:
   - agent: tool calling and agentic benchmarks (tau-bench, BFCL, SWE-bench)
   - vision: image and document benchmarks (MMMU, OCRBench, ChartQA)
   - audio: speech recognition word error rate and audio understanding
   - embedding: MTEB retrieval and the code and multimodal retrieval suites

A model that covers several purposes is sorted in each.

## Verdicts for a model

The verdict rules are the same as SKILL.md's "Verdicts". For a model:

- **verify**: an attributed benchmark on the same host class and backend measured it ahead of the
  incumbent, or at the incumbent's speed with better card evals for the purpose.
- **hold**: its speed on the class is unpublished, comes from another class, or is a lead.
- **skip**: it is measured behind the incumbent with no eval gain, or it failed a gate.
