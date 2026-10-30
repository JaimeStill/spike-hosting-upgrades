# Policy

<!-- The policy document for the hosting-upgrades skill. Save it in the project as
     docs/policy.md. It holds the rules every candidate on every host must keep. When a run needs
     a value this document doesn't state, it asks. -->

## Model origin

<!-- Which model origins are excluded or restricted, and whether a fine-tune takes its base's
     origin. -->

Models of <origin> origin are excluded outright. A fine-tune takes its base model's origin.

<!-- How the run reads a model whose base no source establishes. The skill holds it out without
     a pause unless this says otherwise; conflicting origin evidence is always a pause. -->

**Reading: origin unclear.** A model whose base can't be established from <its card, its API
record, or its publisher's repository or paper> is held out as "origin unclear", without a pause.
The report lists it beside "excluded on origin", with what the run checked.

## Quantization floor

<!-- The lowest quantization each kind of model may run at, and which publisher-evaluated formats
     are accepted below it. -->

A format is accepted when its publisher evaluated it (<formats>). Otherwise nothing goes below
<floor>, and <model kinds> run at <higher floor> or better.

<!-- How the run reads the margin an evaluated format must keep to full precision, if the floor
     sets one. -->

**Reading: within <margin> of <full precision>.** The floor's "card evals within <margin> of
<full precision>" means every eval the card reports for the checkpoint is within <margin> of its
<full precision> score, relative.

## Memory headroom

<!-- How much of the GPU-reachable ceiling a loaded model set must leave free, as a share or an
     absolute figure, and who adjusts it. -->

A model set must leave at least <share>% of the host's GPU-reachable ceiling free.
