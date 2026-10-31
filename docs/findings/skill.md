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

## The probe's drafter check, and per-session context by hand, 2026-10-30

Slice 7 of task `skill` gave the probe a `drafter` line: under each engine container, each
preset section, and each model a router lists, the drafter models its arguments load for
speculative decoding, by file or repository name only, or `none`, then any other speculative key
by name. The keys are llama.cpp's at b11669 (`--spec-draft-model`, `-md`, `--model-draft`;
`--spec-draft-hf`, `-hfd`, `-hfrd`, `--hf-repo-draft`) and vLLM's `--speculative-model` and
`--speculative-config`.

### Commands, exactly as run

The session ran the probe on both hosts, read-only and without sudo, from the repository root,
reaching each over the tailnet by its short name:

```sh
timeout 120 ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-framework-s7.txt
timeout 120 ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-gb10-1-s7.txt
```

For the context check it read llama.cpp's source at the probed tag from this machine, with no
host involved, into the session's scratch directory:

```sh
mkdir -p /tmp/claude-1000/-home-jaime-experiments-spike-hosting-upgrades/45c522cd-42db-47fa-b317-07bbbf74e8d3/scratchpad/src && cd /tmp/claude-1000/-home-jaime-experiments-spike-hosting-upgrades/45c522cd-42db-47fa-b317-07bbbf74e8d3/scratchpad/src && for f in common/arg.cpp common/common.h tools/server/server-context.cpp tools/server/server.cpp; do curl -sfL -o "$(echo $f | tr / _)" "https://raw.githubusercontent.com/ggml-org/llama.cpp/b11669/$f" && echo "got $f"; done; ls -la
cd /tmp/claude-1000/-home-jaime-experiments-spike-hosting-upgrades/45c522cd-42db-47fa-b317-07bbbf74e8d3/scratchpad/src && grep -n "kv_unified\|kv-unified" common_arg.cpp common_common.h tools_server_*.cpp | head -40; echo ===; grep -n '"-md"\|draft\|"--spec' common_arg.cpp | grep -o '{[^}]*}' | sort -u | head -60
cd /tmp/claude-1000/-home-jaime-experiments-spike-hosting-upgrades/45c522cd-42db-47fa-b317-07bbbf74e8d3/scratchpad/src && sed -n 160,190p tools_server_server.cpp; grep -n "n_parallel *=" common_common.h; sed -n 1720,1736p common_arg.cpp; grep -n 'url.*draft\|draft.*url\|"--spec-type"' common_arg.cpp | head; grep -n -A12 '"--spec-type"' common_arg.cpp | head -20; grep -n -B2 -A10 '"-np", "--parallel"' common_arg.cpp | head -20; sed -n 1340,1395p tools_server_server-context.cpp
cd /tmp/claude-1000/-home-jaime-experiments-spike-hosting-upgrades/45c522cd-42db-47fa-b317-07bbbf74e8d3/scratchpad/src && grep -n "n_parallel *= *-1\|n_parallel = -1" *.cpp *.h; sed -n 2538,2547p common_arg.cpp; grep -n "model-url\|-mu\b\|url" common_arg.cpp | grep -i draft | head
cd /tmp/claude-1000/-home-jaime-experiments-spike-hosting-upgrades/45c522cd-42db-47fa-b317-07bbbf74e8d3/scratchpad/src && curl -sfL -o src_llama-context.cpp https://raw.githubusercontent.com/ggml-org/llama.cpp/b11669/src/llama-context.cpp && grep -n "n_ctx_seq *=" src_llama-context.cpp; sed -n 1400,1408p common_arg.cpp

```

### What the probe found

- **framework** (llama.cpp b11960 in `server-vulkan-b11960`, kernel 7.2.8-9-omarchy, Mesa
  26.2.5): `drafter none` on both containers, on all 10 preset sections, `[*]` included, and on
  all 9 models the router lists. No other speculative key.
- **gb10-1** (llama.cpp b11669 in `server-cuda13-b11669`, DGX OS OTA 7.6.0, kernel
  7.0.0-1024-nvidia, driver 580.178.04): `drafter none` on both containers, on all 9 preset
  sections, `[*]` included, and on all 8 models the router lists. No other speculative key.
- **Everything else**: unchanged from each host's previous run (`-home.txt`) apart from the
  memory counters, the containers' uptime, and the order of gb10-1's two `llama` mounts.
- **Tailnet identifiers**: none in either output, and no redaction marker. The one `/home/` in
  each is the vllm container's mount destination, `/home/vllm`, a path inside the container.

### gb10-1's per-session context, by hand

Neither agent section of gb10-1's preset names `--kv-unified` or `--no-kv-unified`, and neither
do the router's listed flags, so the engine's default at b11669 decides. From the source at the
tag:

- `common/common.h:580`: `bool kv_unified = false;`
- `common/arg.cpp:1406`: the server sets `params.n_parallel = -1; // auto by default`
- `tools/server/server.cpp:168-172`: only when `n_parallel < 0` (auto) does the server use 4 slots
  and set `kv_unified = true`
- `src/llama-context.cpp:380-382`: `n_ctx_seq` is `n_ctx` when unified, and `n_ctx / n_seq_max`
  otherwise

Both sections set `--parallel`, so it isn't auto, and the cache is split. Per session
(**estimate**, `ctx-size / parallel`):

| Section | `-c` | `--parallel` | Per session | Against 32,768 |
|---|---|---|---|---|
| `ggml-org/gpt-oss-120b-GGUF:MXFP4` | 32768 | 4 | 8,192 | under: hold |
| `gpt-oss-120b-MXFP4-16-slots` | 131072 | 16 | 8,192 | under: hold |

The fix for either is a context, slot count, or unified cache that gives each session at least
32,768 tokens: `-c 131072 --parallel 4` split, or a unified pool, which the gb10-1 report of
2026-10-30 already holds as its proposed agent section.

## The probe reads shell-form command lines, 2026-10-30

The slice 7 review follow-ups gave `serving_flags()` the word-splitting `drafters()` uses: an
argument with spaces that is not a flag or JSON is a shell-form command line (`sh -c
"llama-server ..."`), read word by word. The `-c` before it is the shell's, so it is dropped. The
whitelist is unchanged. Before the change, such a container printed the shell's `-c` with the
whole command line as its value, paths and keys included, since `-c` is on the whitelist as
llama.cpp's context size. Neither host runs a shell-form container, so their lines don't change.

### Commands, exactly as run

The session ran the probe on both hosts, read-only and without sudo, from the repository root,
reaching each over the tailnet by its short name:

```sh
timeout 120 ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-framework-s7b.txt
timeout 120 ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > .state/probe-gb10-1-s7b.txt
```

Both exited 0.

### What the probe found

- **Flags and drafter lines**: identical to each host's previous run (`-s7.txt`), on every
  container, preset section, and router model. gb10-1's vllm container still prints `flags
  --max-num-seqs 4 --max-model-len 8192 --gpu-memory-utilization 0.80 --kv-cache-dtype bfloat16`:
  on vLLM `--max-model-len` caps each request rather than being shared across `--max-num-seqs`,
  so each of its 4 sessions reaches 8,192 tokens, not 2,048 (vLLM's engine arguments: "Model
  context length (prompt and output)"; <https://docs.vllm.ai/en/latest/configuration/engine_args.html>).
- **Everything else**: unchanged apart from the memory counters, gb10-1's `llama` uptime (5 hours
  to 6), and the order of gb10-1's two `llama` mounts.
- **Tailnet identifiers**: none in either output (no `100.64.0.0/10` address, `fd7a:115c:a1e0:`
  prefix, `.ts.net` name, or `tailscale`).

## The origin bar by role, by hand, 2026-10-31

Revision 4, slice 9. The policy's origin rule now excludes a distillation teacher, read by its
role, and records adversary-generated data in a training mix under "dataset sources". It
supersedes the 2026-10-30 data clause and the exclusion of Granite 4.1 30B under it on 2026-10-31
(`docs/policy.md`, "Model origin"). The session checked three models by hand against the
amended text, with no host involved. Nothing here is a run of the skill, and no report changes.

### Sources, exactly as read

The session read each source with WebFetch on 2026-10-31, asking for the training, teacher, and
distillation passages verbatim:

- IBM's Granite 4.1 30B disclosure file, both halves of it (the second from offset 100,000):
  <https://raw.githubusercontent.com/ibm-granite/granite-4.1-language-models/main/disclosures/granite_4.1_30b_disclosure.json>
- the Granite 4.1 30B card: <https://huggingface.co/ibm-granite/granite-4.1-30b>
- the SYNTHETIC-1 dataset card: <https://huggingface.co/datasets/PrimeIntellect/SYNTHETIC-1>
- the LFM2.5-24B-A2B card:
  <https://huggingface.co/LiquidAI/LFM2.5-24B-A2B/raw/main/README.md>
- Liquid's LFM2.5-24B-A2B blog post: <https://www.liquid.ai/blog/lfm2-5-24b-a2b>
- the Nemotron 3 Nano Omni card:
  <https://huggingface.co/nvidia/Nemotron-3-Nano-Omni-30B-A3B-Reasoning-BF16/resolve/main/README.md>

### What the checks found

- **`ibm-granite/granite-4.1-30b`: passes origin.** SYNTHETIC-1 is a dataset source, not a
  teacher.
  - The disclosure file lists `"SYNTHETIC-1"` under post-training, `"source": "third party"`,
    "Reasoning traces for a diverse range of tasks across math, coding and science, whose
    correctness was confirmed with task-specific verifiers." It is one of about fifty
    third-party post-training datasets the file lists (OpenThoughts3-1.2M, NuminaMath-1.5,
    Llama-Nemotron-Post-Training-Dataset, and xlam_function_calling_60k among them). A second
    entry, "DeepCoder-PrimeIntellect Synthetic", `"source": "IBM"`, takes "16K verified coding
    problems from PrimeIntellect's SYNTHETIC-1" (disclosure file, read 2026-10-31).
  - "SYNTHETIC-1 is a reasoning dataset obtained from Deepseek-R1" (dataset card, read
    2026-10-31). So DeepSeek-R1, of adversary origin, generated one dataset in the mix.
  - Nothing the file or the card says presents DeepSeek-R1's outputs as what the model was
    distilled from or as its principal post-training corpus. The card says "our SFT data is
    largely comprised of three key sources", names the base, Granite-4.1-30B-Base, and names no
    teacher (card, read 2026-10-31). The models the disclosure file names in a generating role
    are Phi-4 ("Using Phi-4 as a teacher model", for one synthetic science set), Phi-4-reasoning,
    Mixtral-8x7B-Instruct-v0.1, and Nemotron4-340B-Instruct, none of adversary origin.
  - So the row records SYNTHETIC-1 (DeepSeek-R1 traces) under "dataset sources", and no level
    excludes. The card as read 2026-10-31 links no disclosure file; the file is in the publisher's
    own GitHub organization, where gb10-1's run of 2026-10-31 found it.
- **`LiquidAI/LFM2.5-24B-A2B`: stays origin unclear.** Its teachers are unnamed.
  - The card's post-training is "supervised fine-tuning, teacher specialization, two
    multi-domain on-policy distillation stages (one non-agentic, one agentic), and agentic
    reinforcement learning", and it names no teacher model and doesn't say where the teachers
    come from (card, read 2026-10-31).
  - The blog post gives the same five stages, "(2) Teacher Specialization, (3) non-agentic and
    (4) agentic Multi-Domain On-Policy Distillation (MOPD)", and says "During teacher
    specialization, LFM2.5-24B-A2B exhibited well-known reward-hacking behaviors". That hints the
    teachers are specialized copies of the model, but neither document says they are checkpoints
    from Liquid's own pipeline (blog, read 2026-10-31).
  - So the unnamed-teacher rule holds it out as "origin unclear". What would settle it: Liquid
    naming the teachers, or saying they are its own checkpoints.
- **Nemotron 3 Nano Omni: its "improved using" Qwen models are recorded, not excluding.**
  - The card says "This model was improved using Qwen3-VL-30B-A3B-Instruct, Qwen3.5-122B-A10B,
    Qwen3.5-397B-A17B, Qwen2.5-VL-72B-Instruct, and gpt-oss-120b", and points to its training
    dataset section for how (card, read 2026-10-31).
  - That section lists them per dataset as generators or filters, for synthetic data generation
    that "generate[s] reasoning traces", re-captions images and audio, and regenerates or refines
    samples, beside model-based quality and safety judges. The MetaMathQA row, for example, names
    "Qwen3.5-122B-A10B, Gemini 3 Flash Preview for filtering", and other rows name further
    adversary-origin generators in the same way (Kimi-K2.5 for AgentNet, GLM-4.1V-9B-Thinking,
    DeepSeek OCR) beside GPT-4o and NVIDIA's own Magpie TTS (card, read 2026-10-31).
  - The card never says "teacher", "distill", or "distilled", and doesn't present any of these
    models' outputs as its principal post-training corpus. Synthetic data is 41,502,625 of
    354,587,705 training samples by the card's tables (about 12%, the session's arithmetic), and
    that synthetic share is itself spread over several generators, NVIDIA's own and outside ones.
    The base is NVIDIA's own Nemotron 3 Nano 30B-A3B (card, read 2026-10-31).
  - So, read by role, the Qwen models, and the other generators, made datasets in a training mix:
    they go in the row under "dataset sources", and teacher is not the level that excludes it.
    The model is judged by its other levels (its components in the inference path among them),
    which this check didn't read. gb10-1's run of 2026-10-31 excluded it at level 2 under the
    superseded data clause.

## The probe reads GGUF first bytes and the package channel; magic.sh, 2026-10-31

Revision 4, slice 10. The probe gains two reads, both read-only and without sudo: under
`== models ==`, a `magic` line per GGUF file in a store, giving its first 4 bytes as hex and as
text and its path in the store (in a Hugging Face cache, through the snapshot's link to its blob);
and at the head of `== updates ==`, where the host's packages come from. On Arch that is the
mirrorlist's servers, each repository pacman.conf names, and the Omarchy channel; on apt, each
source's URIs and suites, `.list` and deb822 `.sources` alike. Omarchy records no channel:
`omarchy-channel-set` (basecamp/omarchy v4.0.6) runs `omarchy-refresh-pacman`, which copies the
channel's templates (`default/pacman/mirrorlist-<channel>`, `pacman-<channel>.conf`) over
`/etc/pacman.d/mirrorlist` and `/etc/pacman.conf`, so the probe names the channel whose template
each file still matches byte for byte, and the `omarchy` or `omarchy-dev` package installed. The
new `scripts/magic.sh` reads a Hub file's first 4 bytes from a ranged curl that follows the xet
302, from a repository and a file it checks against an allowlist, never a URL.

### Commands, exactly as run

The session ran the probe on both hosts, read-only and without sudo, from the repository root,
and kept each output in its scratchpad:

```sh
ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > <scratchpad>/framework.txt
ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh > <scratchpad>/gb10-1.txt
```

Both exited 0. Then magic.sh, from the repository root:

```sh
.claude/skills/hosting-upgrades/scripts/magic.sh "ggml-org/gpt-oss-120b-GGUF" "gpt-oss-120b-MXFP4.gguf"
.claude/skills/hosting-upgrades/scripts/magic.sh "openai-community/gpt2" "pytorch_model.bin"
.claude/skills/hosting-upgrades/scripts/magic.sh "openai-community/gpt2" "model.safetensors"
.claude/skills/hosting-upgrades/scripts/magic.sh "https://huggingface.co/openai-community/gpt2" "pytorch_model.bin"
.claude/skills/hosting-upgrades/scripts/magic.sh "openai-community/gpt2" "../x"
.claude/skills/hosting-upgrades/scripts/magic.sh "openai-community/gpt2" "/etc/passwd"
.claude/skills/hosting-upgrades/scripts/magic.sh "openai-community/gpt2" "a.bin?x=1"
.claude/skills/hosting-upgrades/scripts/magic.sh "openai-community/gpt2" "no-such-file.bin"
```

### What the probe found

- **First bytes**: every stored GGUF reads `47 47 55 46` (`GGUF`). Each host holds the same
  twelve GGUF files in `/srv/models`, with the same revisions, so both print the same `magic`
  lines:

  ```text
    magic 47 47 55 46  GGUF  models--ggml-org--gemma-4-E4B-it-GGUF/snapshots/a69f018d7678a2b9f5e705f8903d6fb29b9b25dc/gemma-4-E4B-it-Q8_0.gguf
    magic 47 47 55 46  GGUF  models--ggml-org--gemma-4-E4B-it-GGUF/snapshots/a69f018d7678a2b9f5e705f8903d6fb29b9b25dc/mmproj-gemma-4-E4B-it-Q8_0.gguf
    magic 47 47 55 46  GGUF  models--ggml-org--gpt-oss-120b-GGUF/snapshots/7200b74bea78b0a2964ef9f3897eefa401e890ff/gpt-oss-120b-MXFP4.gguf
    magic 47 47 55 46  GGUF  models--google--gemma-4-12B-it-qat-q4_0-gguf/snapshots/29d097773436b69ff9feafd636ab4cf873786537/gemma-4-12b-it-qat-q4_0.gguf
    magic 47 47 55 46  GGUF  models--google--gemma-4-12B-it-qat-q4_0-gguf/snapshots/29d097773436b69ff9feafd636ab4cf873786537/mmproj-gemma-4-12b-it-qat-q4_0.gguf
    magic 47 47 55 46  GGUF  models--google--gemma-4-26B-A4B-it-qat-q4_0-gguf/snapshots/d1c082be9cf3c8a514acf63b8761f4b41935842e/gemma-4-26B-it-mmproj.gguf
    magic 47 47 55 46  GGUF  models--google--gemma-4-26B-A4B-it-qat-q4_0-gguf/snapshots/d1c082be9cf3c8a514acf63b8761f4b41935842e/gemma-4-26B_q4_0-it.gguf
    magic 47 47 55 46  GGUF  models--google--gemma-4-31B-it-qat-q4_0-gguf/snapshots/59dde24573e7e61570dba08b18a2e1fe246955ed/gemma-4-31B-it-mmproj.gguf
    magic 47 47 55 46  GGUF  models--google--gemma-4-31B-it-qat-q4_0-gguf/snapshots/59dde24573e7e61570dba08b18a2e1fe246955ed/gemma-4-31B_q4_0-it.gguf
    magic 47 47 55 46  GGUF  models--google--gemma-4-E4B-it-qat-q4_0-gguf/snapshots/4b4a2c1d584be7264f87aac328a1bc739ce81b6c/gemma-4-E4B-it-mmproj.gguf
    magic 47 47 55 46  GGUF  models--google--gemma-4-E4B-it-qat-q4_0-gguf/snapshots/4b4a2c1d584be7264f87aac328a1bc739ce81b6c/gemma-4-E4B_q4_0-it.gguf
    magic 47 47 55 46  GGUF  models--mrutkows--granite-embedding-english-r2-GGUF/snapshots/f9cb7cf5dd1bf0e4f56cec624099d4000338c002/granite-embedding-english-r2-bf16.gguf
  ```

- **framework's channel and mirror**: Omarchy's stable channel. The mirrorlist is the stable
  template as shipped; pacman.conf has been edited since its template was copied, and its
  `omarchy` repository is the stable one. One update pending (`mise-bin`).

  ```text
  mirrorlist: 1 servers (/etc/pacman.d/mirrorlist)
  mirror: Server = https://stable-mirror.omarchy.org/$repo/os/$arch
  omarchy channel: /etc/pacman.d/mirrorlist matches the template of stable
  omarchy channel: /etc/pacman.conf matches no channel's template (edited since)
  omarchy channel: package omarchy 4.0.6-1
  pending: 1 packages (checkupdates, a fresh sync of the databases)
  ```

- **gb10-1's channel and mirror**: Ubuntu 24.04 (noble) from `ports.ubuntu.com`, DGX OS's
  `dgx` and `spark` repositories, CUDA and the HPC SDK from NVIDIA, Canonical's NVIDIA desktop
  edge PPA (a snapshot URL), and ESM. The lists were refreshed today, with nothing pending.

  ```text
  apt source /etc/apt/sources.list.d/tailscale.list: deb https://pkgs.tailscale.com/stable/ubuntu suites noble components main
  apt source /etc/apt/sources.list.d/ai-workbench-desktop.sources: deb https://workbench.download.nvidia.com/stable/linux/debian suites default components proprietary
  apt source /etc/apt/sources.list.d/canonical-nvidia-ubuntu-nvidia-desktop-edge-noble.sources: deb https://snapshot.ppa.launchpadcontent.net/canonical-nvidia/nvidia-desktop-edge/ubuntu/ suites noble components main
  apt source /etc/apt/sources.list.d/cuda-compute-repo.sources: deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/sbsa/ suites /
  apt source /etc/apt/sources.list.d/dgx.sources: deb https://repo.download.nvidia.com/baseos/ubuntu/noble/arm64/ suites noble noble-updates components common dgx
  apt source /etc/apt/sources.list.d/google-chrome.sources: deb https://dl.google.com/linux/chrome-stable/deb/ suites stable components main
  apt source /etc/apt/sources.list.d/nv-vulkan-desktop-ppa.sources: deb https://snapshot.ppa.launchpadcontent.net/canonical-nvidia/vulkan-packages-nv-desktop/ubuntu/ suites noble components main
  apt source /etc/apt/sources.list.d/nvhpc.sources: deb https://developer.download.nvidia.com/hpc-sdk/ubuntu/arm64/ suites /
  apt source /etc/apt/sources.list.d/spark.sources: deb https://repo.download.nvidia.com/spark/ubuntu/arm64/ suites noble-updates components common
  apt source /etc/apt/sources.list.d/ubuntu-esm-apps.sources: deb https://esm.ubuntu.com/apps/ubuntu suites noble-apps-security noble-apps-updates components main
  apt source /etc/apt/sources.list.d/ubuntu-esm-infra.sources: deb https://esm.ubuntu.com/infra/ubuntu suites noble-infra-security noble-infra-updates components main
  apt source /etc/apt/sources.list.d/ubuntu.sources: deb http://ports.ubuntu.com/ubuntu-ports/ suites noble noble-updates noble-backports components main restricted universe multiverse
  apt source /etc/apt/sources.list.d/ubuntu.sources: deb http://ports.ubuntu.com/ubuntu-ports/ suites noble-security components main restricted universe multiverse
  apt lists: last refreshed 2026-10-31 17:44:37 (0 days ago); the run never refreshes them
  pending: 0 packages (apt, from the cached lists)
  ```

- **Tailnet identifiers**: none in either output. A grep for a `100.64.0.0/10` address, the
  `fd7a:115c:a1e0:` prefix, or a `.ts.net` name finds 0 lines in each, and no line carries a
  redaction marker (`[tailnet-ipv4]`, `[tailnet-ipv6]`, `[magicdns-name]`, `[ipv4]`), so the
  guard had nothing to redact. The mirror and apt source lines pass through the guard as any
  other line does.

### What magic.sh found

- `ggml-org/gpt-oss-120b-GGUF` `gpt-oss-120b-MXFP4.gguf`: `47 47 55 46`, GGUF.
- `openai-community/gpt2` `pytorch_model.bin`: `80 02 8a 0a`, pickle, protocol 2.
- `openai-community/gpt2` `model.safetensors`: `cb 37 00 00`, unknown, with the note that
  safetensors can't be told from 4 bytes (they are its header length's low bytes) and the Hub's
  per-file scan settles it.
- A URL as the repository, `../x`, `/etc/passwd`, and `a.bin?x=1` as the file are each refused
  before any request, with exit 2. A missing file fails with curl's 404 and exit 1:

  ```text
  magic.sh: refused repository "https://huggingface.co/openai-community/gpt2": give <org>/<repo>, letters, digits, ".", "_", "-" only
  magic.sh: refused file "../x": give a path in the repository, letters, digits, ".", "_", "-", and "/" between parts only
  curl: (22) The requested URL returned error: 404
  magic.sh: request failed (curl exit 22): https://huggingface.co/openai-community/gpt2/resolve/main/no-such-file.bin
  ```

No permission prompt blocked magic.sh in this session. Its rule,
`Bash(.claude/skills/hosting-upgrades/scripts/magic.sh *)`, is not yet in `.claude/settings.json`;
the architect adds it at the walkthrough.

## Sources, watch items of any kind, and the descriptors' new watch items, 2026-10-31

Revision 4, slice 11. `sources.md` takes the fresh runs' proposed sources and the architect's
tier rulings: IBM's Granite disclosure files; Omarchy's pacman configuration at a tag and the
stable mirror's `lastsync`; the gregkh/linux commits API, which stands in where WebFetch
truncates the kernel.org ChangeLogs; a new Ubuntu table with the Launchpad publishing history and
packages.ubuntu.com; Ollama's `LLAMA_CPP_VERSION` pin, folded into its row; ggml-org's DGX Spark
benches as an attributed benchmark; NVIDIA's DGX Spark playbooks, the DGX Spark Porting Guide,
and Dell KB 000379162; and four Known leads, each with its ruling's date. SiliconBench and the
forum's Memory Saver and SparkFlash posts aren't listed, since no ruling made them leads. The
tree listing's row now points to models.md, "Artifact integrity", item 2, the per-file scan
since slice 9; the other models.md item references in `sources.md` and `SKILL.md` match the
current numbering.

Watch items are now of any kind (hardware, system, engine). `SKILL.md` answers each by name in
its kind's step (5, 5b, or 6) and report section, and the host template says so. framework's
descriptor gains the unified-KV drop with several slots (#28495, fix #29510) and the Omarchy
stable mirror's snapshot date; gb10-1's gains #30781, #27148 with its fix #27624, #29510 on
CUDA, the reboot and reset reports on the running NVIDIA kernel (forum 387397), and display
reserved memory (UEFI) on the Dell GB10. The skill lists the engine seed list once, in step 6
item 2, with its five engines.

### Commands, exactly as run

The session ran `/hosting-upgrades setup`'s logic by hand: it read `SKILL.md`, "Readiness
check", listed `docs/hosts/` (`framework.md`, `gb10-1.md`), and compared each rule with
`.claude/settings.json`'s `permissions.allow`. `.claude/settings.local.json` doesn't exist. Then,
from the repository root:

```sh
mise run check
```

### What setup would print

Nine rules, eight present and one missing:

```text
present  "Bash(ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh)"
present  "Bash(ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh)"
present  "Bash(gh search issues *)"
present  "Bash(gh search prs *)"
present  "WebSearch"
present  "WebFetch"
present  "Edit(docs/reports/**)"
present  "Bash(.claude/skills/hosting-upgrades/scripts/screen.sh *)"
missing  "Bash(.claude/skills/hosting-upgrades/scripts/magic.sh *)"
```

magic.sh's rule is missing, as expected: the architect adds it to `.claude/settings.json` at the
walkthrough.

### What the check found

`mise run check` exits 0: shellcheck passes on every tracked script, and every relative Markdown
link resolves, the new descriptor and `sources.md` lines included.

## The standards review's checks of magic.sh and the probe's new reads, 2026-10-31

Revision 4's standards review ran magic.sh with hostile arguments on this machine, from the
repository root, over this machine's own internet connection; no host was involved. Before the
fix, from a shell with `LANG=en_US.UTF-8`:

```sh
M=.claude/skills/hosting-upgrades/scripts/magic.sh
t(){ printf '%s\n' "--- $*"; "$M" "$@"; echo "rc=$?"; }
t "-o/x" "f"; t "a/b" "-o"; t "a/b" "--config"; t "a/b" "@file"; t "@a/b" "f"
t "a/b" 'f;id'; t "a/b" 'f$(id)'; t "a/b" $'f\nx'; t $'a/b\n' 'f'; t "a/b" "f/"; t "a/b" "a//b"
t "a/b" "./x"; t "a/b" "a/./b"; t "a/b" "x..y"; t "a/b" "é.bin"; t "a/b" "ﬁ"; t "a/b" "[1-9]"
t "a/b" "{a,b}"; t "a/b" "%2e%2e"; t "a/b" "a\\b"; t "a/b" " "; t "a/b" ""; t "a/b" "x" "y"
t "a/b@evil.com" "x"; t "a/b:443" "x"; t "a/b#" "x"
```

Every argument was refused with exit 2 before any request, except `é.bin` and `ﬁ`: in a UTF-8
locale bash's `[A-Za-z]` matches such letters, so both reached
`https://huggingface.co/a/b/resolve/main/<file>` (a 401, exit 1). Neither could leave
huggingface.co, but the allowlist promised ASCII. magic.sh now sets `LC_ALL=C`, and passes `-q`
first so no `~/.curlrc` adds options. After the fix:

```sh
M=.claude/skills/hosting-upgrades/scripts/magic.sh
for f in "é.bin" "ﬁ" "İ" "a/é"; do "$M" a/b "$f"; echo "rc=$?"; done; "$M" "é/b" x; echo rc=$?
"$M" "openai-community/gpt2" "pytorch_model.bin"; echo rc=$?; "$M" "ggml-org/gpt-oss-120b-GGUF" "gpt-oss-120b-MXFP4.gguf"; echo rc=$?
```

Each non-ASCII argument is refused with exit 2; `pytorch_model.bin` still reads `80 02 8a 0a`
(pickle, protocol 2) and `gpt-oss-120b-MXFP4.gguf` `47 47 55 46` (GGUF).

The review ran the probe's `first_bytes` function, extracted from `probe.sh`, on a scratch store
named `odd [x] *store* with space`, holding a Hugging Face cache with a GGUF link, a pickle linked
as `Q4/-evil $(id).gguf`, and a broken link. The slice's `find -path "$store/..."` printed
`none`, since the store's name is read as a pattern; reading the snapshot path from find's
relative output lists all three, with the broken link now `missing (a broken link)` rather than
`unreadable without root`. Its channel read, run the same way on this machine (Omarchy stable),
printed the mirror, the four repositories, both template lines, and `package omarchy 4.0.6-1`, as
on framework. `mise run check` exits 0.

## The walkthrough of revision 4, 2026-10-31

The architect had the session run slice 12's steps. It first added the ninth rule to
`.claude/settings.json` under `permissions.allow`:
`"Bash(.claude/skills/hosting-upgrades/scripts/magic.sh *)"`. With it, all nine rules the readiness
check names are present.

### Commands, exactly as run

```sh
.claude/skills/hosting-upgrades/scripts/magic.sh "ggml-org/gpt-oss-120b-GGUF" "gpt-oss-120b-MXFP4.gguf"
.claude/skills/hosting-upgrades/scripts/magic.sh "openai-community/gpt2" "pytorch_model.bin"
.claude/skills/hosting-upgrades/scripts/magic.sh "https://evil.example/x" "y"
ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh
ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh
```

### What they found

- **magic.sh:**
  - `gpt-oss-120b-MXFP4.gguf` reads `47 47 55 46`, GGUF, with exit 0.
  - `pytorch_model.bin` reads `80 02 8a 0a`, pickle protocol 2, with exit 0.
  - The URL was refused ("refused repository ... give <org>/<repo>"), with exit 2.
  - No permission prompt appeared for any of them.
- **framework:**
  - `== models ==` has 12 `magic 47 47 55 46  GGUF` lines, one per stored GGUF. The four
    safetensors snapshots get none, as the walkthrough decided (models.md, "Artifact integrity",
    item 1).
  - `== updates ==` prints the Omarchy stable mirror, `repo omarchy: Server =
    https://pkgs.omarchy.org/stable/$arch`, the stable mirrorlist template match, and
    `pending: 1 packages`: mise-bin 2026.10.23-1 -> 2026.10.24-1.
- **gb10-1:**
  - `== models ==` has 12 `magic 47 47 55 46  GGUF` lines.
  - `== updates ==` prints 13 `apt source` lines, from ports.ubuntu.com noble to the DGX, Spark,
    CUDA and HPC SDK repositories, the canonical-nvidia PPAs, and ESM. The lists were refreshed
    2026-10-31, with 0 pending.
- **No tailnet identifiers:** neither probe output holds a tailnet address or a MagicDNS name.

The walkthrough also settled two questions (goal record, Decisions, 2026-10-31):

- A card points to a disclosure file when it links the publisher's repository or organization that
  holds it.
- A stored non-GGUF file is settled by the Hub scan or magic.sh.
