---
name: hosting-upgrades
description: Evaluates upgrades to one inference host's serving stack (its hardware configuration, model engine, and models) from what others publish, and ranks what the workstation has fallen behind on (pending package and firmware updates, failed units, container images behind their tag, unused images and models, configuration that differs from its descriptor). Probes the host over SSH, read-only and without root, and writes a dated, cited report giving each item a verdict (verify, take, hold, or skip); it applies nothing. Its verify mode takes a host's last report to a decision on each item and writes a verification finding; its screen mode gates another spike's model pool for the host's class under today's policy, measures one agent candidate beside the host's set, and writes a dated screen record. Neither changes the host itself. Use when asked to evaluate upgrades for a host, find what it has fallen behind on, plan its next upgrade, verify or settle a report's items, or screen a model pool for a host.
argument-hint: <host> | setup | verify <host> | screen <host>
---

# hosting-upgrades

Evaluates upgrades for one host a run: the host named by its SSH short name, here `$0`. A run
probes the host as it is now, reconciles what it finds with the project's descriptor of that host,
and writes one dated report. The skill knows no particular environment: the hosts and the rules
come from the project's own documents, and every other fact comes from the probe.

The run is interactive. It pauses and asks the architect rather than guessing or failing (see
"When to pause"), and it never runs a command that needs root (see "Facts that need root").

`/hosting-upgrades setup` starts no run: it runs the readiness check alone and prints the full
rule set the workspace needs, for a new workspace or a new host (see "Readiness check").

`/hosting-upgrades verify <host>` starts no run either: it takes the host's last report to a
decision on each of its verify, take, and hold items, prints what applying each would take, and
writes the host's verification finding (see "The verify mode"). Like a run, it changes nothing
on the host itself.

`/hosting-upgrades screen <host>` starts no run either: it gates the model pool the host's
descriptor names for the host's class, under today's policy, measures one agent candidate beside
the host's set in one session, and writes the host's dated screen record (see "The screen mode").
It changes nothing on the host itself, and no served set.

The skill's frontmatter grants no tools. A skill's grant clears when the user sends their next
message, so an interactive run would lose it at its first pause; the durable grants are the
settings rules the readiness check prints.

## Inputs

A run reads two documents from the project, relative to its root (`${CLAUDE_PROJECT_DIR}`), and
writes neither. The report and verify modes take no other spike's model pool as an input; only the
screen mode reads one, the pool the descriptor's Pool section names.

- **The host descriptor**, `docs/hosts/<host>.md`. It holds only:
  - the SSH short name the run reaches the host by
  - the declared model purposes: what the host serves or is meant to serve (agent, vision, audio,
    embedding, or whatever it serves), naming no model
  - optional watch items: named things the run must check, beside its own scan, of any kind:
    hardware (a component step 5 weighs, such as the kernel, the firmware or BIOS, or the memory
    ceiling), system (what step 5b reads, such as the package channel, units, or containers), or
    engine (an engine, a backend, a feature, or a regression, step 6). Each is answered by name in
    the report section of its kind
  - optional measurements: the workspace's own dated findings on this host, each a reference
    name plus a path, which the run counts as attributed benchmarks ([sources.md](sources.md),
    "Tiers")
  - an optional pool: another spike's model pool document, a reference name plus a path in the
    same form, which only the screen mode reads ("The screen mode", step 1)

  Every other fact about the host comes from probing it. [templates/host.md](templates/host.md)
  gives the shape, for an environment writing its own.
- **The policy**, `docs/policy.md`. It states the model-origin rule, artifact integrity with the
  code the architect has accepted, the quantization floor, the agent quality bar, the speed
  floors per purpose, the minimum context per agent session, and the memory headroom a model set
  must leave.
  [templates/policy.md](templates/policy.md) gives the shape.

When a step needs a policy value the document doesn't state (a floor for a kind of model it
doesn't name, a headroom it leaves open), the run asks the architect for the value and records
the answer in the report as the architect's, never inventing one.

## Readiness check

A run's tools need permission rules in the project's settings, or each use asks. The check works
out the rules this workspace needs, finds the ones missing, and prints them for the architect to
add. It never writes a settings file. A run makes it the last part of step 1; the verify mode
makes it its first step, with the verify mode's rules, and the screen mode the same, with the
screen mode's; `setup` makes it the whole run, with all three sets.

1. **Work out the rules.** The probe path is the project-relative one step 2 runs
   (`.claude/skills/hosting-upgrades/scripts/probe.sh` here), and the reports directory is
   `docs/reports`. The rules are:
   - one exact rule per host with a descriptor in `docs/hosts/`, named by the descriptor's SSH
     short name: `Bash(ssh <host> bash -s < <probe path>)`
   - `Bash(gh search issues *)` and `Bash(gh search prs *)`
   - `WebSearch`
   - `WebFetch`
   - `Edit(<reports dir>/**)`, which is `Edit(docs/reports/**)` here; an Edit rule covers creating
     a file too
   - `Bash(.claude/skills/hosting-upgrades/scripts/screen.sh *)`, for the screening-list script
     the origin research runs (models.md, "Origin"); like the probe rule, it names the script's
     project-relative path, the one the run invokes it by
   - `Bash(.claude/skills/hosting-upgrades/scripts/magic.sh *)`, for the first-bytes script the
     artifact integrity check runs (models.md, "Artifact integrity"), named the same way; the
     script takes a repository and a file, never a URL, so the rule can fetch nothing but a file
     on the Hub

   The verify mode needs every one of the run's rules (its probe, and its gate re-checks' reads
   and scripts, models.md), and these beside them:
   - one exact rule per host with a descriptor, named by its SSH short name:
     `Bash(tailscale ping -c 1 <host>)`, for the network path each pass records ("The verify
     mode", step 6)
   - `Edit(docs/findings/verify-*.md)`, for the verification finding, the mode's only write

   The screen mode needs every one of the verify mode's rules (its probe, its gates' reads and
   scripts, and `tailscale ping`), and these beside them:
   - `Edit(docs/screens/**)`, for the screen record, the mode's only write
   - one rule per pool a descriptor names, for reading it outside the project:
     `Read(<the pool's absolute path>)`, written with `~/` for a path under the home directory.
     It names the architect's own checkout, so it belongs in `.claude/settings.local.json`

   Reading the project's own files needs no rule.
2. **Read the settings.** Read `.claude/settings.json` and `.claude/settings.local.json` at the
   project root; either may be missing, which is no error. A rule is present when either file's
   `permissions.allow` holds it exactly as written above.
3. **Print what is missing.** For each rule missing from both, print the exact JSON to add under
   `permissions.allow`, and name the file it belongs in: `.claude/settings.json` when the skill
   lives inside the project, so the rules are committed beside it, and
   `.claude/settings.local.json` when the skill is installed outside it, since its absolute probe
   path is the architect's own. `setup` prints the full rule set first, each rule marked present
   or missing, then the JSON for the missing ones. For example:

   ```text
   Readiness check: 9 rules missing from .claude/settings.json and .claude/settings.local.json.
   Add them to .claude/settings.json, under permissions.allow:

     "Bash(ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh)",
     "Bash(ssh gb10-1 bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh)",
     "Bash(gh search issues *)",
     "Bash(gh search prs *)",
     "WebSearch",
     "WebFetch",
     "Edit(docs/reports/**)",
     "Bash(.claude/skills/hosting-upgrades/scripts/screen.sh *)",
     "Bash(.claude/skills/hosting-upgrades/scripts/magic.sh *)"
   ```

   `setup` prints the verify mode's rules beside the run's: the run's set first, then the verify
   mode's own rules, then the screen mode's own, each marked present or missing, then the JSON for
   every rule missing from any set. The verify mode works out the run's set and its own, and asks
   about any rule missing from either; the screen mode works out all three. For example, in a
   workspace that holds the run's rules:

   ```text
   Readiness check, the run's rules: 9 of 9 present.
     present  "Bash(ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh)"
     ...
   Readiness check, the verify mode's rules (the run's 9, and these): 3 missing.
     missing  "Bash(tailscale ping -c 1 framework)"
     missing  "Bash(tailscale ping -c 1 gb10-1)"
     missing  "Edit(docs/findings/verify-*.md)"
   Add them to .claude/settings.json, under permissions.allow:

     "Bash(tailscale ping -c 1 framework)",
     "Bash(tailscale ping -c 1 gb10-1)",
     "Edit(docs/findings/verify-*.md)"
   ```
4. **Ask.** When a rule is missing, ask whether to continue with the prompts the missing rules
   bring, or wait while the architect adds them; the default is to wait. When none is missing,
   say so and go on. `setup` asks nothing: it stops once it has printed.

Three rules the check never prints:

- **No rule for `gh api`.** Settings rules apply to every agent in the workspace, not only to this
  skill, and `gh api` writes as readily as it reads (`-X POST`, `-f`), with the architect's
  GitHub token. So a `gh api` call, the fallback once unauthenticated reads run out, asks each
  time.
- **No wildcard ssh host.** A rule such as `Bash(ssh * bash -s < <probe path>)` also matches ssh
  options riding along in the wildcard (`-o ProxyCommand=<any command>` runs that command on this
  machine), so each host gets its own exact rule, and a new host's descriptor brings a new rule
  through `setup`. The rule names the probe path literally, because settings rules don't expand
  `${CLAUDE_SKILL_DIR}`.
- **No rule for a command the verify or screen mode prints.** The commands that apply or remove
  an item, load or unload a model, or run a cell (`sudo`, `docker`, `hf`, `curl`, `guidellm`,
  `git push`, the agent tiers, any ssh beyond the probe) change the host or load it. Each is run
  in the architect's view, by the architect or the session as the mode assigns it, and asks each
  time.

## The run

### 1. Load the inputs

1. Take the host from the argument, `$0`. With no argument, list the descriptors in `docs/hosts/`
   by their short names, ask which host to run on, and run on one host only. With `setup`, run
   the readiness check alone, as "Readiness check" says, and stop there. With `verify` and a
   host, `$1`, follow "The verify mode" instead of these steps, and with `screen` and a host, `$1`,
   follow "The screen mode".
2. Read `docs/hosts/<host>.md`. If it is absent, stop and say so: "No descriptor for `<host>` in
   `docs/hosts/`, so the run has no declared purposes to judge against; write one from the
   skill's `templates/host.md` and run again." Name the descriptors that do exist.
3. Read `docs/policy.md`. If it is absent, stop and say so: "The project has no policy document
   (`docs/policy.md`), so no candidate can be judged against the model-origin rule, the
   quantization floor, or the memory headroom; write one from the skill's `templates/policy.md`
   and run again."
4. If the descriptor holds anything beyond its sections (a model name, an engine version, a
   memory figure), treat it as stale: the probe decides those facts, and the report notes the
   extra lines under "Proposed changes".
5. Run the readiness check ("Readiness check") before the probe, and go on as the architect
   answers it. The report's Inventory lists the rules the check found missing and the answer.

### 2. Probe

Run the bundled probe on the host over SSH, from the project root, by its project-relative path,
exactly as:

```sh
ssh <host> bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh
```

`<host>` is the descriptor's SSH short name. The command is the literal one the readiness check's
ssh rule names, with no prefix (`timeout`) and no redirect, so the rule matches it and the run
asks no permission. Where the skill lives elsewhere, the probe path is `${CLAUDE_SKILL_DIR}`
relative to `${CLAUDE_PROJECT_DIR}`, followed by `/scripts/probe.sh`; when the skill is installed
outside the project, it is the probe's absolute path. Write the path out in the command: settings
rules don't expand `${CLAUDE_SKILL_DIR}`, so a command that names the variable matches no rule.

[scripts/probe.sh](scripts/probe.sh) is read-only and needs no root. It prints labeled sections
(`== os ==`, `== kernel ==`, `== firmware ==`, `== gpu ==`, `== memory ==`,
`== container-runtime ==`, `== engines ==`, `== endpoints ==`, `== models ==`, `== updates ==`,
`== firmware-updates ==`, `== units ==`, `== docker-disk ==`, `== skipped ==`).
Each engine container, and each model a llama.cpp router lists, carries a `flags` line: its
launch arguments filtered to the ones that shape serving (context, parallel slots, batching, KV
cache and its checkpoints, offload, memory, sampling), which is the incumbent's configuration
step 6 weighs. A container that mounts a preset (a llama.cpp router's `models.ini`, mounted at
`/etc/llama-preset`) carries a `preset` block: each file's shape (sections, keys, lines the probe
couldn't read), then each section, by the model name the router lists, with its keys through the
same filter: the block names the mount's path inside the container and each file's name, and no
key outside the filter prints its value. A flag neither line shows was not passed, and is at the
engine's default unless it was set another way the probe doesn't read (an environment variable
such as `LLAMA_ARG_CTX_SIZE`, a config file); a flag outside the filter's list doesn't show
either. Each container, each preset section, and each model a router lists also carries a
`drafter` line: the drafter models its arguments load for speculative decoding, each by its file
or repository name only, or `none`, then in parentheses any other speculative key by name; a
`[*]` section's drafter loads with every model. A drafter key whose value the probe couldn't
read shows as `<key> (value unread)`, never as `none`. Each container also carries its
`restart policy`.
`== updates ==`, `== firmware-updates ==`, `== units ==`, and `== docker-disk ==` are what the
host has fallen behind on, and `== models ==` gives each stored model's size and last-modified
date; step 5b reads them.
`== models ==` also carries a `magic` line for each GGUF file in a store: its first 4 bytes, as
hex and as text (a byte outside printable ASCII shows as `.`), and its path in the store (in a
Hugging Face cache, `models--<org>--<repo>/snapshots/<revision>/<file>`, read through the cache's
link to its blob). Those bytes settle a stored file's format (models.md, "Artifact integrity").
A file the probe can't read shows `magic unreadable without root`, and a link whose blob is gone
`magic missing (a broken link)`; neither settles the format.
`== updates ==` opens with where the host's packages come from. On Arch, `mirror:` lines give the
mirrorlist's servers and `repo <name>:` lines each repository pacman.conf names, with its server
or included list. On Omarchy, `omarchy channel:` lines say which channel's template
(`stable`, `rc`, `edge`) the mirrorlist and pacman.conf each still match and which of `omarchy`
or `omarchy-dev` is installed: Omarchy records no channel of its own, so the templates are how
it is read. On apt, an `apt source` line gives each source's URIs and suites, from one-line
`.list` files and deb822 `.sources` files alike.
Each engine container also carries a `published ports` line (what it publishes now, or `none`,
and `none (no network)` when it is on no network) and a `configured binds` line (the bindings it
was created with), each port named by its bind class: `tailnet4` (the tailnet IPv4 address),
`tailnet6` (the tailnet IPv6 address), `all`, `loopback`, or `other`. `== container-runtime ==`
prints `net.ipv4.ip_nonlocal_bind` and `net.ipv6.ip_nonlocal_bind` (`absent` on a kernel without
IPv6). Step 5b's boot-order check reads them all.
A probe whose command is absent on the host prints `skipped:` and the probe goes on; a skip is a
fact too, and the report keeps it. The probe prints no network address: it reads listening ports
from `ss -Hltn` and `docker port` and drops the address from each, and a final guard redacts any
IPv4 address, tailnet IPv6 address, or MagicDNS name that slips through, so its output can go into
the report as is.

- If SSH fails, stop and say the host is unreachable, quoting the error. Don't work around it.
- If the probe's output is incomplete (a section is missing, or docker reports no permission),
  say which sections are missing and ask whether to continue without them.

### 3. Reconcile with the descriptor

Compare what the probe found with what the descriptor declares, and pause on every discrepancy
(see "When to pause") before going on:

- **A served model whose purpose isn't declared**: map each model in `== endpoints ==` to a
  purpose from its name and, where unclear, its card. A model that fits no declared purpose is a
  discrepancy.
- **A declared purpose nothing serves**: a purpose with no served model, including the case where
  nothing serves at all. When nothing serves, the inventory says so, and the later steps judge
  against the installed engines (`== engines ==`) and the stored models (`== models ==`), once
  the architect confirms that is what the run should do.
- **A watch item the probe can't reach**: a watch item naming something the host doesn't have
  (an engine or backend it doesn't run, a component or device it lacks) is kept, not dropped;
  note it for "Proposed changes".

Record each answer the architect gives; the report cites it as the architect's.

### 4. Sources

Gather the public record for what the probe found, from the sources in
[sources.md](sources.md), which lists each by kind (hardware and host stack, engines, models,
benchmarks) and by vendor or project, with its URL and how to read it. Read the machine-readable
endpoint where one exists (the GitHub releases API, the Hugging Face API, Arch's package JSON),
and read it fresh: what a source said on an earlier run is not evidence today.

**When the inventory hasn't moved.** Compare the probe with the Inventory of the host's last
report in `docs/reports/<host>/` (the newest date, and within a date the highest `-N`, step 11;
a file name sort puts `<date>-2.md` before `<date>.md`). When the two match on the engine
builds (each container's image and the build an endpoint reports), the stored and served models
and their files, and the host stack (the OS image, the kernel, the firmware and BIOS, the
driver or Mesa), the run researches only what moved, and cites the last report, by its path and
date, for the rest. Always researched, whatever the inventory shows, because the outside world
moves:

- pending package and firmware updates, and each container image's newest tag (step 5b)
- each component's and engine's newer releases, and what is newly known to break (steps 5 and 6)
- the newest models of the publishers and the scan for new candidates (step 7), with their origin
  chains (models.md, "Origin")
- the descriptor's watch items, of every kind, each answered by name in its kind's step (5, 5b,
  or 6)

A row the run carries from the last report says so, with that report's citation, and keeps its
verdict unless something researched in this run changes it. When any of the three differs, the
run researches in full, and the Inventory names what differs. The Inventory says which of the two
the run did.

Read with WebFetch and search with WebSearch, GitHub included: release pages, api.github.com
JSON, and raw files from raw.githubusercontent.com or the contents API. Search a project's
tracker with `gh search issues` and `gh search prs`. A `gh api` call is only the fallback once
unauthenticated API reads (60 an hour) run out, and it asks permission each time, since the
readiness check prints no rule for it ([sources.md](sources.md), "Reading a source"). When the
research is split across subagents, split it as "Research" says, with the tools it names; no
part reads a source with curl or jq through Bash.

- **Read for the probed versions.** For each component the probe names (OS image, kernel,
  firmware, BIOS, driver or Mesa, each engine and its build), find what is newer, what changed
  between the probed version and the newest, and what is known to break.
- **Search beyond the list.** A web search finds benchmarks and reports the list doesn't hold.
  A found source is tiered by the same bar as a listed one, and a good one is proposed for the
  list under "Proposed changes".
- **Tier every source** as primary, attributed benchmark, or lead, by the bar in
  [sources.md](sources.md), "Tiers". A lead names something to check and never carries a verify
  verdict alone.
- **Read the host's own measurements.** Each finding the descriptor lists under "Measurements"
  is an attributed benchmark on this host. Cite it by its reference name and path, and compare
  only cells measured in one session.
- **Never cite a blocklisted source** ([blocklist.md](blocklist.md)). When one carries a figure
  worth having, follow it to its original and cite that, or leave the figure out. A source met
  in this run that fails a blocklist criterion is proposed for the blocklist, with its reason,
  under "Proposed changes".

#### Citing

Every claim in the report cites its source inline, with its URL and the date it was read, as
`([name](https://...), read YYYY-MM-DD)`. A claim from the probe cites its section
(`probe == memory ==`); a claim from the architect cites the answer and the date. A figure the
run works out on paper rather than reads from a measurement is marked **estimate** and names its
method, for example "estimate: per-slot context = `--ctx-size` / `--parallel` when the KV cache
isn't unified, from `llama-context.cpp` at the probed build". A citation names the page the run
read itself; a search engine's result summary points to a page to read and is never the cited
source. A Sources-table row that names a group, such as "every model named above", does not
stand in for a claim's inline citation: each model's origin, base, and format claims cite that
model's own page.

### 5. Hardware configuration

Recommend adjustments to the host's hardware configuration, one per component that has a
candidate: kernel, firmware (linux-firmware, GPU firmware), BIOS, OS image, driver or Mesa, and
the GPU-reachable memory ceiling (the TTM limit on AMD; on GB10, the system memory). A component
already at its newest, with nothing known to break, gets one line saying so, with the source that
shows it.

First ask which components reach the engine. A containerized engine carries its own Mesa and
ROCm (or CUDA) in its image, so a host Mesa or ROCm update doesn't change what it serves; only the
kernel, the firmware, the BIOS, and the memory ceiling reach it from the host. For such an engine,
the component's version is the image's: read it from the image's Dockerfile or labels at the
probed tag, and cite that. Never run a container to read it. A host component that doesn't reach
the engine is still reported, with its verdict judged on what it does reach (the desktop, other
services), and the report says it doesn't change serving.

Each adjustment gives:

- **From and to**: the probed version and the candidate.
- **Sources**: each with its tier and its citation.
- **Claimed gain**: what the sources claim, in their own terms, or "none claimed".
- **Risk**: what is known to break, whether it needs root, and its rollback (a package
  downgrade, a BIOS reflash, removing a modprobe file).
- **Verdict**: verify, take, hold, or skip, by the rules in "Verdicts" below, with the reason.

Order the adjustments verify, take, hold, skip. A fact the probe can't read without
root (loaded GPU firmware, BIOS settings) is asked for as "Facts that need root" says.

**The hardware watch items.** Answer each of the descriptor's watch items of this kind (a
component this step weighs, such as a kernel's known faults, a firmware or BIOS setting, or the
memory the firmware reserves) by name, under its own heading: what the sources say now, cited,
and what changed since the last report if there is one. An item that bears on a component's
verdict is cited in that component's row.

This step judges each component's version. Whether the host has caught up with what it already
installed (a newer kernel installed but not running, a reboot pending) and the boot-order check
are step 5b's, and the kernel's row here points to them.

### 5b. System updates and debt

Everything the host has fallen behind on, found and ranked: what is pending, what has failed, what
takes disk and serves nothing, and what drifted from the descriptor. The step is numbered 5b so
that the steps after it keep their numbers. The run applies none of it: applying a take or
verify item, with its rollback, is a later task's, and the report says what each would take.

Each item names what the probe found, cited to its section, and takes a verdict by "Verdicts"
(step 6) with its sources:

- **take** is as "Verdicts" (step 6) defines it, with the item's known rollback named in its
  row, and under the same two rules: a root step with no rollback is hold, and an engine build is
  never take.
- **verify** needs an attributed gain, as everywhere; in this step it arises only where an update
  reaches the engine, and that item is judged in step 6 and referenced here.
- **hold** is everything that needs the architect's decision before a later task acts on it: an
  update whose only claim is release notes, or that needs a root step with no rollback; a failed
  or stopped service; a removal; a drift between two values.
- **skip** is an update with a reported regression, or an item the architect's answer retires (a
  service step 3 settled should stay down).

Order the items verify, take, hold, skip; within a verdict, the item that risks serving first (a
boot-order failure, a stopped engine), then by disk freed.

1. **Pending package updates** (`== updates ==`). List every pending update with its from and to
   versions. On apt, give the lists' age from the `apt lists` line: the count is as of that date,
   and refreshing the lists is root's (`ssh -t <host> sudo apt-get update`, asked for as "Facts
   that need root" says, after which the run probes again). On Arch, the count is a fresh sync.
   Read the updates against the channel and mirror the probe prints at the section's head (the
   `mirror:`, `repo`, and `omarchy channel:` lines, or the `apt source` lines): an update is
   what that channel and mirror offer, and a mirror that serves a snapshot (Omarchy's stable
   mirror) can lag the distribution's own. Read the distribution's notices for each (Arch news
   for a manual intervention, the release's changelog or security notice), and give the verdict
   by them. When a notice urges an upgrade of a package the probe doesn't list, ask for its
   installed version as "Package versions a notice names" says. A package step 5 weighs (the
   kernel, firmware, Mesa, the driver) keeps its verdict there and is listed here by reference.
   Packages that share a verdict and a reason may share a row that names each.
2. **Firmware updates** (`== firmware-updates ==`). Each device with an update, by name, from and
   to, with the vendor's release notes for that version (LVFS or the vendor's page). "No updates"
   is an item too, with the fwupd metadata's date, which bounds what it can know. Applying
   firmware is a root step; one with no downgrade path has no rollback, so it is hold
   ("Verdicts").
3. **The kernel and a pending reboot** (`== kernel ==`). An installed kernel newer than the
   running one, or a pending reboot (`reboot: pending`), is an item: the reboot that takes it is
   take when step 5's kernel row finds no regression at the installed version and the running
   kernel stays in the boot menu as its rollback, and hold otherwise ("Verdicts").
4. **Failed units, and services meant to run** (`== units ==`, `== engines ==`). Every failed
   unit, system and user, with its state. Then every service a descriptor or container implies
   should run that doesn't: an engine unit that is disabled or inactive while the purpose it
   serves is declared, and a container whose restart policy (`always`, `unless-stopped`) says it
   should run while it is exited. Name the cause the probe shows, and the recovery the architect
   would run; a cause only the journal shows is asked for as "Facts that need root" says when the
   journal needs root. Each is hold, or skip when step 3's answer says it stays down.
5. **The boot-order check** (below): each finding is hold, first among the holds, since it can
   leave the engine unreachable after a reboot; its remedy is a root step with a rollback.
6. **Container images behind their tag's latest release** (`== engines ==`). For each container's
   image, read the newest release of its repository's tag series from the registry with WebFetch:
   Docker Hub's tags API (`https://hub.docker.com/v2/repositories/<namespace>/<name>/tags`), or a
   GitHub package page for ghcr.io ([sources.md](sources.md), "Engines"). Give the probed tag, its
   `image created` date, and the newest tag with its date. An engine's image is the engine's
   version, which step 6 judges: list it here with step 6's verdict, by reference. Whether a
   moving tag (`latest`) or the same tag was rebuilt since the pull answers only to a
   manifest digest, which takes a token-bearing read WebFetch can't send; write "not checked" for
   it, and never pull to find out.
7. **Unused images and models taking disk** (`== docker-disk ==`, `== models ==`). The dangling
   images (count and size), each image no container uses (name, tag, size), and the reclaimable
   build cache from `docker system df`. Then each stored model that nothing serves or lists:
   judge it against the router's model list (`== endpoints ==`), the preset's sections, and
   every container's mounts, and give its size and last-modified date. The date is when the file
   was written, not when it was last loaded, so an old date alone doesn't make a model unused. A
   model step 7 ranks as a candidate is not debt. Each removal is hold, with the space it frees.
8. **Configuration that differs from the descriptor.** Compare what the probe shows with what the
   descriptor declares: a purpose nothing is configured to serve (no preset section, no
   container), a watch item that names a setting the probe shows differently, and a preset whose
   keys differ from the flags the router lists for the same model (the router was started before
   the preset changed, or a key doesn't apply). Give both values, cited. Each is hold. The
   descriptor's stale lines are step 1's, under "Proposed changes", and not repeated here.
9. **A drafter of adversary origin that a preset loads** (the `drafter` lines under
   `== engines ==` and `== endpoints ==`). Judge each drafter named there by the origin rule
   (models.md, "Origin"), as a component outside the output path. One of adversary origin is a
   host configuration fault, not an exclusion: the main model verifies every drafted token, so
   the drafter can't change what is served, and the target model stays eligible in step 7. The
   item is hold, with the section that loads it, cited to the probe, and the fix is removing the
   drafter's keys from that section (a `[*]` section loads it for every model); the rollback is
   restoring them. The preset belongs to whoever owns it, so the fix is a change for that owner.
   A drafter whose origin passes is recorded in its model's row in step 7, and `none` everywhere
   is one line saying so.
10. **Agent sessions under the minimum context.** Each agent preset's per-session context, from
    step 6's computation, that falls under the policy's minimum per agent session
    (`docs/policy.md`, "Agent session context") is hold, listed here by reference to step 6, with
    the fix stated there.

**The system watch items.** Answer each of the descriptor's watch items of this kind (what this
step reads, such as the package channel's snapshot date, a unit, or a container) by name, under
its own heading: what the probe and the sources say now, cited, and what changed since the last
report if there is one. An item that bears on one of the items above is cited in that item.

#### Boot-order check

Item 5 of this step.

An engine container that binds its port on the tailnet address can't publish it until Tailscale
has assigned that address, and docker may start first at boot. Read each engine container's
`published ports` and `configured binds` lines and both `ip_nonlocal_bind` keys from the probe,
and report each of these in the section, cited to the probe. Each family has its own key: a
`tailnet4` bind is judged against `net.ipv4.ip_nonlocal_bind`, and a `tailnet6` bind against
`net.ipv6.ip_nonlocal_bind`.

- **A `tailnet4` or `tailnet6` bind with its family's key 0 (or the IPv6 key `absent`)**: flag
  that a boot where docker starts before Tailscale leaves the container with no published port.
  The remedy is the matching key, `net.ipv4.ip_nonlocal_bind = 1` or
  `net.ipv6.ip_nonlocal_bind = 1`, in a file under `/etc/sysctl.d`, a root step the architect runs
  (the run prints it as "Facts that need root" does, and never runs it). Its side effect: any
  process on the host may then bind an address of that family the host doesn't hold yet. Its
  rollback, also root, is removing the file and running `sysctl -w <key>=0`, or rebooting:
  `sysctl --system` alone leaves the value at 1, since it applies only the keys a file sets.
- **A running container whose `published ports` is `none` while its `configured binds` is not**:
  flag that it serves nothing off the host, however healthy docker reports it, which is the
  boot-order failure itself. The recovery depends on the cause, and needs no root either way; the
  architect runs it:
  - `published ports none (no network)`: the container is attached to no network. The recovery
    is `docker network connect bridge <name>`.
  - `published ports none`, still on a network: the start failed to bind. The recovery is
    `docker restart <name>`, once the address exists.

  Either recovery serves the container now; the sysctl remedy above prevents it recurring, so
  point to it. A container configured with no binds (one on the host's network, say) publishes
  nothing by design, and a stopped container publishes nothing either; neither is flagged.
- **A family's key 1**: report the remedy as present for that family, with its side effect.

### 6. Engines

An objective look at the most effective engine setup on the probed hardware, for the purposes the
descriptor declares.

1. **The incumbent.** Name the engine that serves (or, when nothing serves, the installed engines
   step 3 settled on), with its version, its backend, and its configuration from the probe's
   `flags` lines: context, parallel slots, KV cache (unified or split), batching, offload. Read
   each flag the line doesn't show at its default from the engine's source or docs at the probed
   version, and cite it, naming it a default read rather than a probed value. Note where the
   configuration works against a declared purpose (a per-slot context too short for agent
   sessions, slots that can't share a cache).

   **Per-session context.** For each preset section or container that serves the agent purpose,
   compute the context one agent session can reach, marked **estimate** with its method:
   - **Split KV cache**: `ctx-size / parallel`, the context divided among the slots.
   - **Unified KV cache**: the whole pool, `ctx-size`, shared by every session, so one session
     can reach it all while the others take what is left; a per-slot cap the engine applies (a
     `--kv-unified-per-slot`, the model's trained context) bounds it, and the report names the
     cap.
   - **vLLM**: `--max-model-len`, which caps each request rather than being a total shared
     across `--max-num-seqs`; the KV pool (from `--gpu-memory-utilization`) limits how many
     sessions run at once, not how far each one reaches. So `--max-num-seqs 4 --max-model-len
     8192` gives each session 8,192, not 2,048.

   Whether the cache is unified comes from the section's keys and the flags (`--kv-unified`,
   `-kvu`, `--no-kv-unified`). Where neither says, read the engine's default at the probed build
   from its source, and cite the file and the line: on llama.cpp the default can depend on other
   flags, such as `--parallel` being set or left at auto. Compare each figure with the policy's
   minimum per agent session (`docs/policy.md`, "Agent session context"). A section under it is
   hold, with the figure, the minimum, and the fix stated: a context, a slot count, or a unified
   cache that brings each session to the minimum, and toward the model's native context where
   memory allows (step 8 checks the memory). Step 5b lists it by reference.
2. **The seed list, filtered to the backend.** Weigh the incumbent against llama.cpp, vLLM,
   SGLang, TensorRT-LLM, and ggml-hrx, keeping only what the probed backend supports:
   TensorRT-LLM only on NVIDIA, and on AMD only what the engine's own docs or published images
   list for the probed gfx target. ggml-hrx is AMD's HRX backend for llama.cpp, built for
   gfx1100 and gfx1151; its published figures measure it against HIP, but it is judged against
   the backend the host serves on, which on Strix Halo is Vulkan, so a gain over HIP is not a
   gain here. Judge a packager (Ollama, LM Studio) by the engine and build it embeds, not as an
   engine of its own. For each engine kept, say whether its newest release supports the backend,
   how the host would install it, and what any attributed benchmark on the same hardware class
   measured against the incumbent.
3. **The scan.** Look each run for emerging capabilities and engines: a backend an engine newly
   supports (vLLM on Vulkan, or on ROCm for the probed gfx target), a change that improves
   concurrent-session throughput, a new engine built for the hardware. A newly found engine is
   weighed in this run like a seed-list engine, and proposed for the seed list under "Proposed
   changes".
4. **The engine watch items.** Answer each of the descriptor's watch items of this kind (an
   engine, a backend, a feature, or a regression) by name, under its own heading: what the
   sources say now, cited, and what changed since the last report if there is one. The hardware
   and system watch items are step 5's and step 5b's.
5. **The conclusion.** Name the most effective engine platform and configuration to date for the
   host: either an adjustment to the incumbent (a version, a backend, a flag) or a migration to
   another engine, with its verdict by the same rules; a newer build of the incumbent is never
   take ("Verdicts"). Then list the other candidates, ordered verify, take, hold, skip.

An engine change is judged within how the host installs engines, which the probe shows (a
container from the engine's published image, a systemd unit, a package). A candidate that needs
another install method (building an image locally, installing from source on the host) is skip
until the architect changes the method, and the report says what it would take.

#### Verdicts

Every item in steps 5, 5b, 6, and 7 takes one of four verdicts:

- **verify**: a source that names its hardware, engine version, and method (an attributed
  benchmark) measured a gain on the same host class and backend, and no such source reports a
  regression. A verify verdict is a reason to measure on this host, not a decision to adopt.
- **take**: a version update of something the host already runs (a package, firmware, an image
  to its tag's newer release, a new revision of a model's file) that claims nothing, has no
  reported regression, and has a known rollback: the previous kernel kept in the boot menu, a
  package downgrade from the cache, or the previous image tag. It needs no measurement first: it
  is applied with the next host update, which keeps the host current. Two rules bound it:
  - A root step with no rollback is hold, never take. Whenever both take and hold seem to apply,
    hold wins.
  - A change to the engine's build is never take, because engine changes go through
    spike-model-engines' `engines` suite with anchors. A newer engine build is verify or hold,
    by the rules here. Nor is a change of engine, backend, or model ever take.
- **hold**: the only claim is release notes, or comes from another hardware class, or the
  upgrade needs a root step with no rollback. An agent candidate the policy's agent quality bar
  can't yet place is hold, by the bar's own reading (`docs/policy.md`, "Reading the bar", as
  [models.md](models.md), "Gate 4", applies it). So is a candidate whose speed against its
  purpose's floor is a paper estimate alone (`docs/policy.md`, "Reading the floors", as
  [models.md](models.md), "Gate 5", applies it).
- **skip**: sources show no gain or show a regression, or the upgrade breaks a rule: the policy,
  or an engine change outside how the host installs engines.

Measured slower, but ahead on evals, is hold: an attributed benchmark puts the candidate behind
the incumbent while its card's evals for the purpose put it ahead. Neither verify nor skip fits a
trade between speed and quality, so the run holds it and names both figures for the architect.

Two attributed sources that disagree on the gain are a pause (see "When to pause"); until the
architect answers, the adjustment is hold.

### 7. Models

The models that could serve each declared purpose, judged against the incumbent. The gates and
their checks are in [models.md](models.md); this step says what the section holds.

1. **The incumbents.** For each purpose, the model step 3 mapped to it, with its format and its
   configuration from the `flags` lines and the preset's keys. When nothing serves and the probe
   doesn't show which stored model an engine would load (no router lists it, and no preset
   section names it), the incumbent for a purpose is the stored model mapped to it that ranks
   first by this step's own gates and sort among the stored models, and the report says so.
2. **The candidates.** Every stored model that isn't an incumbent, the newest models of the
   publishers in [sources.md](sources.md), "Models", and what a web search finds. A model whose
   card serves several purposes (a multimodal model that takes text, images, and audio) is a
   candidate for each, and the report says which incumbents it would replace.
3. **The gates, in order**: the policy (the origin rule, then artifact integrity, then the
   quantization floor, as `docs/policy.md` states them and reads them), a fit in the probed
   memory, the host's engine serving the architecture on its backend, for the agent purpose the
   policy's agent quality bar, and the policy's speed floor for the purpose ([models.md](models.md),
   "Gate 5"). A model that fails a gate stops there and is listed
   with the gate it failed and why. The floor takes one of the policy's three paths, settled by
   the build, not the label (the publisher's native or QAT release, the publisher's
   post-training checkpoint, or a third party's conversion), and never by the repository id: a
   trained-in format passes by name with the publisher's quality statement quoted, a
   publisher's post-training checkpoint passes only when every eval its card reports is within
   the policy's margin of BF16 (the row names any outside it), and everything else meets the
   floor.
4. **Excluded on origin, and origin unclear.** The run builds each model's evidence chain
   (publisher identity, the publisher's own documents, then artifact checks, as models.md,
   "Origin", gives it). A model with any disclosed or detected involvement of an adversarial
   entity at a level the policy excludes on, or a publisher or uploader that fails the policy's
   compliance gate, goes in the section's "excluded on origin" list and never reaches a verdict.
   Each entry names the level and cites, inline, the URL and read date of the source that shows
   it. A teacher is read by its role, not by its label. Involvement at a level the policy only
   records, and adversary-generated data that is one dataset in the training mix (under "dataset
   sources"), go in the model's row, cited, and the model goes on to the next gate. A model the
   chain leaves short of the policy's pass bar, with no involvement found at an excluding level,
   is researched further (the uploader's identity and affiliation, the conversion against the
   publisher's weights, the publisher's own mentions of it, the uploader's other work) until the
   answer is definitive; a model the research brings to the pass bar passes, and its row records
   the evidence that settled it. Only a model the research can't settle (an unidentified
   publisher, an unestablished lineage, a teacher the card doesn't name and the publisher doesn't
   place in its own pipeline, or sources that contradict each other) goes, without a pause, in the
   "origin unclear" list beside it, and never reaches a verdict either. Each entry names what the
   run checked, each source cited inline. A pass means "no disclosed or detected involvement at
   an excluding level", and the section says so. A model that already fails a later gate
   (artifact integrity, the floor, fit, the engine, the agent bar, the speed floor), shown by a
   read the run has
   made, may stop at "not settled" for origin instead of being researched to the end: its row
   says origin is not settled, that the research stopped because the model fails that gate, and
   names the gate and its source (models.md, "Origin"). It is listed under the gate it fails, not
   under "origin unclear".
5. **Sort and judge.** An agent candidate's card figures must clear the policy's agent quality
   bar before speed sorts it, and the bar decides its verdict until the local tool-reliability
   check runs (`docs/policy.md`, "Reading the bar", as [models.md](models.md), "Gate 4",
   applies it). Models that pass every gate sort by published speed on the same hardware class,
   then by the card's evals for the purpose. Each takes a verdict by "Verdicts" (step 6), with
   its citations: a model's gain is measured speed on the same host class and backend, or a card
   eval for the purpose, against the incumbent's.

Order each purpose's rows verify, take, hold, skip; within a verdict, by speed, then by evals; a
model that failed a gate is skip and comes after the passing skips. Each row names the exact
repository and file the host would load, its build, and, when the model has a projector
(`mmproj`), the projector's repository, file, and precision, which for a vision or audio model
are part of its precision (models.md, "A model's row"). When a gate needs a policy value the
document doesn't state, pause (see "When to pause").

### 8. Model set

The most effective combination of one model per declared purpose, which the host can serve at
once.

1. **Place each incumbent in step 7's order.** It ranks below the purpose's verify candidates,
   which an attributed benchmark measured ahead of it, and above its take, hold, and skip
   candidates, which nothing measured ahead of it. The report states each incumbent's place.
2. **The candidates per purpose**: the top three from step 7 that pass every gate, plus the
   incumbent, so at most four per purpose. The report states this bound and how many sets it
   weighed. A model that serves several purposes can fill each of them in one set, and its memory
   counts once.
3. **Keep the sets that fit together**: the estimated memory of every model in the set, loaded at
   its configured context and slots, leaves the policy's headroom of the GPU-reachable ceiling
   free. A model serving two purposes is estimated at the more demanding purpose's
   configuration: the larger context and the more slots of the two. The agent model is estimated
   at a configuration that gives each session at least the policy's minimum context (step 6,
   "Per-session context"): a set whose agent preset leaves a session under it is flagged, hold,
   with the fix stated, and the set is also weighed at the fixed configuration, so the report
   shows what the minimum costs in memory.
4. **Keep the sets the chosen engine can serve side by side**: the engine is the conclusion of
   step 6. Either one process holds several models (a llama.cpp router), or each model runs in its
   own process with its own memory reservation (vLLM's `--gpu-memory-utilization`, a share of the
   whole device), and the reservations, not the weights, must fit within the headroom.
5. **Recommend** the most effective set kept: compared first by the agent purpose's model (its
   place in step 7's order, with the incumbent placed as item 1 says), then by the other
   purposes' places summed, then by memory left free. Give its estimated memory, marked
   **estimate** with its method (see [models.md](models.md), "Memory estimate"), why it wins, and
   the runner-up with why it lost. Each entry in the set names the exact repository and file, and
   its projector's repository, file, and precision when it has one. When no set but the
   incumbents fits, say so.

### 9. Verify next

One closing line naming a single verify item from across the sections: the one with the largest
claimed gain on the agent purpose, and among equal claimed gains, the lowest risk first (no root
and rolled back by removing a flag, before a root step with a rollback, before a reboot), with a
one-line reason. It names a verify item only, never a take, hold, or skip item. When no item is
verify, the line says so and names nothing.

### 10. Proposed changes

Every change the run would make to a document it reads, each with its reason, for the architect
to accept or reject one by one. The run applies none of them (see "What a run writes"). Five
lists, each "None" when empty:

- **Descriptor watch items** (`docs/hosts/<host>.md`): a watch item to add, such as a scan finding
  worth checking each run, or one the probe can't reach (step 3); the descriptor's stale lines
  (step 1) and the purposes a discrepancy answer drops (step 3).
- **Trusted sources** ([sources.md](sources.md)): a source found beyond the list that meets its
  tier's bar (step 4).
- **Blocklist** ([blocklist.md](blocklist.md)): a source met in the run that fails a criterion,
  with what was found (step 4).
- **Engine seed list** (step 6): a newly found engine to weigh every run.
- **Policy and the model gates** (`docs/policy.md`, [models.md](models.md)): a value the policy
  lacked and the architect's answer at a pause, a rule a candidate sat on the edge of, and a
  remedy a gate points to that needs a host step (the project's own conversion of a model, say),
  for a task to plan.

### 11. Write the report

The report is the run's only write: one file per host per run, at
`docs/reports/<host>/<YYYY-MM-DD>.md`, dated the day the run read its sources. A report is never
edited once written; a later run writes a new report, and reads the last one only to say what
changed (and, when the inventory hasn't moved, to cite for what it didn't research, step 4). When
the host already has a report of that date, the run writes `<YYYY-MM-DD>-2.md`, then `-3`, and so
on, the next number free, and never edits or replaces the earlier one. The last report is the
newest date, and within a date the highest number.

The report's sections, in order:

```markdown
# <host>: hosting upgrades, <YYYY-MM-DD>

## Inventory
The probe's findings, by section, and the descriptor and policy the run read. Says plainly when
nothing serves, and what the run ranks against instead. Lists the rules the readiness check
found missing (or "none") and the architect's answer, every probe skip, every fact that needed
root (with the architect's read-out or "declined"), and every pause with its answer. Says whether
the inventory matched the last report's, and so whether the run researched in full or only what
moved, citing that report (step 4).

## Hardware configuration
Step 5's adjustments, verify, take, hold, skip, then each hardware watch item by name.

## System updates and debt
Step 5b's items: pending package updates (with the lists' age), firmware updates, the kernel and a
pending reboot, failed units and services meant to run, the boot-order check, container images
behind their tag, unused images and models taking disk, configuration that differs from the
descriptor, a drafter of adversary origin a preset loads, and agent sessions under the minimum
context, each with its verdict and sources, verify, take, hold, skip; then each system watch item
by name.

## Engines
Step 6: the incumbent, the seed list, the scan, each engine watch item by name, and the
conclusion.

## Models
Step 7: per declared purpose, the incumbent and its candidates, each with its exact repository
and file (and its projector's repository, file, and precision), gates, speed, evals, and verdict;
then the models excluded on origin, and beside them the models of unclear origin with what the
run checked.

## Model set
Step 8: the bound on candidates per purpose, the sets weighed and kept, the recommended set with
each entry's exact repository and file (and projector) and its estimated memory, why it wins, and
the runner-up.

## Verify next
Step 9's one line.

## Proposed changes
Step 10's five lists.

## Sources
Every source cited, with its tier, URL, and read date.
```

Within every section, items are ordered verify, take, hold, skip.

## Research

Step 4's research is large enough that a run may split it across subagents. When it does, it
splits it into these five parts, so that runs are repeatable:

1. **Hardware and system**: the OS image, kernel, firmware, BIOS, driver or Mesa, and memory
   ceiling (step 5), and the system's pending updates, firmware updates, and container images'
   newest tags (step 5b), with the hardware and system watch items.
2. **Engines**: the incumbent engine, the seed list, the scan, and the engine watch items
   (step 6).
3. **Agent models**: the agent purpose's candidates, their speed on the class, and their cards'
   BFCL figures against the policy's agent quality bar, each with its gap (step 7).
4. **Other models**: every other declared purpose's candidates (step 7).
5. **Origin**: the evidence chain for every model the model parts name (models.md, "Origin").

**A second, narrower round.** The model parts find candidates as they go, so some reach the run
after the origin part has started, or after it has returned. When parts 3 and 4 have returned, the
run lists every model they name that the origin part's return doesn't cover, and sends only those
to the origin part again, with the same inputs and tools. So every model step 7 ranks has an
origin chain, and none is left "origin unclear" only because nobody researched it. The second
round researches origin alone; a gap it finds in another part's work (a model nobody researched
for speed, a config a memory estimate needs) is closed by a read of the run's own, cited as any
other.

**What each part gets.**

- Its inputs: the probe's inventory, the host descriptor, and the policy.
- The source tiers and the sources for its kind, from [sources.md](sources.md), and the
  blocklist ([blocklist.md](blocklist.md)).
- The tools it may use: WebSearch, WebFetch, `gh search issues`, and `gh search prs`. The origin
  part may also run the screening-list script. The origin part and the model parts (3 and 4),
  which check each file's artifact integrity, may also run the first-bytes script. Each script
  runs from the project root by exactly the path its readiness rule names, with each argument
  quoted: `.claude/skills/hosting-upgrades/scripts/screen.sh "<name>" ...` (models.md, "Origin",
  item 1) and `.claude/skills/hosting-upgrades/scripts/magic.sh "<org>/<repo>" "<file>"`
  (models.md, "Artifact integrity", item 2). The screening list's "no match" is never "clean",
  and magic.sh can't tell safetensors from 4 bytes ([sources.md](sources.md), "Origin and build
  checks").

**What each part returns.** Cited claims, each with its source's URL, its read date, and its
tier, in the form "Citing" (step 4) gives. The run, not the part, gives verdicts.

**No curl.** No subagent uses curl or jq through Bash: the readiness check prints no rule for
them, so they would run outside the rules the architect granted. Data too large for WebFetch, or
behind a header or a redirect WebFetch can't handle, goes through a narrow script bundled with the
skill, which reads one source and is granted by its own rule, naming its path. There are two:
`scripts/screen.sh` reads the screening list, and `scripts/magic.sh` reads a Hub file's first 4
bytes past the xet CDN's 302. With the probe, they hold the skill's only curl.

## When to pause

The run stops and asks the architect, rather than guessing or failing, in four cases:

1. **The probe contradicts the descriptor**: a served model whose purpose isn't declared, or a
   declared purpose nothing serves (step 3).
2. **Sources conflict on a claim**: two sources disagree on a version, a gain, or a support claim.
   A version conflict among vendor notes that no verdict depends on is not a pause: the probe's
   installed versions decide, and the report records the conflict ([sources.md](sources.md),
   "Tiers"). One that changes a verdict still is.
3. **A policy question arises**: the policy lacks a value a step needs, or a candidate sits on a
   rule's edge: a format the floor doesn't name, a file whose floor path its build doesn't
   settle, or a scanner message under a "safe" status other than the one the policy passes by
   name. Origin is never a pause: a model with involvement found at a level the policy excludes
   on, or that fails its compliance gate, is excluded on origin; involvement at a level the policy
   only records, and adversary-generated data in a training mix, go in the model's row; and a
   model short of the pass bar is researched further and, only if the research can't settle it,
   including when its sources conflict or a teacher stays unnamed, held out as "origin unclear"
   (step 7).
4. **A source's tier is unclear**: the run can't tell whether a source is primary, an attributed
   benchmark, or a lead.

A pause states what was found, cites where (the probe section, the descriptor line, the source),
gives the options with the one the run would take by default, and waits. For example:

```text
Pause: the probe contradicts the descriptor (gb10-1).

The descriptor (docs/hosts/gb10-1.md) declares four purposes: agent, vision, audio, embedding.
The probe finds nothing serving: == endpoints == reports nothing OpenAI-compatible on loopback,
both containers (llama, vllm) are exited, and both units (llama-router, vllm-server) are
disabled and inactive. So no declared purpose is served.

Installed: llama.cpp (ghcr.io/ggml-org/llama.cpp:server-cuda13-b11669), vLLM
(vllm/vllm-openai:v0.32.0), and 14 models in /srv/models.

How should the run go on?
  a. (default) Treat the installed engines and stored models as the incumbent: the inventory says
     nothing serves, and every section ranks against what is installed.
  b. The host is meant to serve fewer purposes: name the ones to drop, and the report proposes
     the descriptor change.
  c. Stop: the host is mid-change, and the run should wait until it serves again.
```

## Facts that need root

The probe reads only what an unprivileged user can. When a step needs a fact only root can read,
the run never runs sudo itself. It prints the exact command, in the form that runs it on the host
from this machine (`ssh -t <host> sudo <command>`, where `-t` gives sudo a terminal for its
password), says what fact it needs and why, asks the architect to run it and paste the output,
and continues from the pasted output, citing it in the report as the architect's read-out.

For the GPU's loaded firmware, the command is
`ssh -t <host> sudo cat /sys/kernel/debug/dri/<N>/amdgpu_firmware_info`, where `<N>` is the card
number in the probe's `/sys/class/drm/card<N>` line under `== memory ==`. For example, when the
probe prints `/sys/class/drm/card1: GTT total ...`:

```text
The report needs the GPU's loaded firmware versions, which only root can read. Run this from
this machine and paste the output (N = 1, from the probe's /sys/class/drm/card1):

  ssh -t framework sudo cat /sys/kernel/debug/dri/1/amdgpu_firmware_info
```

If the architect declines, the run goes on without the fact and the report says which fact is
missing and what it would have decided.

### Package versions a notice names

When Arch news, or another distribution's notice, urges an upgrade of a package the probe's
output doesn't list, the run asks for its installed version the same way, though no root is
needed: it prints the command (`ssh <host> pacman -Q <package>` on Arch, and
`ssh <host> dpkg-query -W <package>` on apt), says which notice names the package and why, asks
the architect to run it and paste the output, and continues from it, citing it as the
architect's read-out. The run doesn't run it itself: the readiness check grants ssh only for the
probe. For example:

```text
Arch news of <date> urges upgrading <package> before the next update. The probe doesn't list it.
Run this from this machine and paste the output:

  ssh framework pacman -Q <package>
```

## The verify mode

`/hosting-upgrades verify <host>` takes the host's last report to a decision on each of its items,
and leaves the record a verification needs: what was measured, against what claim, and what each
item came to. A report run finds and ranks; the verify mode settles. It is interactive, as a run
is, and pauses as "When to pause" says.

The mode changes nothing on the host. It prints every command that would (an update, a reboot, a
removal, a model load, a cell), says who runs it, and records each as it was run: a step that
needs root is the architect's, printed as "Facts that need root" prints one (`ssh -t <host> sudo
<command>`), and a step that needs no root is one the session may run itself, over SSH or from
this machine, in the architect's view, once the architect has agreed it. The skill bundles no
script that changes a host: the commands are the host's own tools (the package manager,
`docker`, `hf`, the engine's API), and an engine change goes through spike-model-engines'
`engines` suite, as "Verdicts" (step 6) says.

### 1. Load the inputs

1. Take the host from `$1`. With none, list the descriptors in `docs/hosts/` by their short names,
   ask which host to verify, and verify one host only.
2. Read `docs/hosts/<host>.md` and `docs/policy.md`. If either is absent, stop and say so, in the
   words step 1 of the run gives for each.
3. Read the host's last report: in `docs/reports/<host>/`, the newest date, and within that date
   the highest `-N` (`<date>.md` is the first of its date; a file name sort puts `<date>-2.md`
   before it, so sort by date, then by number). If the directory holds no report, stop and say
   so: "No report for `<host>` in `docs/reports/<host>/`, so there is nothing to verify; run
   `/hosting-upgrades <host>` first." Name the report the mode read, by its path and date.
4. **The items.** Every verify, take, and hold item in the report's "Hardware configuration" and
   "System updates and debt", and the item its "Verify next" line names. An item listed in two
   sections by reference (a kernel's row and its reboot item, say) is one item. The engine and
   model rows the report ranks verify or hold, other than the one "Verify next" names, are
   candidates rather than the host's items: the mode lists them by name, as left for a later
   verification or a fresh run, and asks no decision on them. The verify item is of one of two
   kinds, and the steps below say where they differ: a **model item** (a model in place of its
   purpose's incumbent) or an **engine item** (a build of the engine the host serves in place of
   the build it runs, the report's engine verdict).
5. Read the host's last earlier anchor readings: the findings the descriptor lists under
   "Measurements", and the host's earlier verification finding, if there is one. Step 6 sets the
   first anchors beside them.

### 2. Readiness and probe

1. Run the readiness check with the verify mode's rules ("Readiness check"), and go on as the
   architect answers it.
2. Run the probe exactly as step 2 of the run gives it, and stop as it says when SSH fails.
3. **What moved.** Compare the probe with the report's Inventory and with each item's own "what
   the probe shows". Name every item whose state has moved since the report, cited to the probe
   section that shows it: an update now on the host's channel that wasn't (`== updates ==`), an
   item that is gone (a container, an image, a snapshot), a unit or a container whose state
   changed, a kernel now running or newly installed, a setting now at another value. An item that
   hasn't moved says so. Ask the architect what they ran on the host since the report (an update,
   an autoremove, a regenerated spec), and name each step as they report it, beside the probe
   section that reads it back, or with "not visible to the probe" when none does. The mode doesn't
   research again: a moved item goes to the architect's decision with its movement beside it, and a
   change that would alter its verdict is a pause.

For example, on framework against its 2026-10-30-2 report:

```text
Moved since docs/reports/framework/2026-10-30-2.md:
  - linux-omarchy: 7.2.15-1 is now on the host's channel (probe == updates ==); the report held
    7.2.14, which hadn't reached it.
Not moved: the other ten items.
```

### 3. Decisions

List every item from step 1, ordered as the report orders them (verify, take, hold, then by
section), each with its report verdict, the report's recommendation, and its movement from step
2. Ask the architect's decision on each:

- **apply**: make the change the item names.
- **remove**: take the item off the host (an image, a container, a stored model, a cache).
- **close**: no action, with the architect's reason in a line (not on the host's channel, a
  headroom met, a section no agent loads).

Record each decision with its date, as the architect's. Applying the verify item is measured:
its gates are re-checked (step 5), its cells run (step 6), and the verdict (step 8) settles
whether it stays or rolls back. An engine item's verdict is the engine rule, and its rollback is
the suite's update to the earlier build (step 8).

### 4. What each decision takes

For each item to apply or remove, print:

- **The exact commands**, in the order they run, each in the form that runs it from this
  machine (`ssh <host> <command>`, or `ssh -t <host> sudo <command>` for root). They come from
  the report's row (its remedy and rollback), checked against the probe today. A removal that
  its tool can rehearse is rehearsed first (a dry run), and the dry run's output goes to the
  architect before the removal.
- **Who runs each step**: root steps are the architect's; steps that need no root the session
  may run, in the architect's view; a tool's first use on this host, and any step the architect
  asks to keep, is the architect's.
- **The rollback**, as commands, and whether it needs root.
- **Whether a reboot is needed.** The changes that need a reboot share one reboot, after which
  the probe reads them back: the new kernel running, each engine up with its port published
  (step 5b's boot-order check).

**An offered update with no known rollback is an escalation**: a firmware update `fwupdmgr`
lists, a BIOS, anything else with no downgrade path. The mode prints it, says it has no rollback,
and asks the architect, who decides it outside the mode's defaults. An approved one gets a reboot
of its own, after the host's other changes have booted cleanly, so a failure is traceable to it.

Order the work so that each pass measures one state: the host stack first (its updates, its
settings, the reboot, a probe), then any approved escalation and its reboot, then the verify
item's pass (step 6), then the removals, each read back by the probe.

### 5. Re-check the verify item's gates

Before the verify item is measured, re-check its gates under the policy as it reads today, as a
run's step 7 gates a model, by [models.md](models.md). For an engine item, the gated models are
every model its pass loads, one per purpose with cells (step 6, "An engine item"), each gated as
below, since a pass loads each of them under today's policy:

1. **Origin** ("Origin"): the evidence chain, read fresh, with the screening-list script
   (`.claude/skills/hosting-upgrades/scripts/screen.sh "<name>" ...`).
2. **Artifact integrity** ("Artifact integrity"): the format of the file the host would load,
   from the probe's `magic` line for a stored file, or the Hub's per-file scan or
   `.claude/skills/hosting-upgrades/scripts/magic.sh "<org>/<repo>" "<file>"` for one not
   stored, and its projector's the same way. Then the chat-template check: the GGUF's embedded
   template against the publisher's, read from the repository's `chat_template.jinja` when it has
   one (Google keeps it there, and its `tokenizer_config.json` carries no `chat_template`), and
   otherwise from `tokenizer_config.json`'s `chat_template`; a single trailing newline is no
   difference (`jq -r` adds one), and any other difference is quoted.
3. **The quantization floor** ("Quantization floor"): the path its build takes, and the
   publisher's quality statement quoted for path 1.
4. **Fit** ("Gate 2: fit"): its memory estimate against the probed ceiling and the policy's
   headroom, and the model set it would join.

Each gate cites what it read, with its date, as "Citing" (step 4) says. If a gate fails, stop
the item's verification and name the gate and what failed it: the item isn't measured, and the
finding records the gate. For an engine item, a model that fails a gate is a pause: its purpose's
cells can't run until the architect names another model for it.

### 6. The cells

Print the agreed cells before any runs, then each command as it runs. The host serves one model
per purpose (`STANDARDS.md`, "Hosts"), so every load in the pass follows one rule: unload the
model that serves the purpose, wait until the router reports it unloaded, and only then load the
other, through the engine (a router's `/models/unload` and `/models/load`, read back by its
`/models`). Never load a candidate beside its purpose's incumbent. A router holds a cap on loaded
models (llama.cpp's `--models-max`, 4 by default), and a load that arrives before an unload has
finished takes it over the cap, so the router evicts its least recently used model, another
purpose's, unseen. For a model item, the cells are the following; an engine item's pass spans two
builds instead ("An engine item", below):

- **Anchors A and B before the change**, on the anchor section the host's earlier readings used,
  loaded beside the incumbent of the item's purpose, with any section that would compete for the
  GPU unloaded meanwhile, named.
- **The item's cells beside its purpose's incumbent**, at the same shapes: the incumbent's cells,
  then the item's, which loads only once the incumbent is reported unloaded.
- **Anchors A and B after the change**, on the same section, loaded beside the item.

Once the pass ends, restore the host's set, one model per purpose by the same rule: the set it
served before the pass, or, on adoption (step 8), that set with the item in its incumbent's place.

**Each model's cells run once each from a fresh load**: unload the model, wait until the router
reports it unloaded, load it, then run its cells, each once. Never rerun a cell within one load:
GuideLLM's synthetic prompts are the same on every run, so a second run in one load hits the
router's prompt cache and reads faster than the first.

Every cell of a model item's pass runs on one engine build and one kernel; a pass whose build or
kernel changes partway starts again. An engine item's pass runs on one kernel and its two builds.
Each run is capped at 10 minutes (`timeout 10m`). Each pass records the engine build and the host
stack (a probe), and the network path:

```sh
tailscale ping -c 1 <host>
```

**The routing check** runs from this machine before each pass, and a failed check is a pause:

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

The fix the verify-framework finding records ("Routing") keeps the LAN from answering for the
host, and both steps need root, so both are the architect's: the host stops sending its hostname
in DHCP (NetworkManager's `ipv4.dhcp-send-hostname` and `ipv6.dhcp-send-hostname` set to `no` on
each of its connections, which then come up again), and the router's lease names for the host
are cleared (its DHCPv4 and DHCPv6 lease files, with the router's DHCP services restarted).

The scenarios are the project's `bench/`: `anchor-a.yaml` and `anchor-b.yaml` for the anchors;
`shape-a.yaml` and `shape-b.yaml`, the anchors' loads on any model, for every item's and
incumbent's cells; and `audio-a.yaml` and `audio-b.yaml` beside them for an audio purpose's ASR
cells. So an audio item and its incumbent each run shape A, shape B, ASR A, and ASR B. GuideLLM
runs from this machine (`mise.bench.toml`), with the engine's URL exported in
`GUIDELLM__SPEC__BACKEND__TARGET` by the host's short name (`http://<host>:<port>`), so no
address is committed. Each result goes under `.state/verify/<host>/`:

```sh
MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/anchor-<a|b>.yaml --output "kind=json,path=.state/verify/<host>/<pass>-anchor-<a|b>.json"
MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/<scenario>.yaml --backend "kind=openai_http,model=<model>" --tokenizer "kind=huggingface_auto,model=<tokenizer>" --output "kind=json,path=.state/verify/<host>/<cell>.json"
```

A cell's figure is its output tokens per second
(`.benchmarks[0].metrics.output_tokens_per_second.successful.mean` in its JSON), and for an ASR
cell its audio seconds a second (`.benchmarks[0].metrics.audio.seconds.input_per_second.successful.mean`),
since a transcript's length is the model's own. A cell counts only with its full request count,
the scenario's `max_requests` count (8 for A, 32 for B), in
`.benchmarks[0].metrics.request_totals.successful`: a cell that records fewer successful requests
fails, even with none errored. A cell with fewer, or with any errored or incomplete request, is a
failed cell, rerun once from a fresh load of its model, and then a pause.

**The reasoning check**, on each of the candidate's cells whose requests don't ask for reasoning
(the ASR cells; the shape cells ask for it by design, `enable_thinking: true`), and on the
incumbent's beside them (for an engine item, the candidate build's ASR cells and the incumbent
build's): count the replies that reasoned in the thought channel (a non-empty
`reasoning_output`), and the replies whose text speaks about the task instead of answering it
("The user wants me to ...", "Thinking Process"). Read the replies the second count flags, to
confirm each:

```sh
jq -c '.benchmarks[0].requests.successful | {replies: length, reasoned_in_channel: (map(select((.reasoning_output // "") != "")) | length), reasoned_in_text: (map(select((.output // "") | test("The user wants me to|Thinking Process"; "i"))) | length)}' .state/verify/<host>/<cell>.json
```

A configuration that turns reasoning off is tested with the budget-0 variants,
`bench/audio-a-budget0.yaml` and `bench/audio-b-budget0.yaml`: `audio-a.yaml` and `audio-b.yaml`
with `reasoning_budget_tokens: 0` sent in every request, which llama.cpp honours by closing a
thought block as soon as the model opens one. They run in place of the ASR cells, for both
models. Budget 0 empties the channel, but it can move the reasoning into the text: in
verify-framework's run 4 it did, on 2 of E4B QAT's 40 replies, and the text count catches it.

**The first anchors** are set beside the host's last earlier readings (step 1, item 5). A move
beyond run noise, 1.4%, the widest the workspace has recorded, is a finding: the finding names
it, with both readings and what changed between them (the engine build, the kernel, the
firmware), and the comparison within the pass goes on, since only cells of one session are
compared. In an engine item's pass, the first anchors are the incumbent build's.

#### An engine item

An engine item's pass measures the host's set on two builds of the engine, in one pass, in this
order:

1. **The incumbent build's cells**, on the build the probe shows serving.
2. **The move to the candidate build**, through spike-model-engines' `engines` suite, run from
   the host's clone of it, with the candidate's version as its argument (the session's step, no
   root):

   ```sh
   ssh <host> 'cd <clone> && host/engines <engine> update <candidate build>; echo "exit $?"'
   ```

   `<engine>` is the suite's name for how the host runs the engine (`llama` for llama.cpp in a
   container). The update pulls the candidate's image before it replaces the container, so a
   failed pull leaves the incumbent serving, and it refuses while another engine serves. The new
   container starts with no model loaded. Read back the build it runs, by the probe's `==
   engines ==` and the engine's own report of its build.
3. **The same cells on the candidate build**, in the same order, each model from a fresh load.

The candidate is the build the item names, or a newer build of the same image, newest at the
session's start, when the architect takes it in its place; the finding names which, and why.

**The cells.** One pair per purpose the host serves whose load the project's `bench/` has
scenarios for, on the model that serves the purpose in the host's set (with the host stack's
decisions applied, step 3), each model gated (step 5):

- agent: anchors A and B (`anchor-a.yaml`, `anchor-b.yaml`), on the agent purpose's section;
- vision: shape A and B (`shape-a.yaml`, `shape-b.yaml`), on the vision purpose's model;
- audio: ASR A and B (`audio-a.yaml`, `audio-b.yaml`), on the audio purpose's model;
- a purpose with no scenario (embedding) has no cells, and the finding says so.

Each model's cells run with only that model loaded, from a fresh load, by the rule above, so the
two builds' cells differ only by the build. Every cell of the pass runs on one kernel: a kernel
change partway, or a move to a third build, starts the pass again from the incumbent's cells.

**The figures beside each cell.** Each cell's row gives, for both builds: its request count, its
figure (output tok/s, or audio seconds a second for an ASR cell) and the change, and its TTFT
median and the change, with the published claim the report cited for the build set beside the
TTFT median: the claim that applies to the cell's model (a prefill gain measured on an MoE beside
an MoE's cells, a dense model's beside a dense model's, a fix beside the family it names). The
anchors and the vision cells send 512 prompt tokens, so their TTFT median is where a prefill
claim shows; an ASR cell's prompt is its clip, so the claim beside it is context, not a test.
Output tok/s goes beside the claim, since a prefill gain claims nothing about decode.

Print the pass before it runs. For example, on gb10-1 against its 2026-10-31 report:

```text
Engine pass: llama.cpp b11669 -> b12033 (server-cuda13), kernel 7.0.0-1024, one pass.
Each cell: GuideLLM 0.8.1 from this machine, http://gb10-1:8080, timeout 10m, fresh load.
  b11669   1 Anchor A  gpt-oss-120b MXFP4, agent section    1 x 8, 512 / 256
           2 Anchor B  gpt-oss-120b MXFP4, agent section    4 x 32, 512 / 256
           3 Vision A  Gemma 4 26B-A4B QAT Q4_0             1 x 8, 512 / 256, thinking on
           4 Vision B  Gemma 4 26B-A4B QAT Q4_0             4 x 32, 512 / 256, thinking on
           5 ASR A     Gemma 4 E4B Q8_0                     1 x 8 LibriSpeech clips, <=256 out
           6 ASR B     Gemma 4 E4B Q8_0                     4 x 32 clips, <=256 out
  move     ssh gb10-1 'cd <clone> && host/engines llama update b12033; echo "exit $?"'
  b12033   7-12 the same six cells
Embedding: no cells (no scenario). Verdict: the engine rule (step 8).
```

### 7. Transcripts

For a transcription purpose, the ASR B cell's 32 replies are compared with their LibriSpeech
references by word differences, with curl and jq and no other tool. The references are the
first 32 rows of `hf-internal-testing/librispeech_asr_dummy` (`clean`, `validation`), the rows
`audio-b.yaml` reads, from the Hub's dataset viewer, read once:

```sh
curl -s 'https://datasets-server.huggingface.co/rows?dataset=hf-internal-testing/librispeech_asr_dummy&config=clean&split=validation&offset=0&length=32' > .state/verify/<host>/librispeech-refs.json
```

Each reply is paired with its reference in the order its request was queued
(`.info.timings.queued`), which is the order the scenario reads the rows. Both are lower-cased
and stripped of punctuation, then split into words, and the word differences are the word-level
edit distance (substitutions, insertions, and deletions). The cell must hold 32 successful
requests:

```sh
jq --slurpfile refs .state/verify/<host>/librispeech-refs.json '
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
' .state/verify/<host>/<cell>.json
```

The finding gives each model's total, the reference words, and each pair's count, and quotes any
pair whose count differs between the two models by more than a word. For an engine item, the two
are the audio model's ASR B cell on each build.

### 8. The verdict

For a model item, adopt only when all four hold:

- anchors A and B after the change are each within 1.4% of before
- no candidate cell is behind the incumbent's cell at the same shape by more than 1.4%
- for a transcription purpose, the candidate's word differences are within the incumbent's total
  plus 1.4% of the reference words
- the candidate's reasoning check (step 6) counts no reply that reasoned in the thought channel
  and no reply whose text speaks about the task

Otherwise roll back. State what the rule gave on each condition, with the figures, then the
outcome. The architect may overrule it; the finding records the overrule and its reason beside
what the rule gave. On adoption, the incumbent the item replaces is retired: the engine serves
the item, and the incumbent is unloaded. Its files leave the store only once the walkthrough
confirms the item, with their rollback (a download) printed.

**The engine rule.** For an engine item, adopt the candidate build only when all four hold:

- every cell on the candidate is within 1.4% of the same cell on the incumbent, or ahead of it,
  by the cell's figure (output tok/s, or audio seconds a second for an ASR cell)
- every cell of the pass, on both builds, holds its full request count
- the audio model's ASR B word differences on the candidate are within the incumbent's total
  plus 1.4% of the reference words
- the reasoning check on the candidate's ASR cells counts no more replies than on the
  incumbent's, for each of its two counts (the thought channel, the text)

Otherwise roll back. A gain need not exceed run noise: engines stay current (the experiment's
rule), so a candidate that holds every cell is adopted. State what the rule gave on each
condition, with the figures, then the outcome; the architect may overrule it, and the finding
records the overrule and its reason beside what the rule gave.

**On adopt**, the candidate serves, and the mode prints its rollback exactly: the suite's update
to the incumbent build, the session's step, no root:

```sh
ssh <host> 'cd <clone> && host/engines <engine> update <incumbent build>; echo "exit $?"'
```

The rollback pulls the incumbent build's image again, since the update to the candidate removed
every image of every other build, server and full, in every flavor, and every untagged image
(spike-model-engines `host/engines-llama-update`, `llama_remove_images` in `host/llama.sh`). Forward
again is the same update with the candidate build. **On roll back**, the session runs that same
update now, and the probe reads the incumbent build back as serving. Either way, the host's set
is then loaded on the build that stays, one model per purpose, by step 6's rule.

### 9. Write the finding

The finding is the mode's only write: one file per host, `docs/findings/verify-<host>.md`. It is
written at the first decision and kept current as each step runs; a later verification of the
same host adds its own dated part below the earlier one, which it never edits. The mode never
edits a report. The finding's sections, in order:

```markdown
# <host>: verification of <report path>, <YYYY-MM-DD>

## The report and the probe
The report verified, by its path and date; the descriptor and policy read; the readiness rules
found missing and the answer; the probe's date; every item that moved since the report, cited to
its probe section; and the engine and model candidates left for later (step 1, item 4).

## Decisions
One row per item, in step 3's order: the item, its report verdict, the architect's decision
(apply, remove, or close) with its date, the reason for a closure, and the outcome.

## Host stack
Each applied item: every command exactly as run, who ran it (the architect, with root, or the
session), its output where it settles something, its rollback, and the reboot; each escalation,
with the architect's decision; then the probe that read the stack back.

## Gates
The verify item's four gates under today's policy, each with what it read and its citation.

## Cells
Each pass: its routing check, its engine build and host stack, from the probe, and
`tailscale ping -c 1`. Then the cells,
every command exactly as run, each cell's figure with its median TTFT and ITL: anchors A and B
before, the incumbent's and the item's cells side by side, anchors A and B after. The first
anchors beside the host's last earlier readings, and any move beyond run noise, named as a
finding.

## Transcripts
For a transcription purpose: the command as run, each model's word differences, the reference
words, and the pairs that differ.

## Reasoning
The reasoning check as run, and for each model's cells the replies that reasoned in the thought
channel and the replies whose text speaks about the task, each such reply quoted by its opening.

## Verdict
The rule, what it gave on each condition with its figures, the outcome (adopt or roll back), and
any overrule by the architect with its reason.

## The claim beside the anchors
The published claim the report cited for the item, with its source, beside what this host
measured, and how far the source held.

## Removals
Each removal: the dry run, the command as run, the space freed, its rollback, and the probe
reading it back as gone.

## Where <retired model> still lives
On adoption only: a table of every place that still names the retired model and that the mode
didn't change (a preset, a script, a guide, a finding, another host, a consumer's model list),
with its repository and path, addressed to whatever comes to own the host tooling.

## Sources
Every source cited, with its tier, URL, and read date.
```

For an engine item, one section takes the place of the sections from "Gates" through "The claim
beside the anchors", and "Where <retired model> still lives" is left out, since no model retires.
It sits after "Host stack", and its parts, in order:

```markdown
## Engine pass: <engine> <incumbent build> to <candidate build>
The candidate and why it was chosen (the item's build, or the newest at the session's start).

### Gates
Each model the pass loads, one per purpose with cells, through the four gates under today's
policy, each with what it read and its citation.

### Cells
The pass's routing check, its kernel and host stack, from the probe, and `tailscale ping -c 1`.
Every command exactly as run: the incumbent build's cells, the move through the suite with its
output and the build read back, the candidate build's cells. One row per cell: its requests on
each build, its figure on each build and the change, its TTFT median on each build and the
change, and the published claim beside the TTFT, with output tok/s beside it. The first anchors
beside the host's last earlier readings, and any move beyond run noise, named as a finding.
A purpose with no cells, named with its reason.

### Transcripts
The audio model's ASR B on each build: the command as run, each build's word differences, the
reference words, and the pairs that differ.

### Reasoning
The reasoning check on each build's ASR cells, with both counts, each flagged reply quoted by its
opening.

### Verdict
The engine rule, what it gave on each of its four conditions with its figures, the outcome (adopt
or roll back), and any overrule by the architect with its reason. On adopt, the rollback exactly
as printed; on roll back, the update as run and the probe reading the incumbent back.
```

## The screen mode

`/hosting-upgrades screen <host>` gates another spike's model pool for the host's class under the
policy as it reads today, then measures one agent candidate beside the host's set in one session,
and leaves the host's screen record. A report run ranks what the public record says; the verify
mode settles a report's items; the screen mode judges a pool someone else assembled, by this
project's rules and this host's checks. It adopts nothing: a candidate both the sources and the
host's checks support is recorded as kept, a later report ranks it, and no served set changes. It
is interactive, as a run is, and pauses as "When to pause" says.

The mode changes nothing on the host itself, as the verify mode doesn't: it prints every command
that would load, unload, restart, or measure, says who runs it, and records each as it ran ("The
verify mode", step 4, for who runs what). At its end the host serves the set it served at its
start.

### 1. Load the inputs

1. Take the host from `$1`. With none, list the descriptors in `docs/hosts/` by their short names,
   ask which host to screen, and screen one host only.
2. Read `docs/hosts/<host>.md` and `docs/policy.md`. If either is absent, stop and say so, in the
   words step 1 of the run gives for each.
3. **The pool.** Read the descriptor's "Pool" section: a reference name and a path, as its
   Measurements give a finding. Resolve the name as a Measurements entry is resolved, to the local
   checkout the coordinator's `references.local.toml` maps it to, the key its `references.toml`
   names. If the descriptor has no Pool section, stop and say so: "The descriptor for `<host>`
   names no pool (`## Pool`), so there is nothing to screen; add one from the skill's
   `templates/host.md` and run again." If the key has no checkout, or the file isn't there, stop
   and name the path tried. Name the pool by its reference, its path, and the commit its checkout
   is at; then what it says of itself: its date, the host class and build it was judged for, and
   the rules it was judged by. Read its rows, never its verdicts: each status was reached under its
   own rules, and the screen judges every row again (step 3).
4. Read the host's last report (as "The verify mode", step 1, item 3, finds it), its verification
   finding, and the findings its Measurements list: the earlier published and measured claims each
   cell is set beside (step 6), and the report's rows for the incumbents and their citations. A
   host with no report is no stop: the incumbents come from the probe.
5. **The candidate to measure.** One agent candidate a screen measures, which the architect names
   at the start, with the section it loads on: a candidate the last report or this screen holds at
   "needs measurement" (step 4). With none named, the mode gates the pool, lists the candidates,
   and stops before the pass.

### 2. Readiness and probe

1. Run the readiness check with the screen mode's rules ("Readiness check"), and go on as the
   architect answers it.
2. Run the probe exactly as step 2 of the run gives it, and stop as it says when SSH fails.
3. From the probe: the engine and its build, the GPU-reachable ceiling (`== memory ==`), and the
   host's set, one model per purpose, each by its router ID (`== endpoints ==`). This is the set
   the pass measures beside and restores (set A, on this project's hosts).

### 3. Gate the pool

Every row of the pool, in every purpose's table, is one or more candidates: a row that names
several models is one candidate per model, and the rows the pool excluded are candidates too. For
each candidate, in the purpose its row is listed under (and each other purpose its card serves,
step 7 of the run, item 2):

1. **The file the host would load today.** The exact repository and file, its build, and the
   projector's repository, file, and precision, as [models.md](models.md), "A model's row", gives
   them. When the pool's file fails a gate another file of the same model passes (a converter's
   post-training Q4_0 where the publisher releases a QAT Q4_0, say), the row names the file that
   passes, beside the pool's. For example, the pool's `ggml-org/gemma-4-26B-A4B-it-GGUF:Q4_0` is
   a post-training Q4_0 that fails the floor, and the host would load Google's QAT file,
   `google/gemma-4-26B-A4B-it-qat-q4_0-gguf` (`gemma-4-26B_q4_0-it.gguf`, with
   `gemma-4-26B-it-mmproj.gguf`).
2. **The gates, in order**, by [models.md](models.md), each stopping the candidate at its first
   failure:
   - origin, artifact integrity, and the quantization floor (Gate 1), under the policy as it reads
     today
   - fit in the probed memory (Gate 2)
   - the host's engine at the probed build (Gate 3)
   - for the agent purpose, the agent quality bar (Gate 4)
   - the speed floor (Gate 5), whose reading the policy gives (`docs/policy.md`, "Reading the
     floors"): a measured or attributed figure under its floor drops the row, and a paper estimate
     alone holds it. A pool's figures are its class's: on a host of another class they are paper
     estimates.

   A row the pool excluded on an earlier origin rule is judged again under today's, by its own
   evidence chain (models.md, "Origin"), and a row the pool admitted is judged again too; neither
   stands on the pool's word.
3. **The outcome**, one of three:
   - **kept candidate**: every gate passes on cited figures, for the agent purpose the local
     tool-reliability check included, so only a measured candidate can be kept, by the keep rule
     (step 8)
   - **hold**: a gate can't yet place it; the row names the measurement that would (the BFCL
     category its card lacks, the tool-reliability check, the floor and the `bench/` cell that
     measures it)
   - **drop**: a gate fails it; the row names the gate and its source

   Excluded on origin and origin unclear are drops, listed as step 7 of the run lists them.

Every claim cites its source with its URL and read date ("Citing", step 4 of the run); a figure
taken from the pool cites the pool's path and the source the pool gives for it. The research may
be split as "Research" says: its agent-models, other-models, and origin parts, with their tools.

### 4. Needs measurement

List the agent candidates the gates leave at "needs measurement", by name, each with what it
needs: the BFCL category with no card figure, the tool-reliability check, or a speed floor's
cell. On 2026-11-04 these were Muse-Glimmer-30B, Flint, granite-switch-4.1-30b, Gemma 4 31B QAT,
and LFM2.5-24B-A2B, wherever each reaches Gate 4; the list is the screen's own, read fresh. Only
the candidate step 1 names is measured; the others wait for a later screen.

### 5. Before any load

1. **The candidate's gates, re-checked** under the policy as it reads today, as "The verify mode",
   step 5, re-checks a verify item's, the chat-template check included. A failed gate stops the
   pass: the record names the gate and what failed it.
2. **The conform profile for the host's class**, `bench/conform/<class>.toml` (`strix-halo` for
   a Strix Halo host, `nvidia-cuda` for a GB10), validated by spike-model-hosting's profile loader
   from its checkout, read-only (the session, no root), where `<project>` is this project's root:

   ```sh
   cd <spike-model-hosting checkout> && mise exec -- go run ./hosting/cmd/profile validate <project>/bench/conform/<class>.toml
   ```

   It prints `<path>: valid`. The profile names the router IDs of the candidate's set: the
   candidate's section for chat and vision, and the host set's audio and embedding models. A
   profile whose IDs differ from the router's `/models`, or that fails to validate, is a pause.
3. **The candidate's section** on the host's clone of the repository that owns the preset
   (spike-model-engines' `host/llama-preset/models.ini`), from the branch that adds it, pushed
   over ssh and the router restarted so it reads it (the session, no root), each command printed
   before it runs; the router's `/models` reads the section back, unloaded.
4. **The routing check**, the probe, the build, and `tailscale ping -c 1 <host>`, as "The verify
   mode", step 6, gives them.
5. **The cells, printed** (step 6): every cell with its command, who runs it, and its cap, before
   the first load.

### 6. The cells

The verify mode's cell rules hold for every cell and are not restated here ("The verify mode",
step 6): one model per purpose, so a load waits until the router reports the purpose's model
unloaded; each model's cells from a fresh load; every cell at its full request count; and the
probe, the build, and `tailscale ping`, with the routing check before the pass. The screen's own
rules beside them:

- **The tool**: GuideLLM 0.8.1 from this machine (`mise.bench.toml`) against the host's router,
  in the verify mode's command form, with each result under `.state/screen/<host>/`:

  ```sh
  MISE_ENV=bench timeout 10m mise exec -- guidellm run -c bench/<scenario>.yaml --backend "kind=openai_http,model=<section>" --tokenizer "kind=huggingface_auto,model=<tokenizer>" --output "kind=json,path=.state/screen/<host>/<phase>-<cell>.json"
  ```

- **The caps**: `timeout 10m` on every cell, and `timeout 15m` on each BFCL tier. A cap hit is an
  escalation: a pause, with the cell named.
- **One shared load**: BFCL single-turn, BFCL multi-turn, and conform share one fresh load of the
  candidate's section; every other cell runs from its own.
- **Two phases.** Phase 1 runs on the host's set as served. Phase 2 runs on the candidate's set:
  the candidate's section serving agent and vision, with the set's agent and vision models
  unloaded and its audio and embedding models loaded. The host's set is restored at the end.

The cells, for an agent candidate that would also take vision:

| Phase | Cell | Model, section | Scenario | Load | Informs |
|---|---|---|---|---|---|
| 1 | Anchor A, B | the set's agent, on the anchor section the host's earlier readings used | `anchor-a.yaml`, `anchor-b.yaml` | 1 × 8, 4 × 32, 512 / 256 | the incumbent's decode and TTFT, and concurrency |
| 1 | Long A | the set's agent, on the set's own section | `long-a.yaml` | 1 × 4, 8,192 / 512 | prefill and TTFT beside the candidate's |
| 1 | Long B | the same, with the whole set loaded | `long-b.yaml` | 4 × 16, 8,192 / 512 | streams at agent prompt size; the set's memory read after |
| 1 | Sweep | the set's agent, on its 16-slot section | `sweep.yaml` | 1/4/16/32 streams, 512 / 256, 60 s a level | capacity |
| 1 | Vision A, B | the set's vision model, on its section | `vision-a.yaml`, `vision-b.yaml` | 1 × 8, 4 × 32, 720p + 200 / 64 | the reasoning count and the vision baseline |
| 2 | Cold start | the candidate's section | the router's API | a load from unloaded, timed | local only |
| 2 | Shape A, B | the same | `shape-a.yaml`, `shape-b.yaml` | 1 × 8, 4 × 32, 512 / 256, thinking on | the decode floor, beside anchors A and B |
| 2 | Long A | the same | `long-a.yaml` | 1 × 4, 8,192 / 512 | the prefill and TTFT floors |
| 2 | Long B | the same, with the candidate's set loaded | `long-b.yaml` | 4 × 16, 8,192 / 512 | the stream floor; the set's memory read after |
| 2 | Sweep | the same | `sweep.yaml` | as phase 1's | capacity |
| 2 | Vision A, B | the same | `vision-a.yaml`, `vision-b.yaml` | as phase 1's | the vision floor and the reasoning count |
| 2 | BFCL single | the same, one fresh load | spike-model-hosting's tier list | 100 samples, 4 in flight | the single-turn floor |
| 2 | BFCL multi | the same load | spike-model-hosting's tier list | 20 samples, 4 in flight | the multi-turn floor |
| 2 | Conform | the same load | `bench/conform/<class>.toml` | Pi, k = 5, 9 capabilities | tool reliability and the API surface |

The anchor section a host's earlier readings used may not be the set's own (framework's anchors
ran on the 4-slot section, with the set's agent unloaded meanwhile); a section that gives a slot
fewer than 8,704 tokens can't hold a long cell, so the long cells run on the set's own section on
every host. Every scenario but the anchors names no model, so each command gives its section and
its tokenizer (the model's upstream repository: `openai/gpt-oss-120b`,
`google/gemma-4-26B-A4B-it`). gpt-oss-120b's BFCL doesn't run: the floors are its own two runs,
less their spread (`docs/policy.md`, "Agent quality bar").

**The agent tiers**, spike-model-hosting's, run from this machine in its checkout, read-only: its
consumers mise environment, its suites project (Inspect AI and inspect_evals' stock BFCL task),
and its seeded tier lists, with every output and cache in this project's ignored `.state/`, so
the checkout is never written. At the router's defaults (the card's sampling, the template's
default reasoning), with parallel tool calls allowed, 4 requests in flight, the count the floors
were measured at. A tier runs its whole list: no `--bar`, so no early stop. A new tool's first
walk is the architect's (the experiment's rules); after it, the session runs them:

```sh
cd <spike-model-hosting checkout>/evaluation && S=<project>/.state/screen/<host> && PYTHONDONTWRITEBYTECODE=1 UV_PROJECT_ENVIRONMENT=$S/../suites-venv HF_HOME=$S/../cache/huggingface INSPECT_EVALS_CACHE_DIR=$S/../cache/inspect_evals MISE_ENV=consumers timeout 15m mise exec -- uv run --project suites --locked --no-python-downloads python suites/agent_quality.py eval --router http://<host>:<port> --model <section> --tier bfcl-<single|multi> --list tiers/agent-bfcl-<single|multi>.txt --slots 4 --output $S/bfcl-<single|multi>
cd <spike-model-hosting checkout>/evaluation && MISE_ENV=consumers timeout 10m mise exec -- go run ./cmd/evaluate conform -router http://<host>:<port> -profile <project>/bench/conform/<class>.toml -consumers pi -k 5 -state <project>/.state/screen/<host>/conform
```

A tier's figure is its accuracy over its whole list, read from the Inspect JSON log the tier
leaves under its output directory. Conform's figure is its table: each capability's trials passed
of 5, and the invalid requests.

**The local-only checks**, each recorded with its command as run:

- **Cold start**: the router's `/models/load` for the candidate's section from unloaded, timed
  until `/models` reads it loaded (the session, no root), as spike-model-engines' setup times a
  load.
- **Memory**, read warmed after each set's long B cell, with the set still loaded: on a GB10,
  `ssh <host> grep ^MemAvailable /proc/meminfo`; on a Strix Halo, the GTT in use,
  `ssh <host> 'cat /sys/class/drm/card*/device/mem_info_gtt_used'`.
- **Each slot's context**, read back from the router for the candidate's section:
  `curl -s "http://<host>:<port>/props?model=<section>" | jq '{n_ctx: .default_generation_settings.n_ctx, total_slots}'`.
- **The API surface**: chat completions with tools under `tool_choice` `required`,
  `response_format` `json_schema`, and image input, each answered without error, read from
  conform's recordings (its state's `conform/wire/`) and one request each against the section.
- **Whether a feature works**: images on the candidate's section, and replies with no unprompted
  reasoning.

**The reasoning check** runs on all four vision cells, both phases', by "The verify mode", step 6:
the replies that reasoned in the thought channel, and those whose text speaks about the task.

Print the pass before it runs, in the verify mode's form. For example, on framework:

```text
Screen pass: framework, llama.cpp b11960 (server-vulkan), Gemma 4 26B-A4B QAT on its agent section.
Each cell: GuideLLM 0.8.1 from this machine, http://framework:8080, fresh load, the session.
  phase 1, set A
   1 Anchor A     gpt-oss-120b, 4-slot section *         1 x 8, 512 / 256          timeout 10m
   2 Anchor B     the same                               4 x 32, 512 / 256         timeout 10m
   3 Long A       gpt-oss-120b, set A's section          1 x 4, 8,192 / 512        timeout 10m
   4 Long B       the same, set A loaded; GTT after      4 x 16, 8,192 / 512       timeout 10m
   5 Sweep        gpt-oss-120b, 16-slot section          1/4/16/32, 60 s a level   timeout 10m
   6 Vision A, B  26B-A4B QAT, vision section            1 x 8 / 4 x 32, 720p      timeout 10m each
  phase 2, the Gemma set (gpt-oss-120b and the vision section unloaded)
   7 Cold start   26B-A4B QAT, agent section             API load, timed           the session
   8 Shape A, B   the same                               1 x 8 / 4 x 32, thinking  timeout 10m each
   9 Long A       the same                               1 x 4, 8,192 / 512        timeout 10m
  10 Long B       the same, the set loaded; GTT after    4 x 16, 8,192 / 512       timeout 10m
  11 Sweep        the same                               1/4/16/32, 60 s a level   timeout 10m
  12 Vision A, B  the same                               1 x 8 / 4 x 32, 720p      timeout 10m each
  13 BFCL single  the same, one fresh load               100 samples, 4 in flight  timeout 15m, the architect (first walk)
  14 BFCL multi   the same load                          20 samples, 4 in flight   timeout 15m, the architect (first walk)
  15 Conform      the same load                          Pi, k = 5                 timeout 10m, the architect (first walk)
  * set A's agent unloaded meanwhile. Set A restored at the end, read back by /models and the probe.
```

### 7. The figures beside each cell

Each cell's row gives its request count, its figure (output tok/s), its TTFT median, and its ITL
median, and beside them the earlier claims for the same model and shape: the pool's figure, the
last report's published claim, and the host's earlier measured cell, each cited with its build.
Only cells of this session are compared with each other; an earlier claim is context, never a
condition (the experiment's comparisons rule, as the verify mode keeps it).

### 8. The keep rule

For an agent candidate serving agent and vision with the set's agent model unloaded. Keep only
when every condition holds; otherwise drop. The record states what the rule gave on each
condition, with its figures, then the outcome; the architect may overrule it, and the record
gives the overrule and its reason beside what the rule gave.

- **Gates**: every gate passes, and no open tracker report has the engine's parser rejecting the
  model's tool calls.
- **Capability**: BFCL single-turn at least 0.630 and multi-turn at least 0.325, each on its
  whole list (`docs/policy.md`, "Agent quality bar").
- **Tool reliability**: conform through Pi passes every applicable capability 5 of 5, with 0
  invalid requests.
- **Completeness**: every cell holds its full request count.
- **Speed** (`docs/policy.md`, "Speed floors"): shape A at least 20 output tok/s; long A prefill
  at least 500 tok/s, with TTFT median at most 20 s; long B ITL median at most 100 ms (each stream
  at least 10 tok/s). The set's agent model's same-session figures go beside them.
- **Capacity**: the highest sweep level where the candidate's ITL median stays at 100 ms or less
  is at least the set's agent model's, and every one of the candidate's slots holds the context
  its section gives, as the router reports it.
- **Memory**: the candidate's set leaves the policy's headroom (`docs/policy.md`, "Memory
  headroom") and uses no more than the host's set read the same way in the same session.
- **Vision**: on the candidate's section, every vision A and B request is answered within 10 s,
  and no more replies reasoned than on the set's vision section, for each of the two counts.

A keep is recorded, not adopted: the host's set is restored either way.

### 9. The end state

Restore the host's set by the verify mode's one-model-per-purpose rule, then read it back by the
router's `/models` and the probe: the host serves what it served at the screen's start. A clone
moved to a branch for the pass returns to its default branch with the router restarted, unless a
keep leaves the branch's pull request open; the brief says which.

### 10. Write the record

The record is the mode's only write: one file per host per screen, at
`docs/screens/<host>/<YYYY-MM-DD>.md`, dated the day the screen read its sources. When the host
already has a record of that date, the screen writes `<YYYY-MM-DD>-2.md`, then `-3`, the next
number free. It is written once, when the screen ends (after the end state is read back, or when
the architect stops the screen, saying where it stopped), and never edited. A screen stopped
before its pass writes no record unless the architect asks for one. The record's sections, in
order:

```markdown
# <host>: screen of <pool reference> <pool path>, <YYYY-MM-DD>

## Inputs and probe
The pool read (its reference, path, commit, and what it says of itself), the descriptor and policy
read, the readiness rules found missing and the answer, the probe's date and inventory, and the
candidate measured, with its section.

## The gated pool
Per purpose, one row per candidate: the file the host would load (and the pool's, when it
differs), its projector, each gate with its citation, and its outcome (kept candidate, hold with
the measurement that would place it, or drop with the gate and its source). Then the drops on
origin and the models of unclear origin, with what the screen checked.

## Needs measurement
Step 4's list, each candidate with what it needs.

## Closures
Each item closed with no action, with its reason (the standing closures below, and any the
architect makes in this screen).

## Gates
The measured candidate's gates re-checked before any load, each with what it read and its
citation, and the conform profile's validation as run.

## Cells
The routing check, the engine build and host stack from the probe, and `tailscale ping -c 1`.
Every command exactly as run, in order, with who ran it. Phase 1's cells, then phase 2's, each row
with its requests, figure, TTFT median, and ITL median, the earlier claims beside it (step 7).

## BFCL and conform
Each tier's command as run, its accuracy on its whole list against its floor, and its time;
conform's table, invalid requests, and fit.

## Local-only checks
Cold start, each set's memory read-out, each slot's context as the router reports it, the API
surface, and whether each feature works, each with its command as run.

## Reasoning
The reasoning check on the four vision cells, both counts each, each flagged reply quoted by its
opening.

## Verdict
The keep rule, what it gave on each condition with its figures, the outcome (keep or drop), and
any overrule by the architect with its reason beside what the rule gave.

## End state
The host's set restored, read back by `/models` and the probe; the clone's branch and the router's
restart.

## Sources
Every source cited, with its tier, URL, and read date.
```

**The standing closures**, which every record's "Closures" carries until the architect reopens
one (the architect's decisions, 2026-11-04):

- **E4B QAT's logit-bias ban on `<|channel>`**: closed, no action. Its unprompted reasoning was in
  the reply's plain text, which a ban on the channel token can't reach, and Google has published
  no revision of `google/gemma-4-E4B-it-qat-q4_0-gguf` since the one verify-framework rolled back
  (sha 4b4a2c1d, 2026-07-17); E4B QAT is revisited only on a revision (framework's descriptor's
  watch item).
- **12B QAT's and 31B QAT's reasoning check**: closed, no action. Neither serves a purpose nor is
  a measured candidate, so the check runs on 26B-A4B QAT alone; both are named as not checked.

## What a run writes

A run writes nothing except its report: not the descriptor, not the policy, not the skill, and
nothing on the host. Changes it would make to any of them go into the report as proposals.

The verify mode writes nothing except the host's verification finding,
`docs/findings/verify-<host>.md`: not the report it verifies, not the descriptor, not the policy,
not the skill, and nothing on the host. The commands that change the host are printed, run by the
architect or the session as the mode assigns them, and recorded in the finding as run.

The screen mode writes nothing except the host's screen record,
`docs/screens/<host>/<YYYY-MM-DD>.md`: not the pool, not a report or a finding, not the
descriptor, the policy, the skill, or its conform profiles, and nothing on the host beyond the
loads and the branch the record gives as run. `setup` writes nothing.
