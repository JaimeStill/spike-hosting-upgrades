# The benchmark scenarios

This page gives the load and reasoning of each GuideLLM scenario in `bench/`, one section per file,
and of the conform profiles in `bench/conform/`. Each file's header points at its section with a
`See` line. The skill's rules (`.claude/skills/hosting-upgrades/rules.md`, "Cells") say how the
cells are run and read.

## What every scenario shares

Every scenario runs from the repository root and takes its target, the router's URL, from
`GUIDELLM__SPEC__BACKEND__TARGET`, which the architect sets, so no address is committed
(`spike-model-engines/docs/findings/bench-gb10-container.md`, "Method"). The anchors name their
model, tokenizer, and JSON's path in the file. Every other scenario is engine-neutral: the model,
its tokenizer, and the JSON's path are given on the command line, so one file serves both engines.

Whenever a scenario sets output_tokens, GuideLLM sends the cap with ignore_eos, so every request
generates its full output: as max_tokens for the anchors, and as max_completion_tokens for the
rest.

## anchor-a

Anchor cell A: gpt-oss-120b MXFP4 on the llama.cpp router, 1 stream sending 8 requests back to
back, each 512 synthetic prompt tokens and exactly 256 output tokens
(`spike-model-engines/docs/findings/llama-gb10-container.md`).

The router serves GGUF files, which carry no tokenizer GuideLLM reads: the prompt is cut to its 512
tokens by the model's upstream tokenizer, `openai/gpt-oss-120b`, fetched from Hugging Face.

## anchor-b

Anchor cell B: gpt-oss-120b MXFP4 on the llama.cpp router, 4 streams sending 32 requests in all, 8
each back to back, each 512 synthetic prompt tokens and exactly 256 output tokens: one stream per
slot of the preset's 4 (`spike-model-engines/docs/findings/llama-gb10-container.md`).

Its tokenizer is anchor A's ([anchor-a](#anchor-a)).

## shape-a

Shape cell A: one Gemma 4 model, 1 stream sending 8 requests back to back, each 512 synthetic
prompt tokens and exactly 256 output tokens: anchor cell A's load. One file serves both engines,
every Gemma 4 shape, and the quantization pairs.

Gemma 4 reasons only when its chat template is asked to, so every request asks
(`chat_template_kwargs.enable_thinking`), as vLLM's anchors A' and B' do: the 256 tokens are
reasoning first, then the reply.

## shape-b

Shape cell B: one Gemma 4 model, 4 streams sending 32 requests in all, 8 each back to back, each
512 synthetic prompt tokens and exactly 256 output tokens: anchor cell B's load, one stream per
slot of the preset's 4 (vLLM: per sequence of its 4).

Every request asks for reasoning, as shape A's do ([shape-a](#shape-a)).

## long-a

Long-prompt cell A: one agent model, 1 stream sending 4 requests back to back, each 8,192 synthetic
prompt tokens and exactly 512 output tokens: the agent floors' 8k prompt
(`spike-model-hosting/evaluation/floors.toml`, "[agent]"), for single-stream prefill and its TTFT.
A section must give each slot more than 8,704 tokens and the model's chat template, so framework's
4-slot gpt-oss section (8,192 a slot) can't hold it. No request asks for reasoning: the template's
default stands, and every request generates its full 512 either way.

## long-b

Long-prompt cell B: one agent model, 4 streams sending 16 requests in all, 4 each back to back, each
8,192 synthetic prompt tokens and exactly 512 output tokens: the agent floors' agentic streams
(`spike-model-hosting/evaluation/floors.toml`, "[agent]", stream_decode_tok_s), each judged by its
own decode, never their sum. A section must give each of 4 slots more than 8,704 tokens and the
model's chat template. As in long-a, no request asks for reasoning.

## sweep

Concurrency sweep: gpt-oss-120b on 16 slots, 512 synthetic prompt tokens and exactly 256 output
tokens a request, at 1, 4, 16, and 32 streams, each level sending requests back to back for 60 s:
four benchmarks in one run, one JSON. At 32 streams half the requests wait for a slot, which is
what the sweep records past the slots.

A level stops sending at 60 s; the requests then in flight are cancelled and counted incomplete,
so each level's figures cover its 60 s.

## Vision requests

The vision cells read their two sources side by side, one row of each a request: the text, cut
to its 200 tokens by the tokenizer, and the image, which carries the request's output tokens, 64.
The cells need GuideLLM's vision extra, which mise.bench.toml installs.

## vision-a

Vision cell A: gemma-4-26B-A4B, 1 stream sending 8 requests back to back, each one synthetic 720p
JPEG (1280 x 720, GuideLLM's default gradient at quality 85, different in every request) beside 200
synthetic text tokens, and exactly 64 output tokens ([Vision requests](#vision-requests)).

## vision-b

Vision cell B: gemma-4-26B-A4B, 4 streams sending 32 requests in all, 8 each back to back, each one
synthetic 720p JPEG (1280 x 720, GuideLLM's default gradient at quality 85, different in every
request) beside 200 synthetic text tokens, and exactly 64 output tokens: one stream per slot of the
preset's 4 ([Vision requests](#vision-requests)).

## Audio requests

[audio-a](#audio-a), [audio-b](#audio-b), and their budget-0 variants build their requests the
same way. The cells need GuideLLM's audio extra, which mise.bench.toml installs.

- **The reply cap.** A transcript is as long as its clip, so no request sets output tokens or
  ignore_eos; `max_tokens` caps each reply, sent as max_completion_tokens, should the model not
  stop.
- **The sources.** The two sources are read side by side, one row of each a request, and the run
  stops when either runs out. Source 0 is the prompt, from Gemma 4's card ("Transcribe the
  following speech segment in {LANGUAGE} into {LANGUAGE} text. ... Only output the
  transcription, with no newlines."), once a request. Source 1 is
  hf-internal-testing/librispeech_asr_dummy, 73 clips from LibriSpeech's clean validation split,
  about 9 MB fetched once from Hugging Face; the 32 the cells read run 1.7 to 29.4 s, within the
  card's 30-second audio limit.
- **The columns.** Only the prompt and the clip: LibriSpeech's own text column is the reference
  transcript, which the mapper's defaults would otherwise send as the prompt.
- **The encoding.** Every clip is re-encoded as 16 kHz mono WAV, which both engines' input_audio
  accepts; the source is FLAC, which llama.cpp's doesn't.

## audio-a

ASR cell A: gemma-4-E4B's audio through chat, 1 stream sending 8 requests back to back. Each
request is one LibriSpeech clip with the model card's transcription prompt, and the reply ends when
the model stops, at most 256 tokens ([Audio requests](#audio-requests)).

## audio-b

ASR cell B: gemma-4-E4B's audio through chat, 4 streams sending 32 requests in all, 8 each back to
back, one stream per slot of the preset's 4. Each request is one LibriSpeech clip with the model
card's transcription prompt, and the reply ends when the model stops, at most 256 tokens
([Audio requests](#audio-requests)).

## audio-a-budget0

ASR cell A with reasoning off: bench/audio-a.yaml, unchanged but for one field every request sends,
`reasoning_budget_tokens: 0`. llama.cpp (b11960 and later) then forces the end of any thought block
the model opens, at once, so a reply is the transcript alone. It tests whether that keeps Gemma 4
E4B QAT from reasoning unprompted on a transcription (verify-framework,
[docs/findings/verify-framework.md](findings/verify-framework.md), "Verdict", "Run 4"). The rest of
the file is audio-a.yaml's ([audio-a](#audio-a)).

## audio-b-budget0

ASR cell B with reasoning off: bench/audio-b.yaml, unchanged but for the field
[audio-a-budget0](#audio-a-budget0) adds, `reasoning_budget_tokens: 0`, and for the same test. The
rest of the file is audio-b.yaml's ([audio-b](#audio-b)).

## Conform profiles

`bench/conform/strix-halo.toml` (framework) and `bench/conform/nvidia-cuda.toml` (gb10-1) are each a
host's conform profile, in spike-model-hosting's profile schema
(`spike-model-hosting/hosting/profile/profile.go`), modelled on its
`spike-model-hosting/devices/strix-halo/profile.toml`. Its one use is conform, the agent bar's
tool-reliability check ([docs/policy.md](policy.md), "Agent quality bar"), which the measure mode's
candidate screen runs from spike-model-hosting's clone with -profile naming the file
(`.claude/skills/hosting-upgrades/measure.md`, steps 4 and 7). conform reads a profile's set alone:
its models, which it checks the router has loaded, and its roles, the model each of the consumers'
requests goes to. So each model's id is its section's name in the router's preset,
`spike-model-engines/host/llama-preset/models.ini`, as spike-model-engines' screen commit (4d5e114)
has it; main has since dropped the Gemma agent section, so conform on this profile needs that
section restored. The set is the Gemma set: 26B-A4B QAT's agent section for chat and vision, E4B
Q8_0 for audio, and granite BF16 for embeddings.

The profile is never rendered. The router serves spike-model-engines' preset, not this file:
`profile render presets` would give a wrong one. Each model's c is one slot's context, since every
section's KV cache is split across its slots (kv = "per-slot") and the loader bounds c by the
card's context. The section's own c, its slots' total, is in each c_reason.

Each is validated read-only from spike-model-hosting's clone, as the measure mode gives it:

```sh
mise exec -- go run ./hosting/cmd/profile validate <the file's absolute path>
```

### The keys

- **kv.** Every section in the preset leaves its KV cache split: setting parallel turns llama.cpp's
  kv-unified auto default off, and no section the set loads sets kv-unified.
- **[engine].** The image flavor and the floor build the profile was written on.
- **[defaults].** The schema requires these; every model sets its own c and slots, and no other key
  reads them. gpu_layers 999 is the preset's n-gpu-layers = all; checkpoint_min_step is llama.cpp's
  default, 8192, which the preset leaves as it is; c is spike-model-hosting's default for a model
  without its own section.
- **[[sets]].** The Gemma set, the one the keep rule weighs: Gemma 4 26B-A4B QAT serving agent and
  vision, with gpt-oss-120b and the vision section unloaded.
- **[sets.memory_budget].** Estimated, never measured here (each host's figures below). The
  screen's memory read after the long B cell is the measurement; it is recorded in the screen
  record, not here.
- **licence.** The card's license metadata (apache-2.0); for the two Gemma 4 models it links
  Google's Gemma 4 licence page, https://ai.google.dev/gemma/docs/gemma_4_license.
- **roles.** gemma-4-26B-A4B-QAT-Q4_0-agent has vision through its mmproj, which the router loads
  beside the weights. gemma-4-E4B has audio and vision through its mmproj; the set sends it audio
  alone.
- **card_context.** The card's context: 256K for gemma-4-26B-A4B, 128K for gemma-4-E4B, and the
  8192-token context for granite.
- **dims.** Granite's 768-dimension output, as its card states.

### strix-halo

framework's profile, the strix-halo host class. Its llama.cpp is ggml's Vulkan image at b11960
([docs/findings/verify-framework.md](findings/verify-framework.md)).

The memory budget: the agent section about 56 GiB with its weights ([the screen
Decisions][screen-decisions]; its parts, from the screen brief: 37.5 GiB of full-attention KV at
20,480 bytes a token over c = 1966080, and 15.63 GB of weights and projector), E4B Q8_0 9.7 GiB and
granite about 1.5 GiB (`spike-model-hosting/docs/pool.md`'s budgets). 56 + 9.7 + 1.5 = 67.2 GiB,
68,813 MiB. The pool is framework's GTT, 112.0 GiB
([docs/reports/framework/2026-10-30-2.md](reports/framework/2026-10-30-2.md), Inventory).

### nvidia-cuda

gb10-1's profile, the nvidia-cuda host class, on ggml's CUDA image. Its `min_build` b12063 is the
build the profile was written on ([docs/findings/verify-gb10-1.md](findings/verify-gb10-1.md));
gb10-1 has since moved to b12098 ([the gb10-1 screen](screens/gb10-1/2026-11-05.md), "The engine
move").

The memory budget: the agent section about 59 GiB with its weights ([the screen
Decisions][screen-decisions]; its parts, from the screen brief: 40 GiB of full-attention KV at
20,480 bytes a token over c = 2097152, and 15.63 GB of weights and projector), E4B Q8_0 9.7 GiB and
granite about 1.5 GiB (`spike-model-hosting/docs/pool.md`'s budgets). 59 + 9.7 + 1.5 = 70.2 GiB,
71,885 MiB. The pool is gb10-1's system memory, MemTotal 127,533,180 kB, 124,544 MiB
([docs/reports/gb10-1/2026-10-31.md](reports/gb10-1/2026-10-31.md), Inventory).

[screen-decisions]: https://github.com/JaimeStill/spike-hosting-upgrades/blob/7a7bfeb65de35b1b227cc2b4fee985d763fa53a9/context/goals/experiment.hosting.spike-hosting-upgrades.md
