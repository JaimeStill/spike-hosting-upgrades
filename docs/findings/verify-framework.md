# framework: verification of docs/reports/framework/2026-10-30-2.md, 2026-11-02

Written by `/hosting-upgrades verify framework` (the skill's verify mode,
`.claude/skills/hosting-upgrades/SKILL.md`, "The verify mode"), task verify-framework of
experiment.hosting.spike-hosting-upgrades.

## The report and the probe

- **The report verified:** [`docs/reports/framework/2026-10-30-2.md`](../reports/framework/2026-10-30-2.md),
  framework's last report (2026-10-30, the second run that day).
- **Read:** the descriptor [`docs/hosts/framework.md`](../hosts/framework.md) and the policy
  [`docs/policy.md`](../policy.md), 2026-11-02.
- **Readiness:** the run's 9 rules present; the verify mode's 3 missing (`Bash(tailscale ping
  framework)`, `Bash(tailscale ping gb10-1)`, `Edit(docs/findings/verify-*.md)`). The session went on
  with each use asking.
- **The probe:** `ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh`, run
  2026-11-02 before any change. Omarchy 4.0.6-1, kernel 7.2.8-9-omarchy (booted 2026-10-27),
  BIOS 03.06, mesa and vulkan-radeon 1:26.2.5-1, linux-firmware 20260916-1, docker 29.9.2, TTM
  112.0 GiB; `llama` on `ghcr.io/ggml-org/llama.cpp:server-vulkan-b11960` (build b11960-8642541b2),
  running and healthy, publishing `8080/tcp tailnet4`; `vllm` exited; loaded:
  `gpt-oss-120b-MXFP4-set-a`, `ggml-org/gemma-4-E4B-it-GGUF:Q8_0`,
  `google/gemma-4-26B-A4B-it-qat-q4_0-gguf:Q4_0`, `mrutkows/granite-embedding-english-r2-GGUF:BF16`;
  `net.ipv4.ip_nonlocal_bind: 0`; fwupd metadata last refreshed 2026-09-17, no firmware updates.
- **What moved since the report** (probe `== updates ==`): linux-omarchy and
  linux-omarchy-headers 7.2.8-9 → 7.2.15-1 are now on the host's channel; the report held 7.2.14,
  which hadn't reached it. mise-bin 2026.10.23-1 → 2026.10.25-1 is pending, as before. Nothing
  else moved: the Mesa and linux-firmware updates are still not on the channel, the TTM ceiling,
  the boot-order sysctl, the stopped `vllm`, the stored snapshots, and the build cache (47.01 GB,
  354.7 MB reclaimable) read as the report gave them.
- **Left for later** (step 1, item 4): the report's engine and model rows ranked verify or hold,
  other than Verify next, are candidates, not the host's items: they wait for the screen task or
  the answer task's fresh run.

## Decisions

The architect decided each item in the task's plan rounds, 2026-11-02.

| Item | Report verdict | Decision | Reason or outcome |
|---|---|---|---|
| Gemma 4 E4B QAT Q4_0 as the audio model (Verify next) | verify | apply, measured | rolled back by the verdict rule in run 3 (ASR B −5.0%) and in run 4 with reasoning off (ASR A −11.0%; reasoning written into 2 of 40 replies); see "Verdict" and "Run 4" |
| Kernel: linux-omarchy 7.2.8-9 → 7.2.15-1 (moved) | hold | apply | applied; running 7.2.15-1 ("Host stack") |
| Boot-order: `net.ipv4.ip_nonlocal_bind = 1` | hold | apply | applied; llama published its port after the reboot |
| fwupd metadata refresh (45 days old) | hold | apply | applied; no update offered |
| Mesa and vulkan-radeon 1:26.2.5 → 26.2.6 | hold | close | not on the host's channel (Omarchy stable mirror, snapshot 2026-10-22), and the router runs its image's Mesa |
| linux-firmware 20260916 → 20261019 | hold | close | not on the host's channel; reached Arch core 2026-11-01 |
| TTM ceiling 112 GiB | hold | close | headroom met: the recommended set leaves 20.5 GiB, more than the 11.2 GiB headroom |
| gpt-oss-120b sections at 8,192 tokens per session | hold | close | the anchors' (4-slot) and the sweep's (16-slot) measurement sections, which no agent loads |
| `vllm` container stopped | hold | remove | removed, with its image and compile cache ("Removals") |
| Six unused safetensors snapshots (~168G) | hold | remove | removed, 178.0G ("Removals") |
| Docker build cache, 47.01 GB | hold | remove | cleared ("Removals") |

## Host stack

Run 2026-11-02, in this order, with no anchor pass around it (the architect's decision: anchors
measure the model swap only, both passes on the new kernel).

1. **fwupd metadata refresh**: the architect, with root (fwupdmgr's first walk on this host):

   ```sh
   ssh -t framework sudo fwupdmgr refresh --force
   ```

   Output: "Successfully downloaded new metadata: 6 devices are updatable; 4 devices are supported
   in the enabled remotes (an update has been published)". Then the session, with no root:

   ```sh
   ssh framework 'fwupdmgr get-updates 2>&1'
   ```

   "No updates available". At the latest: System Firmware (BIOS 03.06), UEFI CA, UEFI dbx, Windows
   UEFI CA (the four supported devices). No firmware published: Laptop DB, Option ROM UEFI CA, the
   hub, KEK CA, Laptop KEK, and both WD BLACK SN850X drives. So no escalation, and no firmware
   reboot. No rollback is needed: a refresh changes only the metadata.
2. **Boot-order sysctl**: the architect, with root:

   ```sh
   ssh -t framework "echo 'net.ipv4.ip_nonlocal_bind = 1' | sudo tee /etc/sysctl.d/60-tailnet-bind.conf && sudo sysctl --system"
   ```

   `sysctl --system` applied `/etc/sysctl.d/60-tailnet-bind.conf`: `net.ipv4.ip_nonlocal_bind = 1`.
   Its side effect: any process on the host may bind an IPv4 address the host doesn't yet hold.
   Rollback, root: `ssh -t framework "sudo rm /etc/sysctl.d/60-tailnet-bind.conf && sudo sysctl -w net.ipv4.ip_nonlocal_bind=0"`.
3. **The update**: the architect:

   ```sh
   ssh -t framework omarchy update
   ```

   It took linux-omarchy and linux-omarchy-headers 7.2.8-9 → 7.2.15-1, and mise-bin
   2026.10.23-1 → 2026.10.25-1. Rollback, root: boot Arch `linux` 7.2.11 from Limine, then
   `sudo pacman -U /var/cache/pacman/pkg/linux-omarchy-7.2.8-9-x86_64.pkg.tar.zst /var/cache/pacman/pkg/linux-omarchy-headers-7.2.8-9-x86_64.pkg.tar.zst`
   (both read in the cache before the update), then reboot.
4. **The reboot**: the architect: `ssh -t framework sudo reboot`. One reboot carried the kernel
   and the sysctl.

**Read back** by the probe after the reboot
(`ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh`):

- `== kernel ==`: running 7.2.15-1-omarchy, booted 2026-11-02 08:55:37; installed linux-omarchy
  7.2.15-1 and Arch `linux` 7.2.11 (the fallback); no reboot pending.
- `== container-runtime ==`: `net.ipv4.ip_nonlocal_bind: 1`.
- `== engines ==`: `llama` running, `published ports 8080/tcp tailnet4` from `configured binds
  8080/tcp tailnet4`, so the boot-order check passes on this boot. `vllm` exited, as before.
- `== endpoints ==`: build b11960-8642541b2, unchanged; every preset section unloaded after the
  restart, as the router starts. Set A loads on request.
- `== updates ==`: 0 pending. `== firmware-updates ==`: metadata refreshed 2026-11-02, no
  updates. `== units ==`: no failed unit, system or user.

**The closures** (no host step): Mesa 26.2.6 and linux-firmware 20261019 are still not on the
host's channel (probe `== updates ==`, 0 pending, after the update); the TTM ceiling and the
gpt-oss measurement sections stand as decided (see "Decisions").

### Routing

Settled 2026-11-02, before the model pass that counts (the architect's decisions at two
escalations). The bare name `framework` resolved IPv4 from MagicDNS (the tailnet address) but,
now and then, through this machine's `lan` search domain to `framework.lan`, which the LAN router
(OpenWrt 25.12.4) published from framework's DHCP leases: IPv6 from odhcpd, two `fda0:` ULA
addresses, and IPv4 from dnsmasq. framework's ufw drops port 8080 on the LAN, so a connection that
took a LAN address waited out GuideLLM's 5 s connect timeout: `ConnectTimeout('')`. ufw's log
showed this machine's connections to framework's LAN IPv4 on port 8080 at the moments of the
errors. MagicDNS serves no AAAA record for dual-stack nodes
([tailscale#1152](https://github.com/tailscale/tailscale/issues/1152), open, read 2026-11-02), so a
tailnet IPv6 bind couldn't win the lookup. The fix keeps the LAN from answering for `framework`:

1. framework stops sending its hostname in DHCP: the architect, with root:

   ```sh
   ssh -t framework "sudo nmcli con mod 'Wired connection 1' ipv4.dhcp-send-hostname no ipv6.dhcp-send-hostname no && sudo nmcli con mod '<Wi-Fi connection>' ipv4.dhcp-send-hostname no ipv6.dhcp-send-hostname no && sudo systemd-run --unit=lan-reup-wifi nmcli con up '<Wi-Fi connection>' && sleep 10 && sudo systemd-run --unit=lan-reup-wired nmcli con up 'Wired connection 1'"
   ```

   Rollback: the same with `yes`.
2. The router kept the name bound to the leases, so the architect cleared them on the router
   (`ssh root@192.168.1.1`): odhcpd's (`/tmp/odhcpd.leases`, `/tmp/hosts/odhcpd.hosts.lan`, which
   held `framework` on both `fda0:` addresses), then dnsmasq's (`/tmp/dhcp.leases`):

   ```sh
   /etc/init.d/odhcpd stop
   sed -i '/framework/d' /tmp/odhcpd.leases /tmp/hosts/odhcpd.hosts.lan
   /etc/init.d/odhcpd start
   /etc/init.d/dnsmasq reload
   /etc/init.d/dnsmasq stop
   sed -i '/framework/d' /tmp/dhcp.leases
   /etc/init.d/dnsmasq start
   ```

**The routing check**, from this machine, before the pass: `framework.lan` has no A record and no
AAAA record (`resolvectl query -t A framework.lan`, `-t AAAA`); `framework` resolves to the
tailnet IPv4 only (`getent ahosts framework`); and 50 connects to `http://framework:8080/health`
with none failed and none over 50 ms (`curl -w '%{time_connect}'`; they read 2 to 5 ms, where the
IPv6 fallback had read 205 ms). The tailnet path is direct over the LAN (`tailscale ping`, "via
<LAN private address>:41641", 1 to 8 ms), so the tailnet costs no local-network latency.

The GB10s' names had no LAN record when checked (`gb10-1.lan`, `gb10-2.lan`: no AAAA), and both
connected at once; they take the same DHCP setting as prevention (gb10-1 in verify-gb10, gb10-2 a
note for spike-ai-pipeline).

## Gates

Gemma 4 E4B QAT Q4_0, `google/gemma-4-E4B-it-qat-q4_0-gguf` at
`4b4a2c1d584be7264f87aac328a1bc739ce81b6c` (the stored snapshot, probe `== models ==`; the Hub's
`sha`, [model record](https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf),
read 2026-11-02), files `gemma-4-E4B_q4_0-it.gguf` and its projector `gemma-4-E4B-it-mmproj.gguf`.
All four gates pass under today's policy.

1. **Origin:** pass. The publisher and uploader are Google
   ([model record](https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf),
   `author: google`, read 2026-11-02); the base is `google/gemma-4-E4B-it-qat-q4_0-unquantized`
   (`cardData.base_model`, same read). The screening list has no match for "Google LLC" or
   "Alphabet Inc." (`.claude/skills/hosting-upgrades/scripts/screen.sh "Google LLC" "Alphabet Inc."`,
   list downloaded 2026-11-02). The rest of the chain is the report's, unchanged (report,
   "Models", audio).
2. **Artifact integrity:** pass.
   - Both files are GGUF: probe `magic 47 47 55 46  GGUF` for each, and the Hub's per-file scan,
     "Safe GGUF model" for each, status `safe`
     ([tree](https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf/tree/main?expand=true),
     read 2026-11-02). The model file carries Protect AI's "PAIT-GGUF-100" under `safe`, which
     passes by that name (policy, "Artifact integrity").
   - **The chat template:** the GGUF's embedded template (`gguf.chat_template`, 18,569 bytes)
     is identical to the publisher's, byte for byte, in both `google/gemma-4-E4B-it-qat-q4_0-unquantized`
     and `google/gemma-4-E4B-it`, read 2026-11-02. Google keeps the template in
     `chat_template.jinja`; neither repository's `tokenizer_config.json` carries a
     `chat_template` key, so the comparison read the `.jinja` file. Commands, as run:

     ```sh
     curl -sf 'https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf?expand[]=gguf&expand[]=cardData&expand[]=author&expand[]=sha' > qat.json
     jq -r '.gguf.chat_template' qat.json > qat.tmpl
     curl -sf https://huggingface.co/google/gemma-4-E4B-it-qat-q4_0-unquantized/raw/main/chat_template.jinja > google_gemma-4-E4B-it-qat-q4_0-unquantized.jinja
     curl -sf https://huggingface.co/google/gemma-4-E4B-it/raw/main/chat_template.jinja > google_gemma-4-E4B-it.jinja
     diff qat.tmpl google_gemma-4-E4B-it-qat-q4_0-unquantized.jinja   # differs only by the newline jq -r adds
     ```
3. **Quantization floor:** pass, path 1 (Google's own QAT release). The card: "optimized with
   Quantization-Aware Training (QAT), which allows preserving similar quality to bfloat16 while
   dramatically reducing the memory requirements to load the model"
   ([card](https://huggingface.co/google/gemma-4-E4B-it-qat-q4_0-gguf), line 25, read 2026-11-02).
4. **Fit:** pass. 5.8G stored against the Q8_0's 8.1G (probe `== models ==`), so the swap
   lowers the set's memory; the recommended set already left 20.5 GiB beyond the policy's
   11.2 GiB headroom (report, "Model set").

## Cells

**The pass that counts** is run 3, 2026-11-02 20:13–20:25 UTC, after the routing check passed
("Routing"). Two earlier passes are discarded, by the architect's decisions: run 1 (before the
routing fix: Q8_0's first shape A recorded 7 of 8 requests and its rerun lost one to a
`ConnectTimeout`, and a rerun within one load hit the router's prompt cache, TTFT 386 → 160 ms),
and run 2 (after the IPv6 half of the fix: QAT shape B and both anchors after lost requests to
`ConnectTimeout`, traced to the IPv4 half). Both were rolled back the same session, and neither's
figures count.

Every cell of run 3 ran on llama.cpp b11960-8642541b2
(`ghcr.io/ggml-org/llama.cpp:server-vulkan-b11960`) and kernel 7.2.15-1-omarchy, the stack the
post-reboot probe read ("Host stack"), from this machine (GuideLLM 0.8.1, `mise.bench.toml`).
The network path: `tailscale ping -c 1 framework`, "pong from framework ... via <LAN private
address>:41641", 6 ms before the pass and 1 ms before the anchors after. The script, as run
(`bash pass.sh` from the repository root; results under `.state/verify/framework/pass3/`):

```sh
U=http://framework:8080; S=.state/verify/framework/pass3; mkdir -p $S
export GUIDELLM__SPEC__BACKEND__TARGET="$U"
G=ggml-org/gpt-oss-120b-GGUF:MXFP4; Q8=ggml-org/gemma-4-E4B-it-GGUF:Q8_0; QAT=google/gemma-4-E4B-it-qat-q4_0-gguf:Q4_0
api() { curl -s -X POST "$U/models/$1" -H "Content-Type: application/json" -d "{\"model\": \"$2\"}"; echo " $1 $2"; }
anchors() { for c in a b; do MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/anchor-$c.yaml --output "kind=json,path=$S/$1-anchor-$c.json" > $S/$1-anchor-$c.log 2>&1; done; }
cells() { for c in shape-a shape-b audio-a audio-b; do MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/$c.yaml --backend "kind=openai_http,model=$2" --tokenizer "kind=huggingface_auto,model=google/gemma-4-E4B-it" --output "kind=json,path=$S/$1-$c.json" > $S/$1-$c.log 2>&1; done; }
# unload_all unloads every loaded section and waits; wait_for polls $U/models for a state
unload_all; api load $G; api load $Q8; anchors before        # 1. anchors before
unload_all; api load $Q8; cells q8 $Q8                        # 2. Q8_0 alone, fresh load
unload_all; api load $QAT; cells qat $QAT                     # 3. QAT alone, fresh load
api load $G; anchors after                                    # 4. anchors after
```

Each anchor pass ran beside that pass's audio model, so before and after differ only by the swap;
each model's cells ran once each from a fresh load, with only that model loaded.

| Cell | Requests | Output tok/s | Audio s/s | TTFT median ms | ITL median ms |
|---|---|---|---|---|---|
| Anchor A, before | 8/8 | 44.86 | – | 640 | 19.73 |
| Anchor B, before | 32/32 | 77.14 | – | 2149 | 45.21 |
| Q8_0 shape A | 8/8 | 37.33 | – | 363 | 25.34 |
| Q8_0 shape B | 32/32 | 126.65 | – | 1031 | 28.38 |
| Q8_0 ASR A | 8/8 | 29.02 | 11.67 | 250 | 24.84 |
| Q8_0 ASR B | 32/32 | 53.17 | 19.55 | 439 | 55.85 |
| QAT shape A | 8/8 | 57.99 | – | 303 | 16.07 |
| QAT shape B | 32/32 | 182.65 | – | 943 | 19.03 |
| QAT ASR A | 8/8 | 38.80 | 15.74 | 254 | 15.49 |
| QAT ASR B | 32/32 | 83.14 | 18.57 | 390 | 29.51 |
| Anchor A, after | 8/8 | 44.66 | – | 638 | 19.71 |
| Anchor B, after | 32/32 | 77.31 | – | 2151 | 45.09 |

No request errored or went incomplete in any cell. A cell's figure is its output tok/s, and an
ASR cell's its audio seconds a second (skill, "The verify mode", step 6).

**The first anchors beside the host's last readings.** The last framework anchors on b11960, on
kernel 7.2.8-9: A 44.97903 and B 76.79873 tok/s (spike-model-engines
`docs/findings/vllm-strix.md`, "Anchors"). Run 3's before-anchors on kernel 7.2.15-1: A 44.86
(−0.3%), B 77.14 (+0.4%), each within 1.4%. No move beyond run noise, so the kernel update moved
nothing the anchors measure.

## Transcripts

ASR B's 32 replies per model, each paired with its LibriSpeech reference in queued order, by the
skill's step 7. The references, as run:

```sh
curl -s 'https://datasets-server.huggingface.co/rows?dataset=hf-internal-testing/librispeech_asr_dummy&config=clean&split=validation&offset=0&length=32' > .state/verify/framework/librispeech-refs.json
jq -c --slurpfile refs .state/verify/framework/librispeech-refs.json -f wer.jq .state/verify/framework/pass3/<model>-audio-b.json
```

(`wer.jq` is the skill's step 7 program, saved to a file.)

| Model | Pairs | Reference words | Word differences | Output tokens (all 32) | Replies that reasoned |
|---|---|---|---|---|---|
| E4B Q8_0 | 32 | 568 | 45 | 668 | 0 |
| E4B QAT | 32 | 568 | 50 | 1,085 | 2 |

Per pair, Q8_0: 1,1,2,2,9,0,1,0,1,3,2,5,0,2,0,2,0,0,0,3,1,0,0,1,0,5,1,0,0,0,2,1. QAT:
1,2,1,2,14,0,2,0,1,2,2,3,0,2,2,2,0,0,0,3,1,0,0,1,0,3,3,0,0,0,2,1. The pairs that differ by more
than a word: #4 (Q8_0 9, QAT 14, LibriSpeech's longest clip, the "Linnell's pictures" passage)
and #14 ("by harry quilter m a": Q8_0 0, QAT 2, "by Harry Quilter", a reply that reasoned first).

**QAT's unprompted reasoning.** On 2 of ASR B's 32 requests (#14, #30), and none of ASR A's 8, QAT
opened a reasoning block the prompt didn't ask for ("Thinking Process: 1. **Analyze the
Request:** ..."), which GuideLLM records as `reasoning_output`: #14 spent the cap of 256 tokens
in 8.3 s, and #30 186 tokens in 3.5 s. Q8_0 opened none, with the same template, prompt, and
engine (the templates are byte-identical, "Gates"). The discarded runs showed the same behavior,
on 6 and 3 of 32.

## Verdict

**Roll back.** The rule (skill, "The verify mode", step 8), condition by condition:

1. **Anchors A and B after within 1.4% of before:** holds. A 44.86 → 44.66 (−0.45%), B 77.14 →
   77.31 (+0.21%).
2. **No candidate cell behind the incumbent's by more than 1.4%:** fails, on ASR B alone: −5.0%
   (18.57 against 19.55 audio s/s). The other three lead: shape A +55.4% (57.99 against 37.33),
   shape B +44.2% (182.65 against 126.65), ASR A +34.9% (15.74 against 11.67).
3. **Transcription within the incumbent's total plus 1.4% of the reference words:** holds. 50
   against a bound of 45 + 7.95 = 52.95.

The architect applied the rule, with no overrule (2026-11-02). Rolled back the same session: QAT
and the 4-slot section unloaded, and set A loaded as before the pass
(`gpt-oss-120b-MXFP4-set-a`, `ggml-org/gemma-4-E4B-it-GGUF:Q8_0`,
`google/gemma-4-26B-A4B-it-qat-q4_0-gguf:Q4_0`, `mrutkows/granite-embedding-english-r2-GGUF:BF16`),
read back by the router's `/models`. E4B Q8_0 stays the audio model, so nothing is retired and no
"Where … still lives" table applies. QAT's files stay in the store, as before the task.

**For a later task.** ASR B's loss traces to the two replies that reasoned: QAT's median request
took 0.95 s against Q8_0's 1.23 s, and with no reply reasoning (ASR A) it leads by 35%. A section
that turns reasoning off for the audio model (the router's reasoning budget, or the template's
thinking switch) might keep QAT's speed with no reasoning replies. That is a new candidate
configuration in a preset this spike doesn't own (spike-model-engines `host/llama-preset`), for
the screen task, or for whatever comes to own the host tooling.

### Run 4: E4B QAT with reasoning off

Revision 2 of the brief (the architect, after run 3): QAT is wanted as the Gemma baseline, so run 4
tested whether turning its reasoning off removes run 3's loss. Gemma 4's template already defaults
thinking off (`enable_thinking | default(false)`; no `<|think|>` token; the reply opens with
`<|turn>model`), so QAT's thought blocks are its own. llama.cpp b11960's reasoning-budget sampler,
at budget 0, forces the end tag as soon as the model opens a thought block
(`common/reasoning-budget.cpp`), and the server takes it per request,
`reasoning_budget_tokens` (`tools/server/server-common.cpp:1519`).

**Smoke check**, QAT loaded, one request asking for thinking (`enable_thinking: true`):

```sh
curl -s http://framework:8080/v1/chat/completions -H "Content-Type: application/json" -d '{"model": "google/gemma-4-E4B-it-qat-q4_0-gguf:Q4_0", "max_tokens": 256, "chat_template_kwargs": {"enable_thinking": true}, "messages": [{"role": "user", "content": "What is 17 times 23? Answer with the number only."}], "reasoning_budget_tokens": 0}'
```

With the budget: no reasoning, "391" in 4 tokens. Without it (the control): 366 characters of
reasoning, then "391", 177 tokens. The smoke check loaded QAT beside set A, and the router evicted
set A's agent section unseen; set A was restored before the pass, and the architect made one model
per purpose a standard (`STANDARDS.md`, "Hosts").

**The pass**, 2026-11-02 21:33–21:47 UTC, run 3's script with the ASR cells swapped for
`bench/audio-a-budget0.yaml` and `bench/audio-b-budget0.yaml` (each request sends
`reasoning_budget_tokens: 0`) for both models; the shape cells unchanged, since they ask for
thinking by design. The routing check passed first (`framework.lan`: no A, no AAAA). Results under
`.state/verify/framework/pass4/`. Every cell held its full count with no error.

| Cell | Q8_0 | QAT | QAT vs Q8_0 |
|---|---|---|---|
| Anchor A before → after (tok/s) | 44.91 | 44.66 | −0.6% |
| Anchor B before → after (tok/s) | 76.73 | 76.46 | −0.4% |
| Shape A (tok/s) | 37.29 | 57.93 | +55.3% |
| Shape B (tok/s) | 125.65 | 183.20 | +45.8% |
| ASR A, budget 0 (audio s/s) | 11.60 | 10.32 | −11.0% |
| ASR B, budget 0 (audio s/s) | 19.41 | 24.64 | +26.9% |
| ASR B word differences (of 568) | 43 | 49 | bound 50.95 |
| Replies in a thought block (of 40) | 0 | 0 | |
| Replies with reasoning in the text (of 40) | 0 | 2 | |

**What budget 0 did.** It closed every thought block: no reply reasoned in the channel, none came
back empty, none hit the cap. But on 2 of ASR A's 8 requests (#1, #2), QAT wrote its reasoning into
the reply itself, before the transcript: "The user wants me to transcribe the provided speech
segment into English text.\nThe speech segment is: \"nor ..." (85 and 121 tokens, against Q8_0's 14
and 34). A consumer would take that text as the transcript. That costs ASR A its lead, and the
replies are wrong as transcripts. Q8_0 did it on no request in any run.

**Verdict: roll back**, by the rule, and by the stop condition the architect set for this run
(budget 0 still let a reply reason): anchors hold; ASR A trails by 11.0%; the transcripts hold; the
channel count holds, but the text carries reasoning on 2 of 40. Set A was restored, one model per
purpose (`gpt-oss-120b-MXFP4-set-a`, `ggml-org/gemma-4-E4B-it-GGUF:Q8_0`,
`google/gemma-4-26B-A4B-it-qat-q4_0-gguf:Q4_0`, `mrutkows/granite-embedding-english-r2-GGUF:BF16`).
No preset was changed. E4B QAT's unprompted reasoning, in the channel or in the text, goes to the
screen task, with the check that caught it: replies whose text speaks about the task.

## The claim beside the anchors

The report's claim: E4B QAT +56.6% at text shape A over E4B Q8_0 (58.1 against 37.1 output tok/s)
on this host, Vulkan, b11669 (spike-model-engines `docs/findings/llama-strix-rocm.md`, as the
report cites it). Measured here, b11960 and kernel 7.2.15-1, with the anchors steady within 0.5%:
+55.4% (57.99 against 37.33). The claim held for what it measured, within about a point, and the
lead carries to shape B (+44.2%) and to ASR A (+34.9%). It said nothing of the model's
unprompted reasoning, which costs ASR B its lead. A speed claim measured on fixed-length text
doesn't show a behavior that changes a reply's length, so the verify mode's cells per purpose,
with replies the model ends itself, are what caught it.

## Removals

1. **vLLM**: the session, no root, through spike-model-engines' `engines` suite from the host's
   clone (at 9f994c3):

   ```sh
   ssh framework 'cd ~/repos/spike-model-engines && host/engines vllm uninstall; echo "exit $?"'
   ```

   "removed container vllm", "removed image vllm/vllm-openai-rocm:v0.32.0", "removed compile
   cache /home/jaime/.cache/vllm" (1.5G), exit 0. Rollback: `host/engines vllm install`.
2. **The six unused safetensors snapshots**: the session, no root, the dry run first, shown to
   the architect before the removal:

   ```sh
   ssh framework 'cd ~/repos/spike-model-engines && MISE_ENV=host HF_HUB_CACHE=/srv/models mise exec -- hf cache rm model/openai/gpt-oss-120b model/google/gemma-4-26B-A4B-it model/google/gemma-4-E4B-it model/google/gemma-4-12B-it-qat-w4a16-ct model/google/gemma-4-31B-it-qat-w4a16-ct model/google/gemma-4-E4B-it-qat-w4a16-ct --dry-run'
   ssh framework 'cd ~/repos/spike-model-engines && MISE_ENV=host HF_HUB_CACHE=/srv/models mise exec -- hf cache rm model/openai/gpt-oss-120b model/google/gemma-4-26B-A4B-it model/google/gemma-4-E4B-it model/google/gemma-4-12B-it-qat-w4a16-ct model/google/gemma-4-31B-it-qat-w4a16-ct model/google/gemma-4-E4B-it-qat-w4a16-ct -y'
   ```

   "Deleted 6 repo(s) and 6 revision(s); freed 178.0G" (hf's decimal G; the report's ~168G was
   GiB). ibm-granite's 288M weights stay. Rollback: `hf download` each repository.
3. **The docker build cache**: the session, no root:

   ```sh
   ssh framework docker builder prune -a -f
   ```

   "Total: 47.01GB". Rollback: none needed; a later build rebuilds what it needs.

**Read back** by the probe: `== engines ==` lists only `llama`, running and healthy; `==
models ==` lists eight snapshots, none of the six; `== docker-disk ==` shows one image (1.211GB)
and a build cache of 0B.

**The space hasn't come back yet.** `df -h /` reads 524G free after the removals, about what it
read before them. `/srv/models` and docker's data live in the root subvolume
(`btrfs /dev/mapper/root[/@]`, `findmnt -T /srv/models`), which Omarchy's snapper config `root`
snapshots (`/etc/snapper/configs/root`), so the removed files' extents stay held until the
snapshots that hold them rotate out or the architect deletes them (root). That a 100G-scale model
store sits inside snapshotted root is a finding for the host's next report and for whatever comes
to own the host tooling: a store on its own subvolume, outside the snapshots, frees space when
a model is removed.

## Sources

| Source | Tier | URL | Read |
|---|---|---|---|
| E4B QAT model record | primary | <https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf> | 2026-11-02 |
| E4B QAT per-file scan | primary | <https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf/tree/main?expand=true> | 2026-11-02 |
| E4B QAT card | primary | <https://huggingface.co/google/gemma-4-E4B-it-qat-q4_0-gguf> | 2026-11-02 |
| Publisher's template, QAT unquantized | primary | <https://huggingface.co/google/gemma-4-E4B-it-qat-q4_0-unquantized/raw/main/chat_template.jinja> | 2026-11-02 |
| spike-model-engines vllm-strix.md, "Anchors" (last framework anchors) | attributed benchmark | spike-model-engines `docs/findings/vllm-strix.md` | 2026-11-02 |
| tailscale#1152, "Add AAAA records to MagicDNS" | primary | <https://github.com/tailscale/tailscale/issues/1152> | 2026-11-02 |
| LibriSpeech references, dataset viewer | primary | <https://datasets-server.huggingface.co/rows?dataset=hf-internal-testing/librispeech_asr_dummy&config=clean&split=validation&offset=0&length=32> | 2026-11-02 |
| Publisher's template, E4B-it | primary | <https://huggingface.co/google/gemma-4-E4B-it/raw/main/chat_template.jinja> | 2026-11-02 |
| Consolidated Screening List | primary | <https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.json> | 2026-11-02 |
