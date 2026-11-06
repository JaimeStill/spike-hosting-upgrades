# Shared rules

The rules `survey` and `measure` share, each defined here once. A mode file cites a rule by this
file and its heading, as `rules.md`, "Fresh loads", and never restates it. The model gates are in
[models.md](models.md) and the sources in [sources.md](sources.md).

## Who runs what

A run changes nothing on a host by itself. It prints every command that would change or load the
host (an update, a reboot, a removal, a model load or unload, a cell, an engine move), says who
runs it, and records each as it was run:

- **Root** steps are the architect's, printed as "Root" says (`ssh -t <host> sudo <command>`).
- **Steps that need no root** the session may run itself, over SSH or from this machine, in the
  architect's view, once the architect has agreed them (the brief, or an answer in the run).
- **A tool's first use** on a host, a new tool's or concept's first walk, and any step the
  architect asks to keep are the architect's.

The bundled scripts only read. The commands that change a host are the host's own tools (the
package manager, `docker`, `hf`, the engine's API), and an engine changes only through
spike-model-engines' `engines` suite, run from the host's clone of it with the version as its
argument.

## Default rules

Three rules settle what the screen task escalated (the architect's decisions, 2026-11-06). A run
applies them without asking, and its record names each time one applied:

1. **The engine build.** An engine move takes the newest build with an image for the host's class
   (the image series the host's engine runs, such as `server-cuda13-<build>` or
   `server-vulkan-<build>`) that passes the build gate ([measure.md](measure.md), "Build gate").
   A newer build with no image for the class is passed over, named in the record with the
   registry read that showed it missing. A build that fails the gate is rolled back at once and
   recorded, and the newest imaged build older than it and newer than the incumbent becomes the
   candidate; when none is left, the host stays on the incumbent and the record says so.
2. **A failure is retried once from a fresh load.** A failed load (a timeout, an error), or a
   failed cell (fewer successful requests than its full count, an errored or incomplete request,
   an errored run), is run again once, from a fresh load of its model ("Fresh loads"). A second
   failure of the same step is recorded as failed, and the run goes on: the verdict's rule reads
   it as an incomplete cell. A failure that leaves the host unable to serve (the router down,
   SSH or the probe failing) is no retry: the run stops, an escalation ("Pause").
3. **A cap hit is recorded, and the run goes on.** A step that reaches its cap ("Caps") is
   recorded with what it completed before the cap. The verdict's rule reads it at every finish
   its unfinished part allows: a condition that holds at every finish, or fails at every finish,
   is settled (6 of 20 passing is under 0.325 however the rest would finish); one the cap leaves
   open fails, as an incomplete cell does. A reply that runs past its tier's token cap counts as
   a cap hit ("Caps"), and so does a step the memory floor stops.

Escalations remain only for what these rules don't settle; "Pause" lists them.

## Load targets

Each purpose a host descriptor lists carries a load target: the concurrent sessions (for the agent
purpose) or concurrent requests (for any other) it is sized for, and the context each one reaches.
The descriptor cites where each figure comes from. A host serves the purposes its descriptor lists
and no others; no rule here or in a mode assumes a fixed set of purposes, and which host serves
which purpose is spike-model-layout's to decide.

A run judges against the targets:

- **Configuration.** Each section or container serving a purpose meets its target: at least the
  target's slots (or, on vLLM, `--max-num-seqs`), and a per-session context ("Per-session
  context") of at least the target's context. A section short of its target is hold, with the fix
  stated; one sized beyond it spends memory the set could use, and is named.
- **Engine fit.** An engine, or a build, is weighed at the concurrency the targets name, not at
  one stream alone: a published figure at another concurrency is context, and says which.
- **Capacity.** A candidate's capacity is judged at its purpose's target: its sweep holds the ITL
  ceiling at the target's concurrency, and each of its slots holds the target's context.
- **Memory.** A model set is estimated with each model at its purpose's target slots and context
  ([models.md](models.md), "Memory estimate"), and it must leave the policy's headroom.

A purpose the descriptor lists without a load target is a pause ("Pause", a policy question): the
run asks the architect for it and records the answer as the architect's, never inventing one.

### Per-session context

The context one session can reach, marked **estimate** with its method:

- **Split KV cache**: `ctx-size / parallel`, the context divided among the slots.
- **Unified KV cache**: the whole pool, `ctx-size`, shared by every session, so one session can
  reach it all while the others take what is left; a per-slot cap the engine applies (a
  `--kv-unified-per-slot`, the model's trained context) bounds it, and the record names the cap.
- **vLLM**: `--max-model-len`, which caps each request rather than being a total shared across
  `--max-num-seqs`; the KV pool (from `--gpu-memory-utilization`) limits how many sessions run at
  once, not how far each one reaches. So `--max-num-seqs 4 --max-model-len 8192` gives each
  session 8,192, not 2,048.

Whether the cache is unified comes from the section's keys and the flags (`--kv-unified`, `-kvu`,
`--no-kv-unified`). Where neither says, read the engine's default at the probed build from its
source, and cite the file and the line: on llama.cpp the default can depend on other flags, such
as `--parallel` being set or left at auto. An agent session is also held to the policy's minimum
(`docs/policy.md`, "Agent session context"): a section under it is hold, with the figure, the
minimum, and the fix stated (a context, a slot count, or a unified cache that brings each session
to the minimum, and toward the model's native context where memory allows).

## Citing

Every claim in a record cites its source inline, with its URL and the date it was read, as
`([name](https://...), read YYYY-MM-DD)`. A claim from the probe cites its section
(`probe == memory ==`); a claim from the architect cites the answer and the date; a claim from a
cell cites the cell and its result file. A figure worked out on paper rather than read from a
measurement is marked **estimate** and names its method, for example "estimate: per-slot context
= `--ctx-size` / `--parallel` when the KV cache isn't unified, from `llama-context.cpp` at the
probed build". A citation names the page the run read itself; a search engine's result summary
points to a page to read and is never the cited source. A Sources-table row that names a group,
such as "every model named above", does not stand in for a claim's inline citation: each model's
origin, base, and format claims cite that model's own page.

## Dated records

A mode writes one record per host per run, at `docs/<kind>/<host>/<YYYY-MM-DD>.md`, dated the day
the run read its sources (a survey) or began its cells (a measure). When the host already has a
record of that kind and date, the run writes `<YYYY-MM-DD>-2.md`, then `-3`, the next number free.
A record is never edited once written; a later run writes a new one. The last record is the newest
date, and within a date the highest number (a file name sort puts `<date>-2.md` before
`<date>.md`, so sort by date, then by number).

## Fresh loads

The host serves one model per purpose, so every load follows one rule: unload the model that
serves the purpose, wait until the router reports it unloaded, and only then load the other,
through the engine (a router's `/models/unload` and `/models/load`, read back by its `/models`).
Never load a candidate beside its purpose's incumbent. A router holds a cap on loaded models
(llama.cpp's `--models-max`, 4 by default), and a load that arrives before an unload has finished
takes it over the cap, so the router evicts its least recently used model, another purpose's,
unseen.

**Each model's cells run once each from a fresh load**: unload the model, wait until the router
reports it unloaded, load it, then run its cells, each once. Never rerun a cell within one load:
GuideLLM's synthetic prompts are the same on every run, so a second run in one load hits the
router's prompt cache and reads faster than the first. The one exception is a candidate's agent
tiers and conform, which share one fresh load (measure.md, "The candidate screen").

At a run's end, restore the host's set by the same rule (the set it served at the start, or the
set a verdict adopts), and read it back by the router's `/models` and the probe.

## Cells

**One state a pass.** Every cell of a pass runs on one engine build and one kernel; a pass whose
build or kernel changes partway starts again. An engine move's pass spans its two builds on one
kernel. Each pass records the engine build and the host stack (a probe), the routing check
("Routing"), and the network path:

```sh
tailscale ping -c 1 <host>
```

**The tool.** GuideLLM 0.8.1 from this machine (`mise.bench.toml`), with the engine's URL
exported in `GUIDELLM__SPEC__BACKEND__TARGET` by the host's short name (`http://<host>:<port>`), so
no address is committed. Measure's `cell` helper runs it (measure.md, "Step helpers"), one cell a
call, under the monitor, and its result goes under `.state/measure/<host>/`, as these commands
give it:

```sh
MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/anchor-<a|b>.yaml --output "kind=json,path=.state/measure/<host>/<pass>-anchor-<a|b>.json"
MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/<scenario>.yaml --backend "kind=openai_http,model=<section>" --tokenizer "kind=huggingface_auto,model=<tokenizer>" --output "kind=json,path=.state/measure/<host>/<pass>-<cell>.json"
```

Every scenario but the anchors names no model, so its command gives the section and the tokenizer
(the model's upstream repository, such as `openai/gpt-oss-120b`).

**The scenarios**, the project's `bench/`: `anchor-a.yaml` and `anchor-b.yaml` (512 prompt tokens
in, 256 out; A is 1 stream × 8 requests, B is 4 × 32); `shape-a.yaml` and `shape-b.yaml`, the
anchors' loads on any model, with thinking on; `audio-a.yaml` and `audio-b.yaml` for a
transcription purpose's ASR cells, with their budget-0 variants ("Reasoning check");
`vision-a.yaml` and `vision-b.yaml` (720p and 200 tokens in, 64 out); `long-a.yaml` (1 × 4, 8,192
in, 512 out) and `long-b.yaml` (4 × 16); and `sweep.yaml` (1, 4, 16, and 32 streams, 60 s a
level). A purpose with no scenario (embedding) has no cells, and the record says so.

**A cell's figure** is its output tokens per second
(`.benchmarks[0].metrics.output_tokens_per_second.successful.mean` in its JSON), and for an ASR
cell its audio seconds a second (`.benchmarks[0].metrics.audio.seconds.input_per_second.successful.mean`),
since a transcript's length is the model's own. A cell counts only with its full request count,
the scenario's `max_requests`, in `.benchmarks[0].metrics.request_totals.successful`: a cell that
records fewer successful requests fails, even with none errored, and "Default rules", item 2,
applies.

## Caps

Each GuideLLM cell is capped at 10 minutes (`timeout 10m`), each agent tier at 15 minutes
(`timeout 15m`), and any other step at the cap its brief agrees. A step that reaches its time cap
exits 124. A cap hit is recorded, and the run goes on ("Default rules", item 3).

**A tier's token cap.** A reply past its tier's token cap is a cap hit. The token cap is the
`max_tokens` the tier sends. BFCL sends none (the harness's requests carry the model, the tools,
`tool_choice`, and `parallel_tool_calls`, and no token limit; `docs/screens/gb10-1/2026-11-05.md`,
"Cells"), so a runaway reply runs on until the model stops or the section's per-session context
ends it: one multi-turn sample there generated 23,306 tokens, one reply of 7,326 ("BFCL and
conform"). Until the harness sends a cap, a BFCL reply's cap is the section's per-session context,
and a reply that stops there (Inspect's stop reason `max_tokens` or `model_length`) is a cap hit;
the record gives each tier's largest reply beside its count, with its sample, so a runaway that
stopped short of the context still shows. A sample a runaway holds past the tier's time cap is the
time cap's hit.

**The memory floor.** A long step (an agent tier, conform, any step capped past 10 minutes) and
every cell run under the monitor (measure.md, "During cells") stop when the memory available to
the GPU falls under the floor: the policy's headroom on the probed ceiling (`docs/policy.md`,
"Memory headroom"), 12.2 GiB on gb10-1 (its screen's floor, `docs/screens/gb10-1/2026-11-05.md`,
"BFCL and conform") and 11.2 GiB on framework (10% of its 112 GiB GTT ceiling). The memory
available is MemAvailable on a GB10 and the GTT free (`mem_info_gtt_total` less
`mem_info_gtt_used`) on a Strix Halo, each the ceiling the probe reads less what is in use. A
stopped step is recorded with its last readout, as a cap hit: below the floor the set has spent
the headroom the policy keeps, as the screen's no-prompt-cache arm did on gb10-1 (0.69 GiB
available at its end).

## Figures

**Each cell's row** gives its request count, its figure, its TTFT median, and its ITL median. Beside
them go the earlier claims for the same model and shape: the pool's figure, the last survey's
published claim, and the host's earlier measured cell, each cited with its build. In an engine
move, each row gives both builds and the change, and beside the TTFT median the published claim
the survey cited that applies to the cell's model (a prefill gain measured on an MoE beside an
MoE's cells, a fix beside the family it names). The anchors and the vision cells send short
prompts, so their TTFT median is where a prefill claim shows; an ASR cell's prompt is its clip, so
a claim beside it is context, not a test. Output tok/s goes beside the claim, since a prefill gain
claims nothing about decode.

**Comparisons.** Only cells run in the same session on the same versions are compared with each
other; an earlier claim is context, never a condition.

**The sweep's two figures.** Each sweep level runs 60 s and then cancels the requests in flight,
so the record gives two output figures a level, and `summarize` prints both
(measure.md, "Step helpers"):

- **completed-request**: the output tokens of the requests that finished within the level, over
  its time (`.metrics.output_tokens_per_second.successful.mean`). With 256 tokens a request it is
  the completed count times 256 over 60, so it is flat wherever the completed count is (the
  earlier records' "flat 68 tok/s" at 4, 16 and 32 streams).
- **every-token**: every output token generated in the level, by the finished requests and by
  those cancelled at the cutoff (`.metrics.output_tokens_per_second.total.mean`), what the slots
  actually decoded (gpt-oss-120b on gb10-1's 16-slot section: 49.4, 76.5, 125.6 and 124.5 at 1, 4,
  16 and 32 streams; `docs/screens/gb10-1/2026-11-05.md`, "The sweep's measure").

The sweep's incomplete requests are by design, not failures. The capacity condition reads ITL,
not either figure.

**Run noise.** Each descriptor's "Run noise" gives two spreads, each the widest relative spread
between readings of one cell on one engine build and one kernel, (highest − lowest) / lowest, of
its figure:

- **within-session**: readings in one session. It is the engine rule's and the keep rule's run
  noise (measure.md, "The verdict"), and the bound on any comparison within one run.
- **across-days**: readings in different sessions, across reboots and days. It bounds a rerun
  anchor against an earlier task's reading of the same cell, and the first anchors against the
  host's earlier readings.

A cell moved only when its change is beyond the matching spread. The descriptor cites each
spread's readings. A spread marked provisional is set by the next measure that repeats cells
(the same cell twice, each from a fresh load, in one session): the widest of its sources and the
repeats, which the record states and the session writes into the descriptor. A set spread widens
when a later same-build spread exceeds it, never narrows by one quiet run, and changes otherwise
only by the architect's decision. A descriptor with no "Run noise" is a pause ("Pause", a policy
question).

**The first anchors** of a run are set beside the host's last earlier readings (the descriptor's
Measurements and the host's earlier records). A move beyond the across-days spread is a finding:
the record names it, with both readings and what changed between them (the engine build, the
kernel, the firmware), and the comparison within the run goes on.

## Reasoning check

On each candidate cell whose requests don't ask for reasoning (the ASR and vision cells; the shape
cells ask for it by design, `enable_thinking: true`), and on the incumbent's beside them: count
the replies that reasoned in the thought channel (a non-empty `reasoning_output`), and the replies
whose text speaks about the task instead of answering it ("The user wants me to ...", "Thinking
Process"). Read the replies the second count flags, to confirm each:

```sh
jq -c '.benchmarks[0].requests.successful | {replies: length, reasoned_in_channel: (map(select((.reasoning_output // "") != "")) | length), reasoned_in_text: (map(select((.output // "") | test("The user wants me to|Thinking Process"; "i"))) | length)}' .state/measure/<host>/<cell>.json
```

A configuration that turns reasoning off is tested with the budget-0 variants,
`bench/audio-a-budget0.yaml` and `bench/audio-b-budget0.yaml`: `audio-a.yaml` and `audio-b.yaml`
with `reasoning_budget_tokens: 0` sent in every request, which llama.cpp honours by closing a
thought block as soon as the model opens one. They run in place of the ASR cells, for both models.
Budget 0 empties the channel, but it can move the reasoning into the text: in verify-framework's
run 4 it did, on 2 of E4B QAT's 40 replies, and the text count catches it.

## Transcripts

For a transcription purpose, the ASR B cell's 32 replies are compared with their LibriSpeech
references by word differences, with curl and jq and no other tool. The references are the first
32 rows of `hf-internal-testing/librispeech_asr_dummy` (`clean`, `validation`), the rows
`audio-b.yaml` reads, from the Hub's dataset viewer, read once:

```sh
curl -s 'https://datasets-server.huggingface.co/rows?dataset=hf-internal-testing/librispeech_asr_dummy&config=clean&split=validation&offset=0&length=32' > .state/measure/<host>/librispeech-refs.json
```

Each reply is paired with its reference in the order its request was queued
(`.info.timings.queued`), which is the order the scenario reads the rows. Both are lower-cased and
stripped of punctuation, then split into words, and the word differences are the word-level edit
distance (substitutions, insertions, and deletions). The cell must hold 32 successful requests:

```sh
jq --slurpfile refs .state/measure/<host>/librispeech-refs.json '
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
' .state/measure/<host>/<cell>.json
```

The record gives each model's total, the reference words, and each pair's count, and quotes any
pair whose count differs between the two models (or two builds) by more than a word.

## Routing

The routing check runs from this machine before each pass:

- `<host>.lan`, in the LAN domain this machine's resolver searches, has no A and no AAAA record;
- the bare host name resolves to the tailnet address only;
- 50 connects to the router's `/health` with none failed and none over 50 ms.

The commands name no numbered field (a dollar sign and a digit): Claude Code replaces those in a
skill with the skill's arguments when it loads it, so a field is read by `cut` or by `$NF`. The
check reads the resolver as it stands, with no cache flush, so it sees what GuideLLM will. It
guards against a LAN record for the bare name: the resolver tries the search domain too, so when
the LAN router publishes `<host>.lan` from the host's DHCP leases, a connection can take the LAN
address, where the host's firewall drops the engine's port, and the client waits out its connect
timeout (GuideLLM's 5 s, `ConnectTimeout('')`). The commands, each printing a label rather than an
address:

```sh
for ty in A AAAA; do echo "<host>.lan $ty: $(resolvectl query -t $ty <host>.lan >/dev/null 2>&1 && echo PRESENT || echo none)"; done
t=$(tailscale ip <host>); echo "bare name: $(getent ahosts <host> | cut -d' ' -f1 | sort -u | while read -r a; do echo "$t" | grep -qxF "$a" && echo tailnet || echo NOT-TAILNET; done | paste -sd' ')"
for i in $(seq 1 50); do curl -s -o /dev/null -w '%{time_connect} ' --connect-timeout 5 http://<host>:<port>/health || echo -n "FAIL "; done | tr ' ' '\n' | awk 'NF{n++; if($NF=="FAIL")f++; else if($NF>0.05)s++; if($NF>m)m=$NF} END{print n" connects, "f+0" failed, "s+0" over 50 ms, max "m" s"}'
```

A LAN record for `<host>.lan`, a bare name that resolves off the tailnet, or a failed connect is
a failed check, and a failed check is a pause. Connects over 50 ms with none failed, when
`tailscale ping -c 1 <host>` answers through a DERP relay (no direct connection), are not: the
relay adds the same latency to both sides of a comparison within one session, so the check records
the relay, its region and the ping, and the pass goes on. An across-days comparison names each
reading's path, direct or relayed (the architect's decision, 2026-11-06). Connects over 50 ms on a
direct path are a pause. The fix verify-framework recorded (`docs/findings/verify-framework.md`,
"Routing") keeps the LAN from answering for the host, and both steps need root, so both are the
architect's: the host stops sending its hostname in DHCP (NetworkManager's
`ipv4.dhcp-send-hostname` and `ipv6.dhcp-send-hostname` set to `no` on each of its connections,
which then come up again), and the router's lease names for the host are cleared (its DHCPv4 and
DHCPv6 lease files, with the router's DHCP services restarted).

## Pause

A run stops and asks the architect, rather than guessing or failing, only for a choice the rules
don't settle:

1. **The probe contradicts the descriptor**: a served model whose purpose isn't listed, or a
   listed purpose nothing serves (survey.md, step 2).
2. **Sources conflict on a claim**: two sources disagree on a version, a gain, or a support claim.
   A version conflict among vendor notes that no verdict depends on is not a pause: the probe's
   installed versions decide, and the record keeps the conflict ([sources.md](sources.md),
   "Tiers"). One that changes a verdict still is.
3. **A policy question**: the policy lacks a value a step needs, a purpose lacks a load target, a
   descriptor lacks its run noise, or a candidate sits on a rule's edge: a format the floor doesn't name, a file whose floor path its
   build doesn't settle, or a scanner message under a "safe" status other than the one the policy
   passes by name. Origin is never a pause: a model with involvement found at a level the policy
   excludes on, or that fails its compliance gate, is excluded on origin; involvement at a level
   the policy only records, and adversary-generated data in a training mix, go in the model's row;
   and a model short of the pass bar is researched further and, only if the research can't settle
   it, held out as "origin unclear" (survey.md, step 8).
4. **A source's tier is unclear**: the run can't tell whether a source is primary, an attributed
   benchmark, or a lead.
5. **The host can't serve**: the router down, SSH or the probe failing mid-run ("Default rules",
   item 2).
6. **The routing check fails** ("Routing"): its fix is root's.
7. **A gate fails a model a measure needs**: a model that would serve a purpose in the pass fails
   a gate under today's policy, so its purpose's cells wait until the architect names another.
8. **A profile doesn't match**: a conform profile that fails to validate, or whose router IDs
   differ from the router's `/models`.
9. **The host moved under a verdict**: a change on the host since the survey that would alter an
   item's verdict.
10. **A step with no rollback**: an offered update with no downgrade path (a firmware update
    `fwupdmgr` lists, a BIOS), which the architect decides outside the defaults.
11. **Anything outside the task's brief.**

A pause states what was found, cites where (the probe section, the descriptor line, the source),
gives the options with the one the run would take by default, and waits. For example:

```text
Pause: the probe contradicts the descriptor (gb10-1).

The descriptor (docs/hosts/gb10-1.md) lists its purposes, each with a load target. The probe finds
nothing serving: == endpoints == reports nothing OpenAI-compatible on loopback, both containers
(llama, vllm) are exited, and both units (llama-router, vllm-server) are disabled and inactive.
So no listed purpose is served.

How should the run go on?
  a. (default) Treat the installed engines and stored models as the incumbent: the inventory says
     nothing serves, and every section ranks against what is installed.
  b. The host is meant to serve fewer purposes: name the ones to drop, and the report proposes
     the descriptor change.
  c. Stop: the host is mid-change, and the run should wait until it serves again.
```

Record each answer the architect gives, with its date; the record cites it as the architect's.

## Root

The probe reads only what an unprivileged user can. When a step needs a fact only root can read,
the run never runs sudo itself. It prints the exact command, in the form that runs it on the host
from this machine (`ssh -t <host> sudo <command>`, where `-t` gives sudo a terminal for its
password), says what fact it needs and why, asks the architect to run it and paste the output, and
continues from the pasted output, citing it as the architect's read-out.

For the GPU's loaded firmware, the command is
`ssh -t <host> sudo cat /sys/kernel/debug/dri/<N>/amdgpu_firmware_info`, where `<N>` is the card
number in the probe's `/sys/class/drm/card<N>` line under `== memory ==`. For example, when the
probe prints `/sys/class/drm/card1: GTT total ...`:

```text
The report needs the GPU's loaded firmware versions, which only root can read. Run this from
this machine and paste the output (N = 1, from the probe's /sys/class/drm/card1):

  ssh -t framework sudo cat /sys/kernel/debug/dri/1/amdgpu_firmware_info
```

If the architect declines, the run goes on without the fact and the record says which fact is
missing and what it would have decided.

### Package versions a notice names

When Arch news, or another distribution's notice, urges an upgrade of a package the probe's output
doesn't list, the run asks for its installed version the same way, though no root is needed: it
prints the command (`ssh <host> pacman -Q <package>` on Arch, and `ssh <host> dpkg-query -W
<package>` on apt), says which notice names the package and why, asks the architect to run it and
paste the output, and continues from it, citing it as the architect's read-out. The run doesn't run
it itself: the readiness check grants ssh only for the probe. For example:

```text
Arch news of <date> urges upgrading <package> before the next update. The probe doesn't list it.
Run this from this machine and paste the output:

  ssh framework pacman -Q <package>
```
