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

<!-- The levels of a model at which involvement excludes it: those that give an adversary control
     over the model's behavior, such as its weights (the publisher, the base chain, a merge), its
     behavioral training signal (a distillation teacher, a generator of the responses or traces it
     trained on), and the components in its inference path (an encoder, a projector, the
     tokenizer). -->

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

<!-- Which training data counts as involvement, a subset inside a larger dataset included. Say how
     the run records data that doesn't count, how it reads a model whose relevant subsets can't be
     told apart, and why the line is drawn there. -->

**Data.** <Which data excludes a model, and which the run records instead.>

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
     is (the Hugging Face record's file metadata, or the file's first bytes), never from its
     extension. -->

<The formats that pass, and what fails unless its code is accepted below.>

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
     policy has no such path. -->

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
     absolute figure, and who adjusts it. -->

A model set must leave at least <share>% of the host's GPU-reachable ceiling free.
