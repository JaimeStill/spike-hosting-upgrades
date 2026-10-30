# Models: gates, sort, and memory

How steps 7 and 8 of [SKILL.md](SKILL.md) judge a model. Every value a gate compares against
comes from the project's `docs/policy.md` or from the probe, never from this page; this page says
how to read the sources that settle each gate. A gate that needs a value the policy doesn't state
is a pause (SKILL.md, "When to pause"), and the run never fills the value in itself.

## Gate 1: the policy

Checked first, because a model the policy excludes isn't weighed further.

### Origin

The policy names what counts as an adversarial entity, the levels of a model at which involvement
excludes it, and the bar a model must clear to pass. No registry records a model's origin, so
the run builds the evidence chain itself, most authoritative source first, and cites each link
inline. "Origin" here is who was involved in a model; "build" (Quantization floor) is how the
file the host would load was made.

1. **Publisher identity.** Establish who published the model and who uploaded the file the host
   would load, which can differ for a conversion or quantization:
   - the Hugging Face organization and whether it is verified (sources.md, "Origin and build
     checks")
   - then the entity named on the publisher's own domain, linked from the organization or card
   - then that entity's legal domicile, and who owns or controls it

   Check the entity and its domicile against the foreign-adversary list, 15 CFR 791.4, read fresh
   from eCFR, and against the Consolidated Screening List (sources.md, "Origin and build
   checks"). Screen the list by running the bundled script from the project root, in one call
   for the publisher, the uploader, and every entity the publisher's documents name (item 2: a
   base model's publisher, a teacher's, a data generator's, a component's), each name quoted:

   ```sh
   .claude/skills/hosting-upgrades/scripts/screen.sh "<publisher>" "<uploader>" "<entity>" ...
   ```

   A match whose entry is the same entity (its name, country, and address agree with what the
   documents say) is detected involvement, cited by the entry's name, source list, and start
   date, and the file's date and URL; a match on a different entity that shares the name is
   noted and set aside, with why. A miss is "no match on normalized name", never clean: the row
   says which names were screened, and the rest of the chain still settles origin.
2. **The publisher's own documents.** Read the technical report or paper, and the card's base,
   distillation, and training-data sections, for every level the policy names: the base chain,
   followed through each record's `cardData.base_model` from the API record
   (`https://huggingface.co/api/models/<org>/<name>`) until a record names none; a distillation
   teacher; a synthetic-data generator, a judge, a labeler, or a translator, or a model the card
   says it was "improved using"; and each component the publisher ships (a vision or audio
   encoder, the tokenizer, a drafter, a projector). Read the training-data sections for the
   datasets too: a dataset is involvement only as the policy's data rule says (below), and the
   row lists the human-made datasets from adversary-origin institutions under "dataset sources".
   These documents are authoritative for what they disclose, and only for that.
3. **Artifact checks.** These find contradictions with what the documents say; they can't prove a
   model clean. A check that ties the model to an adversarial entity is detected involvement.
   - the config's `architectures` and `model_type`
   - the tokenizer's vocabulary size and hash, against known families. Compare two vocabularies
     by shared token IDs (the same string at the same ID), not shared strings: 50-70% string
     overlap is normal across byte-level BPE vocabularies, so string overlap alone shows nothing.
   - the chat template. A template, tool-call format, or input-placeholder layout shared with an
     excluded family is a convention, which the policy may say is not involvement (below); it
     prompts a closer look at the levels, and doesn't exclude by itself.
   - the LICENSE text, such as a Qwen or DeepSeek licence
   - the GGUF metadata from `https://huggingface.co/api/models/<id>?expand[]=gguf`: its parameter
     count (`gguf.total`) and architecture, and `general.base_model.*` where the record exposes it.
     As read 2026-10-30 the record doesn't carry `general.base_model.*`, and ggml-org's GGUF
     headers often lack it too; the base the card's model tree names (`cardData.base_model`)
     stands in for it, cited as such, and for a ggml-org file its `.src_sha` is the better pin
     (item 4).
4. **Conversions.** A conversion or quantization passes when its converter is the publisher, or
   when it is `ggml-org` with a `.src_sha` file that pins the publisher's repository and shapes
   (the parameter count and architecture) that match the publisher's model (sources.md, "Origin
   and build checks"). Any other converter's file takes item 5.
5. **Further research**, when items 1 to 4 leave the model short of the pass bar with no
   involvement found. The run researches until it reaches a definitive answer, citing each item:
   - the uploader's or converter's identity and affiliation: their Hugging Face profile
     (`https://huggingface.co/api/users/<name>/overview`), organization membership, linked
     GitHub, and employer as they state it
   - the conversion against the publisher's own weights: the GGUF's base (item 3), its parameter
     count and architecture, and tensor shapes that match the publisher's `config.json`
   - the publisher's own repositories, announcements, and documentation naming the conversion or
     the uploader
   - the uploader's other published work

   For example, a community conversion whose uploader's profile names their employer as the
   publisher, and whose shapes match the publisher's `config.json`, can pass; one with no card
   and an uploader with no stated tie to the publisher can't. When the research can't settle a
   conversion, the remedy is the project's own conversion from the publisher's weights, which
   makes the project the authority for the file. That conversion is a host step for a task to
   plan; the run names it under "Proposed changes" and never takes it.

Then judge the model, reading the policy's own limits on what counts:

- **Conventions**: what the policy says is not involvement (a chat template, a tool-call format,
  an input-placeholder layout copied from an excluded family) excludes nothing. The row names
  the convention and the family it comes from.
- **Components as shipped**: judge the model with the components its publisher ships. An
  excluded component excludes the model even when a flag would leave it out.
- **Data**: only the data the policy's data rule names excludes. A dataset that holds such a
  subset, used without saying which subsets, makes the model origin unclear. A human-made
  dataset from an adversary-origin institution goes in the row under "dataset sources".

- **Excluded on origin**: any disclosed or detected involvement at any level. The model goes in
  the section's "excluded on origin" list, with the level and the source that shows it, cited
  inline. It never reaches a verdict or the model set.
- **Passes**: the publisher is identified and not an adversarial entity, its own documents
  establish the lineage, and no check finds involvement, whether at once or after item 5's
  research. The row says the pass means "no disclosed or detected involvement", as the policy
  does, and a pass after research records the evidence that settled it.
- **Origin unclear**: no involvement found, and even item 5's research can't bring the model to
  the pass bar (the publisher can't be identified, the lineage isn't established, or the sources
  contradict each other). It goes in the "origin unclear" list beside "excluded on origin", with
  everything the run checked (each source, cited inline, and what it did or didn't establish). It
  never reaches a verdict or the model set, and it is not a pause.

### Quantization floor

The policy names three paths to the floor. The run first establishes which path a file takes,
from its build, never from the repository id or the quant label: a label such as Q4_0 or MXFP4
names the format, not how the weights were made. The build, not the label, is one of:

- the publisher's native or QAT release of the model
- the publisher's post-training checkpoint
- a third party's conversion

1. **Read the format** from the files (`siblings`: a GGUF's quant type in its name, a
   `quantization_config` in `config.json`) or from the probe's stored model.
2. **Establish how it was made.**
   - The publisher's own repository and card must say the format is QAT or native for it to be
     trained-in.
   - The GGUF's base must point where it should: a QAT build points to the QAT release, and a
     converter's post-training file points to the full-precision model. Read
     `general.base_model.*` from `?expand[]=gguf` where the record exposes it, and otherwise the
     card's `cardData.base_model` (Origin, item 3).
   - A file labelled like a trained-in format whose build is a post-training conversion takes
     path 2 or 3, not path 1.

   For example: `ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_0` is a post-training Q4_0, path 3, and
   fails; `google/gemma-4-26B-A4B-it-qat-q4_0-gguf` is QAT, path 1, and passes.
3. **Path 1, trained-in formats**, pass by name at any size when the policy names them and the
   publisher releases them as its own format of the model. The row quotes the publisher's quality
   statement for the format, cited inline. No evals test applies.
4. **Path 2, post-training checkpoints from the publisher**, pass only when the publisher
   evaluated them: the checkpoint's own card publishes evals for that format beside full
   precision, and every one of them is within the policy's margin, relative
   (|quantized - BF16| / BF16). A checkpoint whose card only points to the base model's card has
   not been evaluated. A checkpoint with no evals of its own, or with any eval outside the margin,
   takes path 3, and the row names the evals outside it, especially the ones for the purpose.
5. **Path 3, everything else**, meets the policy's floor, including any higher floor it sets for
   a kind of model or a size. Count size as the policy says (the parameters the card names as
   effective).
6. **A rule's edge** is a pause: a format the floor doesn't name, or a file whose path its
   build doesn't settle. The default is that the model fails the floor until the architect
   answers. The report still shows the gates it would otherwise pass, so the architect sees what
   the answer decides.

### A model's row

Each model's row names the exact repository and file the host would load (for a GGUF,
`<org>/<repo>` and the `.gguf` file name), its build (the publisher's native or QAT release, the
publisher's post-training checkpoint, or a third party's conversion, named), the floor path the
build gave it, and, when the model has a projector (`mmproj`), the projector's repository, file,
and precision. For a vision or audio model the projector is part of the model's precision: record
it beside the weights' format. It is not a gate of its own.

## Gate 2: fit

A model fits when its memory estimate leaves the policy's headroom of the probed ceiling free
with that model alone. Step 8 checks the set together.

### Memory estimate

Always marked **estimate**, naming this method:

- **Weights**: the snapshot size the probe's `== models ==` reports for a stored model, or the sum
  of the format's file sizes from the API (`?blobs=true`, `siblings[].size`, read with WebFetch)
  for one not stored.
  Include any projector (`mmproj`) or drafter the purpose needs.
- **KV cache**: 2 x layers x KV heads x head dimension x bytes per element x tokens, from
  `config.json`, for the configured context and slots. Count only the window for sliding-window
  layers, and nothing for recurrent (Mamba) layers beyond their fixed state. When no configuration
  is known, use the purpose's working context: the incumbent's, or the engine's default.
- **Engine reservation**: on vLLM, `--gpu-memory-utilization` x the ceiling, which replaces the
  sum above, because vLLM claims that share whatever the model needs. On llama.cpp, the weights
  and KV cache plus a compute buffer, about 1 to 2 GiB per loaded model (estimate).
- **A model serving two purposes** is estimated once, at the more demanding purpose's
  configuration: the larger context and the more slots of the two.

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

## Gate 4: the agent quality bar

For the agent purpose only. The policy's agent quality bar names evals with floors and a
tool-reliability check; a candidate's card figures must clear the floors before speed sorts it,
so a fast model that can't call tools never outranks a slower one that can.

The policy's "Reading the bar" is the rule: which card figures count against the floors, and
which verdict each outcome takes. The gate applies it as written and adds only what each row
holds:

- **The figure and its gap.** Each row that uses a card's BFCL figure cites the card, gives the
  figure, the BFCL version and category, and the card's precision, and states the gap to the
  floor's basis the policy names (another version or the full set against the fixed samples,
  native precision against the served build).
- **The measurement that would place it.** A hold names it: the missing BFCL category for a
  candidate with no card figure, or the tool-reliability check for one that clears the floors.
  Because the check has no published equivalent, no candidate leaves this gate as verify until
  the local check has run.

When the policy states no agent quality bar, the gate is a pause (SKILL.md, "When to pause").

## Sort

Models that pass every gate (for the agent purpose, the four gates, where a candidate whose card
figures clear the floors sorts though it is held for the tool-reliability check; for any other,
the first three) sort by:

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
- **take**: a new revision of the incumbent's own file (the same repository, the same build)
  that meets SKILL.md's "Verdicts" for take, its known rollback included; applied with the next
  host update.
- **hold**: its speed on the class is unpublished, comes from another class, or is a lead; or it
  is an agent candidate that needs measurement (Gate 4); or it is measured slower than the
  incumbent but ahead on the card's evals for the purpose. Measured slower but ahead on evals is
  always hold, never verify or skip: the trade is the architect's to weigh.
- **skip**: it is measured behind the incumbent with no eval gain, or it failed a gate.
