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
| Gemma 4 E4B QAT Q4_0 as the audio model (Verify next) | verify | apply, measured | rolled back by the verdict rule (ASR cells and transcripts); see "Verdict" |
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

One pass, 2026-11-02, from this machine (GuideLLM 0.8.1, `mise.bench.toml`), every cell on
llama.cpp b11960-8642541b2 (`ghcr.io/ggml-org/llama.cpp:server-vulkan-b11960`) and kernel
7.2.15-1-omarchy, the stack the post-reboot probe read ("Host stack"). The network path, before
and after the cells: `tailscale ping -c 3 framework` and `tailscale ping -c 1 framework`, "pong
from framework ... in 2ms", direct (address redacted). The target was the host's short name, so
no address is committed:

```sh
export GUIDELLM__SPEC__BACKEND__TARGET="http://framework:8080"
```

Sections were loaded and unloaded through the router (`U=http://framework:8080`):

```sh
curl -s -X POST $U/models/load -H "Content-Type: application/json" -d "{\"model\": \"$m\"}"
curl -s -X POST $U/models/unload -H "Content-Type: application/json" -d "{\"model\": \"$m\"}"
```

Each anchor and each cell, every run under `timeout 10m`, results under `.state/verify/framework/`:

```sh
MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/anchor-$c.yaml --output "kind=json,path=.state/verify/framework/<pass>-anchor-$c.json"
MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/$c.yaml --backend "kind=openai_http,model=$M" --tokenizer "kind=huggingface_auto,model=google/gemma-4-E4B-it" --output "kind=json,path=.state/verify/framework/<model>-$c.json"
```

The order, and what was loaded for each step (the session's choice within the brief: each anchor
pass beside that pass's audio model, so before and after differ only by the swap; each model's
cells with only that model loaded):

1. **Anchors before**: `ggml-org/gpt-oss-120b-GGUF:MXFP4` (the 4-slot section) beside
   `ggml-org/gemma-4-E4B-it-GGUF:Q8_0`; nothing else loaded.
2. **E4B Q8_0 alone**: shape A, shape B, ASR A, ASR B.
3. **E4B QAT alone** (`google/gemma-4-E4B-it-qat-q4_0-gguf:Q4_0`, Q8_0 unloaded): the same four.
4. **Anchors after**: the 4-slot section beside E4B QAT.

| Cell | Requests | Output tok/s | Audio s/s | TTFT median ms | ITL median ms |
|---|---|---|---|---|---|
| Anchor A, before | 8/8 | 44.48 | – | 639 | 19.88 |
| Anchor B, before | 32/32 | 77.14 | – | 2140 | 44.91 |
| Q8_0 shape A | 8/8 | 37.29 | – | 363 | 25.44 |
| Q8_0 shape B | 32/32 | 125.69 | – | 1030 | 28.67 |
| Q8_0 ASR A | 8/8 | 29.23 | 11.64 | 246 | 24.52 |
| Q8_0 ASR B | 32/32 | 53.58 | 19.77 | 418 | 51.40 |
| QAT shape A | 8/8 | 57.91 | – | 304 | 16.07 |
| QAT shape B | 32/32 | 182.86 | – | 942 | 18.95 |
| QAT ASR A | 8/8 | 50.44 | 7.20 | 261 | 15.93 |
| QAT ASR B | 32/32 | 118.60 | 14.54 | 346 | 25.29 |
| Anchor A, after | 8/8 | 44.44 | – | 644 | 19.84 |
| Anchor B, after | 32/32 | 76.96 | – | 2146 | 45.45 |

A cell's figure is its output tok/s, and an ASR cell's is its audio seconds a second (skill, "The
verify mode", step 6).

**Q8_0's first cells, set aside** (the architect's decision at an escalation, 2026-11-02). Q8_0's
four cells first ran once in one load. Its shape A recorded 7 of 8 requests, none errored or
incomplete (`request_totals` 7/0/0; GuideLLM created 8), at 37.13 tok/s. The rerun, in the same
load, had one request fail with `ConnectTimeout('')` after 5 s, nothing in the router's log, at
34.73 tok/s (the 5 s gap counts in its window; per request 38.49), and its prefill hit the
router's prompt cache: TTFT median 386 → 160 ms, ITL 25.56 → 25.41 ms. GuideLLM's synthetic prompts
are the same every run, so a second run in one load reuses the first's cached prefixes. The
architect decided: reload Q8_0, which empties its cache, and run its four cells again, once each,
as QAT's ran; the table holds that run (`q8-redo-*`). The first run's other three cells, all with
full counts: shape B 125.23, ASR A 11.53 audio s/s, ASR B 19.07, within 4% of the redo. The
ConnectTimeout did not recur in the 120 requests after it.

**The first anchors beside the host's last readings.** The last framework anchors on b11960, on
kernel 7.2.8-9, over the LAN path: A 44.97903 and B 76.79873 tok/s (spike-model-engines
`docs/findings/vllm-strix.md`, "Anchors"). Today's before-anchors on kernel 7.2.15-1: A 44.48
(−1.1%), B 77.14 (+0.4%), each within 1.4%. No move beyond run noise, so no finding.

## Transcripts

ASR B's 32 replies per model, each paired with its LibriSpeech reference in queued order, by the
skill's step 7. The references, as run:

```sh
curl -s 'https://datasets-server.huggingface.co/rows?dataset=hf-internal-testing/librispeech_asr_dummy&config=clean&split=validation&offset=0&length=32' > .state/verify/framework/librispeech-refs.json
jq -c --slurpfile refs .state/verify/framework/librispeech-refs.json -f wer.jq .state/verify/framework/<model>-audio-b.json
```

(`wer.jq` is the skill's step 7 program, saved to a file.)

| Model | Pairs | Reference words | Word differences | Output tokens (all 32) |
|---|---|---|---|---|
| E4B Q8_0 | 32 | 568 | 42 | 666 |
| E4B QAT | 32 | 568 | 85 | 1,984 |

**Why QAT's count doubled.** On 6 of ASR B's 32 requests (#0, #3, #15, #21, #24, #25) and 2 of ASR
A's 8, QAT opened a reasoning block the prompt didn't ask for ("Thinking Process: 1. **Analyze the
Request:** The user wants a transcription..."), which GuideLLM records as `reasoning_output`. It
spent the cap of 256 tokens, so the transcript came back short or empty. Q8_0 opened none, with
the same template, prompt, and engine. The embedded templates are byte-identical ("Gates").

The pairs whose counts differ by more than a word between the models:

| # | Q8_0 | QAT | QAT tokens | QAT reasoned | Reference | Q8_0 | QAT |
|---|---|---|---|---|---|---|---|
| 2 | 1 | 3 | 35 | no | he tells us that at this festive season of the year with christmas and roast beef looming before us similes drawn from eating and its results occur most readily to the mind | he tells us that at this festive season of the year with christmas and a roast beef looming before us similes drawn from eating and its results occur most readily to the mind | She tells us that at this festive season of the year with christmas and a roast beef looming before us similies drawn from eating and its results occur most readily to the mind |
| 3 | 1 | 10 | 256 | yes | he has grave doubts whether sir frederick leighton's work is really greek after all and can discover in it but little of rocky ithaca | he has grave doubts whether sir frederick layton's work is really greek after all and can discover in it but little of rocky ithaca | He has grave doubts whether Sir Frederick Leighton's work is really Greek after all |
| 10 | 0 | 2 | 17 | no | near the fire and the ornaments fred brought home from india on the mantel board | near the fire and the ornaments fred brought home from india on the mantel board | near the fire and the ornaments fred brought home from india on the mantelboard. |
| 14 | 0 | 2 | 6 | no | by harry quilter m a | by harry quilter m a | by harry quilter ma |
| 15 | 3 | 26 | 256 | yes | because you were sleeping instead of conquering the lovely rose princess has become a fiddle without a bow while poor shaggy sits there a cooing dove | because you were asleep instead of conquering the lovely rose princess has become a fiddle without a bow ohpoor shaggy sits there a cooing dove | (empty) |
| 24 | 0 | 2 | 256 | yes | he doesn't work at all | he doesn't work at all | He doesn't work |
| 26 | 1 | 3 | 7 | no | not exactly returned kaliko | not exactly returned calico | Not exactly we turned calico |

## Verdict

**Roll back.** The rule (skill, "The verify mode", step 8), condition by condition:

1. **Anchors A and B after within 1.4% of before:** holds. A 44.48 → 44.44 (−0.1%), B 77.14 →
   76.96 (−0.2%).
2. **No candidate cell behind the incumbent's by more than 1.4%:** fails. Shape A +55.3% (57.91
   against 37.29), shape B +45.5% (182.86 against 125.69), but ASR A −38.1% (7.20 against 11.64
   audio s/s) and ASR B −26.5% (14.54 against 19.77).
3. **Transcription within the incumbent's total plus 1.4% of the reference words:** fails. 85
   against a bound of 42 + 7.95 = 49.95.

No overrule. Rolled back the same session: QAT and the 4-slot section unloaded, and set A loaded
as before the pass (`gpt-oss-120b-MXFP4-set-a`, `ggml-org/gemma-4-E4B-it-GGUF:Q8_0`,
`google/gemma-4-26B-A4B-it-qat-q4_0-gguf:Q4_0`, `mrutkows/granite-embedding-english-r2-GGUF:BF16`),
read back by the router's `/models` and by the probe's `== endpoints ==`. E4B Q8_0 stays the
audio model, so nothing is retired and no "Where … still lives" table applies. QAT's files stay
in the store, as before the task.

**For a later task.** The ASR loss traces to QAT's unprompted reasoning, not to its speed: its
token rate is ahead at every shape. A section that turns reasoning off for the audio model (the
router's reasoning budget, or the template's thinking switch) might keep QAT's speed and Q8_0's
transcripts. That is a new candidate configuration in a preset this spike doesn't own
(spike-model-engines `host/llama-preset`), so it goes to the screen task, or to whatever comes to
own the host tooling, not to this verification.

## The claim beside the anchors

The report's claim: E4B QAT +56.6% at text shape A over E4B Q8_0 (58.1 against 37.1 output tok/s)
on this host, Vulkan, b11669 (spike-model-engines `docs/findings/llama-strix-rocm.md`, as the
report cites it). Measured here, b11960 and kernel 7.2.15-1, with anchors steady within 0.2%:
+55.3% (57.91 against 37.29). The claim held for what it measured, within 1.3 points. It said
nothing of ASR, where QAT fell behind for a reason no speed figure shows. So a speed claim on
text shapes doesn't carry to another modality of the same model, and the verify mode's cells per
purpose are what caught it.

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
| LibriSpeech references, dataset viewer | primary | <https://datasets-server.huggingface.co/rows?dataset=hf-internal-testing/librispeech_asr_dummy&config=clean&split=validation&offset=0&length=32> | 2026-11-02 |
| Publisher's template, E4B-it | primary | <https://huggingface.co/google/gemma-4-E4B-it/raw/main/chat_template.jinja> | 2026-11-02 |
| Consolidated Screening List | primary | <https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.json> | 2026-11-02 |
