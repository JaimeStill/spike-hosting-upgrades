# Policy

<!-- The policy document for the hosting-upgrades skill. Save it in the project as
     docs/policy.md. It holds the rules every candidate on every host must keep. When a run needs
     a value this document doesn't state, it asks. -->

## Model origin

<!-- Which model origins are excluded or restricted, and whether a fine-tune takes its base's
     origin. -->

Models of <origin> origin are excluded outright. A fine-tune takes its base model's origin.

## Quantization floor

<!-- The lowest quantization each kind of model may run at, and which publisher-evaluated formats
     are accepted below it. -->

A format is accepted when its publisher evaluated it (<formats>). Otherwise nothing goes below
<floor>, and <model kinds> run at <higher floor> or better.

## Memory headroom

<!-- How much of the GPU-reachable ceiling a loaded model set must leave free, as a share or an
     absolute figure, and who adjusts it. -->

A model set must leave at least <share>% of the host's GPU-reachable ceiling free.
