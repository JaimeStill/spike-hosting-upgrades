# gb10-2: alignment with gb10-1, from verify-gb10, 2026-11-03

An alignment report, addressed to spike-ai-pipeline's agent. It is not a `/hosting-upgrades`
run: no probe of gb10-2 was taken, and nothing here was read on gb10-2. Task verify-gb10 of
experiment.hosting.spike-hosting-upgrades wrote it from gb10-1's verification finding,
[`docs/findings/verify-gb10-1.md`](verify-gb10-1.md) ("Host stack", steps 6 to 10,
and "Engine pass"), so that gb10-2 can be brought in line with gb10-1.

spike-ai-pipeline holds gb10-2. **This report changes nothing on gb10-2**: that spike runs each
step, or declines it, under its own rules. "The session" below is spike-ai-pipeline's agent, with
no root, over Tailscale SSH or from the machine its sessions run on; "the architect" runs every
step that needs root.

**What this report doesn't know**, and so doesn't guess: gb10-2's NetworkManager connection
names. Where a step needs them, it gives the read that finds them. spike-ai-pipeline's engine
serves on port 8080, as its host-update reads the router (`scripts/host-update.sh`,
`router=http://$host:8080`), the same port as gb10-1's.

## What already matches gb10-1

- **The IPv4 sysctl**: `net.ipv4.ip_nonlocal_bind = 1`, the boot-order check's remedy for IPv4 on
  gb10-1 (the finding, "Decisions"). To read it, the session, no root:
  `ssh gb10-2 sysctl -n net.ipv4.ip_nonlocal_bind` (it should print `1`).
- **Audio on E4B Q8_0**: `ggml-org/gemma-4-E4B-it-GGUF:Q8_0`, gb10-1's audio model too.

## The routing check

The skill's routing check (`.claude/skills/hosting-upgrades/SKILL.md`, "The verify mode", step
6), as gb10-1's finding ran it, with the host gb10-2 and spike-ai-pipeline's port, 8080. The session
runs it from the machine its measurements run from, with no root:

```sh
h=gb10-2; for ty in A AAAA; do echo "$h.lan $ty: $(resolvectl query -t $ty $h.lan >/dev/null 2>&1 && echo PRESENT || echo none)"; done
t=$(tailscale ip $h); echo "bare name: $(getent ahosts $h | cut -d' ' -f1 | sort -u | while read -r a; do echo "$t" | grep -qxF "$a" && echo tailnet || echo NOT-TAILNET; done | paste -sd' ')"
for i in $(seq 1 50); do curl -s -o /dev/null -w '%{time_connect} ' --connect-timeout 5 http://$h:8080/health || echo -n "FAIL "; done | tr ' ' '\n' | awk 'NF{n++; if($NF=="FAIL")f++; else if($NF>0.05)s++; if($NF>m)m=$NF} END{print n" connects, "f+0" failed, "s+0" over 50 ms, max "m" s"}'
```

It passes when `gb10-2.lan` has no A and no AAAA record, the bare name resolves to the tailnet
address only, and the 50 connects have none failed and none over 50 ms. Each line prints a label,
never an address. The latency condition needs a direct path: from the office, where the machine
reached gb10-1 only through Tailscale's DERP relay (region iad), gb10-1's check read 50 over 50
ms, max 0.248 s. The architect overruled that condition for gb10-1's engine pass alone; the
overrule isn't carried to gb10-2.

## The steps

Run in this order. Each gives who runs it, its rollback, and the routing check that follows it.

1. **The routing check, before**: the session, as above. Its first line decides step 5: if
   `gb10-2.lan` has an A or AAAA record, step 5 runs. Rollback: none needed, it reads only.
2. **NetworkManager's connections**: the session, no root. gb10-1's step 7 named that host's
   connections; this read lists gb10-2's instead of naming them:

   ```sh
   ssh gb10-2 'nmcli -t -f NAME,DEVICE,STATE con show --active; nmcli -t -f NAME con show | while IFS= read -r c; do d=$(nmcli -g GENERAL.DEVICES con show "$c"); echo "$c ($d): $(nmcli -g ipv4.method,ipv6.method,ipv4.dhcp-send-hostname,ipv6.dhcp-send-hostname con show "$c" | paste -sd" ") carrier=$(cat /sys/class/net/$d/carrier 2>/dev/null)"; done; ip route show default | sed -E "s/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/<addr>/g"'
   ```

   The DHCP connections are those whose `ipv4.method` or `ipv6.method` reads `auto`. On gb10-1
   that was `Wired connection 1` alone, the connection carrying the default route; its
   ConnectX-7 connections were manual, and the GB10s have no Wi-Fi. Step 3 sets only gb10-2's
   DHCP connections. Rollback: none needed, it reads only.
3. **The DHCP hostname**: the architect, with root, on gb10-2, for each DHCP connection step 2
   found (`<connection>`, its name as step 2 prints it):

   ```sh
   sudo nmcli con mod '<connection>' ipv4.dhcp-send-hostname no ipv6.dhcp-send-hostname no && sudo systemd-run --unit=lan-reup-wired nmcli con up '<connection>'
   ```

   Read back, the session: `ssh gb10-2 "nmcli -g ipv4.dhcp-send-hostname,ipv6.dhcp-send-hostname con show '<connection>'"`
   prints `no` and `no`. On gb10-1, NetworkManager's journal then showed a new DHCPv4 lease and a
   new DHCPv6 lease within a second. Rollback, root: the same command with `yes`, then `con up`.
4. **The routing check, after step 3**: the session, as above.
5. **The router's leases**, only if a check still finds a `gb10-2.lan` record: the architect, with
   root on the OpenWrt router. First the search:

   ```sh
   grep -nE 'gb10-2|promaxgb10' /tmp/odhcpd.leases /tmp/hosts/odhcpd.hosts.lan /tmp/dhcp.leases
   ```

   `promaxgb10` is the earlier DHCP name gb10-1's leases carried; gb10-1's lines are already
   cleared. If gb10-2's leases carry another earlier name, the architect adds it to the pattern
   here and in the clearing. Then the clearing:

   ```sh
   /etc/init.d/odhcpd stop; sed -i -E '/gb10-2|promaxgb10/d' /tmp/odhcpd.leases /tmp/hosts/odhcpd.hosts.lan; /etc/init.d/odhcpd start; /etc/init.d/dnsmasq stop; sed -i -E '/gb10-2|promaxgb10/d' /tmp/dhcp.leases; /etc/init.d/dnsmasq start
   ```

   On gb10-1's run, dnsmasq's start printed udhcpc's "no lease, failing": OpenWrt's check for
   another DHCP server on the LAN, which found none. Rollback: none needed; a lease renews on its
   own if the host sends its name again. Then the routing check, the session, as above; it should
   read `gb10-2.lan A: none`, `AAAA: none`.
6. **llama.cpp b11669 to b12063**: gb10-1 adopted b12063 (below), and gb10-1 runs
   `ghcr.io/ggml-org/llama.cpp:server-cuda13-b12063`, digest
   `sha256:83faadeff67447144770f9b91b4c6694ce2ea2a218efa82f77092ebc29b0c31f`. spike-ai-pipeline
   pins llama.cpp in `host/llama.env` (`LLAMA_BUILD=b11669`, and
   `LLAMA_IMAGE=ghcr.io/ggml-org/llama.cpp:server-cuda13-$LLAMA_BUILD`), and every file in its
   `host/` but its README and `llama-preset/models.ini` is a byte-identical copy of
   spike-model-engines' `host/` at commit `d285b06`, never edited there: a change comes as a new
   copy from a later commit (its `host/README.md`). b12063 is gb10's pin in spike-model-engines
   from its verify-gb10 pull request on, so the step is a new copy from that pull request's merge
   commit. This report and task change nothing in spike-ai-pipeline; it runs the step as its own
   work.
   - **Before the copy works**: spike-ai-pipeline's scripts read two names the new `host/llama.env`
     no longer has. That `llama.env` replaces `LLAMA_BUILD` with one pin per host class,
     `LLAMA_BUILD_GB10=b12063` and `LLAMA_BUILD_STRIX_HALO=b11960`, which `host/llama-release.sh`'s
     `llama_pin` reads for the class `host/llama.sh` sets from the flavor (gb10 for cuda13); and
     `LLAMA_IMAGE` left spike-model-engines' `host/llama.env` in `e2f0146`, a commit after
     `d285b06`, for `LLAMA_REPOSITORY=ghcr.io/ggml-org/llama.cpp`. spike-ai-pipeline's
     `scripts/host-update-lib.sh` (`clone_router_state`, `echo "pin $LLAMA_IMAGE"`) and
     `scripts/currency.sh` (`[ "$latest" = "$LLAMA_BUILD" ]`) each read one of them under
     `set -u`, so on the new copy each fails on an unbound variable. They need spike-ai-pipeline's
     own change first; until then its pin can't move by copy.
   - **The copy**, the session, no root, in spike-ai-pipeline's checkout, with spike-model-engines
     checked out beside it at the merge commit of spike-model-engines' verify-gb10 pull request
     (`<merge>` below, which doesn't exist yet). The files are those `host/README.md` lists:

     ```sh
     for f in engines engines.sh engines-llama-install engines-llama-update engines-llama-uninstall llama.env llama.sh llama-release.sh; do
       git -C ../spike-model-engines show <merge>:host/$f > host/$f
     done
     ```

     Then `host/README.md`'s commit, `d285b06`, becomes `<merge>`, in its prose and in its check
     loop, and the check loop prints nothing. The copy is committed and reaches gb10-2's clone as
     spike-ai-pipeline delivers any commit: host-update fast-forwards a branch with an upstream,
     and a task branch is delivered by push (its `scripts/host-update.sh`, step 2).
   - **The update**, the session: `mise run host-update`, from the laptop. It needs no root on
     gb10-2 and runs nothing that does (`scripts/host-update.sh`); it moves the router to the pin
     in `host/llama.env` with the copied `host/engines llama update`. Its preflight stops it, the
     router untouched, when gb10-2 has pending apt upgrades, a stale CDI spec, or a pending reboot,
     and prints the root commands for those, which are the architect's.
   - **Read back**, the session: `curl -s http://gb10-2:8080/props | jq -r '.build_info'`, which
     on gb10-1 reads `b12063-2cbca389f`; host-update prints the build too (its step 6).
   - **Rollback**: host-update takes no version; it reads the pin from `host/llama.env`. So the
     rollback is the copy from `d285b06` again (the loop above with `d285b06` for `<merge>`, and
     `host/README.md` back to `d285b06`), then `mise run host-update`, the session. The copied
     `host/engines llama update` takes a version (`host/engines llama update b11669` on gb10-2), but
     the next host-update moves the router back to the pin, so it serves only until then. On gb10-1
     the suite's update removed every other build's image, and so does the copied update, so the
     rollback pulls b11669's image again.
   - Then the routing check, the session, as above, before any measurement on the new build.

**What gb10-2 takes on with b12063.** gb10-1 measured both builds on one kernel and one boot, from
fresh loads (the finding, "Engine pass", "Cells"). Vision held or gained (shape A +4.3%, shape B
+0.3%), and anchor A held (−1.25%). But it fell behind at 4 streams: anchor B −1.9%, ASR A
−3.8%, and ASR B −11.1% (14.32 against 16.10 audio seconds a second). ASR B's loss is its time to
first token, 964 to 1,188 ms, with its inter-token latency unchanged. The transcripts held (45
word differences against 46, of 568), and no reply reasoned on either build. So the engine rule
gave roll back. The architect overruled it and adopted b12063, with the reason, in the
architect's words: "outside of legitimate broken behavior, we should prioritize staying on the
latest version." No upstream issue reports the regression; llama.cpp
[#30804](https://github.com/ggml-org/llama.cpp/pull/30804) and
[#29510](https://github.com/ggml-org/llama.cpp/pull/29510) (each as the finding read it, 2026-11-03)
are candidates, by inference only (the finding, "Verdict").

## What gb10-2 doesn't take

- **E4B QAT** (`google/gemma-4-E4B-it-qat-q4_0-gguf:Q4_0`): framework's verification found it
  writing its reasoning into its replies (`docs/findings/verify-framework.md`, "Verdict"), and
  gb10-1 serves E4B Q8_0 for audio.
- **gb10-1's debt**: the removals of the `vllm` container, its image, and its compile cache; the
  bare-metal units `llama-router.service` and `vllm-server.service`; the six unused snapshots; the
  `hello-world` image; the 6.17.0-1008 kernel; and the `update-notifier-crash` reset. Each was an
  item of gb10-1's own report, and gb10-2's state for any of them is unknown here.
- **Package updates**: nvidia-spark-initcall-bl 1.0-2 and tailscale 1.104.5 reached gb10-1
  from their channels (NVIDIA's DGX Spark repository and Tailscale's). gb10-2 takes them with its
  own routine apt update, not from this report.

## gb10-2's model configuration

Any change to gb10-2's model configuration (its preset's sections, its served set, or which model
serves a purpose) stays an escalation in spike-ai-pipeline. That includes gb10-1's agent section,
`gpt-oss-120b-MXFP4-set-a`, and the rest of gb10-1's set: this report names them, and it asks
for none of them.

## Sources

| Source | Tier | URL | Read |
|---|---|---|---|
| gb10-1's verification finding, "Host stack" and "Engine pass" | the finding | [`docs/findings/verify-gb10-1.md`](verify-gb10-1.md) | 2026-11-03 |
| framework's verification finding, "Verdict" (E4B QAT's reasoning) | the finding | [`docs/findings/verify-framework.md`](verify-framework.md) | 2026-11-03 |
| spike-ai-pipeline's pin | local read | spike-ai-pipeline, `host/llama.env` | 2026-11-03 |
| spike-ai-pipeline's copies, their source commit and file list | local read | spike-ai-pipeline, `host/README.md` | 2026-11-03 |
| spike-ai-pipeline's host-update: the task, no root, no version, port 8080 | local read | spike-ai-pipeline, `mise.toml` (`[tasks.host-update]`) and `scripts/host-update.sh` | 2026-11-03 |
| spike-ai-pipeline's reads of `LLAMA_IMAGE` and `LLAMA_BUILD` | local read | spike-ai-pipeline, `scripts/host-update-lib.sh` (`clone_router_state`) and `scripts/currency.sh` | 2026-11-03 |
| spike-model-engines' per-class pins | local read | spike-model-engines, branch verify-gb10, `host/llama.env`, and `host/llama-release.sh` (`llama_pin`, `llama_build`) and `host/llama.sh` (`llama_flavor`) | 2026-11-03 |
| `LLAMA_IMAGE`'s removal | local read | spike-model-engines, commit `e2f0146`, `host/llama.env` | 2026-11-03 |
| The skill's routing check | the skill | [`.claude/skills/hosting-upgrades/SKILL.md`](../../.claude/skills/hosting-upgrades/SKILL.md), "The verify mode", step 6 | 2026-11-03 |
| llama.cpp #30804, "CUDA: chunk graphs to amortize graph launch" (through the finding, "Verdict") | primary | <https://github.com/ggml-org/llama.cpp/pull/30804> | 2026-11-03 (the finding) |
| llama.cpp #29510, `flash_attn_ext_rows` (through the finding, "Verdict") | primary | <https://github.com/ggml-org/llama.cpp/pull/29510> | 2026-11-03 (the finding) |
