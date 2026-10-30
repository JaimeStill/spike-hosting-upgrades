# Finding: the skill's read-only probe on both hosts

Task `skill`, dated 2026-10-29. What the hosting-upgrades skill's probe
(`.claude/skills/hosting-upgrades/scripts/probe.sh`) read on the Framework and gb10-1 while the
skill was built. Nothing here is a performance measurement; the probe reads the host stack and
changes nothing. The section "gb10-1 after its update, 2026-10-30" adds the next day's probes
and the architect's fix between them; the sections before it keep their 2026-10-29 readings.

## Commands, exactly as run

Run by the session on 2026-10-29, at slices 1, 2, and 3 and at the spec review, from the
repository root:

```sh
ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-framework.txt
ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-gb10-1.txt
```

The spec review ran the same command under `timeout 120`, redirecting each host's output to a
scratch file outside the repository.

No run used sudo, and no host was changed: the probe only reads.

## Network path

The session's machine to each host over the tailnet, by SSH, with each host reached by its SSH
short name (`framework`, `gb10-1`). The probe prints no network address, and this finding records
none.

## What the runs showed

From each host's last saved probe output.

### framework

- **OS**: Omarchy 4.0.6, x86_64.
- **Kernel**: 7.2.8-9-omarchy running; linux 7.2.11 is installed too, and no reboot was pending.
- **Firmware**: BIOS 03.06 (2026-07-13); linux-firmware 20260916.
- **GPU stack**: AMD Strix Halo (Radeon 8060S class), Mesa and vulkan-radeon 26.2.5, ROCm 7.2.4.
- **Memory ceiling**: 125.1 GiB MemTotal; TTM pages limit 29360128 pages (112.0 GiB), with GTT
  reporting 112.0 GiB.
- **Container runtime**: Docker 29.9.2.
- **Engines**: llama.cpp `server-vulkan-b11960` running, build b11960-8642541b2, as a router;
  vLLM `vllm-openai-rocm:v0.32.0` present and exited.
- **What serves**: the llama.cpp router, with four models loaded (gemma-4-E4B-it Q8_0,
  gemma-4-26B-A4B-it QAT Q4_0, gpt-oss-120b MXFP4 set-a, granite-embedding-english-r2 BF16) and
  five more listed unloaded.
- **Store**: `/srv/models`, 14 models.
- **Skipped**: dgx-release, nvidia-smi, vulkaninfo, nvidia-ctk, ollama.

### gb10-1

- **OS**: Ubuntu 24.04.5 LTS, DGX OS (software build 7.4.0, OTA 7.6.0), aarch64.
- **Kernel**: 7.0.0-1019-nvidia running; no reboot was pending.
- **Firmware**: BIOS 5.36_4.1.0 (2025-10-08); linux-firmware 20240318.
- **GPU stack**: NVIDIA GB10, driver 580.178.04, CUDA 13.0; NVIDIA Container Toolkit 1.20.1.
- **Memory ceiling**: unified memory, so the system memory: 121.6 GiB MemTotal.
- **Container runtime**: Docker 29.6.2.
- **Engines**: llama.cpp `server-cuda13-b11669` and vLLM `vllm-openai:v0.32.0`, both exited; their
  systemd units disabled and inactive.
- **What serves**: nothing; no OpenAI-compatible endpoint answered on loopback.
- **Store**: `/srv/models`, 14 models.
- **Skipped**: omarchy-version, vulkaninfo, ollama.

## gb10-1 after its update, 2026-10-30

The architect updated gb10-1's system on 2026-10-30; the session took no part in the update. The
entries above keep their 2026-10-29 readings.

### The session's probe after the update

Run by the session, read-only, from the repository root:

```sh
timeout 120 ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-gb10-1-after-update.txt
```

- **Kernel**: 7.0.0-1019-nvidia → 7.0.0-1024-nvidia, booted 2026-10-30 08:44; no reboot pending.
- **Unchanged**: the driver, the OTA version, the containers, and the 14 stored models.
- **What serves**: nothing; no OpenAI-compatible endpoint answered on loopback.
- **Tailnet identifiers**: none in the output.

### The architect's fix for a boot-order failure

The llama container publishes its port on the host's tailnet address. On the boot after the
update, docker started before Tailscale assigned that address, so the container's start failed to
bind and left it with no published port. The architect ran these on gb10-1, exactly as run; the
first two ran with root:

```sh
echo 'net.ipv4.ip_nonlocal_bind = 1' | sudo tee /etc/sysctl.d/90-nonlocal-bind.conf
sudo sysctl --system
docker start llama
docker network connect bridge llama
docker port llama
```

- `sysctl --system` reported `net.ipv4.ip_nonlocal_bind = 1`.
- `docker network connect` answered "endpoint with name llama already exists in network bridge",
  because the start had already restored the container's network.
- `docker port llama` showed `8080/tcp -> <tailnet address>:8080`; the address is redacted here.

The same fix was first worked out on gb10-2 by another spike's session. A second reboot hasn't yet
proven it.

### The session's probe after the fix

Run by the session, read-only, from the repository root:

```sh
timeout 120 ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-gb10-1-after-fix.txt
```

- **Engines**: the llama container running and healthy, as the llama.cpp router at build
  b11669-620d2225c, with 8 router models, all unloaded; the vllm container still exited; both
  systemd units still disabled.
- **Tailnet identifiers**: none in the output.

## The probe's port and sysctl lines, 2026-10-30

The architect approved three read-only lines for the probe: each engine container's published
ports and its configured binds, each port by bind class (`tailnet`, `all`, `loopback`, `other`)
and never by address, and `net.ipv4.ip_nonlocal_bind`. The session ran the updated probe on both
hosts, read-only, from the repository root:

```sh
timeout 120 ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-framework-ports.txt
timeout 120 ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-gb10-1-ports.txt
```

Beside the new lines, the outputs matched each host's previous probe (memory figures and uptimes
aside).

- **framework**: `net.ipv4.ip_nonlocal_bind: 0`. The running llama container publishes
  `8080/tcp tailnet` and is configured with `8080/tcp tailnet`; the exited vllm container
  publishes none and is configured with `8000/tcp tailnet`. So framework carries the bind that
  failed on gb10-1, without the remedy: a boot where docker starts before Tailscale would leave
  llama with no published port.
- **gb10-1**: `net.ipv4.ip_nonlocal_bind: 1`, the architect's remedy above. The running llama
  container publishes `8080/tcp tailnet` and is configured with `8080/tcp tailnet`; the exited
  vllm container publishes none and is configured with `8000/tcp tailnet`.
- **Tailnet identifiers**: none in either output.

## The probe's bind classes by address family, 2026-10-30

The probe's bind classes now split the tailnet by address family, `tailnet4` (100.64.0.0/10) and
`tailnet6` (fd7a:115c:a1e0::/48), since each family has its own `ip_nonlocal_bind` key, and
`== container-runtime ==` prints `net.ipv6.ip_nonlocal_bind` beside the IPv4 key (`absent` when
the kernel has no IPv6). The session ran the updated probe on both hosts, read-only and without
sudo, from the repository root:

```sh
timeout 120 ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-framework-families.txt
timeout 120 ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-gb10-1-families.txt
```

Beside the new lines, the outputs matched each host's previous probe (memory figures and uptimes
aside).

- **framework**: `net.ipv4.ip_nonlocal_bind: 0` and `net.ipv6.ip_nonlocal_bind: 0`. The running
  llama container publishes `8080/tcp tailnet4` and is configured with `8080/tcp tailnet4`; the
  exited vllm container publishes none and is configured with `8000/tcp tailnet4`. Every bind is
  IPv4, so the IPv4 key is the one that matters here, and it is still without the remedy.
- **gb10-1**: `net.ipv4.ip_nonlocal_bind: 1` and `net.ipv6.ip_nonlocal_bind: 0`. The running
  llama container publishes `8080/tcp tailnet4` and is configured with `8080/tcp tailnet4`; the
  exited vllm container publishes none and is configured with `8000/tcp tailnet4`. Every bind is
  IPv4, so the IPv4 remedy covers them; the IPv6 key at 0 matters only if a container is given a
  `tailnet6` bind.
- **Tailnet identifiers**: none in either output, and no redaction marker either: the address
  was dropped before printing, not caught by the guard.

## The probe's system-debt reads and the router preset, 2026-10-30

The tuning slice's part B added read-only, no-root reads to the probe:

- `== updates ==`: pending packages, from apt's cached lists with their age, or Arch's
  `checkupdates`
- `== firmware-updates ==`: `fwupdmgr get-updates`, by device name and version only
- `== units ==`: failed system and user units
- `== docker-disk ==`: `docker system df`, dangling images, and images no container uses
- each stored model's last-modified date beside its size, under `== models ==`
- each engine container's restart policy
- the serving keys of a preset the container mounts, through the `flags` filter

The session ran the probe on both hosts, read-only and without sudo, from the repository root:

```sh
timeout 120 ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-framework-debt.txt
timeout 120 ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-gb10-1-debt.txt
```

The session ran this pair five times while it fixed the preset reader, each run overwriting the
same two files; the readings below are from the last run. Four of the five runs were the pair,
and one (the third) was framework's command alone.

1. The first run listed no file in `/etc/llama-preset`.
2. The second followed links and still found none.
3. The third named the directory's one entry, `models.ini`, a regular file. The reader's size
   bound (`find -size -1M`) had matched only empty files, since find rounds a size up to whole
   MiB.
4. With the bound fixed, the fourth read the file: INI, with `[section]` headers over
   `key = value` lines, every line in a form the reader knows.
5. The fifth read the context key, `c`, the short form of `--ctx-size`, which the fourth had
   dropped.

### framework

- **Preset**: `models.ini`, 10 sections and 69 keys, none unread. `[*]` sets
  `--n-gpu-layers all`. Each model section sets `-c` (32768, or 131072 for
  `gpt-oss-120b-MXFP4-16-slots`, `gpt-oss-120b-MXFP4-set-a`, and the granite embedding),
  `--parallel` (4, or 16 for the 16-slots model and the embedding), and the sampling keys.
  `gpt-oss-120b-MXFP4-set-a` adds `--kv-unified true --checkpoint-min-step 4096`, and the
  embedding adds `--batch-size 8192 --ubatch-size 8192`. Every section's context, slots, and
  sampling keys match the flags the router lists for the same model, so the probe shows no drift
  between preset and router.
- **Updates**: `checkupdates` found 0 pending packages, from a fresh sync.
- **Firmware**: no updates, against fwupd metadata last refreshed 2026-09-17.
- **Units**: system and user managers `running`, no failed units.
- **Docker disk**: 2 images (47.86 GB), both used; no dangling images; build cache 47.01 GB, 354.7
  MB of it reclaimable.
- **Restart policy**: both containers `unless-stopped`; the vllm container is exited.
- **Models**: the 14 stored models, last modified 2026-10-27 or 2026-10-28.

### gb10-1

- **Preset**: `models.ini`, 9 sections and 60 keys, none unread. It is framework's preset without
  the `gpt-oss-120b-MXFP4-set-a` section, and it matches the router's listed flags as framework's
  does.
- **Updates**: apt's lists last refreshed 2026-10-30 11:44:34, and 0 pending packages in them.
- **Firmware**: no updates, against fwupd metadata last refreshed 2026-10-30.
- **Units**: system and user managers `running`, no failed units. The engine units
  `llama-router` and `vllm-server` are still disabled and inactive.
- **Docker disk**: 4 images (45.27 GB), 3.014 GB reclaimable; no dangling images. Two images no
  container uses: `ghcr.io/ggml-org/llama.cpp:full-cuda13-b11669` (10 GB) and
  `hello-world:latest` (22.6 kB).
- **Restart policy**: both containers `unless-stopped`; the vllm container is exited.
- **Models**: the 14 stored models, last modified between 2026-10-23 and 2026-10-26.

### Both hosts

- **Tailnet identifiers**: none in either output, and no redaction marker either.

## The probe prints ~ for the home directory, 2026-10-30

The redact guard gained one rule: the remote user's home directory (`$HOME` on the host) prints
as `~`, by a literal string match on whole path components. The session ran the probe on both
hosts, read-only and without sudo, from the repository root:

```sh
timeout 120 ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-framework-home.txt
timeout 120 ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-gb10-1-home.txt
```

Each run was compared with the same host's run in the previous section (`-debt.txt`):

- **Home paths**: each host's two mount sources now read `~/.cache/vllm` and
  `~/repos/spike-model-engines/host/llama-preset`. The one `/home/` left in each output is the vllm
  container's mount destination, `/home/vllm`, a path inside the container rather than the remote
  user's home, which the rule leaves as it is.
- **Everything else**: unchanged apart from the memory counters (`MemFree`, `MemAvailable`,
  `Cached`, and on framework `SwapFree`). On gb10-1, the `apt lists` line also moved from
  11:44:34 to 12:44:37: the host refreshed its own lists between the runs, the probe never does,
  and the pending count stayed 0.
- **Tailnet identifiers**: none in either output, and no redaction marker either.

## Session report: gb10-1's validation run, 2026-10-30

Slice 6 of task `skill`: the tuned skill's validation run on gb10-1, `/hosting-upgrades gb10-1`,
in the architect's view. During the run the architect refined the origin rule, and the session
carried the refinement through the policy and the skill. This section consolidates the session.
The run's own record is the report, [gb10-1, 2026-10-30](../reports/gb10-1/2026-10-30.md).

### Commands, exactly as run

The session ran the probe once, read-only and without sudo, from the repository root, by the
readiness check's exact rule, with no `timeout` and no redirect:

```sh
ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh
```

The origin research part ran the screening-list script twice from the repository root. It
reported the names below; the commands are rebuilt from its report, not copied from a log:

```sh
.claude/skills/hosting-upgrades/scripts/screen.sh "Google LLC" "OpenAI" "International Business Machines" "IBM" "ggml-org" "ggml.ai" "NVIDIA Corporation" "Mistral AI" "Microsoft Corporation" "Meta Platforms" "Liquid AI" "mrutkows" "Michael Rutkowski" "Alphabet Inc" "Mistral AI SAS"
.claude/skills/hosting-upgrades/scripts/screen.sh "Matt Rutkowski" "Google DeepMind" "Answer.AI" "LightOn" "Allen Institute for Artificial Intelligence" "Liquid AI, Inc." "Meta Platforms, Inc." "Kokoro" "Hugging Face"
```

Every name came back "no match on normalized name". The first call downloaded the day's list to
`.state/csl/2026-10-30.json`. No other command touched a host; every other read was WebFetch,
WebSearch, or `gh search`.

### Network path and host stack

The session's machine reached gb10-1 over the tailnet by SSH, by its short name. The host stack is
the report's Inventory:

- DGX OS 7.4.0 with OTA 7.6.0
- kernel 7.0.0-1024-nvidia
- driver 580.178.04
- llama.cpp b11669 in `server-cuda13-b11669`

### How the run went

- **Readiness check.** All eight rules were present in `.claude/settings.json`.
  - The probe ran under its exact ssh rule, and the session saw no denial.
  - The session ran in plan mode, so whether a permission prompt reached the architect isn't
    visible here.
  - The question the framework walkthrough left open, whether the exact rule matches outside
    auto mode, is therefore not settled by this run.
- **Research.** The run split step 4 into SKILL.md's five parts (hardware and system, engines,
  agent models, other models, origin), as five parallel subagents.
  - Together they used about 578,000 tokens and 340 tool calls, and took up to about 10 minutes.
  - The session then made three reads of its own: Muse-Glimmer's card and `.src_sha`, Granite
    4.1's card, and b12004's release date.
- **Pauses.** There were nine questions in all, each recorded with its answer in the report's
  Inventory:
  - three at step 3: the valid set, then two follow-ups on vision size and the audio build
  - the agent preset, answered with two questions of the architect's own
  - vLLM and the bare-metal stack
  - the agent bar's floors
  - the origin rule's edges, which became the refinement below
  - conflicting DGX OS version notes
  - one source's tier

### The architect's decisions

1. **The valid set.**
   - agent: gpt-oss-120b MXFP4
   - vision: Gemma 4 QAT Q4_0, 26B-A4B or 31B
   - audio: Gemma 4 E4B QAT Q4_0
   - embedding: granite-embedding-english-r2 BF16

   Every other stored or listed model is extraneous.
2. **Containerized llama.cpp stays the GB10 engine.** vLLM stays down unless a finding favours it,
   and the bare-metal units and the vllm container are to be removed.
3. **The agent bar's floors are confirmed:** BFCL single-turn ≥ 0.630, multi-turn ≥ 0.325.
4. **The origin rule is refined.** A level excludes by how much control it gives an adversary's
   model over the served behavior.
   - **Excluding levels:** weights, behavioral training signal, and components in the inference
     path.
   - **Recorded levels:** narrow transformations, components outside the output path, and
     conventions.
   - **Two new gates:** compliance, and artifact integrity.
5. **DGX OS version conflicts:** "trust the current state of the GB10 workstation". The probe's
   installed versions decide.
6. **ggml-org's `benches/dgx-spark/dgx-spark.md` is an attributed benchmark.**
7. **Refinements are worked out in this session** and consolidated here, rather than handed to
   another session.

### Changes made in the session

- **`docs/policy.md`:**
  - Model origin is rewritten as the tiered levels, with the threat stated, the data rule
    narrowed to behavioral training signal, and a compliance gate.
  - A new "Artifact integrity" section passes GGUF and safetensors and fails code-running
    checkpoints.
  - The agent bar is marked confirmed.
  - The granite example now records the research that passed the conversion.
- **`.claude/skills/hosting-upgrades/models.md`:** origin's documents step notes each named model's
  role. The judging rules follow the tiers, with compliance added. A new "Artifact integrity"
  subsection sits under Gate 1.
- **`.claude/skills/hosting-upgrades/SKILL.md`:** step 7 gates on artifact integrity after origin,
  and excludes only at the levels the policy excludes on.
- **`.claude/skills/hosting-upgrades/templates/policy.md`:** the template has the threat,
  excluding and recorded levels, compliance, and an artifact-integrity section.
- **`context/goals/experiment.hosting.spike-hosting-upgrades.md`:** two decisions, the refinement
  and this session report.
- **`docs/reports/gb10-1/2026-10-30.md`:** the run's report.

`mise run check` passes. Nothing is committed: the commits are the architect's.

### What the run found

The report holds every finding with its citation; these are the ones that matter most.

- **Per-session context is 8,192 tokens** on both agent sections. Each sets `--parallel`, which
  leaves the KV cache split (llama.cpp source at b11669). gpt-oss-120b's trained context is
  131,072.
- **Memory and concurrency (estimate).** With the valid set loaded, about 20 GiB remains for
  gpt-oss-120b's KV and buffer, which is **4 sessions at full context** at about 36 KiB per token.
  ggml-org's GB10 curve halves per-stream decode at 4 streams.
  - The proposed section `-c 524288 --parallel 4 --kv-unified` is **hold**.
  - It still needs a check on whether a unified slot is capped at the trained context, and on
    `--kv-unified-per-slot`.
- **Vision, 31B against 26B-A4B.** 31B leads every shared eval: MRCR v2 128k 66.4 against 44.1,
  MMMU Pro 76.9 against 73.8. It decodes about 6× slower on GB10 and costs about 6 GiB more, so
  the run holds it: "measured slower, ahead on evals".
- **The only verify item is image `server-cuda13-b12004`.** Its GB10 measurements are +17.2%
  prefill on a mixture-of-experts model (#31188) and +7.1% on a dense one (#29948), and no
  regression has been reported.
- **llama.cpp #27148, open:** the RAM prompt cache can restore one conversation's content into
  another slot under concurrent load. It is on by default; `--cache-ram 0` is held until #27624
  lands.
- **Origin:**
  - The granite embedding conversion passes after research: an IBM employee, IBM's own
    conversion repository naming the model, and exact shapes.
  - gpt-oss-120b's bundled Eagle3 drafter is recorded, not excluding, and must not be loaded.
  - Only the Nemotron family is excluded.
- **Debt.** Removals worth about 161 GiB of models, plus the vllm container and image, the
  bare-metal units, and an unused 10 GB image. All are hold, citing the architect's decision. The
  preset's extraneous sections belong to spike-model-engines, which owns the preset.

### What the run showed about the skill

These are for the skill's next tuning pass. The report's "Proposed changes" carries the
source-list and descriptor items.

- **The research partition left gaps** that only show at synthesis:
  - origin chains for candidates the model parts surfaced late (Muse-Glimmer, Granite 4.1, Flint,
    Mistral Small 4)
  - Llama 4 Scout, which nobody researched
  - E4B's config, needed for its KV estimate
  - the mmproj files' precision, which the API doesn't show

  A second, narrower round after the model parts, feeding their candidates to the origin part,
  would close most of them.
- **"Origin unclear" carried candidates the research didn't finish.** The policy asks for
  research until the answer is definitive. The run listed five models as not settled, each
  already failing another gate. The skill could say that a model failing a later gate may stop at
  "not settled", and say so.
- **Speed across quantizations.** No GB10 figure measures Google's QAT Q4_0 files, and the run
  sorted by Q4_K_M figures of the same models. models.md, "Sort", should say whether a same-model,
  same-bit-width figure stands in.
- **Comparing evals across cards.** EmbeddingGemma 2's "MTEB (eng, v2)" and granite's "MTEB-v2
  (41)" may be one suite, but neither card names its tasks.
- **The descriptor's measurements decide what counts.** gb10-1's descriptor lists none, so
  spike-model-engines' GB10 findings didn't count, though they are the basis of the architect's
  engine decision. The report proposes listing three.
- **Version conflicts among vendor notes.** The architect's answer, that the probe decides,
  could go into sources.md, so that a conflict no verdict depends on isn't a pause.
- **Bundled drafters.** A probe or report check that no preset section loads an excluded drafter
  would make the recorded level enforceable.
- **The run's cost.** Five research parts at about 578,000 tokens is the run's main expense. A
  host whose inventory hasn't changed since its last report could research only what moved.

### Open after the session

- **The architect's commit** of the report and the session's refinements, on `skill`.
- **The goal record's Progress line** still reads slice 6 pending. It and any brief revision for
  the origin refinement are the editor's to bring current.
- **verify-gb10:** b12004 with anchors A and B, the `--kv-unified` agent section beside it in one
  session, and then the removals, each with its rollback.
- **A spike-model-engines task** for the preset: one agent section, the extraneous sections
  removed, and no drafter loaded.
