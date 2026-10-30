# Policy

The rules the hosting-upgrades skill (`.claude/skills/hosting-upgrades/`) applies to every
candidate on every host. A run reads this document and never writes to it; when a step needs a
value this document doesn't state, the run stops and asks.

## Model origin

In the architect's words, of 2026-10-30:

> Any involvement of a Chinese AI lab or other adversarial entity to the USA at any level of the
> model should exclude it from consideration.

This is the architect's rule of 2026-10-30, and it is stricter than the workspace's constraint
(`ai-strategy.md`, "Constraint: model origin"), which avoids such models where an alternative
serves. The spike excludes them, and excludes any model they had a hand in.

**Adversarial entity.** Any of:

- a country on the Commerce Department's foreign-adversary list, 15 CFR 791.4, which the run
  reads fresh from eCFR each time and cites with its read date. As read on 2026-10-30, it lists
  the People's Republic of China, including Hong Kong and Macau; Cuba; Iran; North Korea; Russia;
  and the Maduro regime of Venezuela. The list can change, so the run's reading, not this one,
  decides.
- any entity domiciled in, or owned or controlled from, such a country
- any entity on the trade.gov Consolidated Screening List

**Levels.** The model is excluded on any disclosed or detected involvement of an adversarial
entity at any of these levels:

- the publisher, and the uploader of a conversion or quantization
- every ancestor in the base chain
- a distillation teacher
- a synthetic-data generator, a judge, a labeler, or a translator, or a model the card says the
  model was "improved using"
- a component: a vision or audio encoder, the tokenizer, a drafter, or a projector

**Conventions are not involvement.** A chat template, a tool-call format, or an
input-placeholder layout copied from an adversary-origin family doesn't exclude a model. These
are conventions, not weights or training signal: a model that formats its tool calls like
GLM-4.5, or places its image tokens like Qwen3-VL, is judged by its levels above, not by its
format.

**Components are judged as shipped.** A model is judged with the components its publisher ships
it with, not as we might configure it. A model that ships an excluded component is excluded,
even when a configuration flag would leave that component out.

**Data.** Only data an adversary-origin model generated, labelled, judged, or translated excludes
a model, and that includes such a subset inside a larger dataset. The rule follows the threat: a
model compromised on purpose, through content an adversary's model chose token by token.

- A human-made dataset from an adversary-origin institution doesn't exclude a model. The run
  records it under "dataset sources" in the model's row.
- A model that trained on a dataset holding a subset an adversary-origin model made, and that
  doesn't say which subsets it used, is "origin unclear": its relevant subsets can't be told
  apart.

The reason: excluding every adversary-authored dataset would punish disclosure. Nearly every
model trains on public datasets and few cards list them, so such a rule would exclude the
publishers who disclose their data and pass the ones who stay silent.

**The pass bar.** A model passes only when its publisher is an identified entity that is not an
adversarial entity, the publisher's own documents establish its lineage, and no check finds
involvement at any level. A pass means "no disclosed or detected involvement", and no more: no
public source certifies a model's training data, and undisclosed synthetic data is common.

**Further research.** The architect decided on 2026-10-30 that an unestablished origin is not an
immediate hold-out. When the evidence chain leaves a model short of the pass bar with no
involvement found, the run researches further to reach a definitive answer, citing each item:

- the uploader's or converter's identity and affiliation: their Hugging Face profile,
  organization membership, linked GitHub, and employer as they state it
- the conversion against the publisher's own weights: the parameter count, the architecture, and
  tensor shapes that match the publisher's config; for a ggml-org conversion, the `.src_sha` file
  that pins the publisher's repository, since ggml-org's GGUF headers often lack
  `general.base_model.*`
- the tokenizer against the publisher's, compared by shared token IDs, not shared strings:
  50-70% string overlap is normal across byte-level BPE vocabularies
- the publisher's own repositories, announcements, and documentation naming the conversion or
  the uploader
- the uploader's other published work

The model passes when that research meets the pass bar, and its row records the evidence that
settled it.

**Origin unclear.** Only when the further research can't settle it is the model held out as
"origin unclear", without a pause. It never reaches a verdict or a model set. The report lists it
beside "excluded on origin", with everything the run checked.

For example, `mrutkows/granite-embedding-english-r2-GGUF:BF16`, framework's embedding model on
2026-10-30, is origin unclear: its repository has no card, and the conversion isn't the
publisher's. The remedy is the project's own conversion from IBM's weights,
`ibm-granite/granite-embedding-english-r2`, which makes the project the authority for the file.
That conversion is a host step for a task to plan; a run names it and never takes it.

## Quantization floor

As `ai-hosting.md` states it, under "The rules":

> The quantization floor: a format is accepted when its publisher evaluated it (native MXFP4, a
> QAT Q4_0, or an NVFP4 or FP8 checkpoint whose card evals are within about 1% of BF16).
> Otherwise nothing goes below Q5_K_M or FP8, and embedding, ASR, and dense models under 8B run at
> Q8_0 or FP8 or better.

**Reading: three paths.** The evals clause attaches to the post-training formats only. A format
meets the floor by one of three paths, and the file's build decides which, not its label:

1. **Trained-in formats** pass by name, at any size, when the publisher releases them as its own
   format of the model. These are native formats, such as gpt-oss's MXFP4, and quantization-aware
   training (QAT), such as Google's Gemma 4 QAT Q4_0. The report quotes the publisher's quality
   statement for the format.
2. **Post-training checkpoints from the publisher** (NVFP4, FP8, a GGUF the publisher made) pass
   only when every eval the checkpoint's card reports is within about 1% of its BF16 score,
   relative (|quantized - BF16| / BF16). A checkpoint with any eval outside it, or with no evals
   of its own, takes path 3.
3. **Everything else**, which is community and converter quantizations and post-training
   quantizations with no evals, goes no lower than Q5_K_M or FP8. Embedding models, ASR models,
   and dense models under 8B run at Q8_0 or FP8 or better.

**Reading: a model's size.** Size is counted by the parameters the card names as effective.
Gemma 4 E4B is "4.5B effective (8B with embeddings)", and its per-layer embeddings are lookups,
not compute, so it counts as under 8B.

## Agent quality bar

A candidate for the agent purpose must clear this bar before speed sorts it: an agent model that
is fast but can't call tools is no upgrade. The floors below are **proposed, for the architect to
confirm in the validation run**. They are spike-model-hosting's bars for the agent role
(spike-model-hosting `docs/pool.md`, whose profiles name "set A's BFCL bars"; the values are in
`evaluation/bars.toml` and `docs/findings/baseline.md`, "Quality: each tier's two scores, spread
and bar"): set A's gpt-oss-120b, measured twice on llama.cpp b11715, less its two-run spread.

**Named evals and their floors.**

| Eval | Measure | Floor | Set A's two runs |
|---|---|---|---|
| BFCL single-turn | accuracy | at least 0.630 | 0.65, 0.69 |
| BFCL multi-turn | accuracy | at least 0.325 | 0.40, 0.35 |

**The floors' basis.** spike-model-hosting measured these on fixed samples: BFCL single-turn
100 and multi-turn 20, from Gorilla at `dac44e7`, drawn with seed 20261016, at the card's
sampling, on the served build.

**What counts against a floor** (the architect's decision, 2026-10-30). A card's published BFCL
figure for the matching category counts: BFCL v3 or v4, single-turn against the single-turn
floor and multi-turn against the multi-turn floor, at the card's own precision. A card's BFCL
overall score, or another category, does not count. A card figure is not a measurement on the
floors' basis, so each row that uses one states the gap: the floor is gpt-oss-120b's score on
spike-model-hosting's 100- and 20-item samples (Gorilla `dac44e7`, seed 20261016), while the
card may use another BFCL version or the full set, and measures the model at its native
precision rather than the build the host would serve.

**The tool-reliability check.** The model, on the host's engine, fits the consumer harness:
`conform` pass^5 through Pi, every capability that applies passing 5 of 5 trials, with 0 invalid
requests (an invalid request is one the server can't parse, such as a 500 "does not match the
expected peg-native format"). It is spike-model-hosting's harness-fit bar
(spike-model-hosting `docs/findings/tool-reliability.md`, "Harness fit on b11715: set A's
baseline"), which set A's agent model met in both baseline runs. An open report on the engine's
tracker that its parser rejects the model's tool calls fails the check. The check has no
published equivalent: no card or benchmark reports it, so only a local run measures it.

**Reading the bar.** This is the rule; the skill applies it and points here.

- A candidate whose card figure is under a floor fails the bar: skip, with the eval, the figure,
  and the gap.
- A candidate with no card BFCL figure for a named eval is hold, "needs measurement", and the
  row names the eval.
- A candidate whose card figures clear every floor is sorted by speed with the others that do.
  It is still hold, "needs the tool-reliability measurement", never verify, until the local
  check runs, because the check is always unmeasured until then. A candidate whose local check
  has run and passed clears the bar; one whose check fails, or that an open parser report
  covers, fails it: skip.

## Memory headroom

A model set must leave at least **10% of the host's GPU-reachable ceiling** free once every
model in it is loaded at its configured context and slots: on a 112 GiB ceiling, 11.2 GiB. The
ceiling is what the probe reports (the GTT total on AMD, the system memory on GB10).

The value is the architect's to adjust; until then it is the session's starting figure.
