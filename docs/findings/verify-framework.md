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
| Gemma 4 E4B QAT Q4_0 as the audio model (Verify next) | verify | apply, measured | see "Cells" and "Verdict" |
| Kernel: linux-omarchy 7.2.8-9 → 7.2.15-1 (moved) | hold | apply | with `omarchy update`; rollback in "Host stack" |
| Boot-order: `net.ipv4.ip_nonlocal_bind = 1` | hold | apply | before the kernel's reboot |
| fwupd metadata refresh (45 days old) | hold | apply | fwupdmgr's first walk; any offer is an escalation |
| Mesa and vulkan-radeon 1:26.2.5 → 26.2.6 | hold | close | not on the host's channel (Omarchy stable mirror, snapshot 2026-10-22), and the router runs its image's Mesa |
| linux-firmware 20260916 → 20261019 | hold | close | not on the host's channel; reached Arch core 2026-11-01 |
| TTM ceiling 112 GiB | hold | close | headroom met: the recommended set leaves 20.5 GiB, more than the 11.2 GiB headroom |
| gpt-oss-120b sections at 8,192 tokens per session | hold | close | the anchors' (4-slot) and the sweep's (16-slot) measurement sections, which no agent loads |
| `vllm` container stopped | hold | remove | the container and every vLLM image, through the `engines` suite |
| Six unused safetensors snapshots (~168G) | hold | remove | `hf cache rm`, dry run first; ibm-granite's weights stay |
| Docker build cache, 47.01 GB | hold | remove | `docker builder prune -a -f` |

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

_Pending: slice 3._

## Transcripts

_Pending: slice 3._

## Verdict

_Pending: slice 3._

## The claim beside the anchors

_Pending: slice 3._

## Removals

_Pending: slice 3._

## Sources

| Source | Tier | URL | Read |
|---|---|---|---|
| E4B QAT model record | primary | <https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf> | 2026-11-02 |
| E4B QAT per-file scan | primary | <https://huggingface.co/api/models/google/gemma-4-E4B-it-qat-q4_0-gguf/tree/main?expand=true> | 2026-11-02 |
| E4B QAT card | primary | <https://huggingface.co/google/gemma-4-E4B-it-qat-q4_0-gguf> | 2026-11-02 |
| Publisher's template, QAT unquantized | primary | <https://huggingface.co/google/gemma-4-E4B-it-qat-q4_0-unquantized/raw/main/chat_template.jinja> | 2026-11-02 |
| Publisher's template, E4B-it | primary | <https://huggingface.co/google/gemma-4-E4B-it/raw/main/chat_template.jinja> | 2026-11-02 |
| Consolidated Screening List | primary | <https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.json> | 2026-11-02 |
