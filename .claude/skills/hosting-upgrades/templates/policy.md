# Policy

<!-- The policy document for the hosting-upgrades skill. Save it in the project as
     docs/policy.md. It holds the rules every candidate on every host must keep. When a run needs
     a value this document doesn't state, it asks. -->

## Model origin

<!-- The origin rule in its owner's words, who set it and when, and how it relates to any wider
     constraint it tightens or loosens. -->

<The rule, quoted.> This is <owner>'s rule of <date>.

<!-- Who counts as an adversarial entity: named lists the run reads fresh each time (give each
     list's source, so sources.md can say how to read it), and the kinds of entity tied to them. -->

**Adversarial entity.** Any of:

- <a country on a named list, read fresh each run>
- <an entity domiciled in, or owned or controlled from, such a country>
- <an entity on a named screening list>

<!-- The threat the rule guards against, in a sentence or two, so the levels below can be read by
     it: what an adversary's involvement could do to the served model. -->

**The threat.** <What the rule guards against.>

<!-- Optional. The bar a model must clear, in its owner's words, with its date: who may have
     been involved in the model and in the models it was directly trained on. -->

**The bar.** <The bar, quoted.>

<!-- The levels of a model at which involvement excludes it: those that give an adversary control
     over the model's behavior, such as its weights (the publisher, the base chain, a merge), a
     distillation teacher (a model whose outputs or logits the model was trained to reproduce),
     and the components in its inference path (an encoder, a projector, the tokenizer). Say how a
     teacher is read: the skill reads it by role, not by label, so a model whose outputs the
     publisher's documents present as what the model was distilled from, or as its principal
     post-training corpus, is a teacher whatever the card calls it. -->

**Excluding levels.** The model is excluded on any disclosed or detected involvement at any of
these:

- <level>

<!-- Optional. The levels at which involvement is recorded and doesn't exclude, such as a model
     that only transformed data (punctuation restoration, translation, filtering, quantization
     calibration), a component outside the output path (a speculative-decoding drafter), and a
     convention (a chat template, a tool-call format, an input-placeholder layout). Say how the
     run treats a preset that loads a recorded component of adversary origin: the skill flags it
     as a host configuration fault, hold, with removing it as the fix, and the model stays
     eligible. Delete it if every involvement excludes. -->

**Recorded levels.** <What is recorded in a model's row without excluding it.>

<!-- How the run judges a model's components: as the publisher ships them, or as the project
     would configure them. -->

**Components.** A model is judged <with the components its publisher ships, or as configured>.

<!-- Which training data counts as involvement, and which the run records in the model's row
     under "dataset sources" instead, such as adversary-generated data that is one dataset in a
     training mix (synthetic SFT data, reasoning traces, preferences), a human-made dataset from
     an adversary-origin institution, or data an adversary-origin model only transformed. Say why
     the line is drawn there, and date each refinement that moves it. -->

**Dataset sources.** <Which data excludes a model, and which the run records instead.>

<!-- Optional. How the run finds a model's teachers: the publisher documents it reads (a
     disclosure file the card points to, say), and how it reads a teacher the card doesn't name.
     The skill passes an unnamed teacher only when the publisher's own documents say it is a
     checkpoint from their own pipeline, and otherwise holds the model out as "origin unclear",
     unless this says otherwise. -->

**Finding the teachers.** <What the run reads, and how it treats an unnamed teacher.>

<!-- Optional. Whether dealing with an adversarial publisher or uploader excludes a model whatever
     its levels show. -->

**Compliance.** <Whether an adversarial publisher or uploader excludes the model outright.>

<!-- What a model must show to pass, and what a pass does and doesn't claim. -->

**The pass bar.** A model passes only when <the publisher, lineage, and check conditions>.

<!-- How the run treats a model the evidence chain leaves short of the pass bar: whether it
     researches further first, and what that research looks at (the uploader's identity, the
     conversion's shapes and source pin against the publisher's weights, the tokenizer by shared
     IDs). -->

**Further research.** When the evidence chain leaves a model short of the pass bar with no
involvement found at an excluding level, the run researches <what> before deciding.

<!-- How the run reads a model the research can't settle. The skill holds it out as "origin
     unclear", without a pause, unless this says otherwise. -->

**Origin unclear.** A model the research can't bring to the pass bar is held out as "origin
unclear". The report lists it beside "excluded on origin", with what the run checked.

## Artifact integrity

<!-- Which file formats the host may load, and how the run treats a model that runs code when
     loaded (a pickle checkpoint, trust_remote_code). The skill reads a file's format from what it
     is, never from its extension: a file stored on the host by the probe's read of its first
     bytes, and any other file by the Hugging Face record's per-file scan where that names the
     format, or by a ranged read of its first bytes (the skill's scripts/magic.sh). Say what a
     file none of the reads settles does. -->

<The formats that pass, how each file's format is read, and what fails unless its code is
accepted below.>

<!-- Optional. Scanner messages that may appear under an overall "safe" status: those recorded
     and passed, each by its exact name, and how the run treats any other. The skill treats an
     unnamed one as a rule's edge, a pause, with the file failing until the owner answers. -->

**Scanner messages under "safe".** <The messages that pass by name, and how any other is
treated.>

<!-- Optional. Whether the run compares a GGUF's embedded chat template with the publisher's
     template (tokenizer_config.json), which the engine's renderer executes, and which differences
     fail: the skill records each difference with the lines quoted, and one that adds text the
     model sees (a system prompt, instructions) fails integrity. -->

**The chat template.** <What the run compares, and which differences fail.>

<!-- The code the architect has reviewed and accepts, which only the architect edits: one entry
     per repository, exact revision, and file reviewed. A model whose code isn't listed fails
     artifact integrity, and the run proposes the acceptance. Keep the list, with "None.", when
     it is empty. -->

**Accepted code.** <Who edits the list.> Each is one line: `<repository>` at `<revision>`,
`<file>`, accepted `<date>`.

- None.

## Quantization floor

<!-- The floor as its source states it, quoted, then how the run reads it as paths. The skill
     knows three, and a file's build decides which it takes, not its label: formats trained in by
     the publisher, which pass by name; the publisher's post-training checkpoints, which pass
     within an evals margin; and everything else, which meets a floor. Leave a path out if the
     policy has no such path. Name any build that resembles a trained-in format but isn't one (a
     quantization-aware distillation build, say), and the path it takes. -->

<The floor, quoted from its source.>

**Reading: paths.** A format meets the floor by one of these paths:

1. **Trained-in formats** pass by name, at any size, when the publisher releases them as its own
   format of the model: <named formats>.
2. **Post-training checkpoints from the publisher** (<formats>) pass only when every eval the
   checkpoint's card reports is within <margin> of its <full precision> score, relative.
3. **Everything else** goes no lower than <floor>, and <model kinds and sizes> run at
   <higher floor> or better.

<!-- How the run counts a model's size against a size threshold, if the floor sets one. -->

**Reading: a model's size.** Size is counted by <which parameters count>.

## Agent quality bar

<!-- Optional, for a host with an agent purpose. The evals an agent candidate must clear before
     speed sorts it, each with its floor and where the floor comes from, and the tool-reliability
     check it must pass. Say which published figures count against a floor and the gap each row
     states between such a figure and the floor's basis; then, under "Reading the bar", the
     verdict for each outcome: a figure under a floor, no figure, and figures that clear the
     floors while a check with no published equivalent is unmeasured.
     Delete the section if no host serves an agent. -->

**Named evals and their floors.**

| Eval | Measure | Floor |
|---|---|---|
| <eval> | <measure> | <floor> |

<Where the floors come from, which published figures count against them, and the gap a row
states.>

**The tool-reliability check.** <The harness, the trials, and the pass bar.>

**Reading the bar.** <The verdict for each outcome.>

## Agent session context

<!-- Optional, for a host with an agent purpose. The least context one agent session must reach,
     and what the run aims at beyond it (the model's native context, as memory allows). The skill
     computes each agent preset's per-session context (ctx-size / parallel with a split KV cache,
     the shared pool with a unified one) and holds a preset under the minimum. Delete the section
     if no host serves an agent. -->

Each agent session must reach at least <tokens> tokens of context, aiming at <target> where
memory allows.

## Memory headroom

<!-- How much of the GPU-reachable ceiling a loaded model set must leave free, as a share or an
     absolute figure, who adjusts it, and how it is held: by sizing the model set, where a
     container memory limit can't hold it (memory a GPU allocator takes outside the container's
     cgroup, say). -->

A model set must leave at least <share>% of the host's GPU-reachable ceiling free.
