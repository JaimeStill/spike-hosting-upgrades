---
name: hosting-upgrades
description: Evaluates upgrades to one inference host's serving stack (its hardware configuration, its model engine, and its models) from what others publish, and finds and ranks everything the workstation has fallen behind on (pending package and firmware updates, failed or stopped units, container images behind their tag, unused images and models taking disk, and configuration that differs from its descriptor). Probes the host live over SSH, read-only and without root, reconciles the probe with the project's host descriptor and policy, and writes a dated, cited report that gives each item a verdict (verify, take, hold, or skip); it applies nothing. Use when asked to evaluate upgrades for a host, check what's new for a host's engine or models, find what a host has fallen behind on or what debt it carries, or plan a host's next upgrade.
argument-hint: <host> | setup
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

The skill's frontmatter grants no tools. A skill's grant clears when the user sends their next
message, so an interactive run would lose it at its first pause; the durable grants are the
settings rules the readiness check prints.

## Inputs

A run reads two documents from the project, relative to its root (`${CLAUDE_PROJECT_DIR}`), and
writes neither.

- **The host descriptor**, `docs/hosts/<host>.md`. It holds only:
  - the SSH short name the run reaches the host by
  - the declared model purposes: what the host serves or is meant to serve (agent, vision, audio,
    embedding, or whatever it serves), naming no model
  - optional engine watch items: named things the run must check, beside its own scan
  - optional measurements: the workspace's own dated findings on this host, each a reference
    name plus a path, which the run counts as attributed benchmarks ([sources.md](sources.md),
    "Tiers")

  Every other fact about the host comes from probing it. [templates/host.md](templates/host.md)
  gives the shape, for an environment writing its own.
- **The policy**, `docs/policy.md`. It states the model-origin rule, artifact integrity with the
  code the architect has accepted, the quantization floor, the agent quality bar, the minimum
  context per agent session, and the memory headroom a model set must leave.
  [templates/policy.md](templates/policy.md) gives the shape.

When a step needs a policy value the document doesn't state (a floor for a kind of model it
doesn't name, a headroom it leaves open), the run asks the architect for the value and records
the answer in the report as the architect's, never inventing one.

## Readiness check

A run's tools need permission rules in the project's settings, or each use asks. The check works
out the rules this workspace needs, finds the ones missing, and prints them for the architect to
add. It never writes a settings file. A run makes it the last part of step 1; `setup` makes it
the whole run.

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
4. **Ask.** When a rule is missing, ask whether to continue with the prompts the missing rules
   bring, or wait while the architect adds them; the default is to wait. When none is missing,
   say so and go on. `setup` asks nothing: it stops once it has printed.

Two rules the check never prints:

- **No rule for `gh api`.** Settings rules apply to every agent in the workspace, not only to this
  skill, and `gh api` writes as readily as it reads (`-X POST`, `-f`), with the architect's
  GitHub token. So a `gh api` call, the fallback once unauthenticated reads run out, asks each
  time.
- **No wildcard ssh host.** A rule such as `Bash(ssh * bash -s < <probe path>)` also matches ssh
  options riding along in the wildcard (`-o ProxyCommand=<any command>` runs that command on this
  machine), so each host gets its own exact rule, and a new host's descriptor brings a new rule
  through `setup`. The rule names the probe path literally, because settings rules don't expand
  `${CLAUDE_SKILL_DIR}`.

## The run

### 1. Load the inputs

1. Take the host from the argument, `$0`. With no argument, list the descriptors in `docs/hosts/`
   by their short names, ask which host to run on, and run on one host only. With `setup`, run
   the readiness check alone, as "Readiness check" says, and stop there.
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
- **A watch item the probe can't reach**: a watch item naming an engine or backend the host
  doesn't have is kept, not dropped; note it for "Proposed changes".

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
- the descriptor's watch items, each answered by name (step 6)

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
4. **The watch items.** Answer each of the descriptor's watch items by name, under its own
   heading: what the sources say now, cited, and what changed since the last report if there is
   one.
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
  [models.md](models.md), "Gate 4", applies it).
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
   memory, and the host's engine serving the architecture on its backend, and, for the agent
   purpose, the policy's agent quality bar. A model that fails a gate stops there and is listed
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
   sources"), go in the model's row, cited, and the model goes on to the next gate. A model the chain leaves short of the policy's pass bar, with no
   involvement found at an excluding level, is researched further (the uploader's identity and
   affiliation, the conversion against the publisher's weights, the publisher's own mentions of
   it, the uploader's other work) until the answer is definitive; a model the research brings to
   the pass bar passes, and its row records the evidence that settled it. Only a model the
   research can't settle (an unidentified publisher, an unestablished lineage, a teacher the
   card doesn't name and the publisher doesn't place in its own pipeline, or sources that
   contradict each other) goes, without a pause, in the "origin unclear" list beside it, and
   never reaches a verdict either. Each entry names what the run checked, each source cited
   inline. A pass means "no disclosed or detected involvement at an excluding level", and the
   section says so. A model that already fails a later gate (artifact integrity, the floor, fit, the
   engine, the agent bar), shown by a read the run has made, may stop at "not settled" for origin
   instead of being researched to the end: its row says origin is not settled, that the research
   stopped because the model fails that gate, and names the gate and its source (models.md,
   "Origin"). It is listed under the gate it fails, not under "origin unclear".
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
Step 5's adjustments, verify, take, hold, skip.

## System updates and debt
Step 5b's items: pending package updates (with the lists' age), firmware updates, the kernel and a
pending reboot, failed units and services meant to run, the boot-order check, container images
behind their tag, unused images and models taking disk, configuration that differs from the
descriptor, a drafter of adversary origin a preset loads, and agent sessions under the minimum
context, each with its verdict and sources, verify, take, hold, skip.

## Engines
Step 6: the incumbent, the seed list, the scan, each watch item by name, and the conclusion.

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
   newest tags (step 5b).
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
- The tools it may use: WebSearch, WebFetch, `gh search issues` and `gh search prs`, and, for the
  origin part only, the screening-list script and the first-bytes script, each run from the
  project root by exactly the path its readiness rule names, with each argument quoted:
  `.claude/skills/hosting-upgrades/scripts/screen.sh "<name>" ...` (models.md, "Origin", item 1)
  and `.claude/skills/hosting-upgrades/scripts/magic.sh "<org>/<repo>" "<file>"` (models.md,
  "Artifact integrity"). The screening list's "no match" is never "clean", and magic.sh can't tell
  safetensors from 4 bytes ([sources.md](sources.md), "Origin and build checks").

**What each part returns.** Cited claims, each with its source's URL, its read date, and its
tier, in the form "Citing" (step 4) gives. The run, not the part, gives verdicts.

**No curl.** No subagent uses curl or jq through Bash: the readiness check prints no rule for
them, so they would run outside the rules the architect granted. Data too large for WebFetch, or
behind a header or a redirect WebFetch can't handle, goes through a narrow script bundled with the
skill, which reads one source and is granted by its own rule, naming its path:
`scripts/screen.sh` (the screening list) and `scripts/magic.sh` (a Hub file's first 4 bytes, past
the xet CDN's 302) are the two such scripts today, and with the probe they hold the skill's only
curl.

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

## What a run writes

A run writes nothing except its report: not the descriptor, not the policy, not the skill, and
nothing on the host. Changes it would make to any of them go into the report as proposals.
