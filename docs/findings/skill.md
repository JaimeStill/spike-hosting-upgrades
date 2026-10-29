# Finding: the skill's read-only probe on both hosts

Task `skill`, dated 2026-10-29. What the hosting-upgrades skill's probe
(`.claude/skills/hosting-upgrades/scripts/probe.sh`) read on the Framework and gb10-1 while the
skill was built. Nothing here is a performance measurement; the probe reads the host stack and
changes nothing.

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
