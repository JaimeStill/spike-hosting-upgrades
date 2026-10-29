---
name: hosting-upgrades
description: Evaluates upgrades to one inference host's serving stack (its hardware configuration, its model engine, and its models) from what others publish. Probes the host live over SSH, read-only and without root, reconciles the probe with the project's host descriptor and policy, and writes a dated, cited report of upgrades. Use when asked to evaluate upgrades for a host, check what's new for a host's engine or models, or plan a host's next upgrade.
argument-hint: <host>
allowed-tools:
  - Bash(ssh * bash -s < ${CLAUDE_SKILL_DIR}/scripts/probe.sh)
  - Read
  - Edit(docs/reports/**)
---

# hosting-upgrades

Evaluates upgrades for one host a run: the host named by its SSH short name, here `$0`. A run
probes the host as it is now, reconciles what it finds with the project's descriptor of that host,
and writes one dated report. The skill knows no particular environment: the hosts and the rules
come from the project's own documents, and every other fact comes from the probe.

The run is interactive. It pauses and asks the architect rather than guessing or failing (see
"When to pause"), and it never runs a command that needs root (see "Facts that need root").

## Inputs

A run reads two documents from the project, relative to its root (`${CLAUDE_PROJECT_DIR}`), and
writes neither.

- **The host descriptor**, `docs/hosts/<host>.md`. It holds only:
  - the SSH short name the run reaches the host by
  - the declared model purposes: what the host serves or is meant to serve (agent, vision, audio,
    embedding, or whatever it serves), naming no model
  - optional engine watch items: named things the run must check, beside its own scan

  Every other fact about the host comes from probing it. [templates/host.md](templates/host.md)
  gives the shape, for an environment writing its own.
- **The policy**, `docs/policy.md`. It states the model-origin rule, the quantization floor, and
  the memory headroom a model set must leave. [templates/policy.md](templates/policy.md) gives
  the shape.

When a step needs a policy value the document doesn't state (a floor for a kind of model it
doesn't name, a headroom it leaves open), the run asks the architect for the value and records
the answer in the report as the architect's, never inventing one.

## The run

### 1. Load the inputs

1. Take the host from the argument, `$0`. With no argument, list the descriptors in `docs/hosts/`
   by their short names, ask which host to run on, and run on one host only.
2. Read `docs/hosts/<host>.md`. If it is absent, stop and say so: "No descriptor for `<host>` in
   `docs/hosts/`, so the run has no declared purposes to judge against; write one from the
   skill's `templates/host.md` and run again." Name the descriptors that do exist.
3. Read `docs/policy.md`. If it is absent, stop and say so: "The project has no policy document
   (`docs/policy.md`), so no candidate can be judged against the model-origin rule, the
   quantization floor, or the memory headroom; write one from the skill's `templates/policy.md`
   and run again."
4. If the descriptor holds anything beyond its three sections (a model name, an engine version, a
   memory figure), treat it as stale: the probe decides those facts, and the report notes the
   extra lines under "Proposed changes".

### 2. Probe

Run the bundled probe on the host over SSH, from the project root, exactly as:

```sh
ssh <short name> bash -s < ${CLAUDE_SKILL_DIR}/scripts/probe.sh
```

[scripts/probe.sh](scripts/probe.sh) is read-only and needs no root. It prints labeled sections
(`== os ==`, `== kernel ==`, `== firmware ==`, `== gpu ==`, `== memory ==`,
`== container-runtime ==`, `== engines ==`, `== endpoints ==`, `== models ==`, `== skipped ==`).
A probe whose command is absent on the host prints `skipped:` and the probe goes on; a skip is a
fact too, and the report keeps it. The probe reads no network address and redacts any that slips
through, so its output can go into the report as is.

- If SSH fails, stop and say the host is unreachable, quoting the error. Don't work around it.
- If the probe's output is incomplete (a section is missing, or docker reports no permission),
  say which sections are missing and ask whether to continue without them.

### 3. Reconcile with the descriptor

Compare what the probe found with what the descriptor declares, and pause on every discrepancy
(see "When to pause") before going on:

- **A served model whose purpose isn't declared**: map each model in `== endpoints ==` to a
  purpose from its name and, where unclear, its card. A model that fits no declared purpose is a
  discrepancy.
- **A declared purpose nothing serves**: a purpose with no served model, including the case where
  nothing serves at all. When nothing serves, the inventory says so, and the later steps judge
  against the installed engines (`== engines ==`) and the stored models (`== models ==`), once
  the architect confirms that is what the run should do.
- **A watch item the probe can't reach**: a watch item naming an engine or backend the host
  doesn't have is kept, not dropped; note it for "Proposed changes".

Record each answer the architect gives; the report cites it as the architect's.

### 4. Sources

*Placeholder.* Gathering and tiering the public record for the host's hardware, engines, and
models is specified in a later slice.

### 5. Hardware configuration

*Placeholder.* Specified in a later slice.

### 6. Engines

*Placeholder.* Specified in a later slice.

### 7. Models

*Placeholder.* Specified in a later slice.

### 8. Model set

*Placeholder.* Specified in a later slice.

### 9. Verify next

*Placeholder.* Specified in a later slice.

### 10. Proposed changes

*Placeholder.* Specified in a later slice; it collects the discrepancies and stale descriptor
lines steps 1 and 3 noted.

### 11. Write the report

*Placeholder.* Specified in a later slice. The report is the run's only write, a dated file in
`docs/reports/`.

## When to pause

The run stops and asks the architect, rather than guessing or failing, in four cases:

1. **The probe contradicts the descriptor**: a served model whose purpose isn't declared, or a
   declared purpose nothing serves (step 3).
2. **Sources conflict on a claim**: two sources disagree on a version, a gain, or a support claim.
3. **A policy question arises**: the policy lacks a value a step needs, or a candidate sits on a
   rule's edge (an origin that's unclear, a format the floor doesn't name).
4. **A source's tier is unclear**: the run can't tell whether a source is primary, an attributed
   benchmark, or a lead.

A pause states what was found, cites where (the probe section, the descriptor line, the source),
gives the options with the one the run would take by default, and waits. For example:

```text
Pause: the probe contradicts the descriptor (gb10-1).

The descriptor (docs/hosts/gb10-1.md) declares four purposes: agent, vision, audio, embedding.
The probe finds nothing serving: == endpoints == reports nothing OpenAI-compatible on loopback,
both containers (llama, vllm) are exited, and both units (llama-router, vllm-server) are
disabled and inactive. So no declared purpose is served.

Installed: llama.cpp (ghcr.io/ggml-org/llama.cpp:server-cuda13-b11669), vLLM
(vllm/vllm-openai:v0.32.0), and 14 models in /srv/models.

How should the run go on?
  a. (default) Treat the installed engines and stored models as the incumbent: the inventory says
     nothing serves, and every section ranks against what is installed.
  b. The host is meant to serve fewer purposes: name the ones to drop, and the report proposes
     the descriptor change.
  c. Stop: the host is mid-change, and the run should wait until it serves again.
```

## Facts that need root

The probe reads only what an unprivileged user can. When a step needs a fact only root can read,
the run never runs sudo itself. It prints the exact command, says what fact it needs and why, asks
the architect to run it on the host and paste the output, and continues from the pasted output,
citing it in the report as the architect's read-out. For example:

```text
The report needs the GPU's loaded firmware versions, which only root can read. Run this on
framework and paste the output:

  sudo cat /sys/kernel/debug/dri/1/amdgpu_firmware_info
```

If the architect declines, the run goes on without the fact and the report says which fact is
missing and what it would have decided.

## What a run writes

A run writes nothing except its report: not the descriptor, not the policy, not the skill, and
nothing on the host. Changes it would make to any of them go into the report as proposals.
