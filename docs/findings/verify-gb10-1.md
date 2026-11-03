# gb10-1: verification of docs/reports/gb10-1/2026-10-31.md, 2026-11-02

Written by `/hosting-upgrades verify gb10-1` (the skill's verify mode,
`.claude/skills/hosting-upgrades/SKILL.md`, "The verify mode"), task verify-gb10 of
experiment.hosting.spike-hosting-upgrades. The session ran 2026-11-02 to 2026-11-03; times are
gb10-1's (EST) unless marked UTC. "The session" is the agent, over Tailscale SSH or from this
machine, in the architect's view; "the architect" ran a step with root.

## The report and the probe

- **The report verified:** [`docs/reports/gb10-1/2026-10-31.md`](../reports/gb10-1/2026-10-31.md),
  gb10-1's last report (2026-10-31).
- **Read:** the descriptor [`docs/hosts/gb10-1.md`](../hosts/gb10-1.md) and the policy
  [`docs/policy.md`](../policy.md), 2026-11-02.
- **Readiness:** the run's 9 rules were present, and the verify mode's 3 were missing
  (`Bash(tailscale ping -c 1 framework)`, `Bash(tailscale ping -c 1 gb10-1)`,
  `Edit(docs/findings/verify-*.md)`). The architect added them to `.claude/settings.json`
  (committed in 5c32f8d), and the mode went on.
- **The probe:** run 2026-11-02, before any step of the session. Kernel 7.0.0-1024-nvidia running,
  booted 2026-10-30 08:44:22 (`== kernel ==`); driver 580.178.04 (`== gpu ==`); the CDI spec
  `/var/run/cdi/nvidia.yaml` modified 2026-11-02 17:53:48 (`== container-runtime ==`); the
  6.17.0-1008 image and module tree still installed (`== kernel ==`); apt's lists refreshed
  2026-11-02 20:44:38, one pending, tailscale 1.104.4 → 1.104.5 (`== updates ==`); fwupd metadata
  from 2026-11-02, no updates (`== firmware-updates ==`); the user unit `update-notifier-crash`
  failed (`== units ==`); `llama` on b11669, running and healthy, and `vllm` exited
  (`== engines ==`); the preset's 9 sections, none of them a set A section (`== endpoints ==`);
  `ip_nonlocal_bind` 1 for IPv4, 0 for IPv6 (`== container-runtime ==`).
- **What moved since the report**, beside the architect's own account of what they ran on the host
  since it (2026-11-02, given as complete):
  - `apt upgrade`: 0 upgraded. The probe reads kernel 7.0.0-1024 and driver 580.178.04, as the
    report gave them (`== kernel ==`, `== gpu ==`).
  - `apt autoremove`: took three 6.17.0-1008 packages, which the probe doesn't show; the 1008
    image and module tree remain (`== kernel ==`).
  - The CDI spec was regenerated, spec 0.7.0 (`== container-runtime ==`, its modified time).
  - tailscale 1.104.5 is newly on the host's channel (`== updates ==`); the report doesn't name it.
  - The newest llama.cpp release is b12063; the report named b12019, and the task's brief b12033.
  - Not moved: the `vllm` container and the bare-metal units, the stored models, both unused
    images, the failed user unit, the sysctls, and the preset.
- **Left for later** (step 1, item 4): `--cache-ram 0`, vLLM, SGLang, and TensorRT-LLM, named only.
  They are candidates, not the host's items.

## Decisions

The architect decided each item, on the date in its row. The rows follow the report's order: its
verify item, then its holds by section ("Hardware configuration", then "System updates and
debt"), then the two closures the task's brief added, then three items new since the report.

| Item | Report verdict | Decision | Reason or outcome |
|---|---|---|---|
| llama.cpp `server-cuda13-b11669` → b12019 (Verify next), taken to the newest cuda13 build at the session's start, b12063 | verify | apply, measured by the engine rule (2026-11-02) | gates pass ("Engine pass", "Gates"); cells and verdict pending slice 3 |
| Kernel 7.0.0-1024-nvidia: GB10 reboot and reset reports; roll back to 1019, or stay | hold | close (2026-11-02) | no symptom on gb10-1, and a hold would stop the every-session update; 1019 stays installed. An unexpected boot at the session's first probe would have been an escalation: none, the boot of 2026-10-30 08:44:22 was the one the report saw (`== kernel ==`) |
| Display reserved memory (UEFI), 2 GB to Auto or 0.5 GB | hold | close (2026-11-02) | it frees memory, not speed; the set leaves headroom ("Gates", "Fit"); Dell's support is untested |
| NVIDIA driver 580.178.04 → 580.196.07 | hold | close (2026-11-02) | not on the host's channel |
| Boot-order check: the remedy is present for IPv4 | hold | close (2026-11-02) | present for IPv4; IPv6 waits on MagicDNS AAAA records ([tailscale#1152](https://github.com/tailscale/tailscale/issues/1152), as verify-framework's finding, "Routing", read it 2026-11-02) |
| Agent sessions under the minimum context | hold | apply (2026-11-02) | done: set A's section, through the clone pulled to main ("Host stack", step 4) |
| The `vllm` container, its image, and the compile cache, to remove | hold | remove (2026-11-02) | every vLLM image goes with it, through the suite, by the session; pending slice 3 |
| Bare-metal units `llama-router.service` and `vllm-server.service`, to remove | hold | remove (2026-11-02) | the suite's native uninstalls, then the architect's root steps; pending slice 3 |
| Extraneous stored models, to remove | hold | remove (2026-11-02) | the six unused snapshots, ~146G (`openai/gpt-oss-120b`, `nvidia/Gemma-4-26B-A4B-NVFP4`, `nvidia/Gemma-4-31B-IT-NVFP4`, `google/gemma-4-E4B-it`, `google/gemma-4-12B-it-qat-w4a16-ct`, `google/gemma-4-E4B-it-qat-w4a16-ct`), dry run first; ibm-granite's safetensors and ggml-org's E4B Q8_0 stay; pending slice 3 |
| Images `llama.cpp:full-cuda13-b11669` and `hello-world:latest`, to remove | hold | remove (2026-11-02) | `hello-world` by the session, pending slice 3; the full image leaves with the suite's update on adopt, pending slice 3 |
| Configuration that differs from the declared set | hold | apply (2026-11-02) | the set: agent, set A's gpt-oss-120b section (4 slots sharing 131,072); vision, 26B-A4B QAT Q4_0; audio, E4B Q8_0, following verify-framework's finding; embedding, granite BF16. E4B QAT's files stay until Google publishes a fix. Set A's section is in the preset and the router lists it (steps 4, 12); the set's load on the build that stays is pending slice 3 |
| Docker Engine 29.6.2, behind 29.9.2 | hold | close (2026-11-02) | not on the host's channel |
| Failed user unit `update-notifier-crash.service` | hold | apply: read and reset (2026-11-02) | done ("Host stack", step 3) |
| Old kernels installed: 6.17.0-1008-nvidia and 7.0.0-1019-nvidia | hold | remove 6.17.0-1008's image and modules (2026-11-02) | the architect's, with root; pending slice 3. 1019 stays, the fallback |
| The preset's sections beyond the set | – (a closure the task's brief named) | close (2026-11-02) | shared with framework, and they cost nothing unloaded |
| The gpt-oss-120b sections at 8,192 tokens per session | – (a closure the task's brief named) | close (2026-11-02) | measurement sections, which no agent loads |
| tailscale 1.104.4 → 1.104.5 | new | apply (2026-11-02), with the session's apt step, before the engine pass | done ("Host stack", step 5) |
| nvidia-spark-initcall-bl 1.0-1 → 1.0-2, newly pending 2026-11-03 | new | escalated; apply, with a reboot of its own, before the engine pass (2026-11-03); closing it for the task was rejected | done ("Host stack", steps 11, 13, 14) |
| The `llama` container's restart on b11669, so the router reads set A's section | new | apply, agreed at the same escalation (2026-11-03) | done ("Host stack", step 12) |

## Host stack

Run 2026-11-02 to 2026-11-03, in this order.

1. **apt**: the architect, with root, 2026-11-02, before the session:

   ```sh
   sudo apt update && sudo apt upgrade
   sudo apt autoremove
   ```

   0 upgraded; the autoremove took three 6.17.0-1008 packages; the CDI spec was regenerated (spec
   0.7.0). The session's first probe read these back ("The report and the probe").
2. **fwupd**: the architect, with root, 2026-11-02:

   ```sh
   sudo fwupdmgr refresh --force && fwupdmgr get-updates
   ```

   "Successfully downloaded new metadata: 14 devices are updatable; 5 devices are supported in the
   enabled remotes". No device lists an available update. With no firmware updates available: Bios
   DB Key, Bios FW Aux Authority, ESL04TBTLCZ-27J4-TYN, KEK CA, Key Exchange Key, MT2910 Family
   (ConnectX-7) (Composite), SBAT, UEFI dbx, Windows UEFI CA. At the latest available: Embedded
   Controller, TPM, UEFI CA, and two UEFI Device Firmware. The lines under "Devices that have been
   updated successfully" (Embedded Controller 0x01000800 → 0x02000c00, UEFI Device Firmware 2.1.0
   → 4.1.0, UEFI Device Firmware 0x00000507 → 0x00000516) are fwupd's history of an earlier
   update, applied under kernel 6.17.0-1008 with BIOS 5.36_2.1.0, now 5.36_4.1.0; the architect
   answered y to upload that history report to LVFS. No update was offered, so no firmware
   escalation and no firmware reboot. The next probe read fwupd metadata from 2026-11-03, no
   updates (`== firmware-updates ==`).
3. **`update-notifier-crash`**: the session, no root, 2026-11-03. It read, over SSH,
   `systemctl --user status`, `journalctl --user -u update-notifier-crash.service`, and
   `ls -la /var/crash` (empty; the directory's mtime Oct 31 07:39). The unit failed on Oct 20
   03:35:56, Oct 22 07:39:18, and Oct 31 07:39:58, each time its path unit
   (`PathChanged=/var/crash/`) fired.

   **The cause:** `/usr/lib/update-notifier/update-notifier-crash` runs under `set -e` and starts
   with `which whoopsie`. whoopsie isn't installed (`which` exits 1, and dpkg-query lists it with no
   version), so the helper exits 1 before it looks for a report. The kernel journal since
   2026-10-19 holds no segfault, Xid, NVRM error, Oops, BUG, or panic (its one match, "simple-framebuffer
   ... Registered 1 planes with drm panic", is the panic handler registering at boot), and the
   system journal records no apport report written. So no kernel, driver, or engine crash, and no
   root process's crash report to read.

   The reset, as run:

   ```sh
   ssh gb10-1 'systemctl --user reset-failed update-notifier-crash.service'
   ```

   Exit 0; `is-failed` reads `inactive`, and the user manager `running`. It recurs whenever
   `/var/crash` changes while whoopsie is absent; fixing the helper is outside the task. No
   rollback is needed: it resets a state.
4. **The clone**: the session, no root, 2026-11-03, on a clean tree:

   ```sh
   ssh gb10-1 'cd ~/repos/spike-model-engines && git pull --ff-only'
   ```

   54fcd01 → a89afc5 (main). The preset gains `[gpt-oss-120b-MXFP4-set-a]`:
   `-c 131072 --parallel 4 --kv-unified true --checkpoint-min-step 4096 --temp 1 --top-p 1 --top-k 0 --min-p 0`,
   with no drafter. Rollback: `git checkout 54fcd01`.
5. **tailscale**: the architect, with root, 2026-11-03:

   ```sh
   sudo apt-get install --only-upgrade -y tailscale
   ```

   Read back over Tailscale SSH: `tailscale version` 1.104.5, tailscaled active, dpkg-query
   1.104.5. The upgrade restarts tailscaled, which drops Tailscale SSH sessions for a moment.
   Rollback, root: `sudo apt-get install tailscale=1.104.4`.
6. **The routing check before the DHCP change**: the session, from this machine, 2026-11-03, the
   skill's routing check (SKILL.md, "The verify mode", step 6). `gb10-1.lan A: PRESENT`,
   `AAAA: PRESENT`; the bare name: tailnet; 50 connects, 0 failed, 0 over 50 ms, max 0.015100 s.
   So `gb10-1.lan` now had both records, where verify-framework's finding ("Routing") read no
   AAAA for it on 2026-11-02. During the session, three SSH connections to gb10-1 failed with
   `Permission denied (publickey)` while a retry succeeded: the name reached the LAN address,
   where OpenSSH answers, rather than Tailscale SSH on the tailnet. That is the routing fault
   itself.
7. **NetworkManager's connections**: read by the session. `Wired connection 1` (enP7s7): ipv4
   auto, ipv6 auto, and it carries the default route. `netplan-enP2p1s0f0np0` and
   `netplan-enp1s0f0np0` (the ConnectX-7): ipv4 manual, ipv6 ignore. Then tailscale0, docker0,
   and lo. Each had `dhcp-send-hostname` yes for IPv4 and IPv6. The GB10s have no Wi-Fi, so
   `Wired connection 1` is gb10-1's only DHCP connection.
8. **The DHCP hostname**: the architect, with root, 2026-11-03, the setting verify-framework's
   finding gave framework, on gb10-1's only DHCP connection:

   ```sh
   sudo nmcli con mod 'Wired connection 1' ipv4.dhcp-send-hostname no ipv6.dhcp-send-hostname no && sudo systemd-run --unit=lan-reup-wired nmcli con up 'Wired connection 1'
   ```

   Read back: `no no`. NetworkManager's journal: 07:18:42, a new DHCPv4 lease and the device
   activated; 07:18:43, a new DHCPv6 lease. Rollback, root: the same with `yes`, then `con up`.
9. **The router's leases**: the architect, with root on the OpenWrt router, 2026-11-03. First the
   search:

   ```sh
   grep -nE 'gb10-1|promaxgb10' /tmp/odhcpd.leases /tmp/hosts/odhcpd.hosts.lan /tmp/dhcp.leases
   ```

   It found gb10-1 in `/tmp/odhcpd.leases` (an IPv6 ULA lease) and `/tmp/dhcp.leases` (the host's
   IPv4 lease). Then the clearing:

   ```sh
   /etc/init.d/odhcpd stop; sed -i -E '/gb10-1|promaxgb10/d' /tmp/odhcpd.leases /tmp/hosts/odhcpd.hosts.lan; /etc/init.d/odhcpd start; /etc/init.d/dnsmasq stop; sed -i -E '/gb10-1|promaxgb10/d' /tmp/dhcp.leases; /etc/init.d/dnsmasq start
   ```

   dnsmasq's start printed udhcpc's "no lease, failing": OpenWrt's check for another DHCP server
   on the LAN, which found none. No rollback is needed: a lease renews on its own if the host
   sends its name again.
10. **The routing check after**: the session, 2026-11-03. `gb10-1.lan A: none`, `AAAA: none`; the
    bare name: tailnet; 50 connects, 0 failed, 0 over 50 ms, max 0.005878 s.
11. **The probe**: the session, 2026-11-03, after steps 3 to 10. The kernel unchanged
    (`== kernel ==`); the user manager running, no failed unit (`== units ==`); fwupd metadata
    from 2026-11-03, no updates (`== firmware-updates ==`); apt's lists 2026-11-03 06:44:37, one
    pending, nvidia-spark-initcall-bl 1.0-1 → 1.0-2, from
    <https://repo.download.nvidia.com/spark/ubuntu/arm64> noble-updates (`== updates ==`). The
    package's one file is `/etc/default/grub.d/nvidia-spark-initcall-bl.cfg`, which at 1.0-1
    reads `GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT initcall_blacklist=tegra234_cbb_init"`.
    No changelog was readable on the host.

    **An escalation**: a package newly on the channel, which sets the kernel's command line, with
    no changelog to read. The architect chose to apply it, with a reboot of its own, before the
    engine pass (2026-11-03), and rejected closing it for the task. The `llama` restart (step 12)
    was agreed at the same escalation.
12. **The `llama` restart on b11669**: the session, no root, 2026-11-03:

    ```sh
    ssh gb10-1 docker restart llama
    ```

    Exit 0. The router's `/models` then lists `gpt-oss-120b-MXFP4-set-a  unloaded`: the router
    reads its preset only at start. Rollback: the same restart.
13. **nvidia-spark-initcall-bl**: the architect, with root, 2026-11-03:

    ```sh
    sudo apt-get install --only-upgrade -y nvidia-spark-initcall-bl
    sudo update-grub
    sudo reboot
    ```

    1 upgraded; its postinst ran update-grub itself, finding 7.0.0-1024, 7.0.0-1019, and
    6.17.0-1008, so the second `update-grub` was redundant. `dpkg-query -W` reads 1.0-2, and the
    cfg now reads `... initcall_blacklist=tegra234_cbb_init,power_wrap_init`. The reboot was its
    own, after the host's other changes and before the engine pass. Rollback, root:
    `sudo apt-get install nvidia-spark-initcall-bl=1.0-1 && sudo update-grub && sudo reboot`.

**Read back** by the probe after the boot (the session, 2026-11-03):

- `== kernel ==`: running 7.0.0-1024-nvidia, booted 2026-11-03 07:25:38. The kernel log reads
  "blacklisting initcall tegra234_cbb_init" and "blacklisting initcall power_wrap_init", each
  then "blacklisted", and no fault line.
- `== units ==`: systemd's system and user managers running, no failed unit.
- `== engines ==`: `llama` on b11669 (build b11669-620d2225c), up and healthy, publishing
  `8080/tcp tailnet4`, with `ip_nonlocal_bind` 1 for IPv4, so the boot-order check passes on this
  boot. `vllm` exited (published none, not flagged, since it's stopped).
- `== endpoints ==`: `/models` lists `gpt-oss-120b-MXFP4-set-a` unloaded.
- `== updates ==`: 0 pending. `== firmware-updates ==`: no updates.
- **The routing check**: no `gb10-1.lan` A or AAAA record; the bare name: tailnet; 50 connects, 0
  failed, 0 over 50 ms, max 0.006553 s.

## Engine pass: llama.cpp b11669 to b12063

**The candidate**: b12063, the newest llama.cpp release at the session's start (published
2026-11-03T01:39:05Z, [releases](https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=5),
read 2026-11-02), by the architect's decision to take the newest cuda13 server image at the
session's start (2026-11-02). The report named b12019, and the task's brief b12033.

### Gates

Each model the pass loads with cells, one per purpose (agent, vision, and audio), through the
four gates under the policy as it read 2026-11-02, by the session's gate check. All three pass.

**What the three share**, read 2026-11-02:

- **Foreign adversaries** (15 CFR 791.4(a)): unchanged, China (including Hong Kong and Macau),
  Cuba, Iran, North Korea, Russia, and the Maduro regime; the latest amendment 89 FR 96893,
  2024-12-06 ([eCFR](https://www.ecfr.gov/api/renderer/v1/content/enhanced/current/title-15?part=791&section=791.4),
  read 2026-11-02).
- **The screening list**, as run, against the list downloaded 2026-11-02 (`.state/csl/2026-11-02.json`,
  [trade.gov CSL](https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.json),
  read 2026-11-02):

  ```sh
  .claude/skills/hosting-upgrades/scripts/screen.sh "OpenAI" "OpenAI OpCo LLC" "ggml-org" "ggml.ai" "Google LLC" "Alphabet Inc." "Google DeepMind"
  ```

  Every name: "no match on normalized name". A miss is not proof of clean.
- **The Hub organizations**: `openai` verified, "OpenAI"
  ([org](https://huggingface.co/api/organizations/openai/overview)); `google` verified, "Google"
  ([org](https://huggingface.co/api/organizations/google/overview)); `ggml-org` not verified
  ([org](https://huggingface.co/api/organizations/ggml-org/overview)); each read 2026-11-02.
- **No new revisions**: each repository's Hub `sha` equals the probe's stored snapshot.
- **The ceiling**: MemTotal 127,533,180 kB = 121.6 GiB; the policy's 10% headroom, 12.2 GiB; a
  budget of 109.5 GiB.
- **The chat-template check**, byte for byte, the session, 2026-11-02: each GGUF's embedded
  template from the Hub's API against the publisher's `chat_template.jinja`, compared with `cmp`.
  The reads, as run:

  ```sh
  curl -sf "https://huggingface.co/api/models/<repo>?expand[]=gguf" | jq -j '.gguf.chat_template'
  curl -sfL https://huggingface.co/<publisher>/raw/main/chat_template.jinja
  ```

  A first comparison with `jq -r` showed one extra trailing newline for the Gemmas: jq's own
  newline after a template that ends in one. `jq -j` settles it.

1. **Agent**: `ggml-org/gpt-oss-120b-GGUF`, `gpt-oss-120b-MXFP4.gguf`, snapshot 7200b74…, set A's
   section.
   - **Origin:** pass. A ggml-org conversion: its `.src_sha` reads
     `PRIMARY=b5c939de8f754692c1647ca79fbf85e8c1e70f8a`
     ([.src_sha](https://huggingface.co/ggml-org/gpt-oss-120b-GGUF/raw/main/.src_sha), read
     2026-11-02), `openai/gpt-oss-120b`'s `sha`
     ([record](https://huggingface.co/api/models/openai/gpt-oss-120b?expand[]=cardData&expand[]=sha&expand[]=author&expand[]=siblings&expand[]=safetensors),
     read 2026-11-02). The GGUF's `gguf.total`, 116,829,156,672, equals OpenAI's
     `safetensors.total`; architecture gpt-oss, context 131072, `base_model` `openai/gpt-oss-120b`
     ([record](https://huggingface.co/api/models/ggml-org/gpt-oss-120b-GGUF?expand[]=gguf&expand[]=sha&expand[]=cardData&expand[]=author&expand[]=lastModified),
     read 2026-11-02). The card names no teacher or base
     ([card](https://huggingface.co/openai/gpt-oss-120b/raw/main/README.md), read 2026-11-02).
     The bundled eagle3 drafter is recorded at level 5; set A loads no drafter.
   - **Artifact integrity:** pass. Probe `magic` GGUF. The Hub's scan: overall "queued", jFrog
     "queued", Protect AI "safe" with "PAIT-GGUF-100", which passes by name, as on 2026-10-31
     ([tree](https://huggingface.co/api/models/ggml-org/gpt-oss-120b-GGUF/tree/main?expand=true),
     read 2026-11-02). The template, against `openai/gpt-oss-120b`'s
     ([template](https://huggingface.co/openai/gpt-oss-120b/raw/main/chat_template.jinja), read
     2026-11-02): 16,738 = 16,738 bytes, byte-identical.
   - **Quantization floor:** pass, path 1 (native MXFP4): "The models were post-trained with
     MXFP4 quantization of the MoE weights"
     ([card](https://huggingface.co/openai/gpt-oss-120b/raw/main/README.md), read 2026-11-02).
2. **Vision**: `google/gemma-4-26B-A4B-it-qat-q4_0-gguf`, `gemma-4-26B_q4_0-it.gguf` with
   `gemma-4-26B-it-mmproj.gguf`, snapshot d1c082b….
   - **Origin:** pass, all Google. The GGUF's author is `google`, its base
     `google/gemma-4-26B-A4B-it-qat-q4_0-unquantized`
     ([record](https://huggingface.co/api/models/google/gemma-4-26B-A4B-it-qat-q4_0-gguf?expand[]=gguf&expand[]=sha&expand[]=cardData&expand[]=author&expand[]=lastModified),
     read 2026-11-02), whose base is `google/gemma-4-26B-A4B-it`
     ([record](https://huggingface.co/api/models/google/gemma-4-26B-A4B-it-qat-q4_0-unquantized?expand[]=cardData&expand[]=siblings&expand[]=sha&expand[]=author),
     read 2026-11-02), whose base is `google/gemma-4-26B-A4B`
     ([record](https://huggingface.co/api/models/google/gemma-4-26B-A4B-it?expand[]=cardData&expand[]=siblings&expand[]=sha&expand[]=author),
     read 2026-11-02), which names no base
     ([record](https://huggingface.co/api/models/google/gemma-4-26B-A4B?expand[]=cardData&expand[]=author),
     read 2026-11-02). The card names no teacher
     ([card](https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-gguf/raw/main/README.md),
     read 2026-11-02).
   - **Artifact integrity:** pass. Probe `magic` GGUF for both files. The Hub's scan: "Safe GGUF
     model" for both, overall safe; the model file carries "PAIT-GGUF-100" under Protect AI's
     safe ([tree](https://huggingface.co/api/models/google/gemma-4-26B-A4B-it-qat-q4_0-gguf/tree/main?expand=true),
     read 2026-11-02). The template, against `google/gemma-4-26B-A4B-it-qat-q4_0-unquantized`'s
     ([template](https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-unquantized/raw/main/chat_template.jinja),
     read 2026-11-02): 18,683 = 18,683 bytes, byte-identical.
   - **Quantization floor:** pass, path 1 (Google's QAT): "optimized with Quantization-Aware
     Training (QAT), which allows preserving similar quality to bfloat16"
     ([card](https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-gguf/raw/main/README.md),
     read 2026-11-02).
3. **Audio**: `ggml-org/gemma-4-E4B-it-GGUF`, `gemma-4-E4B-it-Q8_0.gguf` with
   `mmproj-gemma-4-E4B-it-Q8_0.gguf`, snapshot a69f018….
   - **Origin:** pass. Its `.src_sha` reads `PRIMARY=ee0ef6023621cff504d758262d4e04895a5af4a2`
     ([.src_sha](https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/raw/main/.src_sha), read
     2026-11-02), `google/gemma-4-E4B-it`'s `sha`
     ([record](https://huggingface.co/api/models/google/gemma-4-E4B-it?expand[]=cardData&expand[]=sha&expand[]=author&expand[]=safetensors&expand[]=siblings),
     read 2026-11-02), whose base is `google/gemma-4-E4B`, which names no base
     ([record](https://huggingface.co/api/models/google/gemma-4-E4B?expand[]=cardData&expand[]=author),
     read 2026-11-02). Its `ASSISTANT` pin is `google/gemma-4-E4B-it-assistant`, a drafter,
     recorded at level 5
     ([revision](https://huggingface.co/api/models/google/gemma-4-E4B-it-assistant/revision/8d0031ea8c2109e2b1e86bb9368a4539b537f80a),
     read 2026-11-02). The convert log loads `PRIMARY`
     ([convert.log](https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/raw/main/convert.log), read
     2026-11-02). The card names no teacher
     ([card](https://huggingface.co/google/gemma-4-E4B-it/raw/main/README.md), read 2026-11-02).
     **The parameter count**: the GGUF reads 7,518,069,290
     ([GGUF record](https://huggingface.co/api/models/ggml-org/gemma-4-E4B-it-GGUF?expand[]=gguf&expand[]=sha&expand[]=cardData&expand[]=author&expand[]=lastModified),
     read 2026-11-02) against Google's safetensors' 7,996,156,490 (the `google/gemma-4-E4B-it`
     record above). The ~478M gap matches the ~450M audio and vision encoders the card names,
     which ship in the projector; Google's own QAT GGUF reads 7,463,013,674, also without them
     ([record](https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf?expand[]=gguf),
     read 2026-11-02). Read as a pass.
   - **Artifact integrity:** pass. Probe `magic` GGUF for both files. The Hub's scan: "Safe GGUF
     model" for both; the Q8_0 file carries "PAIT-GGUF-100" under Protect AI's safe
     ([tree](https://huggingface.co/api/models/ggml-org/gemma-4-E4B-it-GGUF/tree/main?expand=true),
     read 2026-11-02). The template, against `google/gemma-4-E4B-it`'s
     ([template](https://huggingface.co/google/gemma-4-E4B-it/raw/main/chat_template.jinja), read
     2026-11-02): 18,569 = 18,569 bytes, byte-identical.
   - **Quantization floor:** pass, path 3: a third party's conversion of a dense model under 8B
     ("4.5B effective (8B with embeddings)",
     [card](https://huggingface.co/google/gemma-4-E4B-it/raw/main/README.md), read 2026-11-02), so
     Q8_0 or better; the file and its projector are Q8_0.

**Fit**: pass, **estimate**. Method: each model's measured MemAvailable footprint at b11669, from
spike-model-engines `docs/findings/bench-gb10-container.md`, "Cold load and footprint"
(attributed benchmark, on this host, read 2026-11-02); set A's derived from it.

| Model | Configuration | Footprint |
|---|---|---|
| gpt-oss-120b, set A | `-c 131072 --parallel 4 --kv-unified` | ~65.2 GiB (the 16-slot row's 65.5 GiB, less the sliding-window buffer's difference: 432 MiB at 16 sequences against 108 MiB at 4) |
| Gemma 4 26B-A4B QAT | `-c 32768 --parallel 4` | 18.1 GiB, measured |
| Gemma 4 E4B Q8_0 | `-c 32768 --parallel 4` | 10.5 GiB, measured |
| granite BF16 | as configured | 1.6 GiB, measured |
| The set | | ~95.4 GiB: 26.2 GiB free (21.6%) against the 12.2 GiB headroom; with an upper bound for context checkpoints (~+3.4 GiB), ~98.8 GiB, 22.8 GiB free |

**Beside the report:** the audio model is now E4B Q8_0 (the report gated E4B QAT Q4_0 and listed
Q8_0 as extraneous), so its gates are new readings; the agent section is set A's (~65.2 GiB
against 61.8), so the set rises to ~95.4 GiB from the report's 89.5 to 92.9; and the
chat-template check is new.

### Cells

Pending: slice 3, the engine pass.

### Transcripts

Pending: slice 3, the engine pass.

### Reasoning

Pending: slice 3, the engine pass.

### Verdict

Pending: slice 3, the engine pass.

## Removals

Pending: slice 3, the removals.

## Sources

| Source | Tier | URL | Read |
|---|---|---|---|
| The probe, `== kernel ==` … `== endpoints ==` | primary (probe) | the host | 2026-11-02, 2026-11-03 |
| The architect's account of what they ran since the report, and each decision | the architect | – | 2026-11-02, 2026-11-03 |
| NVIDIA's DGX Spark apt repository, noble-updates (nvidia-spark-initcall-bl 1.0-2, through the host's apt lists) | primary | <https://repo.download.nvidia.com/spark/ubuntu/arm64> | 2026-11-03 |
| llama.cpp releases (b12063) | primary | <https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=5> | 2026-11-02 |
| tailscale#1152, "Add AAAA records to MagicDNS" (read by verify-framework's finding) | primary | <https://github.com/tailscale/tailscale/issues/1152> | 2026-11-02 |
| eCFR, 15 CFR 791.4 | primary | <https://www.ecfr.gov/api/renderer/v1/content/enhanced/current/title-15?part=791&section=791.4> | 2026-11-02 |
| Consolidated Screening List | primary | <https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.json> | 2026-11-02 |
| Hub organization, openai | primary | <https://huggingface.co/api/organizations/openai/overview> | 2026-11-02 |
| Hub organization, google | primary | <https://huggingface.co/api/organizations/google/overview> | 2026-11-02 |
| Hub organization, ggml-org | primary | <https://huggingface.co/api/organizations/ggml-org/overview> | 2026-11-02 |
| gpt-oss-120b GGUF `.src_sha` | primary | <https://huggingface.co/ggml-org/gpt-oss-120b-GGUF/raw/main/.src_sha> | 2026-11-02 |
| openai/gpt-oss-120b record | primary | <https://huggingface.co/api/models/openai/gpt-oss-120b?expand[]=cardData&expand[]=sha&expand[]=author&expand[]=siblings&expand[]=safetensors> | 2026-11-02 |
| ggml-org/gpt-oss-120b-GGUF record | primary | <https://huggingface.co/api/models/ggml-org/gpt-oss-120b-GGUF?expand[]=gguf&expand[]=sha&expand[]=cardData&expand[]=author&expand[]=lastModified> | 2026-11-02 |
| gpt-oss-120b card | primary | <https://huggingface.co/openai/gpt-oss-120b/raw/main/README.md> | 2026-11-02 |
| gpt-oss-120b GGUF per-file scan | primary | <https://huggingface.co/api/models/ggml-org/gpt-oss-120b-GGUF/tree/main?expand=true> | 2026-11-02 |
| Publisher's template, openai/gpt-oss-120b | primary | <https://huggingface.co/openai/gpt-oss-120b/raw/main/chat_template.jinja> | 2026-11-02 |
| 26B-A4B QAT GGUF record | primary | <https://huggingface.co/api/models/google/gemma-4-26B-A4B-it-qat-q4_0-gguf?expand[]=gguf&expand[]=sha&expand[]=cardData&expand[]=author&expand[]=lastModified> | 2026-11-02 |
| 26B-A4B QAT unquantized record | primary | <https://huggingface.co/api/models/google/gemma-4-26B-A4B-it-qat-q4_0-unquantized?expand[]=cardData&expand[]=siblings&expand[]=sha&expand[]=author> | 2026-11-02 |
| 26B-A4B-it record | primary | <https://huggingface.co/api/models/google/gemma-4-26B-A4B-it?expand[]=cardData&expand[]=siblings&expand[]=sha&expand[]=author> | 2026-11-02 |
| 26B-A4B record | primary | <https://huggingface.co/api/models/google/gemma-4-26B-A4B?expand[]=cardData&expand[]=author> | 2026-11-02 |
| 26B-A4B QAT GGUF card | primary | <https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-gguf/raw/main/README.md> | 2026-11-02 |
| 26B-A4B QAT GGUF per-file scan | primary | <https://huggingface.co/api/models/google/gemma-4-26B-A4B-it-qat-q4_0-gguf/tree/main?expand=true> | 2026-11-02 |
| Publisher's template, 26B-A4B QAT unquantized | primary | <https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-unquantized/raw/main/chat_template.jinja> | 2026-11-02 |
| E4B GGUF `.src_sha` | primary | <https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/raw/main/.src_sha> | 2026-11-02 |
| google/gemma-4-E4B-it record | primary | <https://huggingface.co/api/models/google/gemma-4-E4B-it?expand[]=cardData&expand[]=sha&expand[]=author&expand[]=safetensors&expand[]=siblings> | 2026-11-02 |
| google/gemma-4-E4B record | primary | <https://huggingface.co/api/models/google/gemma-4-E4B?expand[]=cardData&expand[]=author> | 2026-11-02 |
| E4B assistant (drafter) revision | primary | <https://huggingface.co/api/models/google/gemma-4-E4B-it-assistant/revision/8d0031ea8c2109e2b1e86bb9368a4539b537f80a> | 2026-11-02 |
| E4B GGUF convert log | primary | <https://huggingface.co/ggml-org/gemma-4-E4B-it-GGUF/raw/main/convert.log> | 2026-11-02 |
| E4B-it card | primary | <https://huggingface.co/google/gemma-4-E4B-it/raw/main/README.md> | 2026-11-02 |
| ggml-org/gemma-4-E4B-it-GGUF record | primary | <https://huggingface.co/api/models/ggml-org/gemma-4-E4B-it-GGUF?expand[]=gguf&expand[]=sha&expand[]=cardData&expand[]=author&expand[]=lastModified> | 2026-11-02 |
| E4B QAT GGUF record (parameter count) | primary | <https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf?expand[]=gguf> | 2026-11-02 |
| E4B GGUF per-file scan | primary | <https://huggingface.co/api/models/ggml-org/gemma-4-E4B-it-GGUF/tree/main?expand=true> | 2026-11-02 |
| Publisher's template, E4B-it | primary | <https://huggingface.co/google/gemma-4-E4B-it/raw/main/chat_template.jinja> | 2026-11-02 |
| spike-model-engines bench-gb10-container.md, "Cold load and footprint" | attributed benchmark | spike-model-engines `docs/findings/bench-gb10-container.md` | 2026-11-02 |
