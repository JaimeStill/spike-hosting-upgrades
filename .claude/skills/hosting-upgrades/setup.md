# Setup

What every mode runs first. `/hosting-upgrades setup` runs the readiness check alone, for every
host and both modes, and stops. `survey <host>` and `measure <host>` run all three steps below,
with their own mode's rules, before anything else.

## 1. Load the inputs

1. Take the host from `$1`. With none, list the descriptors in `docs/hosts/` by their short names,
   ask which host to run on, and run on one host only.
2. Read `docs/hosts/<host>.md`. If it is absent, stop and say so: "No descriptor for `<host>` in
   `docs/hosts/`, so the run has no purposes or load targets to judge against; write one from the
   skill's `templates/host.md` and run again." Name the descriptors that do exist.
3. Read `docs/policy.md`. If it is absent, stop and say so: "The project has no policy document
   (`docs/policy.md`), so no candidate can be judged against the model-origin rule, the
   quantization floor, or the memory headroom; write one from the skill's `templates/policy.md`
   and run again."
4. Read each purpose's load target from the descriptor's Purposes (rules.md, "Load targets"). A
   purpose with none is a pause, a policy question (rules.md, "Pause").
5. If the descriptor holds anything beyond its sections and the sources its load targets cite (a
   model it declares, an engine version, a memory figure), treat it as stale: the probe decides
   those facts, and the survey notes the extra lines under "Proposed changes".

When a step needs a policy value the document doesn't state (a floor for a kind of model it doesn't
name, a headroom it leaves open), the run asks the architect for the value and records the answer
as the architect's, never inventing one.

## 2. Readiness check

A run's tools need permission rules in the project's settings, or each use asks. The check works
out the rules the mode needs, finds the ones missing, and prints them for the architect to add. It
never writes a settings file. The skill's frontmatter grants no tools: a skill's grant clears when
the user sends their next message, so an interactive run would lose it at its first pause, and the
durable grants are these settings rules.

1. **Work out the rules.** The probe path is the project-relative one step 3 runs
   (`.claude/skills/hosting-upgrades/scripts/probe.sh` here). **Survey's rules**:
   - one exact rule per host with a descriptor in `docs/hosts/`, named by the descriptor's SSH
     short name: `Bash(ssh <host> bash -s < <probe path>)`
   - `Bash(gh search issues *)` and `Bash(gh search prs *)`
   - `WebSearch`
   - `WebFetch`
   - `Edit(docs/reports/**)`, for the dated report; an Edit rule covers creating a file too
   - `Bash(.claude/skills/hosting-upgrades/scripts/screen.sh *)`, for the screening-list script
     the origin research runs (models.md, "Origin"); like the probe rule, it names the script's
     project-relative path, the one the run invokes it by
   - `Bash(.claude/skills/hosting-upgrades/scripts/magic.sh *)`, for the first-bytes script the
     artifact integrity check runs (models.md, "Artifact integrity"), named the same way; the
     script takes a repository and a file, never a URL, so the rule can fetch nothing but a file
     on the Hub
   - one rule per pool a descriptor names, for reading it outside the project:
     `Read(<the pool's absolute path>)`, written with `~/` for a path under the home directory. It
     names the architect's own checkout, so it belongs in `.claude/settings.local.json`
   - `Bash(gh issue view *)` and `Bash(gh pr view *)`, for the blocker register's upstream checks
     and a maintainer's comments (survey.md, "Blocker register"); both only read
   - `Bash(.claude/skills/hosting-upgrades/scripts/fix-in-image.sh *)`, for the script that reads
     whether a merged fix is in the newest build with an image for a host class (survey.md,
     "Blocker register"), named the same way; it takes a repository, a fix, and a class, never a
     URL, and its own `gh api` and registry reads are GETs
   - `Edit(docs/research.md)` and `Edit(docs/blockers.md)`, for the research cache and the blocker
     register, which a survey updates in place and a measure's re-check updates too

   **Measure's rules** are every one of survey's (its probe, and its gate re-checks' reads and
   scripts), and these beside them:
   - one exact rule per host with a descriptor, named by its SSH short name:
     `Bash(tailscale ping -c 1 <host>)`, for the network path each pass records (rules.md,
     "Cells")
   - `Edit(docs/measures/**)`, for the dated measure record, the mode's own write

   Reading the project's own files needs no rule.
2. **Read the settings.** Read `.claude/settings.json` and `.claude/settings.local.json` at the
   project root; either may be missing, which is no error. A rule is present when either file's
   `permissions.allow` holds it exactly as written above.
3. **Print what is missing.** For each rule missing from both, print the exact JSON to add under
   `permissions.allow`, and name the file it belongs in: `.claude/settings.json` when the skill
   lives inside the project, so the rules are committed beside it, and
   `.claude/settings.local.json` when the skill is installed outside it, since its absolute probe
   path is the architect's own (a pool's `Read` rule always goes in the local file). `setup` prints
   survey's set, then measure's own rules, each marked present or missing, then the JSON for every
   rule missing from either. A mode prints its own set the same way. For example:

   ```text
   Readiness check, survey's rules: 14 of 15 present.
     present  "Bash(ssh framework bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh)"
     ...
     missing  "Read(~/experiments/spike-model-hosting/docs/pool.md)"
   Readiness check, measure's rules (survey's 15, and these): 1 missing.
     present  "Bash(tailscale ping -c 1 framework)"
     present  "Bash(tailscale ping -c 1 gb10-1)"
     missing  "Edit(docs/measures/**)"
   Add to .claude/settings.json, under permissions.allow:

     "Edit(docs/measures/**)"

   Add to .claude/settings.local.json, under permissions.allow:

     "Read(~/experiments/spike-model-hosting/docs/pool.md)"
   ```
4. **Ask.** When a rule is missing, ask whether to continue with the prompts the missing rules
   bring, or wait while the architect adds them; the default is to wait. When none is missing, say
   so and go on. `setup` asks nothing: it stops once it has printed. The mode's record lists the
   rules the check found missing (or "none") and the answer.

Three rules the check never prints:

- **No rule for `gh api`.** Settings rules apply to every agent in the workspace, not only to this
  skill, and `gh api` writes as readily as it reads (`-X POST`, `-f`), with the architect's GitHub
  token. So a `gh api` call, the fallback once unauthenticated reads run out, asks each time. The
  register's reads that need it (the releases list and the compare) run inside
  `scripts/fix-in-image.sh`, whose own rule grants only those GETs; `gh issue view` and
  `gh pr view` only read, so they get rules of their own.
- **No wildcard ssh host.** A rule such as `Bash(ssh * bash -s < <probe path>)` also matches ssh
  options riding along in the wildcard (`-o ProxyCommand=<any command>` runs that command on this
  machine), so each host gets its own exact rule, and a new host's descriptor brings a new rule
  through `setup`. The rule names the probe path literally, because settings rules don't expand
  `${CLAUDE_SKILL_DIR}`.
- **No rule for a command measure prints.** The commands that apply or remove an item, load or
  unload a model, move an engine, or run a cell (`sudo`, `docker`, `hf`, `curl`, `guidellm`,
  `git push`, the agent tiers, any ssh beyond the probe) change the host or load it. Each is run in
  the architect's view, by whoever rules.md, "Who runs what", assigns it, and asks each time.
  That holds for measure's step helpers too (measure.md, "Step helpers"): no rule names
  `scripts/measure-lib.sh`, since a command that sources it runs whatever follows the `source`,
  and its `load`, `unload`, `cell`, `tier`, `conform`, `gate` and `watch` load the host. Each
  call asks, and the prompt shows the step it runs. Their read-only calls (`memory`, `readout`,
  `summarize`, `image`, `loaded`) ask too, since they ride in the same sourced shell. The helpers
  need nothing beyond what measure already uses: bash, curl, jq, ssh, and GuideLLM through
  `mise.bench.toml`. Their command log goes to ignored `.state/measure/<host>/`.

## 3. Probe

Run the bundled probe on the host over SSH, from the project root, by its project-relative path,
exactly as:

```sh
ssh <host> bash -s < .claude/skills/hosting-upgrades/scripts/probe.sh
```

`<host>` is the descriptor's SSH short name. The command is the literal one the readiness check's
ssh rule names, with no prefix (`timeout`) and no redirect, so the rule matches it and the run asks
no permission. Where the skill lives elsewhere, the probe path is `${CLAUDE_SKILL_DIR}` relative to
`${CLAUDE_PROJECT_DIR}`, followed by `/scripts/probe.sh`; when the skill is installed outside the
project, it is the probe's absolute path. Write the path out in the command: settings rules don't
expand `${CLAUDE_SKILL_DIR}`, so a command that names the variable matches no rule.

- If SSH fails, stop and say the host is unreachable, quoting the error. Don't work around it.
- If the probe's output is incomplete (a section is missing, or docker reports no permission), say
  which sections are missing and ask whether to continue without them.

**What it prints.** [scripts/probe.sh](scripts/probe.sh) is read-only and needs no root. It prints
labeled sections (`== os ==`, `== kernel ==`, `== firmware ==`, `== gpu ==`, `== memory ==`,
`== container-runtime ==`, `== engines ==`, `== endpoints ==`, `== models ==`, `== updates ==`,
`== firmware-updates ==`, `== units ==`, `== docker-disk ==`, `== skipped ==`).

- **Flags.** Each engine container, and each model a llama.cpp router lists, carries a `flags`
  line: its launch arguments filtered to the ones that shape serving (context, parallel slots,
  batching, KV cache and its checkpoints, offload, memory, sampling), which is the incumbent's
  configuration the survey weighs against each purpose's load target.
- **Presets.** A container that mounts a preset (a llama.cpp router's `models.ini`, mounted at
  `/etc/llama-preset`) carries a `preset` block: each file's shape (sections, keys, lines the probe
  couldn't read), then each section, by the model name the router lists, with its keys through the
  same filter: the block names the mount's path inside the container and each file's name, and no
  key outside the filter prints its value. A flag neither line shows was not passed, and is at the
  engine's default unless it was set another way the probe doesn't read (an environment variable
  such as `LLAMA_ARG_CTX_SIZE`, a config file); a flag outside the filter's list doesn't show
  either.
- **Run flags.** Each engine container also carries a `run flags` line: the flags `docker run`
  took that shape serving beside the engine's arguments, in `docker run`'s terms (`--gpus`,
  `--device`, `--ipc`, `--shm-size`, `--ulimit`, memory and CPU limits, `--network`,
  `--runtime`, `--privileged`, `--cap-add`, `--group-add`), each only when it differs from
  docker's default, or `docker's defaults`. A `run env` line gives each environment variable the
  run set beyond the image's: an engine or GPU-stack variable (`LLAMA_ARG_`, `VLLM_`, `GGML_`,
  `CUDA_`, `NVIDIA_`, `HIP_`, `HSA_`, `ROCR_`, `OMP_`) as `NAME=value` when its name names no
  secret, address, model, or path and its value is short and plain, and any other by name alone,
  `(value not shown)`. The configuration review reads both (survey.md, step 7).
- **Drafters.** Each container, each preset section, and each model a router lists also carries a
  `drafter` line: the drafter models its arguments load for speculative decoding, each by its file
  or repository name only, or `none`, then in parentheses any other speculative key by name; a
  `[*]` section's drafter loads with every model. A drafter key whose value the probe couldn't read
  shows as `<key> (value unread)`, never as `none`. Each container also carries its
  `restart policy`.
- **Debt.** `== updates ==`, `== firmware-updates ==`, `== units ==`, and `== docker-disk ==` are
  what the host has fallen behind on, and `== models ==` gives each stored model's size and
  last-modified date.
- **Magic.** `== models ==` also carries a `magic` line for each GGUF file in a store: its first 4
  bytes, as hex and as text (a byte outside printable ASCII shows as `.`), and its path in the store
  (in a Hugging Face cache, `models--<org>--<repo>/snapshots/<revision>/<file>`, read through the
  cache's link to its blob). Those bytes settle a stored file's format (models.md, "Artifact
  integrity"). A file the probe can't read shows `magic unreadable without root`, and a link whose
  blob is gone `magic missing (a broken link)`; neither settles the format.
- **Package sources.** `== updates ==` opens with where the host's packages come from. On Arch,
  `mirror:` lines give the mirrorlist's servers and `repo <name>:` lines each repository
  pacman.conf names, with its server or included list. On Omarchy, `omarchy channel:` lines say
  which channel's template (`stable`, `rc`, `edge`) the mirrorlist and pacman.conf each still match
  and which of `omarchy` or `omarchy-dev` is installed: Omarchy records no channel of its own, so
  the templates are how it is read. On apt, an `apt source` line gives each source's URIs and
  suites, from one-line `.list` files and deb822 `.sources` files alike.
- **Ports.** Each engine container also carries a `published ports` line (what it publishes now,
  or `none`, and `none (no network)` when it is on no network) and a `configured binds` line (the
  bindings it was created with), each port named by its bind class: `tailnet4` (the tailnet IPv4
  address), `tailnet6` (the tailnet IPv6 address), `all`, `loopback`, or `other`.
  `== container-runtime ==` prints `net.ipv4.ip_nonlocal_bind` and `net.ipv6.ip_nonlocal_bind`
  (`absent` on a kernel without IPv6). The survey's boot-order check reads them all.

A probe whose command is absent on the host prints `skipped:` and the probe goes on; a skip is a
fact too, and the record keeps it. The probe prints no network address: it reads listening ports
from `ss -Hltn` and `docker port` and drops the address from each, and a final guard redacts any
IPv4 address, tailnet IPv6 address, or MagicDNS name that slips through, so its output can go into
a record as is.
