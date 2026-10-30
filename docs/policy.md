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
- a synthetic-data generator, or a model the card says the model was "improved using"
- a component: a vision or audio encoder, the tokenizer, a drafter, or a projector

**The pass bar.** A model passes only when its publisher is an identified entity that is not an
adversarial entity, the publisher's own documents establish its lineage, and no check finds
involvement at any level. A pass means "no disclosed or detected involvement", and no more: no
public source certifies a model's training data, and undisclosed synthetic data is common.

**Further research.** The architect decided on 2026-10-30 that an unestablished origin is not an
immediate hold-out. When the evidence chain leaves a model short of the pass bar with no
involvement found, the run researches further to reach a definitive answer, citing each item:

- the uploader's or converter's identity and affiliation: their Hugging Face profile,
  organization membership, linked GitHub, and employer as they state it
- the conversion against the publisher's own weights: the GGUF `general.base_model.*`, the
  parameter count, the architecture, and tensor shapes that match the publisher's config
- the publisher's own repositories, announcements, and documentation naming the conversion or
  the uploader
- the uploader's other published work

The model passes when that research meets the pass bar, and its row records the evidence that
settled it. For example, `mrutkows/granite-embedding-english-r2-GGUF:BF16` passed as IBM-origin:
the run's further research traced the uploader and the conversion to IBM's model.

**Origin unclear.** Only when the further research can't settle it is the model held out as
"origin unclear", without a pause. It never reaches a verdict or a model set. The report lists it
beside "excluded on origin", with everything the run checked.

## Quantization floor

As `ai-hosting.md` states it, under "The rules":

> The quantization floor: a format is accepted when its publisher evaluated it (native MXFP4, a
> QAT Q4_0, or an NVFP4 or FP8 checkpoint whose card evals are within about 1% of BF16).
> Otherwise nothing goes below Q5_K_M or FP8, and embedding, ASR, and dense models under 8B run at
> Q8_0 or FP8 or better.

**Reading: three paths.** The evals clause attaches to the post-training formats only. A format
meets the floor by one of three paths:

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

## Memory headroom

A model set must leave at least **10% of the host's GPU-reachable ceiling** free once every
model in it is loaded at its configured context and slots: on a 112 GiB ceiling, 11.2 GiB. The
ceiling is what the probe reports (the GTT total on AMD, the system memory on GB10).

The value is the architect's to adjust; until then it is the session's starting figure.
