# Policy

The rules the hosting-upgrades skill (`.claude/skills/hosting-upgrades/`) applies to every
candidate on every host. A run reads this document and never writes to it; when a step needs a
value this document doesn't state, the run stops and asks.

## Model origin

Every model of Chinese origin is excluded outright, whatever it would serve. A fine-tune takes its
base model's origin, so a fine-tune of a Chinese-origin base is excluded too, wherever the
fine-tune was published.

This is stricter than the workspace's constraint (`ai-strategy.md`, "Constraint: model origin"),
which avoids such models where an alternative serves; the spike excludes them, as the `skill`
task's brief decided.

## Quantization floor

As `ai-hosting.md` states it, under "The rules":

> The quantization floor: a format is accepted when its publisher evaluated it (native MXFP4, a
> QAT Q4_0, or an NVFP4 or FP8 checkpoint whose card evals are within about 1% of BF16).
> Otherwise nothing goes below Q5_K_M or FP8, and embedding, ASR, and dense models under 8B run at
> Q8_0 or FP8 or better.

## Memory headroom

A model set must leave at least **10% of the host's GPU-reachable ceiling** free once every
model in it is loaded at its configured context and slots: on a 112 GiB ceiling, 11.2 GiB. The
ceiling is what the probe reports (the GTT total on AMD, the system memory on GB10).

The value is the architect's to adjust; until then it is the session's starting figure.
