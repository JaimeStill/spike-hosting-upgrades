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
- **The probe:** run 2026-11-02, before any step of the session, as every probe of the session
  was run, from the project root:
  `ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh`. Kernel
  7.0.0-1024-nvidia running, booted 2026-10-30 08:44:22 (`== kernel ==`); driver 580.178.04
  (`== gpu ==`); the CDI spec `/var/run/cdi/nvidia.yaml` modified 2026-11-02 17:53:48
  (`== container-runtime ==`); the 6.17.0-1008 image and module tree still installed
  (`== kernel ==`); apt's lists refreshed 2026-11-02 20:44:38, one pending, tailscale 1.104.4 →
  1.104.5 (`== updates ==`); fwupd metadata from 2026-11-02, no updates
  (`== firmware-updates ==`); the user unit `update-notifier-crash` failed (`== units ==`);
  `llama` on b11669, running and healthy, and `vllm` exited (`== engines ==`); the preset's 9
  sections, none of them a set A section (`== endpoints ==`); `ip_nonlocal_bind` 1 for IPv4, 0
  for IPv6 (`== container-runtime ==`).
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
| llama.cpp `server-cuda13-b11669` → b12019 (Verify next), taken to the newest cuda13 build at the session's start, b12063 | verify | apply, measured by the engine rule (2026-11-02) | gates pass ("Engine pass", "Gates"); the engine rule gave roll back (anchor B −1.87%, ASR A −3.79%, ASR B −11.07%), and the architect overruled it: adopted, b12063 serves (2026-11-03; "Engine pass", "Verdict") |
| Kernel 7.0.0-1024-nvidia: GB10 reboot and reset reports; roll back to 1019, or stay | hold | close (2026-11-02) | no symptom on gb10-1, and a hold would stop the every-session update; 1019 stays installed. An unexpected boot at the session's first probe would have been an escalation: none, the boot of 2026-10-30 08:44:22 was the one the report saw (`== kernel ==`) |
| Display reserved memory (UEFI), 2 GB to Auto or 0.5 GB | hold | close (2026-11-02) | it frees memory, not speed; the set leaves headroom ("Gates", "Fit"); Dell's support is untested |
| NVIDIA driver 580.178.04 → 580.196.07 | hold | close (2026-11-02) | not on the host's channel |
| Boot-order check: the remedy is present for IPv4 | hold | close (2026-11-02) | present for IPv4; IPv6 waits on MagicDNS AAAA records ([tailscale#1152](https://github.com/tailscale/tailscale/issues/1152), as verify-framework's finding, "Routing", read it 2026-11-02) |
| Agent sessions under the minimum context | hold | apply (2026-11-02) | done: set A's section, through the clone pulled to main ("Host stack", step 4) |
| The `vllm` container, its image, and the compile cache, to remove | hold | remove (2026-11-02) | every vLLM image goes with it, through the suite, by the session; done ("Removals", 1) |
| Bare-metal units `llama-router.service` and `vllm-server.service`, to remove | hold | remove (2026-11-02) | the suite's native uninstalls, then the architect's root steps; done ("Removals", 2) |
| Extraneous stored models, to remove | hold | remove (2026-11-02) | the six unused snapshots, ~146G (`openai/gpt-oss-120b`, `nvidia/Gemma-4-26B-A4B-NVFP4`, `nvidia/Gemma-4-31B-IT-NVFP4`, `google/gemma-4-E4B-it`, `google/gemma-4-12B-it-qat-w4a16-ct`, `google/gemma-4-E4B-it-qat-w4a16-ct`), dry run first; ibm-granite's safetensors and ggml-org's E4B Q8_0 stay; done, by the exclusive-blob method in place of `hf cache rm`, 143.9 GiB freed ("Removals", 3) |
| Images `llama.cpp:full-cuda13-b11669` and `hello-world:latest`, to remove | hold | remove (2026-11-02) | done: `hello-world` by the session ("Removals", 4); the full image left with the suite's update to b12063 ("Engine pass", "Cells", the move) |
| Configuration that differs from the declared set | hold | apply (2026-11-02) | the set: agent, set A's gpt-oss-120b section (4 slots sharing 131,072); vision, 26B-A4B QAT Q4_0; audio, E4B Q8_0, following verify-framework's finding; embedding, granite BF16. E4B QAT's files stay until Google publishes a fix. Set A's section is in the preset and the router lists it (steps 4, 12); the set loaded on b12063, the build that stays, one model per purpose, MemAvailable 22.0 GiB after ("Engine pass", "Verdict") |
| Docker Engine 29.6.2, behind 29.9.2 | hold | close (2026-11-02) | not on the host's channel |
| Failed user unit `update-notifier-crash.service` | hold | apply: read and reset (2026-11-02) | done ("Host stack", step 3); it failed again five minutes after the reboot and was reset again ("Host stack", step 15) |
| Old kernels installed: 6.17.0-1008-nvidia and 7.0.0-1019-nvidia | hold | remove 6.17.0-1008's image and modules (2026-11-02) | the architect's, with root; done, 397 MB freed ("Removals", 5). 1019 stays, the fallback |
| The preset's sections beyond the set | – (a closure the task's brief named) | close (2026-11-02) | shared with framework, and they cost nothing unloaded |
| The gpt-oss-120b sections at 8,192 tokens per session | – (a closure the task's brief named) | close (2026-11-02) | measurement sections, which no agent loads |
| tailscale 1.104.4 → 1.104.5 | new | apply (2026-11-02), with the session's apt step, before the engine pass | done ("Host stack", step 5) |
| nvidia-spark-initcall-bl 1.0-1 → 1.0-2, newly pending 2026-11-03 | new | escalated; apply, with a reboot of its own, before the engine pass (2026-11-03); closing it for the task was rejected | done ("Host stack", steps 11 and 13, and the read back) |
| The `llama` container's restart on b11669, so the router reads set A's section | new | apply, agreed at the same escalation (2026-11-03) | done ("Host stack", step 12) |
| 20 noble-security updates (bind9, gnome-shell, gvfs, libsoup, libpcre2, libmspack), newly pending after the engine pass, 2026-11-03 | new | apply now, no reboot, before the walkthrough (2026-11-03) | done ("Host stack", step 14); the reboot flag gnome-shell set is closed as not needed: serving needs no reboot, and the architect has ruled out further reboots of gb10-1 |

## Host stack

Run 2026-11-02 to 2026-11-03, in this order.

1. **apt**: the architect, with root, 2026-11-02, before the session:

   ```sh
   sudo apt update && sudo apt upgrade
   sudo apt autoremove
   nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml
   ```

   0 upgraded; the autoremove took three 6.17.0-1008 packages; the CDI spec was regenerated (spec
   0.7.0), as the architect gave the command on 2026-11-03; it writes under `/var/run`, so it ran
   as root. The session's first probe read these back ("The report and the probe"). The spec was
   regenerated again at the reboot of 2026-11-03 (`/var/run/cdi/nvidia.yaml` modified 07:25:49,
   the spec-review probe's `== container-runtime ==`).
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
3. **`update-notifier-crash`**: the session, no root, 2026-11-03. The reads, as run, in order.
   The first also read the clone's state for step 4 and each connection's `dhcp-send-hostname`
   for step 7:

   ```sh
   ssh gb10-1 'cd ~/repos/spike-model-engines && echo "== clone"; git status -sb | head -3; git log --oneline -1; git fetch -q origin && git log --oneline HEAD..origin/main | head; echo "== nmcli"; nmcli -t -f NAME,TYPE,DEVICE con show; for c in $(nmcli -t -f NAME con show | tr " " "_"); do :; done; nmcli -t -f NAME con show | while IFS= read -r c; do echo "$c: $(nmcli -g ipv4.dhcp-send-hostname,ipv6.dhcp-send-hostname con show "$c" | paste -sd" ")"; done; echo "== unit"; systemctl --user status update-notifier-crash.service --no-pager 2>&1 | head -15; echo "== journal"; journalctl --user -u update-notifier-crash.service --no-pager -n 30 2>&1 | tail -30; echo "== /var/crash"; ls -la /var/crash'
   ssh gb10-1 'id -nG; for t in "2026-10-31 07:38" "2026-10-22 07:38" "2026-10-20 03:35"; do echo "== $t"; journalctl --since "$t" --until "$(date -d "$t 3 min" "+%F %T")" --no-pager -o short 2>&1 | grep -iE "apport|whoopsie|crash|segfault|core|Xid|NVRM|llama" | head -8; done; echo "== helper"; sed -n 1,40p /usr/lib/update-notifier/update-notifier-crash 2>/dev/null; cat /usr/lib/systemd/user/update-notifier-crash.path'
   ssh gb10-1 'which whoopsie; echo "which exit $?"; dpkg-query -W whoopsie apport 2>&1; echo "== kernel/driver/engine faults since 2026-10-19"; journalctl -k --since 2026-10-19 --no-pager 2>/dev/null | grep -icE "segfault|Xid|NVRM.*(error|fault)|Oops|BUG:|panic"; journalctl --since 2026-10-19 --no-pager 2>/dev/null | grep -iE "segfault|traps:|Xid|apport.*(called|writing|report)" | tail -8; echo "== what touches /var/crash at 07:39"; systemctl list-timers --all --no-pager 2>/dev/null | grep -iE "apport|crash|tmpfiles|daily" ; ls /etc/cron.daily | grep -i apport'
   ssh gb10-1 'journalctl -k --since 2026-10-19 --no-pager -o short 2>/dev/null | grep -iE "segfault|Xid|NVRM.*(error|fault)|Oops|BUG:|panic"'
   ```

   `/var/crash` was empty, the directory's mtime Oct 31 07:39. The unit failed on Oct 20
   03:35:56, Oct 22 07:39:18, and Oct 31 07:39:58, each time its path unit
   (`PathChanged=/var/crash/`) fired. The third call read `which exit 1`; `apport
   2.28.3-0ubuntu0.1`, and `whoopsie` with no version; a count of 1 kernel match; apport.service's
   stop and start lines around the reboot of 2026-10-30 only; the tmpfiles and apt-daily timers;
   and `apport` in `/etc/cron.daily`. The fourth printed the one kernel match.

   **The cause:** `/usr/lib/update-notifier/update-notifier-crash` runs under `set -e` and starts
   with `which whoopsie`. whoopsie isn't installed (`which` exits 1, and dpkg-query lists it with no
   version), so the helper exits 1 before it looks for a report. The kernel journal since
   2026-10-19 holds no segfault, Xid, NVRM error, Oops, BUG, or panic (its one match,
   "simple-framebuffer ... Registered 1 planes with drm panic", is the panic handler registering
   at boot), and the system journal records no apport report written. So no kernel, driver, or
   engine crash, and no root process's crash report to read.

   The reset, as run:

   ```sh
   ssh gb10-1 'systemctl --user reset-failed update-notifier-crash.service; echo "exit $?"; systemctl --user is-failed update-notifier-crash.service; systemctl --user is-system-running'
   ```

   Exit 0; `is-failed` reads `inactive`, and the user manager `running`. It recurs whenever
   `/var/crash` changes while whoopsie is absent; fixing the helper is outside the task. No
   rollback is needed: it resets a state.
4. **The clone**: the session, no root, 2026-11-03, on a clean tree (step 3's first call read its
   state first). The pull, as run:

   ```sh
   ssh gb10-1 'cd ~/repos/spike-model-engines && git status --porcelain | head; git pull --ff-only 2>&1 | tail -3; echo "exit $?"; git log --oneline -1; grep -n "^\[" host/llama-preset/models.ini'
   ```

   54fcd01 → a89afc5 (main). The preset gains `[gpt-oss-120b-MXFP4-set-a]`:
   `-c 131072 --parallel 4 --kv-unified true --checkpoint-min-step 4096 --temp 1 --top-p 1 --top-k 0 --min-p 0`,
   with no drafter. Rollback: `git checkout 54fcd01`. Then the router's `/models`, from this
   machine, the read step 12 repeats after the restart:

   ```sh
   curl -s --connect-timeout 5 http://gb10-1:8080/models | jq -r '.data[] | "\(.id)  \(.status.value // .status)"'
   ```
5. **tailscale**: the architect, with root, 2026-11-03:

   ```sh
   sudo apt-get install --only-upgrade -y tailscale
   ```

   Read back by the session, from this machine, as run:

   ```sh
   tailscale ping -c 1 gb10-1
   for i in 1 2 3; do ssh -o ConnectTimeout=10 gb10-1 'tailscale version | head -1; systemctl is-active tailscaled; dpkg-query -W tailscale' && break; echo "attempt $i failed"; done
   ```

   `tailscale version` 1.104.5, tailscaled active, dpkg-query 1.104.5. The upgrade restarts
   tailscaled, which drops Tailscale SSH sessions for a moment. Rollback, root:
   `sudo apt-get install tailscale=1.104.4`.
6. **The routing check before the DHCP change**: the session, from this machine, 2026-11-03, the
   skill's routing check (SKILL.md, "The verify mode", step 6), as run here, at step 10, and in the
   read back after the boot:

   ```sh
   h=gb10-1; for ty in A AAAA; do echo "$h.lan $ty: $(resolvectl query -t $ty $h.lan >/dev/null 2>&1 && echo PRESENT || echo none)"; done
   t=$(tailscale ip $h); echo "bare name: $(getent ahosts $h | cut -d' ' -f1 | sort -u | while read -r a; do echo "$t" | grep -qxF "$a" && echo tailnet || echo NOT-TAILNET; done | paste -sd' ')"
   for i in $(seq 1 50); do curl -s -o /dev/null -w '%{time_connect} ' --connect-timeout 5 http://$h:8080/health || echo -n "FAIL "; done | tr ' ' '\n' | awk 'NF{n++; if($NF=="FAIL")f++; else if($NF>0.05)s++; if($NF>m)m=$NF} END{print n" connects, "f+0" failed, "s+0" over 50 ms, max "m" s"}'
   ```

   It read `gb10-1.lan A: PRESENT`, `AAAA: PRESENT`; the bare name: tailnet; 50 connects, 0
   failed, 0 over 50 ms, max 0.015100 s. So `gb10-1.lan` now had both records, where
   verify-framework's finding ("Routing") read no AAAA for it on 2026-11-02. During the session,
   three SSH connections to gb10-1 failed with `Permission denied (publickey)` while a retry
   succeeded: the name reached the LAN address, where OpenSSH answers, rather than Tailscale SSH
   on the tailnet. That is the routing fault itself.
7. **NetworkManager's connections**: read by the session, with no root, in a retry loop, as run;
   attempt 1 failed with `Permission denied (publickey)`:

   ```sh
   for i in 1 2 3; do ssh -o ConnectTimeout=10 gb10-1 'nmcli -t -f NAME,DEVICE,STATE con show --active; for c in "Wired connection 1" netplan-enP2p1s0f0np0 netplan-enp1s0f0np0; do d=$(nmcli -g GENERAL.DEVICES con show "$c"); echo "$c ($d): $(nmcli -g ipv4.method,ipv6.method con show "$c" | paste -sd" ") carrier=$(cat /sys/class/net/$d/carrier 2>/dev/null)"; done; ip route show default | sed -E "s/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/<addr>/g"' && break; echo "attempt $i failed"; done
   ```

   `Wired connection 1` (enP7s7): ipv4 auto, ipv6 auto, and it carries the default route.
   `netplan-enP2p1s0f0np0` and `netplan-enp1s0f0np0` (the ConnectX-7): ipv4 manual, ipv6 ignore.
   Then tailscale0, docker0, and lo. Each had `dhcp-send-hostname` yes for IPv4 and IPv6 (step 3's
   first call). The
   GB10s have no Wi-Fi, so `Wired connection 1` is gb10-1's only DHCP connection.
8. **The DHCP hostname**: the architect, with root, 2026-11-03, the setting verify-framework's
   finding gave framework, on gb10-1's only DHCP connection:

   ```sh
   sudo nmcli con mod 'Wired connection 1' ipv4.dhcp-send-hostname no ipv6.dhcp-send-hostname no && sudo systemd-run --unit=lan-reup-wired nmcli con up 'Wired connection 1'
   ```

   Read back by the session, as run:

   ```sh
   for i in 1 2 3; do ssh -o ConnectTimeout=10 gb10-1 'nmcli -g ipv4.dhcp-send-hostname,ipv6.dhcp-send-hostname con show "Wired connection 1" | paste -sd" "; systemctl status lan-reup-wired --no-pager 2>&1 | head -3' && break; echo "attempt $i failed"; done
   ssh -o ConnectTimeout=10 gb10-1 'journalctl -u NetworkManager --since "-2h" --no-pager -o short 2>/dev/null | grep -E "Wired connection 1|enP7s7" | grep -iE "activation|state change.*activated|dhcp4|dhcp6" | tail -5 | sed -E "s/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/<v4>/g; s/[0-9a-f]{1,4}(:[0-9a-f]{0,4}){3,7}/<v6>/g"; journalctl --since "-2h" --no-pager 2>/dev/null | grep -c lan-reup-wired'
   ```

   `no no`; "Unit lan-reup-wired.service could not be found.", since the transient unit had
   finished. NetworkManager's journal: 07:18:42, a new DHCPv4 lease and the device activated;
   07:18:43, a new DHCPv6 lease; `lan-reup-wired` in the journal 5 times. Rollback, root: the
   same with `yes`, then `con up`.
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
    <https://repo.download.nvidia.com/spark/ubuntu/arm64> noble-updates (`== updates ==`). Then
    the session's reads of the package, as run; the second call also ran step 12's restart:

    ```sh
    ssh gb10-1 'apt-cache show nvidia-spark-initcall-bl 2>/dev/null | grep -E "^(Version|Description|Depends|Source)" ; dpkg -L nvidia-spark-initcall-bl 2>/dev/null; apt-get changelog nvidia-spark-initcall-bl 2>/dev/null | head -20'
    ssh gb10-1 'echo "== cfg (1.0-1)"; cat /etc/default/grub.d/nvidia-spark-initcall-bl.cfg; echo "== cmdline"; cat /proc/cmdline | sed -E "s/root=[^ ]+/root=<root>/"; echo "== restart"; docker restart llama; echo "exit $?"'
    ```

    The package's one file is `/etc/default/grub.d/nvidia-spark-initcall-bl.cfg`, which at 1.0-1
    reads `GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT initcall_blacklist=tegra234_cbb_init"`.
    No changelog was readable on the host.

    **An escalation**: a package newly on the channel, which sets the kernel's command line, with
    no changelog to read. The architect chose to apply it, with a reboot of its own, before the
    engine pass (2026-11-03), and rejected closing it for the task. The `llama` restart (step 12)
    was agreed at the same escalation.
12. **The `llama` restart on b11669**: the session, no root, 2026-11-03, in step 11's second call
    (`docker restart llama; echo "exit $?"`). Exit 0. After `sleep 20`, the router's `/models`,
    read as in step 4, lists `gpt-oss-120b-MXFP4-set-a  unloaded`: the router
    reads its preset only at start. Rollback: the same restart.
13. **nvidia-spark-initcall-bl**: the architect, with root, 2026-11-03:

    ```sh
    sudo apt-get install --only-upgrade -y nvidia-spark-initcall-bl
    sudo update-grub
    sudo reboot
    ```

    1 upgraded; its postinst ran update-grub itself, finding 7.0.0-1024, 7.0.0-1019, and
    6.17.0-1008, so the second `update-grub` was redundant. `dpkg-query -W nvidia-spark-initcall-bl`
    (the architect's, on the host) reads 1.0-2, and the cfg now reads
    `... initcall_blacklist=tegra234_cbb_init,power_wrap_init`. Before the reboot, the session
    read, as run:

    ```sh
    ssh -o ConnectTimeout=10 gb10-1 'uptime -s; cat /proc/cmdline | grep -o "initcall_blacklist=[^ ]*"'
    ```

    Still booted 2026-10-30 08:44:22, with the old argument. The reboot was its own, after the
    host's other changes and before the engine pass. Rollback, root:
    `sudo apt-get install nvidia-spark-initcall-bl=1.0-1 && sudo update-grub && sudo reboot`.

**Read back** by the probe after the boot (the session, 2026-11-03), with two reads beside it,
as run (the probe's output saved, then grepped):

```sh
ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh
ssh gb10-1 'cat /proc/cmdline | grep -o "initcall_blacklist=[^ ]*"; journalctl -k -b --no-pager 2>/dev/null | grep -iE "segfault|Xid|NVRM.*(error|fault)|Oops|BUG:|panic|initcall" | grep -v "drm panic" | head'
curl -s http://gb10-1:8080/models | jq -r '.data[] | select(.id|test("set-a")) | "\(.id)  \(.status.value // .status)"'
```

The kernel log's match on `initcall` includes its command line, not reproduced here.

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

**After the engine pass and the removals**, before the walkthrough. The probe after the removals
(2026-11-03, "Removals") read apt's lists refreshed 2026-11-03 12:25:59 and 20 updates newly
pending, all from noble-security: bind9-dnsutils, bind9-host, bind9-libs; gnome-shell,
gnome-shell-common, gnome-shell-extension-prefs; gvfs, gvfs-backends, gvfs-common, gvfs-daemons,
gvfs-fuse, gvfs-libs; libsoup-2.4-1, libsoup2.4-common, libsoup-3.0-0, libsoup-3.0-common,
gir1.2-soup-3.0; libpcre2-8-0, libpcre2-32-0; libmspack0t64 (`== updates ==`). None reaches the
engine container or the kernel. It also read `update-notifier-crash` failed again (`== units ==`).

14. **The security updates**: the architect decided to apply them now, with no reboot, before the
    walkthrough (2026-11-03), and ran them, with root, on the host:

    ```sh
    sudo apt-get upgrade -y
    ```

    "20 upgraded, 0 newly installed, 0 to remove and 0 not upgraded", 4,443 kB fetched from
    ports.ubuntu.com noble-security. needrestart then restarted 22 services (accounts-daemon,
    colord, cron, cups-browsed, cups, fwupd, gnome-remote-desktop, multipathd, packagekit, polkit,
    smartmontools, ssh, switcheroo-control, systemd-journald, systemd-networkd, systemd-resolved,
    systemd-timesyncd, systemd-udevd, tailscaled, udisks2, upower) and the systemd manager.
    Restarting tailscaled dropped the architect's SSH session, which reconnected; docker and the
    `llama` container were not restarted. The login banner then read "\*\*\* System restart
    required \*\*\*": `/var/run/reboot-required` (13:21) names one package in
    `/var/run/reboot-required.pkgs`, gnome-shell, which takes effect at the next desktop login.
    Serving needs no reboot, and the architect has ruled out further reboots of gb10-1 ("There
    should be no more reboots of gb10-1"), so the flag is closed as not needed.

    Read back by the session, as run:

    ```sh
    ssh -o ConnectTimeout=10 gb10-1 'ls -l /var/run/reboot-required* 2>&1; cat /var/run/reboot-required.pkgs 2>&1; uptime -s; systemctl is-system-running; systemctl --failed --no-legend; systemctl --user --failed --no-legend; docker ps --format "{{.Names}} {{.Image}} {{.Status}}"'
    ```

    `llama` on b12063, up 39 minutes and healthy, the set's four models loaded; the probe: kernel
    7.0.0-1024-nvidia, booted 07:25:38, `reboot: pending (/var/run/reboot-required)`
    (`== kernel ==`); 0 pending (`== updates ==`); no failed system unit (`== units ==`).
    Rollback, root: `sudo apt-get install <package>=<old version>` per package, from the
    archive; the old versions are the probe's "from" versions
    (`.state/verify/gb10-1/probe-removals.txt`, `== updates ==`).
15. **`update-notifier-crash`, again**: it failed 2026-11-03 07:30:45, five minutes after the
    reboot, when `/var/crash` changed (the directory's mtime 07:30; it is empty). The journal for
    13:15–13:30 holds no crash. The read, as run (step 14's read-back listed the failed user unit
    first):

    ```sh
    ssh -o ConnectTimeout=10 gb10-1 'ls -la /var/crash; systemctl --user status update-notifier-crash.service --no-pager 2>&1 | sed -n 3,4p; journalctl --since "13:15" --until "13:30" --no-pager 2>/dev/null | grep -iE "segfault|core dump|apport|crash|traps:|Xid|NVRM" | head -15'
    ```

    The cause is step 3's: whoopsie is absent. The session reset it again, with no root, as run:

    ```sh
    ssh gb10-1 'systemctl --user reset-failed update-notifier-crash.service; echo "exit $?"'
    ```

    Exit 0; the probe then read no failed user unit (`== units ==`). It recurs on any change to
    `/var/crash` while whoopsie is absent, as step 3 says.

## Engine pass: llama.cpp b11669 to b12063

**The candidate**: b12063, the newest llama.cpp release at the session's start (published
2026-11-03T01:39:05Z, [releases](https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=5),
read 2026-11-02), by the architect's decision to take the newest cuda13 server image at the
session's start (2026-11-02). The report named b12019, and the task's brief b12033. Its image, read
by WebFetch of
<https://github.com/ggml-org/llama.cpp/pkgs/container/llama.cpp/versions?filters%5Bversion_type%5D=tagged>
(2026-11-03): `server-cuda13-b12063` listed. The release list was read by WebFetch of the
releases URL above.

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
  The reads, as run, for the three pairs (the session ran them in a shell loop in its
  scratchpad; these are the loop's commands, pair by pair):

  ```sh
  curl -sf "https://huggingface.co/api/models/ggml-org/gpt-oss-120b-GGUF?expand[]=gguf" | jq -j '.gguf.chat_template' > gptoss.raw
  curl -sfL "https://huggingface.co/openai/gpt-oss-120b/raw/main/chat_template.jinja" > gptoss.pub
  cmp gptoss.raw gptoss.pub
  curl -sf "https://huggingface.co/api/models/google/gemma-4-26B-A4B-it-qat-q4_0-gguf?expand[]=gguf" | jq -j '.gguf.chat_template' > g26.raw
  curl -sfL "https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-unquantized/raw/main/chat_template.jinja" > g26.pub
  cmp g26.raw g26.pub
  curl -sf "https://huggingface.co/api/models/ggml-org/gemma-4-E4B-it-GGUF?expand[]=gguf" | jq -j '.gguf.chat_template' > e4b.raw
  curl -sfL "https://huggingface.co/google/gemma-4-E4B-it/raw/main/chat_template.jinja" > e4b.pub
  cmp e4b.raw e4b.pub
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

**Pass 1, a record only.** 2026-11-03, from this machine on the LAN: `tailscale ping -c 1 gb10-1`
read a direct path in 2 ms, and the routing check passed (max connect 6.6 ms). Its two cells,
b11669's anchors, at 12:33:17 UTC (results under `.state/verify/gb10-1/pass1/`). The call, as
run:

```sh
cd ~/experiments/spike-hosting-upgrades && . /tmp/claude-1000/-home-jaime-experiments-spike-hosting-upgrades/77aee5dc-bbd6-4762-aff2-7ee445a2e98e/scratchpad/pass.sh && stack b11669 && agent b11669
```

That `pass.sh`, in the session's scratchpad, has since been cleared. Its text matched pass 2's
`pass.sh` (below) but for the pass directory, `S=.state/verify/gb10-1/pass1`; pass 2's file makes
the directory an argument, and `stack()`'s ping and props reads are unchanged.

| Cell | Requests | Output tok/s | TTFT median ms | ITL median ms |
|---|---|---|---|---|
| Anchor A | 8/8 | 48.94 | 414 | 18.8 |
| Anchor B | 32/32 | 80.78 | 1,837 | 43.8 |

The session paused there while the architect left for the office. On return, the checks, as run:

```sh
ls .state/verify/gb10-1/pass1/; tailscale ping -c 3 gb10-1 2>&1 | sed -E 's/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/<addr>/g'; ssh gb10-1 'uptime -s; uname -r'; curl -s http://gb10-1:8080/props | jq -r '.build_info'; curl -s http://gb10-1:8080/models | jq -c '[.data[]|select(.status.value!="unloaded")|.id]'
```

This machine reached gb10-1 only through Tailscale's DERP relay, region iad, in 51–65 ms ("direct
connection not established"); booted 07:25:38, 7.0.0-1024-nvidia, build b11669-620d2225c, set A
loaded. The routing check, as "Host stack", step 6 gives it, read `gb10-1.lan A:
none`, `AAAA: none`; the bare name: tailnet; 50 connects, 0 failed, 50 over 50 ms, max
0.247762 s. Its latency condition failed, which the skill makes a pause.

**An escalation**: the architect chose to restart the pass from the anchors over the relayed path,
all 12 cells on one path, overruling the latency condition ("I don't think the latency has a
meaningful impact on the results"), and rejected waiting for the LAN (2026-11-03). So pass 1 is
abandoned: its anchors are compared with no cell of pass 2, and they stand only beside the host's
earlier readings (below).

**Pass 2, the pass that counts**, 2026-11-03 17:35–17:58 UTC, over DERP(iad), from this machine
(GuideLLM 0.8.1, `mise.bench.toml`). Every cell ran on kernel 7.0.0-1024-nvidia, on the boot of
07:25:38, the host stack the probe after the boot read ("Host stack", the read back). The helpers,
as run (`. .state/verify/gb10-1/pass.sh pass2` from the project root; `.state/` is ignored by git,
so the file is not committed), whole:

```sh
# verify-gb10 engine pass helpers; source from the project root: . .state/verify/gb10-1/pass.sh <pass dir name>
U=http://gb10-1:8080; S=.state/verify/gb10-1/${1:-pass2}; mkdir -p $S
export GUIDELLM__SPEC__BACKEND__TARGET="$U"
A=gpt-oss-120b-MXFP4-set-a; V=google/gemma-4-26B-A4B-it-qat-q4_0-gguf:Q4_0; Q8=ggml-org/gemma-4-E4B-it-GGUF:Q8_0
api() { curl -s -X POST "$U/models/$1" -H "Content-Type: application/json" -d "{\"model\": \"$2\"}"; echo " $1 $2"; }
state() { curl -s $U/models | jq -c '[.data[] | select(.status.value!="unloaded") | {id, s: .status.value}]'; }
wait_for() { for i in $(seq 1 200); do curl -s $U/models | jq -e --arg m "$1" --arg s "$2" '.data[]|select(.id==$m)|.status.value==$s' >/dev/null && return 0; sleep 3; done; echo "timeout waiting for $1 $2"; return 1; }
unload_all() { for m in $(curl -s $U/models | jq -r '.data[]|select(.status.value!="unloaded")|.id'); do api unload "$m"; wait_for "$m" unloaded; done; }
fresh() { unload_all; api load "$1"; wait_for "$1" loaded && state; }
summ() { jq -c --arg n "$1" '{c: $n, t: .benchmarks[0].metrics.request_totals, tps: .benchmarks[0].metrics.output_tokens_per_second.successful.mean, asps: .benchmarks[0].metrics.audio.seconds.input_per_second.successful.mean, ttft: .benchmarks[0].metrics.time_to_first_token_ms.successful.median, itl: .benchmarks[0].metrics.inter_token_latency_ms.successful.median}' "$S/$1.json"; }
run() { MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/$2.yaml --backend "kind=openai_http,model=$3" --tokenizer "kind=huggingface_auto,model=$4" --output "kind=json,path=$S/$1-$2.json" > $S/$1-$2.log 2>&1; echo "$1 $2 exit $?"; summ $1-$2; }
agent()  { fresh $A  && for c in anchor-a anchor-b; do run $1 $c $A openai/gpt-oss-120b; done; }
vision() { fresh $V  && for c in shape-a shape-b;   do run $1 $c $V google/gemma-4-26B-A4B-it; done; }
audio()  { fresh $Q8 && for c in audio-a audio-b;   do run $1 $c $Q8 google/gemma-4-E4B-it; done; }
stack()  { echo "== $1 $(date -u +%FT%TZ)"; tailscale ping -c 1 gb10-1 2>&1 | sed -E 's/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/<addr>/g'; ssh gb10-1 'uname -r; uptime -s'; curl -s $U/props | jq -r '.build_info'; curl -s $U/health; echo; }
```

The anchors run the anchor scenarios with `--backend model=gpt-oss-120b-MXFP4-set-a`, the agent
purpose's section in the host's set, where the scenario files name the 32,768-token section. Each
model's cells ran once each from a fresh load, with only that model loaded. The calls, in the
order run:

1. `stack b11669`: 17:35:15 UTC; via DERP(iad) in 124 ms; 7.0.0-1024-nvidia; booted 07:25:38;
   build b11669-620d2225c; health ok.
2. `agent b11669`, `vision b11669`, `audio b11669`: the incumbent build's six cells.
3. **The move**, the session, no root, 17:42:37 UTC, through spike-model-engines' `engines` suite
   from the host's clone:

   ```sh
   ssh gb10-1 'cd ~/repos/spike-model-engines && host/engines llama update b12063; echo "exit $?"'
   ```

   It pulled `server-cuda13-b12063` (digest
   `sha256:83faadeff67447144770f9b91b4c6694ce2ea2a218efa82f77092ebc29b0c31f`); "llama moved from
   ghcr.io/ggml-org/llama.cpp:server-cuda13-b11669 to
   ghcr.io/ggml-org/llama.cpp:server-cuda13-b12063"; "removed image
   ghcr.io/ggml-org/llama.cpp:server-cuda13-b11669"; "removed image
   ghcr.io/ggml-org/llama.cpp:full-cuda13-b11669"; exit 0. The router's `/models` then listed the
   set's three cell models, unloaded.
4. `stack b12063`: 17:43:04 UTC; via DERP(iad) in 49 ms; the same kernel and boot; build
   b12063-2cbca389f; health ok; the container up 8 s. The probe after the removals read the same
   build back: `llama` on `ghcr.io/ggml-org/llama.cpp:server-cuda13-b12063`, image id
   `sha256:83faadef…` (`== engines ==`), and the router's build b12063-2cbca389f
   (`== endpoints ==`).
5. `agent b12063`, `vision b12063`, `audio b12063`: the same six cells on the candidate, ending
   about 17:58 UTC.

Every run exited 0, and every cell held its full request count with none errored or incomplete.
A cell's figure is its output tok/s, and an ASR cell's its audio seconds a second (skill, "The
verify mode", step 6). The published claims are the report's ("Engines", "Verify next"): #31188's
+17.2% prefill on an MoE on GB10 (MoE gate/up+GLU fusion in MMQ), beside the MoE cells (gpt-oss
and 26B-A4B); #29948's +7.1% on a dense model (FFN gate/up+GLU fusion in MMQ), beside the dense
E4B's ASR cells, where the prompt is the clip, so the claim is context, not a test; and #31394's
Gemma 4 memory fix, beside the Gemma cells.

| Cell | Requests, b11669 / b12063 | Figure, b11669 → b12063 | Change | TTFT median ms, b11669 → b12063 | Published claim beside the TTFT | Output tok/s, b11669 → b12063 | ITL median ms, b11669 → b12063 |
|---|---|---|---|---|---|---|---|
| Anchor A, gpt-oss-120b set A, 1 × 8, 512 / 256 | 8/8 / 8/8 | 48.744 → 48.136 tok/s | −1.25% | 499.1 → 494.6 (−0.9%) | #31188, +17.2% MoE prefill | the figure | 18.37 → 18.54 |
| Anchor B, 4 × 32 | 32/32 / 32/32 | 80.836 → 79.326 tok/s | −1.87% | 1,858.1 → 1,846.7 (−0.6%) | #31188, +17.2% MoE prefill | the figure | 43.13 → 43.91 |
| Vision A, Gemma 4 26B-A4B QAT Q4_0, 1 × 8, thinking on | 8/8 / 8/8 | 65.254 → 68.060 tok/s | +4.30% | 384.3 → 372.7 (−3.0%) | #31188, +17.2% MoE prefill; #31394, not measured by these cells | the figure | 13.53 → 13.02 |
| Vision B, 4 × 32 | 32/32 / 32/32 | 140.081 → 140.467 tok/s | +0.28% | 1,027.7 → 994.6 (−3.2%) | #31188, +17.2% MoE prefill; #31394, not measured | the figure | 24.70 → 24.80 |
| ASR A, Gemma 4 E4B Q8_0, 1 × 8 clips | 8/8 / 8/8 | 7.0162 → 6.7505 audio s/s | −3.79% | 969.7 → 1,020.6 (+5.2%) | #29948, +7.1% dense prefill (context); #31394, not measured | 17.15 → 16.49 (−3.9%) | 21.98 → 22.49 |
| ASR B, 4 × 32 clips | 32/32 / 32/32 | 16.1032 → 14.3206 audio s/s | −11.07% | 963.7 → 1,188.4 (+23.3%) | #29948, +7.1% dense prefill (context); #31394, not measured | 41.79 → 36.17 (−13.5%) | 38.05 → 37.14 |

**How far the sources held.** On the MoE cells the direction held and the size did not: TTFT fell
0.9% and 0.6% on gpt-oss, 3.0% and 3.2% on 26B-A4B, against #31188's 17.2%, which it measured on
Qwen3-30B-A3B Q4_K_M. The dense claim did not show on our dense model, whose TTFT rose 5.2% at
one stream and 23.3% at four. #31394's memory fix is not measured by these cells; the set on
b12063 left MemAvailable 22.0 GiB ("Verdict").

**Embedding** (granite BF16) has no cells: the project's `bench/` has no scenario for it.

**The first anchors beside the host's last earlier readings.** The host's earlier anchors, b11669,
2026-10-26, on the 32,768-token 4-slot section `ggml-org/gpt-oss-120b-GGUF:MXFP4`: A 50.0 and B
80.9 tok/s (spike-model-engines `docs/findings/bench-gb10-container.md`, as the report cites it).
The first anchors of this session, pass 1's on b11669: A 48.94 (−2.1%), B 80.78 (−0.15%).
**A finding: anchor A moved −2.1%, beyond run noise (1.4%).** The build is the same; between the
two readings the section (set A's, `-c 131072 --parallel 4 --kv-unified`, against the
32,768-token section), the boot, and the kernel's initcall blacklist (`power_wrap_init` added,
"Host stack", step 13) differ. B held. Pass 2's anchors on b11669, over the relay, read A 48.74
(−2.5% from 2026-10-26) and B 80.84 (−0.07%), within 0.4% of pass 1's direct readings, so the
relay moves throughput by under run noise; it added 85 ms to anchor A's TTFT median (414 → 499).
The comparison within the pass goes on, since only cells of one session are compared.

### Transcripts

The audio model's ASR B on each build, by the skill's step 7. The references, as run:

```sh
curl -s 'https://datasets-server.huggingface.co/rows?dataset=hf-internal-testing/librispeech_asr_dummy&config=clean&split=validation&offset=0&length=32' > .state/verify/gb10-1/librispeech-refs.json
```

32 rows, read 2026-11-03. Then, on each build's cell, in one loop with the reasoning check
("Reasoning"), as run (from the project root): the skill's step 7 command (SKILL.md, "The verify
mode", step 7), its jq program verbatim, with `-c` added (compact output), `<host>` as gb10-1, so
the references at `.state/verify/gb10-1/librispeech-refs.json`, and the cell
`.state/verify/gb10-1/pass2/$b-audio-b.json`:

```sh
S=.state/verify/gb10-1/pass2; for b in b11669 b12063; do jq -c --slurpfile refs .state/verify/gb10-1/librispeech-refs.json '
  def words: ascii_downcase | gsub("[^a-z0-9\\s]"; "") | [splits("\\s+")] | map(select(length > 0));
  def lev($a; $b): reduce range(0; $a | length) as $i ([range(0; ($b | length) + 1)];
    . as $p | reduce range(0; $b | length) as $j ([$i + 1];
      . + [[$p[$j + 1] + 1, .[$j] + 1, $p[$j] + (if $a[$i] == $b[$j] then 0 else 1 end)] | min]))
    | .[-1];
  [$refs[0].rows[].row.text] as $r
  | [.benchmarks[0].requests.successful | sort_by(.info.timings.queued)[] | (.output // "")] as $o
  | if ($o | length) != ($r | length) then error("\($o | length) replies for \($r | length) references") else . end
  | [range(0; $r | length) | {r: ($r[.] | words), o: ($o[.] | words)} | {n: (.r | length), d: lev(.r; .o)}]
  | {pairs: length, reference_words: (map(.n) | add), word_differences: (map(.d) | add), per_pair: map(.d)}
' .state/verify/gb10-1/pass2/$b-audio-b.json; for c in audio-a audio-b; do echo -n "$b $c reasoning: "; jq -c '.benchmarks[0].requests.successful | {replies: length, reasoned_in_channel: (map(select((.reasoning_output // "") != "")) | length), reasoned_in_text: (map(select((.output // "") | test("The user wants me to|Thinking Process"; "i"))) | length)}' $S/$b-$c.json; done; done
```

| Build | Pairs | Reference words | Word differences |
|---|---|---|---|
| b11669 | 32 | 568 | 46 |
| b12063 | 32 | 568 | 45 |

Per pair, numbered from #0, b11669: 1,1,1,1,9,0,2,1,1,2,0,5,0,2,2,2,0,1,0,3,1,0,0,1,0,4,3,0,0,0,2,1.
b12063: 1,1,2,1,11,0,2,0,1,3,2,5,0,1,0,2,0,0,0,3,0,0,0,3,0,3,1,0,0,0,2,1. The pairs that differ
by more than a word, each reply as written (replies in queued order, references in row order):

- **#4**, LibriSpeech's longest clip: b11669 9, b12063 11.
  - Reference: "LINNELL'S PICTURES ARE A SORT OF UP GUARDS AND AT EM PAINTINGS AND MASON'S
    EXQUISITE IDYLLS ARE AS NATIONAL AS A JINGO POEM MISTER BIRKET FOSTER'S LANDSCAPES SMILE AT ONE
    MUCH IN THE SAME WAY THAT MISTER CARKER USED TO FLASH HIS TEETH AND MISTER JOHN COLLIER GIVES
    HIS SITTER A CHEERFUL SLAP ON THE BACK BEFORE HE SAYS LIKE A SHAMPOOER IN A TURKISH BATH NEXT
    MAN"
  - b11669: "linnell's pictures are a sort of upgard's and adam paintings and mason's exquisite
    idols are as national as a jingo poem mr burket foster's landscapes smile at one much in the
    same way that mr carker used to flash his teeth and mr john collier gives his sitter a
    cheerful slap on the back before he says like a shampooer in a turkish bath next man"
  - b12063: "linnell's pictures are a sort of upguards and adam paintings and mason's exquisite
    idols are as national as a jingo poem mr burket foster's landscapes smile at one much in the
    same way that mr carcker used to flash his teeth and mr john collier gives his sitter a
    tearful slap on the back before he says like a shampooer in a turkish bath next man"
- **#10**: b11669 0, b12063 2. Reference: "NEAR THE FIRE AND THE ORNAMENTS FRED BROUGHT HOME FROM
  INDIA ON THE MANTEL BOARD". b11669: "near the fire and the ornaments fred brought home from
  india on the mantel board". b12063: "near the fire and the ornaments fred brought home from
  india on the mantleboard."
- **#14**: b11669 2, b12063 0. Reference: "BY HARRY QUILTER M A". b11669: "by harry quilter ma".
  b12063: "by harry quilter m a".
- **#23**: b11669 1, b12063 3. Reference: "I HOPE HE DOESN'T WORK TOO HARD SAID SHAGGY". b11669:
  "i hope it doesn't work too hard said shaggy". b12063: "i hope it does some work too hard said
  shaggy".
- **#26**: b11669 3, b12063 1. Reference: "NOT EXACTLY RETURNED KALIKO". b11669: "not exactly
  we've turned calico". b12063: "not exactly returned calico".

The differences move both ways, two pairs worse and three better on b12063 by more than a word:
the build changes which clips it misreads, not how often.

### Reasoning

The reasoning check, the skill's step 6 program exactly, on each build's two ASR cells: four
invocations, the inner loop of the one "Transcripts" gives as run, after each build's
transcripts.

| Build | Cell | Replies | In the thought channel | In the text |
|---|---|---|---|---|
| b11669 | ASR A | 8 | 0 | 0 |
| b11669 | ASR B | 32 | 0 | 0 |
| b12063 | ASR A | 8 | 0 | 0 |
| b12063 | ASR B | 32 | 0 | 0 |

No reply reasoned, in the channel or in the text, so there is no reply to quote.

### Verdict

**The engine rule gave roll back; the architect overruled it, and b12063 is adopted.** The rule
(skill, "The verify mode", step 8), condition by condition:

1. **Every cell on the candidate within 1.4% of the incumbent's, or ahead:** fails. Anchor B
   −1.87% (79.326 against 80.836 tok/s), ASR A −3.79% (6.7505 against 7.0162 audio s/s), and ASR
   B −11.07% (14.3206 against 16.1032 audio s/s). Anchor A −1.25% is within; vision A +4.30%
   and vision B +0.28% are ahead.
2. **Every cell of the pass, on both builds, at its full request count:** holds. 8/8 for each A
   cell and 32/32 for each B cell, on both builds.
3. **ASR B word differences on the candidate within the incumbent's total plus 1.4% of the
   reference words:** holds. 45 against a bound of 46 + 1.4% × 568 = 53.95.
4. **The candidate's reasoning counts no more than the incumbent's, for each count:** holds. 0
   and 0 on b12063's ASR cells, against 0 and 0 on b11669's.

**The rule's outcome: roll back.**

**The architect's overrule** (2026-11-03): adopt b12063. The architect's reason, in the
architect's words: "outside of legitimate broken behavior, we should prioritize staying on the
latest version." The rule's figures stand beside the overrule.

**The session's research on the regression** (2026-11-03). The searches on ggml-org/llama.cpp,
as run:

```sh
for q in "gemma 4 audio" "mtmd audio" "gemma4 audio slow" "audio regression" "conformer" "gpt-oss performance regression" "cuda regression"; do echo "== $q"; gh search issues "$q" --repo ggml-org/llama.cpp --created ">=2026-10-14" --limit 6 --json number,title,state,createdAt --jq '.[] | "#\(.number) [\(.state)] \(.createdAt[0:10]) \(.title)"' 2>&1; gh search prs "$q" --repo ggml-org/llama.cpp --merged-at ">=2026-10-14" --limit 6 --json number,title,closedAt --jq '.[] | "PR #\(.number) \(.closedAt[0:10]) \(.title)"' 2>&1; done
gh pr view 29510 --repo ggml-org/llama.cpp --json title,mergedAt,body,files
for q in "flash_attn_ext_rows" "29510" "unified kv slower" "multi-seq slower" "parallel slower"; do gh search issues "$q" --repo ggml-org/llama.cpp --created ">=2026-11-01" --limit 5 --json number,title,state --jq '.[] | "#\(.number) [\(.state)] \(.title)"'; done
```

No issue reports slower audio, gpt-oss, or CUDA: the issues found are #31561 (open, a feature
request for `mtmd_audio_stream` on Gemma 4 E2B and E4B) and #30968 (closed, a realtime commit
bug); the pull requests, #30629, #31471, #31309, #30636, and #26603, add audio features, none a
performance change; and no issue since #29510 reports it slower. The commits to `tools/mtmd` and
`ggml/src/ggml-cuda` between the builds' dates, read by WebFetch (2026-11-03), the first ~100,000
characters of each:
<https://api.github.com/repos/ggml-org/llama.cpp/commits?path=tools/mtmd&since=2026-10-15T16:00:00Z&until=2026-11-03T02:00:00Z&per_page=100>
and the same with `path=ggml/src/ggml-cuda`, 17 and 18 commits listed: none is a stated
audio-performance change. The changes on the concurrency
path include [#30804](https://github.com/ggml-org/llama.cpp/pull/30804) ("CUDA: chunk graphs to
amortize graph launch", 2026-10-23) and [#29510](https://github.com/ggml-org/llama.cpp/pull/29510)
(`flash_attn_ext_rows`, more efficient unified KV for multiple sequences, merged
2026-11-02T16:13:34Z, benchmarked on Qwen3.8-27B and Gemma 26B-A4B on an RTX Pro 6000). The
figures locate the loss: ASR B's is its time to first token (963.7 → 1,188.4 ms) with its ITL
unchanged (38.05 → 37.14), and anchor B's is its ITL (+1.8%, 43.13 → 43.91) with its TTFT
unchanged, both only at 4 streams. #30804 and #29510 are candidates by inference, not attributed;
a bisect is outside the task's brief.

**On adopt, the rollback, as printed** (the session's step, no root):

```sh
ssh gb10-1 'cd ~/repos/spike-model-engines && host/engines llama update b11669; echo "exit $?"'
```

It pulls b11669's image again, since the move removed every other build's images. Forward again
is the same update with b12063.

**Proposed**, for the host's next report, under the descriptor: a watch item, "llama.cpp audio
TTFT under concurrency on GB10, from b12063".

**The set on b12063**, the build that stays, the session, 2026-11-03, one model per purpose by the
skill's step 6 rule: `unload_all`, then each loaded in turn, waiting for each to read loaded:
`gpt-oss-120b-MXFP4-set-a`, `google/gemma-4-26B-A4B-it-qat-q4_0-gguf:Q4_0`,
`ggml-org/gemma-4-E4B-it-GGUF:Q8_0`, and `mrutkows/granite-embedding-english-r2-GGUF:BF16`, as
run:

```sh
. .state/verify/gb10-1/pass.sh pass2 && unload_all && for m in $A $V $Q8 mrutkows/granite-embedding-english-r2-GGUF:BF16; do api load "$m"; wait_for "$m" loaded; done; state; ssh gb10-1 "grep -E 'MemAvailable' /proc/meminfo"
```

The router's `/models` read all four loaded. MemAvailable 23,061,568 kB = 22.0 GiB of 121.6 GiB: the
set takes ~99.6 GiB against the estimate's 95.4 to 98.8 ("Gates", "Fit"), and the 22.0 GiB free is
above the policy's 12.2 GiB headroom.

**gb10-2**: the steps that bring gb10-2 in line with gb10-1, for spike-ai-pipeline, which holds
gb10-2, are in [`docs/findings/gb10-2-upgrade.md`](gb10-2-upgrade.md).

## Walkthrough

The architect's, 2026-11-03, from this machine at the office, on b12063 as adopted and gb10-1's
clone on spike-model-engines' verify-gb10 branch (ad754b7, pushed to the clone over ssh, by the
architect's decision). The path was relayed, DERP(nyc), and the architect's overrule of the
routing check's latency condition extends to the walkthrough (Decisions).

1. **The routing check**, as in Host stack step 6, then `tailscale ping -c 1 gb10-1`:
   `gb10-1.lan A: none`, `AAAA: none`; bare name: tailnet; 50 connects, 0 failed, 50 over 50 ms,
   max 0.325178 s; pong via DERP(nyc) in 55 ms, "direct connection not established".
2. **The set on b12063**, one model per purpose, each load waiting for the one before, with the
   pass's helpers:

   ```sh
   . .state/verify/gb10-1/pass.sh walk && unload_all && for m in $A $V $Q8 mrutkows/granite-embedding-english-r2-GGUF:BF16; do api load "$m"; wait_for "$m" loaded; done; state
   curl -s http://gb10-1:8080/props | jq -r .build_info
   ```

   All four unloaded, then loaded in turn; `state` lists the four loaded; `b12063-2cbca389f`.
3. **Anchor A and ASR A**, from that fresh load, with the set's other models loaded:

   ```sh
   run walk anchor-a $A openai/gpt-oss-120b
   run walk audio-a $Q8 google/gemma-4-E4B-it
   ```

   | Cell | Requests | Figure | TTFT median | ITL median | Pass 2, b12063 |
   |---|---|---|---|---|---|
   | Anchor A | 8/8 | 48.127 tok/s | 474.2 ms | 18.60 ms | 48.136 tok/s (-0.02%) |
   | ASR A | 8/8 | 8.826 audio s/s (21.56 tok/s) | 593.8 ms | 21.71 ms | 6.751 audio s/s (+30.7%) |

   Anchor A reproduces pass 2 within 0.02%. ASR A reads 30.7% above pass 2's reading of the same
   cell on the same build, and 25.8% above b11669's (7.016), with TTFT 594 ms against 1,021 ms.
   **A finding:** the audio cells' spread on this host is far wider than the engine rule's 1.4%
   margin. The runs differ in the models loaded beside E4B (the set here, E4B alone in the
   pass) and in time of day; on framework, the same difference moved ASR A by 3%
   (verify-framework's "Walkthrough", 11.33 against 11.67). So the rule's roll back, which rested
   on ASR A (-3.8%) and ASR B (-11.1%) with anchor B (-1.9%), rested on audio figures inside
   their own spread; the architect's overrule stands on firmer ground than the rule did. The
   engine rule's audio condition needs a measured spread, or a margin that fits it: a question
   for the spike's `answer` task.
4. **The suite's update with no version**, from the clone on the branch:

   ```sh
   ssh gb10-1 'cd ~/repos/spike-model-engines && host/engines llama update; echo "exit $?"'
   ```

   `llama already runs ghcr.io/ggml-org/llama.cpp:server-cuda13-b12063; nothing changed`,
   `exit 0`: gb10's per-class pin is b12063.
5. **spike-model-engines' currency**, `cd ~/experiments/spike-model-engines && mise run currency`:
   only the three held items (`mise.bench.toml: python 3.14.10 -> 3.15.2`, `host/vllm.env: vLLM
   v0.32.0 -> v0.33.0rc3`, `host/vllm.env: native Python 3.12 -> 3.15`), exit 1 as it is when it
   reports items.

The architect's review of each closure and removal, and of the gb10-2 report
([`docs/findings/gb10-2-upgrade.md`](gb10-2-upgrade.md)), comes with the acceptance of the
session brief.

## Removals

Each by the decision in its row ("Decisions"), in the order run, 2026-11-03.

1. **vLLM**: the session, no root, through the suite from the host's clone:

   ```sh
   ssh gb10-1 'cd ~/repos/spike-model-engines && host/engines vllm uninstall; echo "exit $?"; docker ps -a --format "{{.Names}} {{.Image}} {{.Status}}"; docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}"; ls -d ~/.cache/vllm 2>&1'
   ```

   "removed container vllm", "removed image vllm/vllm-openai:v0.32.0", "removed compile cache
   /home/jaime/.cache/vllm", exit 0. The suite prints no size. Rollback: `host/engines vllm
   install`, the pinned release.
2. **The bare-metal units**, `llama-router.service` and `vllm-server.service`: first the session,
   no root, the suite's two native uninstalls:

   ```sh
   ssh gb10-1 'cd ~/repos/spike-model-engines && host/engines llama-native uninstall; echo "exit $?"; host/engines vllm-native uninstall; echo "exit $?"'
   ```

   llama-native: removed `/opt/llama.cpp/current`, `/opt/llama.cpp/preset`, and
   `/opt/llama.cpp/b11669`, exit 0. vllm-native: removed `/opt/vllm/current`, `/opt/vllm/v0.32.0`,
   `/opt/vllm/row`, `/opt/vllm/python`, and `/opt/vllm/cache`, exit 0. Each said the architect's
   root steps stay. Then the architect, with root, on the host, from spike-model-engines'
   `docs/engines/llama.cpp/uninstall.md` and `docs/engines/vllm/uninstall.md`:

   ```sh
   sudo rm /etc/sudoers.d/llama-router /etc/systemd/system/llama-router.service && sudo rm /etc/sudoers.d/vllm-server /etc/systemd/system/vllm-server.service && sudo systemctl daemon-reload && sudo rmdir /opt/llama.cpp /opt/vllm
   ```

   No output. Read back by the session after the removals, with the probe
   (`.state/verify/gb10-1/probe-removals.txt`); the same read also covers 3's space and 5's
   module tree, as run:

   ```sh
   ssh gb10-1 'find /lib/modules/6.17.0-1008-nvidia | head; du -sh /lib/modules/6.17.0-1008-nvidia; ls -d /opt/llama.cpp /opt/vllm /etc/systemd/system/llama-router.service /etc/systemd/system/vllm-server.service 2>&1; df -h /srv/models | tail -1; du -sh /srv/models'
   ```

   "No such file or directory" for the two unit files, the two directories, and the 6.17.0-1008
   module tree; `/dev/nvme0n1p3 3.6T 165G 3.3T 5% /`; `113G /srv/models`. The probe lists no
   unit. The sudoers rules, read back by the session later the same day, as run:

   ```sh
   ssh gb10-1 'ls -l /etc/sudoers.d/ 2>&1 | grep -E "llama-router|vllm-server" || echo "no llama-router or vllm-server sudoers file"'
   ```

   `no llama-router or vllm-server sudoers file`. Rollback: the suite's `llama-native install`
   and `vllm-native install`, plus the guides' root setup steps.
3. **The six unused snapshots**: the dry run by the session, shown to the architect; the removal
   by the architect on the host. The dry runs, run by the session from this machine over ssh, with
   a first read of the store's layout, as run:

   ```sh
   ssh gb10-1 'cd ~/repos/spike-model-engines && for r in openai/gpt-oss-120b nvidia/Gemma-4-26B-A4B-NVFP4 nvidia/Gemma-4-31B-IT-NVFP4 google/gemma-4-E4B-it google/gemma-4-12B-it-qat-w4a16-ct google/gemma-4-E4B-it-qat-w4a16-ct; do echo "== $r"; MISE_ENV=host HF_HUB_CACHE=/srv/models mise exec -- hf cache rm model/$r --dry-run 2>&1 | tail -4; done; echo "== blobs layout"; ls /srv/models | head; find /srv/models/models--nvidia--Gemma-4-26B-A4B-NVFP4/blobs -maxdepth 1 -type l | head -2; echo "== kernel pkgs"; dpkg -l | awk "/6\.17\.0-1008/ {print \$1, \$2, \$3}"; df -h /srv/models | tail -1'
   ```

   `openai/gpt-oss-120b` 65.3G, `nvidia/Gemma-4-26B-A4B-NVFP4` 18.8G,
   `nvidia/Gemma-4-31B-IT-NVFP4` 32.7G, `google/gemma-4-E4B-it` 16.0G,
   `google/gemma-4-12B-it-qat-w4a16-ct` 10.3G, `google/gemma-4-E4B-it-qat-w4a16-ct` 11.5G
   (154.6G). The layout, read by the session the same way, as run:

   ```sh
   ssh gb10-1 'cd /srv/models; for d in models--*; do n=$(find $d/blobs -maxdepth 1 -type l 2>/dev/null | wc -l); [ $n -gt 0 ] && echo "$d: $n linked blobs -> $(find $d/blobs -maxdepth 1 -type l -exec readlink -f {} + | xargs -r du -ch 2>/dev/null | tail -1)"; done; echo "== shared /srv/models/blobs"; du -sh /srv/models/blobs; find /srv/models/blobs -type f | wc -l; echo "== other referrers of shared blobs"; for d in models--*; do find $d/snapshots -type l -exec readlink -f {} + 2>/dev/null | grep -c "^/srv/models/blobs/" | sed "s|^|$d snapshot links into shared: |"; done | grep -v ": 0$"'
   ```

   Every repository in `/srv/models` links its files into the shared `/srv/models/blobs` (190G,
   120 files), so `hf cache rm` would remove only the links. So the removal took the
   exclusive-blob method of spike-model-engines' `docs/engines/vllm/uninstall.md`, extended to six
   repositories: the session listed every `/srv/models/blobs` target linked from the six
   (`~/rm-blobs.txt`, in gb10-1's home) and from the 8 kept repositories (`~/keep-blobs.txt`), as
   run:

   ```sh
   ssh gb10-1 'cd /srv/models; rm6="models--openai--gpt-oss-120b models--nvidia--Gemma-4-26B-A4B-NVFP4 models--nvidia--Gemma-4-31B-IT-NVFP4 models--google--gemma-4-E4B-it models--google--gemma-4-12B-it-qat-w4a16-ct models--google--gemma-4-E4B-it-qat-w4a16-ct"; keep=$(for d in models--*; do case " $rm6 " in *" $d "*) ;; *) echo $d;; esac; done); echo "keep: $(echo $keep | wc -w) repos"; for d in $rm6; do find $d -type l -exec readlink -f {} +; done | grep "^/srv/models/blobs/" | sort -u > ~/rm-blobs.txt; for d in $keep; do find $d -type l -exec readlink -f {} +; done | grep "^/srv/models/blobs/" | sort -u > ~/keep-blobs.txt; comm -12 ~/rm-blobs.txt ~/keep-blobs.txt | wc -l | sed "s/^/shared with a kept repo: /"; comm -23 ~/rm-blobs.txt ~/keep-blobs.txt > ~/rm-only.txt; wc -l < ~/rm-only.txt | sed "s/^/blob files to delete: /"; xargs -r du -cb < ~/rm-only.txt | tail -1 | awk "{printf \"size: %.1f GiB\n\", \$1/2^30}"; echo "kept repos: $keep" | tr "\n" " "; echo'
   ```

   They share none, which leaves 27 files to delete, 143.9 GiB (`~/rm-only.txt`). The removal, as
   the architect ran it, in a shell on gb10-1:

   ```sh
   cd /srv/models && xargs -r rm -f -- < ~/rm-only.txt && rm -rf models--openai--gpt-oss-120b models--nvidia--Gemma-4-26B-A4B-NVFP4 models--nvidia--Gemma-4-31B-IT-NVFP4 models--google--gemma-4-E4B-it models--google--gemma-4-12B-it-qat-w4a16-ct models--google--gemma-4-E4B-it-qat-w4a16-ct && find /srv/models/blobs -mindepth 1 -type d -empty -delete && rm ~/rm-blobs.txt ~/keep-blobs.txt ~/rm-only.txt
   ```

   No output. Freed 143.9 GiB: `/srv/models` now 113G, and the root filesystem went from 309G to
   165G used. The task's brief named the removal `hf cache rm`; the store's layout made the
   guide's method the one that frees the space, a deviation, recorded here. Rollback:
   `HF_HUB_CACHE=/srv/models hf download <repo>` per repository. ibm-granite's safetensors and
   ggml-org's E4B Q8_0 stay.
4. **`hello-world:latest`**: the session, no root:

   ```sh
   ssh gb10-1 'docker rmi hello-world:latest; echo "exit $?"; docker images --format "{{.Repository}}:{{.Tag}} {{.Size}}"'
   ```

   "Untagged", "Deleted sha256:11a3eb15…", exit 0. Rollback: `docker pull hello-world`.
5. **The 6.17.0-1008 kernel**: the architect, with root:

   ```sh
   sudo apt-get purge -y linux-image-6.17.0-1008-nvidia linux-modules-6.17.0-1008-nvidia linux-headers-6.17.0-1008-nvidia linux-nvidia-6.17-headers-6.17.0-1008 linux-modules-nvidia-580-open-6.17.0-1008-nvidia linux-modules-nvidia-fs-6.17.0-1008-nvidia
   ```

   6 removed, 397 MB freed; the initramfs and kdump files for 6.17.0-1008 deleted; update-grub
   found 7.0.0-1024 and 7.0.0-1019 only. dpkg warned "/lib/modules/6.17.0-1008-nvidia not empty
   so not removed", and the directory is gone at the read back. No reboot. 1019 stays, the
   fallback. Rollback, root: `sudo apt-get install` the same packages.

b11669's full image, `llama.cpp:full-cuda13-b11669`, left with the move to b12063 ("Engine pass",
"Cells", the move), with b11669's server image.

**Read back** by the probe after the removals (the session, 2026-11-03,
`.state/verify/gb10-1/probe-removals.txt`):

- `== engines ==`: one container, `llama` on `server-cuda13-b12063`, running and healthy; no
  `vllm`.
- `== models ==`: the 8 kept snapshots, none of the six: `ggml-org/gemma-4-E4B-it-GGUF` 8.1G,
  `ggml-org/gpt-oss-120b-GGUF` 60G, `google/gemma-4-12B-it-qat-q4_0-gguf` 6.7G,
  `google/gemma-4-26B-A4B-it-qat-q4_0-gguf` 15G, `google/gemma-4-31B-it-qat-q4_0-gguf` 18G,
  `google/gemma-4-E4B-it-qat-q4_0-gguf` 5.8G, `ibm-granite/granite-embedding-english-r2` 288M,
  `mrutkows/granite-embedding-english-r2-GGUF` 286M.
- `== docker-disk ==`: one image (7.023GB), one container, nothing reclaimable.
- `== kernel ==`: kernel images 7.0.0-1019 and 7.0.0-1024 only, and module trees 1019 and 1024.
- `== units ==`: no failed system unit; the user unit `update-notifier-crash` failed again, reset
  afterwards ("Host stack", step 15).

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
| ghcr.io llama.cpp package versions (`server-cuda13-b12063` published) | primary | <https://github.com/ggml-org/llama.cpp/pkgs/container/llama.cpp/versions> | 2026-11-03 |
| gb10-1's report, "Engines" and "Verify next" (the published claims beside the TTFT) | the report | [`docs/reports/gb10-1/2026-10-31.md`](../reports/gb10-1/2026-10-31.md) | 2026-11-03 |
| llama.cpp #31188, MoE gate/up+GLU fusion in MMQ (+17.2% prefill on GB10, through the report) | attributed benchmark (PR measurement table) | <https://github.com/ggml-org/llama.cpp/pull/31188> | 2026-10-31 (the report) |
| llama.cpp #29948, FFN gate/up+GLU fusion in MMQ (+7.1% dense prefill, through the report) | attributed benchmark (PR measurement table) | <https://github.com/ggml-org/llama.cpp/pull/29948> | 2026-10-31 (the report) |
| llama.cpp #31394, Gemma 4 token_embd fix (through the report) | primary | <https://github.com/ggml-org/llama.cpp/pull/31394> | 2026-10-31 (the report) |
| spike-model-engines bench-gb10-container.md, "Results" (the 2026-10-26 anchors, A 50.0, B 80.9) | attributed benchmark | spike-model-engines `docs/findings/bench-gb10-container.md` | 2026-11-03 |
| LibriSpeech references, dataset viewer | primary | <https://datasets-server.huggingface.co/rows?dataset=hf-internal-testing/librispeech_asr_dummy&config=clean&split=validation&offset=0&length=32> | 2026-11-03 |
| llama.cpp issues and pull requests since 2026-10-14 (`gh search issues`, `gh search prs`) | primary | <https://github.com/ggml-org/llama.cpp/issues> | 2026-11-03 |
| llama.cpp commits to `tools/mtmd` | primary | <https://api.github.com/repos/ggml-org/llama.cpp/commits?path=tools/mtmd> | 2026-11-03 |
| llama.cpp commits to `ggml/src/ggml-cuda` | primary | <https://api.github.com/repos/ggml-org/llama.cpp/commits?path=ggml/src/ggml-cuda> | 2026-11-03 |
| llama.cpp #30804, "CUDA: chunk graphs to amortize graph launch" | primary | <https://github.com/ggml-org/llama.cpp/pull/30804> | 2026-11-03 |
| llama.cpp #29510, `flash_attn_ext_rows`, unified KV for multiple sequences (benchmarked on an RTX Pro 6000, not GB10) | primary | <https://github.com/ggml-org/llama.cpp/pull/29510> | 2026-11-03 |
| spike-model-engines uninstall guides (the root steps, the exclusive-blob method) | primary (the suite's own guides) | spike-model-engines `docs/engines/llama.cpp/uninstall.md`, `docs/engines/vllm/uninstall.md` | 2026-11-03 |
| The probe after the removals and after the security updates | primary (probe) | the host | 2026-11-03 |
