# Survey

`/hosting-upgrades survey <host>` reads the public record for one host: it probes the host as it is
now, reconciles what it finds with the host's descriptor, gathers and cites what others publish on
the host's hardware configuration, model host, and models, gates every candidate model (the pool a
descriptor names among them), and writes one dated report giving each item a verdict: verify,
take, hold, or skip. It judges every configuration, engine, capacity, and memory figure against
the load targets of the purposes the host serves (rules.md, "Load targets"). It applies nothing.

The survey is interactive. It pauses only as rules.md, "Pause", says, and it never runs a command
that needs root (rules.md, "Root").

## 1. Setup

1. Run setup.md, steps 1 to 3, with survey's rules: the inputs, the readiness check, the probe.
2. Read the host's last report in `docs/reports/<host>/` (rules.md, "Dated records"), if any. Step
   3 compares the probe with its Inventory.
3. **The pool.** When the descriptor has a Pool section (a reference name and a path, as its
   Measurements give a finding), resolve the name to the local checkout the coordinator's
   `references.local.toml` maps it to, the key its `references.toml` names. The project names its
   coordinator in its own notes (`CLAUDE.md` or `context/README.md`, such as
   `standards-lab/context/roadmap.toml`); find that checkout from there, not by searching. Without
   one, the pool's `Read` rule (setup.md, step 2) names the checkout's path. If the key has no
   checkout, or the file isn't there, name the path tried and go on without it. Name the pool by
   its reference, its path, and the commit its checkout is at; then what it says of itself: its
   date, the host class and build it was judged for, and the rules it was judged by. Read its rows,
   never its verdicts: each status was reached under its own rules, and step 8 judges every row
   again.

## 2. Reconcile with the descriptor

Compare what the probe found with what the descriptor lists, and pause on every discrepancy
(rules.md, "Pause") before going on:

- **A served model whose purpose isn't listed**: map each model in `== endpoints ==` to a purpose
  from its name and, where unclear, its card. A model that fits no listed purpose is a
  discrepancy.
- **A listed purpose nothing serves**: a purpose with no served model, including the case where
  nothing serves at all. When nothing serves, the inventory says so, and the later steps judge
  against the installed engines (`== engines ==`) and the stored models (`== models ==`), once the
  architect confirms that is what the run should do.
- **A watch item the probe can't reach**: a watch item naming something the host doesn't have (an
  engine or backend it doesn't run, a component or device it lacks) is kept, not dropped; note it
  for "Proposed changes".

A served section whose slots or per-session context differ from its purpose's load target is no
pause: step 5 lists it as a configuration difference, and step 6 weighs it.

## 3. Sources

Gather the public record for what the probe found, from the sources in [sources.md](sources.md),
which lists each by kind (hardware and host stack, engines, models, benchmarks) and by vendor or
project, with its URL and how to read it. Read the machine-readable endpoint where one exists (the
GitHub releases API, the Hugging Face API, Arch's package JSON). A source goes through the research
cache ("Research cache", below): one read within 14 days whose subject hasn't changed is cited from
the cache with its read time, and every other source is read fresh and its entry replaced.

**When the inventory hasn't moved.** Compare the probe with the Inventory of the host's last
report. When the two match on the engine builds (each container's image and the build an endpoint
reports), the stored and served models and their files, and the host stack (the OS image, the
kernel, the firmware and BIOS, the driver or Mesa), the survey researches only what moved, and
cites the last report, by its path and date, for the rest. Always researched, whatever the
inventory shows, because the outside world moves:

- pending package and firmware updates, and each container image's newest tag (step 5)
- each component's and engine's newer releases, and what is newly known to break (steps 4 and 6)
- the newest models of the publishers, the pool, and the scan for new candidates (step 8), with
  their origin chains (models.md, "Origin"), each through its model entry in the research cache
- the descriptor's watch items, of every kind, each answered by name in its kind's step (4, 5, or
  6)
- every blocker register entry's upstream state ("Blocker register")
- the configuration review (step 7) and discovery (step 8), through the research cache

A row the survey carries from the last report says so, with that report's citation, and keeps its
verdict unless something researched in this run changes it. When any of the three differs, the
survey researches in full, and the Inventory names what differs. The Inventory says which of the
two the survey did.

Read with WebFetch and search with WebSearch, GitHub included: release pages, api.github.com JSON,
and raw files from raw.githubusercontent.com or the contents API. Search a project's tracker with
`gh search issues` and `gh search prs`, and read one issue or pull request, its state and its
comments, with `gh issue view` and `gh pr view` (`--json`). A `gh api` call is only the fallback
once unauthenticated API reads (60 an hour) run out, and it asks permission each time, since the
readiness check prints no rule for it ([sources.md](sources.md), "Reading a source"); the image
script makes its own reads, under its own rule. When the research is split across subagents, split
it as "Research" says, with the tools it names.

- **Read for the probed versions.** For each component the probe names (OS image, kernel,
  firmware, BIOS, driver or Mesa, each engine and its build), find what is newer, what changed
  between the probed version and the newest, and what is known to break.
- **Search beyond the list.** A web search finds benchmarks and reports the list doesn't hold. A
  found source is tiered by the same bar as a listed one, and a good one is proposed for the list
  under "Proposed changes".
- **Tier every source** as primary, attributed benchmark, or lead, by the bar in
  [sources.md](sources.md), "Tiers". A lead names something to check and never carries a verify
  verdict alone.
- **Read the host's own measurements.** Each finding the descriptor lists under "Measurements",
  and the host's measure records (`docs/measures/<host>/`), are attributed benchmarks on this
  host. Cite each by its path, and compare only cells measured in one session.
- **Never cite a blocklisted source** ([blocklist.md](blocklist.md)). When one carries a figure
  worth having, follow it to its original and cite that, or leave the figure out. A source met in
  this run that fails a blocklist criterion is proposed for the blocklist, with its reason, under
  "Proposed changes".

Every claim cites its source as rules.md, "Citing", says.

### Research cache

The project's committed `docs/research.md` holds one entry per source a survey read: its URL, its
read time, the hosts and subject it concerns, its tier, and what it said, in the source's own
figures and words. It is one file, updated in place; git keeps the old text. Every host's surveys
share it, so a source read for one host is cited for another while it is fresh. A read time is a
UTC timestamp, `YYYY-MM-DDTHH:MMZ`, so a subject updated upstream on the day of the read is
placed before or after it; an older entry that gives only a date counts as read at 00:00Z that
day.

An entry caches what a source said about its subject: an issue's comments, a release's notes, a
model's card. It never caches which is newest: a release entry names its release and what its
notes say, and whether a newer release exists is read fresh every run (item 1's "Never cached").

**Model entries.** Each model a survey judges (an incumbent or a candidate, from any of step 8's
origins) gets one entry for its card and origin chain, under the cache's "Model cards and origin
chains" heading: its repository, the card's `lastModified`, the publisher, the base chain to the
original weights (each level's repository and publisher), the teachers and the role each played,
the card's reads the gates take (its format and build, its evals for the purpose, its context
and architecture), and the origin chain's verdict inputs (each level's finding with its source
and read time, and whether the chain reached the pass bar, excluded at a level, or stayed
unclear). It holds the inputs, not the survey's verdict. A survey consults it before building the
chain (step 8, item 5) and rebuilds only under item 1's rules, the model's record
(`lastModified`) moving past the entry's being its subject's change.

1. **Before reading a source**, look for its entry. Cite the entry, with its read time and the
   source's URL, instead of reading again, unless one of these holds; then read the source fresh:
   - the entry is 14 days old or more
   - its subject has changed since the read: the issue or pull request was updated after the
     entry's read time (its `updatedAt`, which a `gh issue view` or `gh pr view` gives), the
     release list or the model's record (`lastModified`) has moved past what the entry names, or
     the probe shows the host running something the entry doesn't cover (a newer build, another
     model file)
   - the claim the survey would cite from it is not in the entry

   Never cached, read every run: what says what is newest (a release list, a registry's tags, a
   publisher's model list, a package's or firmware's pending update), and the newest fact itself,
   even where an entry's source also gives it; the foreign-adversary list and the screening list
   ([sources.md](sources.md), "Origin and build checks"); and the register's upstream states. A
   newest-version read is also how a survey sees that a cached entry's subject has changed.
2. **After a read**, replace the source's entry whole, with the read's UTC time: what it says
   now, not what it said then. A source read for the first time gets a new entry, under its
   kind's heading (an engine, the engine choice and models, model cards and origin chains, the
   host stack).
3. **Delete** an entry whose subject no longer concerns any host: a model no host serves or
   screens and no survey ranks, a build that no host runs or is held at and that is two images
   behind the newest for every class it names, or a register entry that is deleted. The report's
   Inventory names the entries deleted.

A cached figure keeps its tier, and a lead stays a lead. The cache holds what a source said, never
the survey's verdicts, and never a register entry's state: the register's upstream checks run every
survey ("Blocker register"). The survey reads the cache first and writes it last, once the
report's research is done (step 13).

The report's Sources table gives each source's read date, from the cache or from this run, and
the Inventory counts the entries cited from the cache, the ones read fresh, and the ones deleted.

### Blocker register

The project's committed `docs/blockers.md` holds what blocks its hosts from an upgrade, one entry
per blocker, with the fields and the four states its head gives (open, fix merged, fix in an image
build, cleared on the host). The descriptors' watch items hold possible upgrades; a blocker lives
in the register, and a descriptor points to it.

1. **Check every entry upstream, every survey**, whatever the research cache holds, with `gh`,
   for each issue and pull request the entry names:

   ```sh
   gh issue view <n> --repo <owner>/<repo> --json state,closedAt,updatedAt
   gh pr view <n> --repo <owner>/<repo> --json state,mergedAt,mergeCommit
   ```

2. **A merged fix: is it in an image?** For each entry whose fix is merged, run the image script
   from the project root, once per host class the entry's hosts belong to (gb10, strix-halo):

   ```sh
   .claude/skills/hosting-upgrades/scripts/fix-in-image.sh "<owner>/<repo>" "<pr or commit>" "<class>"
   ```

   It names the newest build with the class's image (the highest `server-<flavor>-b<N>` in
   ghcr.io's tag list, so an image published for a build with no GitHub release counts) and
   reads GitHub's compare of the fix's merge commit against it:
   `in image: yes` when the build is ahead of the fix or identical to it. Quote its lines, with
   their read time.
3. **Move the state.** An open entry whose fix merged becomes **fix merged**; a fix-merged entry
   whose fix the script finds in the class's newest imaged build becomes **fix in an image
   build**. A state never moves back without a cited reason (a revert, a reopened issue), which
   the entry's upstream line gives. **cleared on the host** is measure's to set, from a measure
   record showing the blocked thing working on a build with the fix; an entry cleared on every
   host it names is deleted. Update each entry's upstream line and its last-checked date in place,
   and write nothing else to it from the check.
4. **A fix in an image is an upgrade item.** An entry at **fix in an image build** becomes an item
   for each host it names that doesn't run that build: the move to the imaged build (step 6, an
   engine item, verify or hold by "Verdicts", never take), with what it unblocks and what else the
   build brings, and every other open entry on the host that the move would cross (a build past a
   blocker's last good build is skip until that entry clears). The item cites the entry and the
   script's output.
5. **New entries.** The survey adds an entry when a record of this project measured what the
   blocker costs (a measure record, a screen record, a finding), with that record linked. A
   public report alone of something that would block a host is a watch item or a configuration
   finding, proposed under "Proposed changes", not an entry.

The report's "Blockers" section lists every entry with its state, its upstream line as checked,
and what moved since the last report.

## 4. Hardware configuration

Recommend adjustments to the host's hardware configuration, one per component that has a
candidate: kernel, firmware (linux-firmware, GPU firmware), BIOS, OS image, driver or Mesa, and the
GPU-reachable memory ceiling (the TTM limit on AMD; on GB10, the system memory). A component
already at its newest, with nothing known to break, gets one line saying so, with the source that
shows it.

First ask which components reach the engine. A containerized engine carries its own Mesa and ROCm
(or CUDA) in its image, so a host Mesa or ROCm update doesn't change what it serves; only the
kernel, the firmware, the BIOS, and the memory ceiling reach it from the host. For such an engine,
the component's version is the image's: read it from the image's Dockerfile or labels at the probed
tag, and cite that. Never run a container to read it. A host component that doesn't reach the
engine is still reported, with its verdict judged on what it does reach (the desktop, other
services), and the report says it doesn't change serving.

Each adjustment gives:

- **From and to**: the probed version and the candidate.
- **Sources**: each with its tier and its citation.
- **Claimed gain**: what the sources claim, in their own terms, or "none claimed".
- **Risk**: what is known to break, whether it needs root, and its rollback (a package downgrade,
  a BIOS reflash, removing a modprobe file).
- **Verdict**: verify, take, hold, or skip, by "Verdicts", with the reason.

Order the adjustments verify, take, hold, skip. A fact the probe can't read without root (loaded
GPU firmware, BIOS settings) is asked for as rules.md, "Root", says.

**The hardware watch items.** Answer each of the descriptor's watch items of this kind (a component
this step weighs, such as a kernel's known faults, a firmware or BIOS setting, or the memory the
firmware reserves) by name, under its own heading: what the sources say now, cited, and what
changed since the last report if there is one. An item that bears on a component's verdict is
cited in that component's row.

This step judges each component's version. Whether the host has caught up with what it already
installed (a newer kernel installed but not running, a reboot pending) and the boot-order check
are step 5's, and the kernel's row here points to them.

## 5. System updates and debt

Everything the host has fallen behind on, found and ranked: what is pending, what has failed, what
takes disk and serves nothing, and what drifted from the descriptor. The survey applies none of
it: applying a take or verify item, with its rollback, is measure's (measure.md, "The host's
items"), and the report says what each would take.

Each item names what the probe found, cited to its section, and takes a verdict by "Verdicts" with
its sources:

- **take** is as "Verdicts" defines it, with the item's known rollback named in its row, and under
  the same two rules: a root step with no rollback is hold, and an engine build is never take.
- **verify** needs an attributed gain, as everywhere; in this step it arises only where an update
  reaches the engine, and that item is judged in step 6 and referenced here.
- **hold** is everything that needs the architect's decision before measure acts on it: an update
  whose only claim is release notes, or that needs a root step with no rollback; a failed or
  stopped service; a removal; a drift between two values.
- **skip** is an update with a reported regression, or an item the architect's answer retires (a
  service step 2 settled should stay down).

Order the items verify, take, hold, skip; within a verdict, the item that risks serving first (a
boot-order failure, a stopped engine), then by disk freed.

1. **Pending package updates** (`== updates ==`). List every pending update with its from and to
   versions. On apt, give the lists' age from the `apt lists` line: the count is as of that date,
   and refreshing the lists is root's (`ssh -t <host> sudo apt-get update`, asked for as rules.md,
   "Root", says, after which the survey probes again). On Arch, the count is a fresh sync. Read the
   updates against the channel and mirror the probe prints at the section's head (the `mirror:`,
   `repo`, and `omarchy channel:` lines, or the `apt source` lines): an update is what that channel
   and mirror offer, and a mirror that serves a snapshot (Omarchy's stable mirror) can lag the
   distribution's own. Read the distribution's notices for each (Arch news for a manual
   intervention, the release's changelog or security notice), and give the verdict by them. When a
   notice urges an upgrade of a package the probe doesn't list, ask for its installed version as
   rules.md, "Package versions a notice names", says. A package step 4 weighs (the kernel,
   firmware, Mesa, the driver) keeps its verdict there and is listed here by reference. Packages
   that share a verdict and a reason may share a row that names each.
2. **Firmware updates** (`== firmware-updates ==`). Each device with an update, by name, from and
   to, with the vendor's release notes for that version (LVFS or the vendor's page). "No updates"
   is an item too, with the fwupd metadata's date, which bounds what it can know. Applying firmware
   is a root step; one with no downgrade path has no rollback, so it is hold ("Verdicts").
3. **The kernel and a pending reboot** (`== kernel ==`). An installed kernel newer than the running
   one, or a pending reboot (`reboot: pending`), is an item: the reboot that takes it is take when
   step 4's kernel row finds no regression at the installed version and the running kernel stays in
   the boot menu as its rollback, and hold otherwise ("Verdicts").
4. **Failed units, and services meant to run** (`== units ==`, `== engines ==`). Every failed unit,
   system and user, with its state. Then every service a descriptor or container implies should run
   that doesn't: an engine unit that is disabled or inactive while the purpose it serves is listed,
   and a container whose restart policy (`always`, `unless-stopped`) says it should run while it is
   exited. Name the cause the probe shows, and the recovery the architect would run; a cause only
   the journal shows is asked for as rules.md, "Root", says when the journal needs root. Each is
   hold, or skip when step 2's answer says it stays down.
5. **The boot-order check** ("Boot-order check", below): each finding is hold, first among the
   holds, since it can leave the engine unreachable after a reboot; its remedy is a root step with
   a rollback.
6. **Container images behind their tag's latest release** (`== engines ==`). For each container's
   image, read the newest release of its repository's tag series from the registry with WebFetch:
   Docker Hub's tags API (`https://hub.docker.com/v2/repositories/<namespace>/<name>/tags`), or a
   GitHub package page for ghcr.io ([sources.md](sources.md), "Engines"). Give the probed tag, its
   `image created` date, and the newest tag with its date. An engine's image is the engine's
   version, which step 6 judges: list it here with step 6's verdict, by reference. Whether a moving
   tag (`latest`) or the same tag was rebuilt since the pull answers only to a manifest digest,
   which takes a token-bearing read WebFetch can't send; write "not checked" for it, and never pull
   to find out.
7. **Unused images and models taking disk** (`== docker-disk ==`, `== models ==`). The dangling
   images (count and size), each image no container uses (name, tag, size), and the reclaimable
   build cache from `docker system df`. Then each stored model that nothing serves or lists: judge
   it against the router's model list (`== endpoints ==`), the preset's sections, and every
   container's mounts, and give its size and last-modified date. The date is when the file was
   written, not when it was last loaded, so an old date alone doesn't make a model unused. A model
   step 8 ranks as a candidate is not debt. Each removal is hold, with the space it frees.
8. **Configuration that differs from the descriptor.** Compare what the probe shows with what the
   descriptor lists: a purpose nothing is configured to serve (no preset section, no container), a
   section whose slots or per-session context differ from its purpose's load target (rules.md,
   "Load targets"), a watch item that names a setting the probe shows differently, and a preset
   whose keys differ from the flags the router lists for the same model (the router was started
   before the preset changed, or a key doesn't apply). Give both values, cited. Each is hold. The
   descriptor's stale lines are setup's (setup.md, step 1), under "Proposed changes", and not
   repeated here.
9. **A drafter of adversary origin that a preset loads** (the `drafter` lines under `== engines ==`
   and `== endpoints ==`). Judge each drafter named there by the origin rule (models.md, "Origin"),
   as a component outside the output path. One of adversary origin is a host configuration fault,
   not an exclusion: the main model verifies every drafted token, so the drafter can't change what
   is served, and the target model stays eligible in step 8. The item is hold, with the section
   that loads it, cited to the probe, and the fix is removing the drafter's keys from that section
   (a `[*]` section loads it for every model); the rollback is restoring them. The preset belongs
   to whoever owns it, so the fix is a change for that owner. A drafter whose origin passes is
   recorded in its model's row in step 8, and `none` everywhere is one line saying so.
10. **Sessions under their target.** Each section whose per-session context falls under its
    purpose's load target, or an agent section under the policy's minimum per agent session
    (rules.md, "Per-session context"), is hold, listed here by reference to step 6, with the fix
    stated there.

**The system watch items.** Answer each of the descriptor's watch items of this kind (what this
step reads, such as the package channel's snapshot date, a unit, or a container) by name, under its
own heading: what the probe and the sources say now, cited, and what changed since the last report
if there is one. An item that bears on one of the items above is cited in that item.

### Boot-order check

An engine container that binds its port on the tailnet address can't publish it until Tailscale
has assigned that address, and docker may start first at boot. Read each engine container's
`published ports` and `configured binds` lines and both `ip_nonlocal_bind` keys from the probe, and
report each of these, cited to the probe. Each family has its own key: a `tailnet4` bind is judged
against `net.ipv4.ip_nonlocal_bind`, and a `tailnet6` bind against `net.ipv6.ip_nonlocal_bind`.

- **A `tailnet4` or `tailnet6` bind with its family's key 0 (or the IPv6 key `absent`)**: flag that
  a boot where docker starts before Tailscale leaves the container with no published port. The
  remedy is the matching key, `net.ipv4.ip_nonlocal_bind = 1` or `net.ipv6.ip_nonlocal_bind = 1`,
  in a file under `/etc/sysctl.d`, a root step the architect runs (printed as rules.md, "Root",
  prints one, and never run by the survey). Its side effect: any process on the host may then bind
  an address of that family the host doesn't hold yet. Its rollback, also root, is removing the file
  and running `sysctl -w <key>=0`, or rebooting: `sysctl --system` alone leaves the value at 1,
  since it applies only the keys a file sets.
- **A running container whose `published ports` is `none` while its `configured binds` is not**:
  flag that it serves nothing off the host, however healthy docker reports it, which is the
  boot-order failure itself. The recovery depends on the cause, and needs no root either way; the
  architect runs it:
  - `published ports none (no network)`: the container is attached to no network. The recovery is
    `docker network connect bridge <name>`.
  - `published ports none`, still on a network: the start failed to bind. The recovery is
    `docker restart <name>`, once the address exists.

  Either recovery serves the container now; the sysctl remedy above prevents it recurring, so point
  to it. A container configured with no binds (one on the host's network, say) publishes nothing by
  design, and a stopped container publishes nothing either; neither is flagged.
- **A family's key 1**: report the remedy as present for that family, with its side effect.

## 6. Engines

An objective look at the most effective engine setup on the probed hardware, at the load targets
of the purposes the host serves (rules.md, "Load targets").

1. **The incumbent.** Name the engine that serves (or, when nothing serves, the installed engines
   step 2 settled on), with its version, its backend, and its configuration from the probe's
   `flags` lines: context, parallel slots, KV cache (unified or split), batching, offload. Read
   each flag the line doesn't show at its default from the engine's source or docs at the probed
   version, and cite it, naming it a default read rather than a probed value. For each section that
   serves a purpose, compute its per-session context (rules.md, "Per-session context") and set its
   slots and context beside its purpose's load target. A section short of its target, or an agent
   section under the policy's minimum, is hold, with the figure, the target, and the fix stated;
   step 10 checks the fix's memory, and step 5 lists it by reference.
2. **The seed list, filtered to the backend.** Weigh the incumbent against llama.cpp, vLLM,
   SGLang, TensorRT-LLM, and ggml-hrx, keeping only what the probed backend supports: TensorRT-LLM
   only on NVIDIA, and on AMD only what the engine's own docs or published images list for the
   probed gfx target. ggml-hrx is AMD's HRX backend for llama.cpp, built for gfx1100 and gfx1151;
   its published figures measure it against HIP, but it is judged against the backend the host
   serves on, which on Strix Halo is Vulkan, so a gain over HIP is not a gain here. Judge a
   packager (Ollama, LM Studio) by the engine and build it embeds, not as an engine of its own. For
   each engine kept, say whether its newest release supports the backend, how the host would
   install it, and what any attributed benchmark on the same hardware class measured against the
   incumbent, at the concurrency the load targets name where a source gives it.
3. **The scan.** Look each run for emerging capabilities and engines: a backend an engine newly
   supports (vLLM on Vulkan, or on ROCm for the probed gfx target), a change that improves
   concurrent-session throughput at the host's targets, a new engine built for the hardware. A newly
   found engine is weighed in this run like a seed-list engine, and proposed for the seed list
   under "Proposed changes".
4. **The engine watch items.** Answer each of the descriptor's watch items of this kind (an engine,
   a backend, a feature, or a regression) by name, under its own heading: what the sources say now,
   cited, and what changed since the last report if there is one.
5. **The conclusion.** Name the most effective engine platform and configuration to date for the
   host at its load targets: either an adjustment to the incumbent (a version, a backend, a flag) or
   a migration to another engine, with its verdict by the same rules; a newer build of the
   incumbent is never take ("Verdicts"). Then list the other candidates, ordered verify, take,
   hold, skip.

An engine change is judged within how the host installs engines, which the probe shows (a container
from the engine's published image, a systemd unit, a package). A candidate that needs another
install method (building an image locally, installing from source on the host) is skip until the
architect changes the method, and the report says what it would take.

### Verdicts

Every item in steps 4 to 8 takes one of four verdicts:

- **verify**: a source that names its hardware, engine version, and method (an attributed
  benchmark) measured a gain on the same host class and backend, and no such source reports a
  regression. A verify verdict is a reason to measure on this host, not a decision to adopt.
- **take**: a version update of something the host already runs (a package, firmware, an image to
  its tag's newer release, a new revision of a model's file) that claims nothing, has no reported
  regression, and has a known rollback: the previous kernel kept in the boot menu, a package
  downgrade from the cache, or the previous image tag. It needs no measurement first: it is applied
  with the next host update, which keeps the host current. Two rules bound it:
  - A root step with no rollback is hold, never take. Whenever both take and hold seem to apply,
    hold wins.
  - A change to the engine's build is never take, because engine changes go through
    spike-model-engines' `engines` suite with anchors (measure.md). A newer engine build is verify
    or hold, by the rules here. Nor is a change of engine, backend, or model ever take.
- **hold**: the only claim is release notes, or comes from another hardware class, or the upgrade
  needs a root step with no rollback. An agent candidate the policy's agent quality bar can't yet
  place is hold, by the bar's own reading (`docs/policy.md`, "Reading the bar", as
  [models.md](models.md), "Gate 4", applies it). So is a candidate whose speed against its
  purpose's floor is a paper estimate alone (`docs/policy.md`, "Reading the floors", as
  [models.md](models.md), "Gate 5", applies it).
- **skip**: sources show no gain or show a regression, or the upgrade breaks a rule: the policy, or
  an engine change outside how the host installs engines.

Measured slower, but ahead on evals, is hold: an attributed benchmark puts the candidate behind the
incumbent while its card's evals for the purpose put it ahead. Neither verify nor skip fits a trade
between speed and quality, so the survey holds it and names both figures for the architect.

Two attributed sources that disagree on the gain are a pause (rules.md, "Pause"); until the
architect answers, the adjustment is hold.

## 7. Configuration review

Every survey reviews how the host serves, flag by flag, against what others publish for the same
host class and engine, at the load targets of the purposes the host serves (rules.md, "Load
targets"). Step 6 names the incumbent and weighs engines; this step weighs each argument. The
review only proposes: a change is the owner's (the preset belongs to whoever owns it, such as
spike-model-engines), and measure settles it on the host.

1. **What is reviewed.**
   - **Each served section's arguments**: every key of each preset section that serves a purpose
     (the probe's `preset` block, at the commit its `preset clone` line names, which is the
     host's checkout and may differ from the workstation's), with the `[*]` section's keys it
     inherits, and each argument the section leaves at its default where published practice for
     the class names a value (the batch and ubatch, flash attention, the KV cache's type and
     whether it is unified, the prompt cache and its idle-slot saves, the context checkpoints,
     offload, mmap). A default is
     read from the build's own argument list (`common/arg.cpp`, `common/common.h` at the probed
     build) and cited as a default read, not a probed value.
   - **The container's run flags**: the probe's `run flags` and `run env` lines for each engine
     container (GPUs, devices, IPC mode, shared memory, ulimits, memory limits, the network, the
     runtime, and an engine argument set through the environment), and its `flags` line.
   - **The engine choice at the load target**: for each purpose, whether the incumbent engine
     fits the load target as published practice and this host's measurements read it, beside
     each engine step 6 kept: its measured figure at the target's concurrency where a source
     gives one, and its fit at the target's sessions and context. An engine that runs one model
     per process with its own reservation (vLLM's `--gpu-memory-utilization`, its
     `--max-model-len` and `--max-num-seqs`) is set at the purpose's target (the target's
     context per session and its sessions) and its reservation weighed against the policy's
     headroom beside the set's other models (step 10, item 4). A maintainer's stated tuning range
     (a number of parallel sequences the engine optimizes for) is set beside each section's
     slots.
2. **Published practice, by source kind** ([sources.md](sources.md), "Configuration practice"):
   the vendor's playbooks for the class (NVIDIA's DGX Spark playbooks), the engine project's own
   benches on the class (ggml-org's DGX Spark benches, which name their flags), the build's own
   argument list and help text, maintainers' comments on the tracker (`gh issue view <n>
   --json comments`, each comment by its `authorAssociation`: `MEMBER`, `OWNER`, or
   `COLLABORATOR` is a maintainer's, primary; `CONTRIBUTOR` or any other is a lead, as
   [sources.md](sources.md), "Reading a source", tiers it), and on Strix Halo the
   community benches the sources list. Each is read through the research cache. A blocker
   register entry is a source too: a flag that works around an open entry (`cache-ram = 0` for a
   prompt-cache bug) is cited to it, and its removal is proposed only once the entry reaches "fix
   in an image build" and the host can run that build.
3. **One row per flag.** Each row gives the section (or container), the flag, its value now
   (probed, or a default read), the practice and its source (cited, with its tier), what the
   difference means at the purpose's load target, a rank, and a verdict by "Verdicts". A flag
   that matches practice gets one line saying so, cited. A flag no source speaks to is listed as
   "no published practice found", with what was searched.
4. **Rank.** Rank the rows that differ from practice, 1 first, by their evidence and their reach:
   - first, a fault measured on this host (a register entry, a record's finding) that the flag
     causes or would remove
   - then an attributed measurement on the same class and engine showing a gain from the
     practice's value
   - then a maintainer's stated practice or the build's own documentation
   - then a lead
   Within one kind, the agent purpose first, then the purpose with the largest load target, then
   the lower risk (a key in one section, before a key in `[*]`, before a container's run flag).
   The verdicts follow "Verdicts": a flag change with an attributed gain on the class is verify,
   one backed only by a maintainer's word or documentation is hold, and none is take (it changes
   how the engine serves). A row that rests on a measured fault on this host names the record.
5. **What it proposes.** The top-ranked verify row is a candidate for "Verify next" (step 11).
   Every row that would change a document or a preset goes under "Proposed changes" as a change
   for its owner, with its rollback (restoring the key or flag). The review applies nothing.

## 8. Models

The models that could serve each purpose the host serves, judged against the incumbent. The gates
and their checks are in [models.md](models.md); this step says what the section holds.

1. **The incumbents.** For each purpose, the model step 2 mapped to it, with its format and its
   configuration from the `flags` lines and the preset's keys. When nothing serves and the probe
   doesn't show which stored model an engine would load (no router lists it, and no preset section
   names it), the incumbent for a purpose is the stored model mapped to it that ranks first by this
   step's own gates and sort among the stored models, and the report says so.
2. **The candidates.** Every stored model that isn't an incumbent, the newest models of the
   publishers in [sources.md](sources.md), "Models", what a web search finds, and every row of the
   pool (step 1). A model whose card serves several purposes (a multimodal model that takes text,
   images, and audio) is a candidate for each the host serves, and the report says which
   incumbents it would replace.
   **Discovery**, every survey: the models others run on the host class join the candidates, read
   through the research cache: each model the vendor's playbooks for the class name, each model
   the class's bench threads and community benches measure (ggml-org's DGX Spark benches and the
   discussion they link, the vendor's forum, and on Strix Halo the community benches,
   [sources.md](sources.md), "Configuration practice"), and each model a playbook or bench names
   for the engine the host runs. A discovered model is a candidate for each purpose its card
   serves, cites where it was found, and goes through every gate below like any other candidate
   (origin, artifact integrity, the floor, fit at the load target, the engine, the agent bar, and
   speed); a published figure on the class is its speed source. The candidates list says which
   came from discovery, from the publishers, from a search, and from the pool.
3. **The pool's rows.** Every row of the pool, in every purpose's table, is one or more candidates:
   a row that names several models is one candidate per model, and the rows the pool excluded are
   candidates too. Each names the file the host would load today: the exact repository and file,
   its build, and the projector's repository, file, and precision, as [models.md](models.md), "A
   model's row", gives them. When the pool's file fails a gate another file of the same model
   passes (a converter's post-training Q4_0 where the publisher releases a QAT Q4_0, say), the row
   names the file that passes, beside the pool's. A row the pool excluded on an earlier origin rule
   is judged again under today's, by its own evidence chain, and a row the pool admitted is judged
   again too; neither stands on the pool's word. A pool's figures are its class's: on a host of
   another class they are paper estimates. A figure taken from the pool cites the pool's path and
   the source the pool gives for it.
4. **The gates, in order**: the policy (the origin rule, then artifact integrity, then the
   quantization floor, as `docs/policy.md` states them and reads them), a fit in the probed memory
   at the purpose's load target, the host's engine serving the architecture on its backend, for the
   agent purpose the policy's agent quality bar, and the policy's speed floor for the purpose
   ([models.md](models.md), "Gate 5"). A model that fails a gate stops there and is listed with the
   gate it failed and why. The floor takes one of the policy's three paths, settled by the build,
   not the label (the publisher's native or QAT release, the publisher's post-training checkpoint,
   or a third party's conversion), and never by the repository id: a trained-in format passes by
   name with the publisher's quality statement quoted, a publisher's post-training checkpoint passes
   only when every eval its card reports is within the policy's margin of BF16 (the row names any
   outside it), and everything else meets the floor.
5. **Excluded on origin, and origin unclear.** The survey builds each model's evidence chain
   (publisher identity, the publisher's own documents, then artifact checks, as models.md,
   "Origin", gives it), starting from the model's entry in the research cache ("Research cache",
   "Model entries"): a fresh entry's chain is cited, with its read time, and only a stale or
   missing entry, or a level the entry doesn't settle, is read again; each chain built or extended
   replaces the model's entry. A model with any disclosed or detected involvement of an
   adversarial entity at a level the policy excludes on, or a publisher or uploader that fails the policy's compliance
   gate, goes in the section's "excluded on origin" list and never reaches a verdict. Each entry
   names the level and cites, inline, the URL and read date of the source that shows it. A teacher
   is read by its role, not by its label. Involvement at a level the policy only records, and
   adversary-generated data that is one dataset in the training mix (under "dataset sources"), go
   in the model's row, cited, and the model goes on to the next gate. A model the chain leaves short
   of the policy's pass bar, with no involvement found at an excluding level, is researched further
   (the uploader's identity and affiliation, the conversion against the publisher's weights, the
   publisher's own mentions of it, the uploader's other work) until the answer is definitive; a
   model the research brings to the pass bar passes, and its row records the evidence that settled
   it. Only a model the research can't settle (an unidentified publisher, an unestablished lineage,
   a teacher the card doesn't name and the publisher doesn't place in its own pipeline, or sources
   that contradict each other) goes, without a pause, in the "origin unclear" list beside it, and
   never reaches a verdict either. Each entry names what the survey checked, each source cited
   inline. A pass means "no disclosed or detected involvement at an excluding level", and the
   section says so. A model that already fails a later gate (artifact integrity, the floor, fit,
   the engine, the agent bar, the speed floor), shown by a read the survey has made, may stop at
   "not settled" for origin instead of being researched to the end: its row says origin is not
   settled, that the research stopped because the model fails that gate, and names the gate and its
   source (models.md, "Origin"). It is listed under the gate it fails, not under "origin unclear".
6. **Sort and judge.** An agent candidate's card figures must clear the policy's agent quality bar
   before speed sorts it, and the bar decides its verdict until the local tool-reliability check
   runs (`docs/policy.md`, "Reading the bar", as [models.md](models.md), "Gate 4", applies it).
   Models that pass every gate sort by published speed on the same hardware class, at the
   purpose's target concurrency where a source gives it, then by the card's evals for the purpose.
   Each takes a verdict by "Verdicts", with its citations: a model's gain is measured speed on the
   same host class and backend, or a card eval for the purpose, against the incumbent's.

Order each purpose's rows verify, take, hold, skip; within a verdict, by speed, then by evals; a
model that failed a gate is skip and comes after the passing skips. Each row names the exact
repository and file the host would load, its build, and, when the model has a projector (`mmproj`),
the projector's repository, file, and precision, which for a vision or audio model are part of its
precision (models.md, "A model's row"). When a gate needs a policy value the document doesn't
state, pause (rules.md, "Pause").

## 9. Needs measurement

List the candidates step 8 holds only for a measurement no one publishes, by name, each with what
it needs: the BFCL category with no card figure, the tool-reliability check, or a speed floor's
`bench/` cell. The list is the survey's own, read fresh from the gates, never carried from an
earlier report. It is measure's input: a measure takes one of them (measure.md, step 2).

## 10. Model set

The most effective combination of one model per purpose the host serves, which the host can serve
at once.

1. **Place each incumbent in step 8's order.** It ranks below the purpose's verify candidates,
   which an attributed benchmark measured ahead of it, and above its take, hold, and skip
   candidates, which nothing measured ahead of it. The report states each incumbent's place.
2. **The candidates per purpose**: the top three from step 8 that pass every gate, plus the
   incumbent, so at most four per purpose. The report states this bound and how many sets it
   weighed. A model that serves several purposes can fill each of them in one set, and its memory
   counts once. The sets need not be enumerated one by one (four purposes give up to 256): the
   survey may prune on paper, dropping a candidate whose memory at its load target leaves no
   room for the other purposes' smallest choices (item 3), and a set another kept set dominates
   (ranked no better on every purpose and using no less memory, as item 5 compares them). The
   report states each pruning, its rule and what it dropped, beside the count of sets weighed.
3. **Keep the sets that fit together**: the estimated memory of every model in the set, each at its
   purpose's load target (rules.md, "Load targets"), leaves the policy's headroom of the
   GPU-reachable ceiling free. A model serving two purposes is estimated at the more demanding
   purpose's target: the larger context and the more slots of the two. An agent model is estimated
   at a configuration that gives each session at least the policy's minimum context too: a set
   whose agent section leaves a session under it is flagged, hold, with the fix stated, and the
   set is also weighed at the fixed configuration, so the report shows what the minimum costs in
   memory.
4. **Keep the sets the chosen engine can serve side by side**: the engine is step 6's conclusion.
   Either one process holds several models (a llama.cpp router), or each model runs in its own
   process with its own memory reservation (vLLM's `--gpu-memory-utilization`, a share of the whole
   device), and the reservations, not the weights, must fit within the headroom.
5. **Recommend** the most effective set kept: compared first by the agent purpose's model where the
   host serves one (its place in step 8's order, with the incumbent placed as item 1 says), then by
   the other purposes' places summed, then by memory left free. Give its estimated memory, marked
   **estimate** with its method (see [models.md](models.md), "Memory estimate"), why it wins, and
   the runner-up with why it lost. Each entry names the exact repository and file, and its
   projector's repository, file, and precision when it has one. When no set but the incumbents
   fits, say so.

## 11. Verify next

One closing line naming a single verify item from across the sections: the one with the largest
claimed gain on the agent purpose (or, on a host with none, on the purpose with the largest load
target), and among equal claimed gains, the lowest risk first (no root and rolled back by removing
a flag, before a root step with a rollback, before a reboot), with a one-line reason. When that
purpose has no verify item (a host that serves the agent purpose with none on it, say), the line
names the top-ranked verify item of any purpose, by the same order: the largest claimed gain, then
the lowest risk. It names a verify item only, never a take, hold, or skip item. When no item is
verify, the line says so and names nothing.

## 12. Proposed changes

Every change the survey would make to a document it reads, each with its reason, for the architect
to accept or reject one by one. The survey applies none of them. Five lists, each "None" when
empty:

- **Descriptor** (`docs/hosts/<host>.md`): a watch item to add, such as a scan finding worth
  checking each run, or one the probe can't reach (step 2); the descriptor's stale lines (setup.md,
  step 1) and the purposes a discrepancy answer drops (step 2).
- **Trusted sources** ([sources.md](sources.md)): a source found beyond the list that meets its
  tier's bar (step 3).
- **Blocklist** ([blocklist.md](blocklist.md)): a source met in the run that fails a criterion,
  with what was found (step 3).
- **Engine seed list** (step 6): a newly found engine to weigh every run.
- **Policy and the model gates** (`docs/policy.md`, [models.md](models.md)): a value the policy
  lacked and the architect's answer at a pause, a rule a candidate sat on the edge of, and a remedy
  a gate points to that needs a host step (the project's own conversion of a model, say), for a
  task to plan.

## 13. Write the report

The survey writes three files: the dated report at `docs/reports/<host>/<YYYY-MM-DD>.md` (rules.md,
"Dated records"), and, in place, the research cache (`docs/research.md`, "Research cache") and the
blocker register (`docs/blockers.md`, "Blocker register"). A survey reads the last report only to
say what changed, and, when the inventory hasn't moved, to cite for what it didn't research (step
3). It writes nothing else: not the descriptor, the policy, the pool, or the skill, and nothing on
the host. Changes it would make to any of them go into the report as proposals.

The report's sections, in order; within every section, items are ordered verify, take, hold, skip:

```markdown
# <host>: hosting upgrades, <YYYY-MM-DD>

## Inventory
The probe's findings, by section, and the descriptor (its purposes and load targets), the policy,
and the pool (its reference, path, commit, and what it says of itself) the survey read. Says
plainly when nothing serves, and what the survey ranks against instead. Lists the rules the
readiness check found missing (or "none") and the architect's answer, every probe skip, every fact
that needed root (with the architect's read-out or "declined"), and every pause with its answer.
Says whether the inventory matched the last report's, and so whether the survey researched in full
or only what moved, citing that report (step 3). Counts the research cache's entries cited, read
fresh, and deleted, and names the deleted ones.

## Blockers
The register's entries (`docs/blockers.md`) that name this host or its class, each with its state,
its upstream line as checked this run (with the image script's lines for a merged fix), its last
checked date, and what moved since the last report; an entry now at "fix in an image build" names
the upgrade item it became.

## Hardware configuration
Step 4's adjustments, then each hardware watch item by name.

## System updates and debt
Step 5's items: pending package updates (with the lists' age), firmware updates, the kernel and a
pending reboot, failed units and services meant to run, the boot-order check, container images
behind their tag, unused images and models taking disk, configuration that differs from the
descriptor, a drafter of adversary origin a preset loads, and sessions under their target, each
with its verdict and sources; then each system watch item by name.

## Engines
Step 6: the incumbent with each section beside its purpose's load target, the seed list, the scan,
each engine watch item by name, and the conclusion.

## Configuration review
Step 7: per purpose, each served section's arguments, then each engine container's run flags and
environment, then the engine choice at the load target, one row per flag (its value now, the
practice and its source, what it means at the load target, its rank, and its verdict), the rows
that differ from practice ordered by rank; then the flags that match practice, one line each.

## Models
Step 8: per purpose, the incumbent and its candidates (the pool's rows among them, with the pool's
file beside the one the host would load where they differ), each with its exact repository and file
(and its projector's repository, file, and precision), gates, speed, evals, and verdict; then the
models excluded on origin, and beside them the models of unclear origin with what the survey
checked.

## Needs measurement
Step 9's list, each candidate with what it needs.

## Model set
Step 10: the bound on candidates per purpose, the sets weighed and kept, the recommended set with
each entry's exact repository and file (and projector) and its estimated memory at the load
targets, why it wins, and the runner-up.

## Verify next
Step 11's one line.

## Proposed changes
Step 12's five lists.

## Sources
Every source cited, with its tier, URL, and read date.
```

## Research

Step 3's research is large enough that a survey may split it across subagents. When it does, it
splits it into these five parts, so that runs are repeatable:

1. **Hardware and system**: the OS image, kernel, firmware, BIOS, driver or Mesa, and memory
   ceiling (step 4), and the system's pending updates, firmware updates, and container images'
   newest tags (step 5), with the hardware and system watch items.
2. **Engines**: the incumbent engine, the seed list, the scan, and the engine watch items (step 6),
   and the configuration review's published practice for each flag and engine choice (step 7).
3. **Agent models**: where the host serves the agent purpose, its candidates (the pool's agent rows
   and the discovered models among them), their speed on the class, and their cards' BFCL figures
   against the policy's agent quality bar, each with its gap (step 8).
4. **Other models**: every other purpose's candidates, the discovered models among them (step 8).
5. **Origin**: the evidence chain for every model the model parts name (models.md, "Origin"),
   from each model's entry in the research cache: a fresh entry is cited, not re-read, and the
   part returns a model entry for each chain it built or extended.

**A second, narrower round.** The model parts find candidates as they go, so some reach the survey
after the origin part has started, or after it has returned. When parts 3 and 4 have returned, the
survey lists every model they name that the origin part's return doesn't cover, and sends only
those to the origin part again, with the same inputs and tools. So every model step 8 ranks has an
origin chain, and none is left "origin unclear" only because nobody researched it. The second round
researches origin alone; a gap it finds in another part's work (a model nobody researched for
speed, a config a memory estimate needs) is closed by a read of the survey's own, cited as any
other.

**What each part gets.**

- Its inputs: the probe's inventory, the host descriptor (with its load targets), the policy, the
  pool's rows for a model part, and the research cache's entries for its kind (for the model and
  origin parts, the model entries), each with whether
  it is fresh ("Research cache"), so a part reads only the stale and the new. A part returns each
  source it read as an entry for the cache; the survey writes the cache. The register's upstream
  checks are the survey's own, not a part's.
- The source tiers and the sources for its kind, from [sources.md](sources.md), and the blocklist
  ([blocklist.md](blocklist.md)).
- The tools it may use: WebSearch, WebFetch, `gh search issues`, `gh search prs`, `gh issue view`,
  and `gh pr view`. The origin
  part may also run the screening-list script. The origin part and the model parts (3 and 4), which
  check each file's artifact integrity, may also run the first-bytes script. Each script runs from
  the project root by exactly the path its readiness rule names, with each argument quoted:
  `.claude/skills/hosting-upgrades/scripts/screen.sh "<name>" ...` (models.md, "Origin", item 1)
  and `.claude/skills/hosting-upgrades/scripts/magic.sh "<org>/<repo>" "<file>"` (models.md,
  "Artifact integrity", item 2). The screening list's "no match" is never "clean", and magic.sh
  can't tell safetensors from 4 bytes ([sources.md](sources.md), "Origin and build checks").

**What each part returns.** Cited claims, each with its source's URL, its read date, and its tier,
in the form rules.md, "Citing", gives. The survey, not the part, gives verdicts.

**No curl.** No subagent uses curl or jq through Bash: the readiness check prints no rule for them,
so they would run outside the rules the architect granted. Data too large for WebFetch, or behind a
header or a redirect WebFetch can't handle, goes through a narrow script bundled with the skill,
which reads one source and is granted by its own rule, naming its path. There are three:
`scripts/screen.sh` reads the screening list, `scripts/magic.sh` reads a Hub file's first 4 bytes
past the xet CDN's 302, and `scripts/fix-in-image.sh` reads ghcr.io's tag list with a pull token
and GitHub's compare ("Blocker register"). With the probe, they hold the survey's only curl;
measure's step helpers (measure.md, "Step helpers") carry their own, run in the architect's view.
