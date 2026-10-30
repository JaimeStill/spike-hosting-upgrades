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

<!-- The levels of a model at which involvement excludes it, such as the publisher, the uploader,
     the base chain, a distillation teacher, a synthetic-data generator, a judge, a labeler, a
     translator, and a component. -->

**Levels.** The model is excluded on any disclosed or detected involvement at any of these:

- <level>

<!-- Optional. What doesn't count as involvement, such as a chat template, a tool-call format, or
     an input-placeholder layout copied from an excluded family. Delete it if every resemblance
     counts. -->

**Conventions are not involvement.** <What a model may share with an excluded family without
being excluded.>

<!-- How the run judges a model's components: as the publisher ships them, or as the project
     would configure them. -->

**Components.** A model is judged <with the components its publisher ships, or as configured>.

<!-- Which training data counts as involvement: such as data an excluded model generated,
     labelled, judged, or translated, a subset inside a larger dataset included. Say how the run
     records data that doesn't count, how it reads a model whose relevant subsets can't be told
     apart, and why the line is drawn there. -->

**Data.** <Which data excludes a model, and which the run records instead.>

<!-- What a model must show to pass, and what a pass does and doesn't claim. -->

**The pass bar.** A model passes only when <the publisher, lineage, and check conditions>.

<!-- How the run treats a model the evidence chain leaves short of the pass bar: whether it
     researches further first, and what that research looks at (the uploader's identity, the
     conversion's shapes and source pin against the publisher's weights, the tokenizer by shared
     IDs). -->

**Further research.** When the evidence chain leaves a model short of the pass bar with no
involvement found, the run researches <what> before deciding.

<!-- How the run reads a model the research can't settle. The skill holds it out as "origin
     unclear", without a pause, unless this says otherwise. -->

**Origin unclear.** A model the research can't bring to the pass bar is held out as "origin
unclear". The report lists it beside "excluded on origin", with what the run checked.

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
     check it must pass. Say what makes a published figure comparable (the same benchmark,
     version, and category). A candidate with no comparable figure is held, "needs measurement".
     Delete the section if no host serves an agent. -->

**Named evals and their floors.**

| Eval | Measure | Floor |
|---|---|---|
| <eval> | <measure> | <floor> |

<Where the floors come from, and what makes a published figure comparable.>

**The tool-reliability check.** <The harness, the trials, and the pass bar.>

## Memory headroom

<!-- How much of the GPU-reachable ceiling a loaded model set must leave free, as a share or an
     absolute figure, and who adjusts it. -->

A model set must leave at least <share>% of the host's GPU-reachable ceiling free.
