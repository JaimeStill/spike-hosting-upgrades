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
