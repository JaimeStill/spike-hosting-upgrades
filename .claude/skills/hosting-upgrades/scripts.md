# The bundled scripts

This page gives the reasoning behind the skill's bundled scripts in [scripts/](scripts/) that
their names and headers don't carry, one section per script, for whoever changes a script. A run
never loads it; the mode files say how a run uses each script. Each script's header says what the
script does and how it is run, and points at its section here with a `See` line.

## probe.sh

[scripts/probe.sh](scripts/probe.sh) runs on the host, read-only and without root. What it prints
is in [setup.md](setup.md), "Probe".

- **One function.** The probe is one function, `probe`, called on the script's last line with
  standard input from `/dev/null`: `bash -s` reads the script from standard input, so a command
  that reads it (`docker exec`) would otherwise eat the rest of the script. The helpers and the
  sections are functions defined before it; the state the sections share (the skips, whether
  docker answered, the container names, the preset clones already printed) is `probe`'s locals.
- **No address.** It never calls sudo, and runs no `ip`, `tailscale`, or `hostname -I`. It reads
  listening ports from `ss -Hltn` and `docker port` and drops the address from each, and gives a
  container's published and configured ports by bind class, never by address. Engine endpoints
  are reached on 127.0.0.1 only, from the host or from inside the engine's container.
- **Bind classes.** `tailnet4` is 100.64.0.0/10, `tailnet6` fd7a:115c:a1e0::/48, `all` 0.0.0.0,
  `::` or no address given, `loopback` 127.0.0.0/8 or `::1`, and anything else `other`; an
  IPv4-mapped IPv6 address classes as its IPv4 address. The family matters because each has its
  own `ip_nonlocal_bind` key, whose 1 lets a container that binds the tailnet address of that
  family start before Tailscale has assigned it; the IPv6 key is absent on a kernel without IPv6.
  The address is dropped before anything prints; the redact guard is the backstop.
- **The guard.** `redact` removes every IPv4 address, tailnet IPv6 address (fd7a:115c:a1e0::/48),
  and MagicDNS name or suffix still in the output. A `package:` or `update:` line comes from the
  package database, and its four-part versions (vulkan-icd-loader 1.4.363.0) read as addresses,
  so only tailnet addresses are redacted there; every other line loses every IPv4 address, version
  or not. An address ending a sentence ("10.0.0.1.") is still an address: only a dot followed by a
  digit makes it part of a longer version. Hex and DNS names are matched in either case.
- **The home directory.** `home_to_tilde` prints the remote user's `$HOME` as `~` on every line:
  mount sources, stores, and any other path. The match is a literal string, never a regex built
  from `$HOME`, and only a whole path component counts: /home/jaime matches in /home/jaime/models
  and on its own, not in /home/jaimex or /data/home/jaime. An empty home, or /, replaces nothing.
- **Serving flags.** `serving_flags` prints only the flags that shape serving, each with its
  value, so no model path, address, alias, or key on a command line reaches the output. It reads
  both `--flag value` and `--flag=value`. An argument with spaces that is not a flag or JSON is a
  shell-form command line (`sh -c "llama-server ..."`), and its words are read as arguments; the
  `-c` before it belongs to the shell, not to the context size (whose value has no spaces), so it
  is dropped, never read with the first word. A preset key reaches the filter as `--<key>`, so a
  short key (`c`, `np`) arrives as `--c` and is read as its short flag.
- **Run flags.** `run_flags`' docker template only prints fields and compares none: a docker that
  decodes inspect's JSON into untyped values (29.6.2 reads `.Count` as a json.Number) fails any
  comparison against a literal, so awk reads the count (-1 is all). A value at docker's default
  doesn't print. A read that fails still prints both lines, as "not readable" with docker's first
  error line, so a missing line never passes for a clean one. An environment variable counts as
  the run's when it is in the container's environment but not its image's; the `run env` line
  joins them with "; ", since a value may hold a comma (`CUDA_VISIBLE_DEVICES=0,1`). So the review
  reads an engine flag set through the environment (`LLAMA_ARG_CTX_SIZE`) and never a token.
- **Drafters.** `drafters` prints each drafter by its name only, never by a path, so a run can
  check that no preset loads an excluded drafter. The file keys are llama.cpp's
  `--spec-draft-model`, `-md` and `--model-draft` (as named at b11669), whose value prints by its
  file name; the repository keys are `--spec-draft-hf`, `-hfd`, `-hfrd`, `--hf-repo-draft` and
  vLLM's `--speculative-model`; the "model" in vLLM's `--speculative-config` JSON prints as either,
  by its form. A path (absolute, home, relative, or a URL) or a model file prints by its last part.
  A shell-form command line is read word by word, except a value that follows a drafter key or
  `--speculative-config`. A short preset key (`md`) arrives as `--md`.
- **Presets.** A preset is a mount whose source or destination names one, read from its
  host-side source without root: a file, or each file in a directory. A llama.cpp router's
  `--models-preset` INI has `[section]` headers, each a model the router lists or `[*]` for every
  model, over `key = value` lines whose keys are the long flag names without their dashes; a key
  may also be a flag (`--ctx-size`) or its environment name (`LLAMA_ARG_CTX_SIZE`), both read as
  the flag. Each section's keys go through `serving_flags`, so no key outside the filter prints its
  value, and a section whose name is a path prints by its last part. A line in no form is counted
  as unread, never printed. A preset file is read only under 1 MiB: a preset is small, and
  anything larger is not one. A directory's links are followed, since a preset directory may link
  its files from elsewhere; with no file to read, each entry prints by its name and kind, in find's
  letters (f file, d directory, l link, and through a link N for a missing target), never a link's
  target, which is a path.
- **The preset clone** prints once per clone, so the configuration review reads the preset the
  host serves, at the host's commit. `GIT_OPTIONAL_LOCKS=0` keeps `git status` from refreshing the
  index, so the read writes nothing.
- **Fields left out.** DGX OS's release file names the software build and OTA version; its serial
  number stays out. Only the world-readable DMI fields print; the serial-number fields need root.
  fwupd's devices print by name and version only, with no serial numbers or device IDs, and its
  metadata is never refreshed; "no updates" is an answer, not a skip.
- **A pending reboot.** Debian and Ubuntu leave a marker; elsewhere an upgraded kernel removes the
  running one's module tree, which says a reboot is pending just as well.
- **Unified memory.** GB10's GPU shares the system memory and nvidia-smi reports none of it, so its
  ceiling is MemTotal and MemAvailable.
- **A container's ports.** A running container that publishes nothing, or has no network at all,
  is the boot-order failure: healthy, but unreachable. A restart policy that restarts (always,
  unless-stopped) says the container is meant to run.
- **Endpoints.** A running container's published port is reached on 127.0.0.1 at its host port,
  or, when the binding excludes loopback (a tailnet-only bind), at its container port from inside
  the container. docker lists a port once per address family, so each is probed once. Every other
  listening TCP port is then tried, for engines run outside containers; only its port is read. A
  router's model list carries each model's launch arguments, of which only the serving flags print.
- **Model stores.** The common stores, plus every directory an engine container mounts. A GGUF
  file's first 4 bytes print as hex and as text with every byte outside printable ASCII shown as
  ".", so a pickle's 80 02 can't garble the output; the bytes say what a file is, whatever its
  name claims. In a Hugging Face cache each snapshot's GGUF files, in its top directory or a quant's
  subdirectory, are read by the link's path, through the link to its blob, never by the blob's
  path; the path in the store is matched after `find`, so a store whose name holds a glob
  character still matches. In any other store a file's last-modified date is when it was written:
  a model can sit unused long after.
- **Package sources.** Pending updates are read against the channel and mirror that offer them.
  Omarchy records no channel: `omarchy-channel-set` (basecamp/omarchy v4.0.6) runs
  `omarchy-refresh-pacman`, which copies the channel's templates
  (`default/pacman/mirrorlist-<channel>` and `pacman-<channel>.conf`) over
  `/etc/pacman.d/mirrorlist` and `/etc/pacman.conf`, and installs `omarchy` for stable and rc,
  `omarchy-dev` for edge and dev. So the channel is read from which template each file still
  matches byte for byte, and from the package installed. An apt source's bracketed options
  (`[signed-by=...]`) are dropped; a deb822 file's stanzas are split by blank lines, and one with
  `Enabled: no` is listed as disabled. These lines take the guard as any other: a mirror is a
  public name, but an address in one is redacted.
- **Pending updates** are read without root and without refreshing anything root keeps: apt's
  cached lists (`apt-get update` is root's, and never run), whose lines read
  `name/suite new-version arch [upgradable from: old-version]`, or Arch's `checkupdates`, which
  syncs a temporary copy of the databases as this user. Only a line in `checkupdates`' own form
  (`name old -> new`) is an update, so a warning on standard error never takes the `update:` prefix
  and its exemption from the IPv4 guard.
- **Failed units** are the system's and the user's; an engine's own units, enabled or not, are
  under `== engines ==`.
- **Docker's disk.** Dangling images are the untagged layers a newer pull left behind; the unused
  ones are the tagged images no container, running or stopped, was made from.

## measure-lib.sh

[scripts/measure-lib.sh](scripts/measure-lib.sh), sourced. The helpers and the command log are in
[measure.md](measure.md), "Step helpers" and "The command log".

- **The serving arguments** `load` prints are the flags that name how a section serves: slots,
  context, the prompt cache and its checkpoints.
- **The sample** runs on the host and prints one line: the memory available to the GPU in MiB and
  where it is read (GTT free on an amdgpu card, MemAvailable otherwise), then the GPU's clocks and
  limits. It reads only what an unprivileged user can.
- **Quiet stretches.** `_measure_quiet` turns xtrace off for a poll or a sampling loop, leaving one
  traced line that says what it does; `_measure_trace_on` turns it back on if it was. A helper
  called inside a quiet stretch adds nothing to the log.
- **The marking.** Every helper opens with the same case on the shell's flags and
  `_measure_marking`, so that what it prints lands in the log once, under the outermost helper's
  name:
  - `*x*:`: the log is on and no helper is marking: run the helper again under `_measure_marked`,
    in a pipe's subshell (no helper sets state its caller reads);
  - `*:on`: that rerun, entered with xtrace off: mark it inside, turn xtrace back on, and go on;
  - `*:off`: (the helpers that load the host) sourced with `MEASURE_LOG=off`: refuse;
  - otherwise a helper inside a marked one, or the log stopped: just run.

  Of the marking, the log holds the case's first line, `_measure_marked`'s call and its two
  lines, and the helper's return; `_measure_lines` runs untraced. `local -` turns xtrace back on
  when `_measure_marked` returns, an interrupt included. `_measure_lines` copies its input to
  standard output unchanged, and each non-empty line to the log through the xtrace descriptor, so
  it sits among the commands in order.
- **Waiting.** `_measure_wait` polls the router's `/models` every 3 s for the section's status
  (loaded, loading, unloaded, or failed), and returns 1 on a failed load or after
  `MEASURE_LOAD_WAIT` seconds.
- **Routing.** The 50 connects log one line, not one each.
- **The decode rate** `readout` gives is that of replies of 90 tokens or more, from the router's
  per-request timings.
- **Stopping a run** under the memory floor kills the process and every descendant, deepest first.
- **A tier cut short** keeps its list's header (tier, dataset, seed) above its first N samples.
- **Summaries.** A cell's summary has one line per benchmark (a sweep level is one); "full"
  checks the scenario's `max_requests` against the successful count. A tier's Inspect log gives
  samples done and passing, the sample times, the largest reply, and the replies that stopped at a
  token or context limit (cap hits). The watch's GPU readings, clocks and throttle reasons, print
  each distinct reading with its count.
- **The image check** is the registry's manifest check: an anonymous pull token, as
  fix-in-image.sh takes, then a HEAD of the tag's manifest, 200 for a published image and 404 for
  none.
- **The prompt's hooks.** In an interactive shell the prompt's hooks (`PROMPT_COMMAND`'s entries
  and the functions they call, PS0's command substitutions) would otherwise run traced after every
  command, a hundred lines of them a prompt. `_measure_prompt_hooks` puts `set +x` first in
  `PROMPT_COMMAND`, its one line the only one the prompt logs, and `_MEASURE_ARM` last, which sets
  a DEBUG trap, after any DEBUG trap already set, for the first command of the next line typed.
  PS0, which bash expands only for a line with a command, marks that line (`_measure_typed`, set by
  an arithmetic expansion in the shell itself, as starship sets its start time), so the trap does
  nothing for the prompt's own hooks after an empty line. On the line's first command the trap puts
  the earlier trap back and `_measure_resume` turns xtrace on again while the log is on
  (`_measure_logging`). The prompt can't tell whether the line before it ended with xtrace off, so
  the log's state is the flag's: sourcing sets it, `MEASURE_LOG=off` clears it, and a line that
  starts with `set +x` or `set -x` stops or resumes it, as the same command does in a
  non-interactive shell.
- **The traps** are set at the top level, not in a function: a function (without functrace)
  neither sees the DEBUG trap set outside it nor keeps one it sets over one that was.
  `_measure_arm`, given `trap -p DEBUG`, sets `_measure_trap` to the trap `_MEASURE_ARM` sets, or
  returns 1 when it is still set (after an empty line); `trap -p` prints
  `trap -- '<command>' DEBUG`, and `set --` takes its words apart in that function only. The trap
  it builds returns 0 either way: under extdebug a DEBUG trap that returns nonzero skips the
  command. `_measure_resume` turns xtrace on last, so nothing after it is traced; a `set +x` is
  traced, so the log shows where it stopped.
- **Read-only sourcing** opens no log, and turns xtrace off if an earlier sourcing in the shell
  turned it on.

## fix-in-image.sh

[scripts/fix-in-image.sh](scripts/fix-in-image.sh). How the survey reads its answer is in
[survey.md](survey.md), "Blocker register".

- **The fix.** A pull request's state and merge commit come from
  `gh pr view --json state,mergedAt,mergeCommit`; a pull request that isn't merged stops there,
  since no build can carry it. A commit is taken as given.
- **The newest imaged build** is the highest `<N>` among the `server-<flavor>-b<N>` tags in
  ghcr.io's tag list for the image, read whole: the registry's `/v2/<repo>/tags/list`, a GET, a
  page at a time by its Link header (`rel="next"`, a path on ghcr.io; the last page has none). The
  200-page bound stops a registry that never ends its list. The registry needs an anonymous pull
  token sent as a header, which WebFetch can't send, so the script fetches it with curl, as
  spike-model-engines' `scripts/currency.sh` does. It reads the tag list, not the releases list,
  because an image can be published for a build with no GitHub release (server-cuda13-b12169 had
  none); llama.cpp publishes images only nightly and on manual runs, so its newest release often
  has none either. The git tag `b<N>` exists either way, and the compare reads it.
- **The flavors** are those spike-model-engines' `scripts/currency.sh` reads for each class:
  cuda13 for gb10, vulkan for strix-halo.
- **The compare** is GitHub's compare API,
  `gh api repos/<owner>/<repo>/compare/<fix>...<build>`: the build carries the fix when its status
  is "ahead" or "identical", and not when it is "behind" or "diverged".
- **No write.** `gh api` runs with `--method GET` and no fields, and curl only reads the token and
  the tag list.
- **The locale.** The allowlist's ranges mean ASCII only in the C locale, so the script sets
  `LC_ALL=C`.

## magic.sh

[scripts/magic.sh](scripts/magic.sh). How the gate reads its answer is in
[models.md](models.md), "Artifact integrity".

- **No URL.** It takes a repository and a file path, never a URL, and builds the resolve URL
  itself, so its permission rule can fetch nothing but a file on the Hub. Both arguments are
  checked against the allowlist first: no scheme, no "..", no leading "/", no query string, and no
  whitespace. Each part starts with a letter, digit, or "_", so no part is "." or "..", and nothing
  can start a scheme (":" is never allowed), a query ("?"), or a fragment ("#").
- **The locale.** The allowlist's ranges mean ASCII only in the C locale: in a UTF-8 locale bash's
  `[A-Za-z]` also matches letters such as "é" and "İ", which would then reach the URL.
- **The read** is a ranged request for bytes 0-3 that follows redirects, since the Hub answers a
  file's resolve URL with a 302 to the xet CDN. `--max-filesize` stops a server that ignores the
  range from sending the whole file: a ranged answer is 4 bytes long, and a full one names the
  file's size, so curl refuses it (exit 63). `-q`, first, keeps a `~/.curlrc` from adding options.
  `first_4_bytes_hex` returns curl's status, which the pipeline would otherwise hide.
- **A long answer.** A ranged answer is exactly 4 bytes; more means the range was ignored, and the
  first 4 still name the format, so only a short read fails.

## screen.sh

[scripts/screen.sh](scripts/screen.sh). How the origin gate reads its answer is in
[models.md](models.md), "Origin".

- **Once a day.** Every call after the day's download reads that file, so running it again changes
  nothing; a new day's download replaces the older files. The download goes to a temporary name
  and moves into place only once it is whole, so an interrupted download never passes for the
  day's file, and a download that is not the list (an error page, an empty result set) fails
  before it can stand as the day's file and turn every name into "no match".
- **Normalizing.** Each name, and each list entry's name and alt_names, is lowercased, its
  punctuation turned to spaces (except the dots of a lettered abbreviation, so "S.A." is "sa" and
  "L.L.C." is "llc"), its whitespace collapsed, and corporate suffixes (co, ltd, inc, sa, pte,
  "S.A. de C.V.", corporation, technologies, and the like) dropped from the end, keeping at least
  one word, so "Huawei Technologies Co., Ltd." is "huawei" and "SAMATA S.A." is "samata".
- **Matching.** A name matches an entry when the normalized forms are equal, or when one contains
  the other on word boundaries and the contained form has at least two words. A match's countries
  come from its addresses, or from the entry's own country field when it has no address.
- **A miss** is "no match", never "clean": the list holds only what US agencies list, and a
  normalized match misses transliterations and renamed subsidiaries.
