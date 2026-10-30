# Sources

The trusted sources a run reads, keyed by kind and by vendor or project, each with its URL and
how to read it. Authority belongs to the vendor or project that ships a thing, not to an
environment, so this list belongs to the skill and holds for every host. A run reads a source
fresh each time and cites the date it read it (see [SKILL.md](SKILL.md), "Citing").

Prefer the machine-readable endpoint where one exists: it returns the same facts as the page,
without the page's layout, and a query can be repeated exactly.

## Reading a source

- **WebFetch reads every source**, GitHub included: release pages, api.github.com JSON (releases,
  compare, contents), and raw files from `https://raw.githubusercontent.com/<owner>/<repo>/<ref>/<path>`
  or the contents API. Ask it for the fields by name and for figures verbatim, so the report
  quotes the source and not a paraphrase.
- **WebSearch finds** what the list doesn't hold; a found page is then read with WebFetch.
- **`gh search issues` and `gh search prs` search a tracker**, such as
  `gh search issues --repo <owner>/<repo> <terms> --sort updated`.
- **`gh api` is only a fallback**, for when api.github.com's unauthenticated reads (60 an hour)
  run out. It asks permission each time, since the readiness check prints no rule for it
  ([SKILL.md](SKILL.md), "Readiness check").
- **No source is read with curl or jq through Bash.** A source too large for WebFetch, or one that
  needs a header WebFetch can't send, is read by a narrow script bundled with the skill, or not
  at all until one exists ([SKILL.md](SKILL.md), "Research"). The Consolidated Screening List is
  read so, by `scripts/screen.sh` ("Origin and build checks").

## Tiers

Every source a report cites carries one of three tiers, and the tier decides what the source can
support.

- **primary**: the vendor's or publisher's own release notes, documentation, model cards, and
  upstream trackers (issues and pull requests on the project's own repository). A primary source
  settles what shipped, when, and what is supported. It supports a gain only where it publishes a
  measurement that also meets the attributed-benchmark bar; a release note's "faster" is a claim,
  not a measurement.
- **attributed benchmark**: a measurement that names its hardware, the engine and its version,
  and its method (the workload, the tool, and the settings). A pull request's measurement table
  that names all three is an attributed benchmark inside a primary source. Only this tier can
  support a verify verdict.
- **lead**: an unattributed forum post, social post, or comment, or a benchmark that omits the
  hardware, the version, or the method. A lead names something to check and is never enough on its
  own for a verify verdict; the report says what would confirm it.

A source that names some of the three but not all (the hardware and the method, but not the
engine build) is a tier question: pause and ask (SKILL.md, "When to pause"), with lead as the
default.

Two rules settle common cases without a pause:

- **A Vulkan benchmark names its driver.** On a Vulkan backend the driver is part of the engine,
  so an attributed Vulkan benchmark must also name its Mesa or Vulkan driver version. One that
  doesn't is a lead.
- **The workspace's own measurements.** The workspace's own measurements on the same host count
  as attributed benchmarks when the host's descriptor lists them under "Measurements"
  ([SKILL.md](SKILL.md), "Inputs"). Only cells measured in one session compare with each other:
  a figure from one session and a figure from another are two readings, not a gain.

The same site can hold sources of different tiers: a vendor forum's release announcement is
primary, and a user's reply under it is a lead.

## Hardware and host stack

### NVIDIA: DGX Spark and GB10

| Source | URL | How to read it |
|---|---|---|
| DGX Spark documentation and release notes | <https://docs.nvidia.com/dgx/dgx-spark/>, release notes at <https://docs.nvidia.com/dgx/dgx-spark/release-notes.html> | Pages; the release notes name each DGX OS build's kernel, driver, and CUDA versions. |
| DGX OS release notes | <https://docs.nvidia.com/dgx/dgx-os-7-user-guide/release_notes.html> | Page; match the probe's `/etc/dgx-release` OTA version. |
| NVIDIA driver releases (Linux) | <https://docs.nvidia.com/datacenter/tesla/> (data center branches), <https://www.nvidia.com/en-us/drivers/unix/> (all branches) | Pages per branch; compare with the probe's `nvidia-smi` driver version. |
| NVIDIA Container Toolkit | <https://api.github.com/repos/NVIDIA/nvidia-container-toolkit/releases> | GitHub releases API (JSON), with WebFetch: each release's `tag_name`, `published_at`, and notes. |
| NVIDIA developer forum, DGX Spark | <https://forums.developer.nvidia.com/c/accelerated-computing/dgx-spark-gb10/> | Discourse; WebFetch a topic URL with `.json` appended. Staff posts are primary; user posts are leads. |

### AMD: Strix Halo, ROCm, Mesa, linux-firmware

| Source | URL | How to read it |
|---|---|---|
| ROCm releases | <https://api.github.com/repos/ROCm/ROCm/releases> | GitHub releases API, with WebFetch: the first four releases' `tag_name` and `published_at`. |
| ROCm RDNA3.5 (Strix Halo) system optimization | <https://rocm.docs.amd.com/en/latest/reference/system-optimization/rdna3-5.html> | Page; the TTM/GTT guidance, BIOS VRAM advice, and minimum kernels for gfx1151. The banner names the ROCm version it documents. |
| ROCm compatibility matrix | <https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html> | Page; which GPUs and kernels each ROCm release supports. |
| Mesa release notes | `https://docs.mesa3d.org/relnotes/<version>.html` | Page per release; read its RADV and ACO lines for fixes and regressions on RDNA. |
| linux-firmware | <https://gitlab.com/kernel-firmware/linux-firmware> | GitLab API (JSON), with WebFetch: tags at `https://gitlab.com/api/v4/projects/kernel-firmware%2Flinux-firmware/repository/tags`, commits with `.../repository/commits?since=<ISO date>`. Strix Halo's graphics firmware is `GC 11.5.1` and `PSP 14.0.1`; a revert in the log names a regression. |
| linux-firmware commit diff | `https://gitlab.com/api/v4/projects/kernel-firmware%2Flinux-firmware/repository/commits/<sha>/diff` | GitLab API (JSON), with WebFetch: each entry's `new_path` names a blob the commit touched, which tells a Strix Halo firmware change (`amdgpu/gc_11_5_1*`, `amdgpu/psp_14_0_1*`) from the rest. |
| TheRock releases | <https://api.github.com/repos/ROCm/TheRock/releases> | GitHub releases API, with WebFetch: `tag_name` and `published_at`. As read 2026-10-30, ROCm/ROCm's releases stop at 7.14.0, and newer ROCm ships here. |
| ROCm version history | <https://rocm.docs.amd.com/en/latest/release/versions.html> | Page; every ROCm version with its date, to place the probed or an engine image's ROCm. |
| amdgpu issue tracker | <https://gitlab.freedesktop.org/drm/amd/-/issues> | GitLab; upstream reports of amdgpu regressions. As read 2026-10-30 it blocks automated reads (an Anubis challenge), so a run reads the stand-ins below and says the tracker wasn't read. |
| ROCm/TheRock tracker (stand-in) | <https://github.com/ROCm/TheRock/issues> | `gh search issues --repo ROCm/TheRock <gfx target> --sort updated`. AMD staff replies are primary; user reports are leads. |
| ROCm/legacy-rocm-build tracker (stand-in) | <https://github.com/ROCm/legacy-rocm-build/issues> | `gh search issues --repo ROCm/legacy-rocm-build <gfx target> --sort updated`; reports of MES and firmware faults on gfx1151. AMD staff replies are primary; user reports are leads. |
| Framework SoftwareFirmwareIssueTracker (stand-in) | <https://github.com/FrameworkComputer/SoftwareFirmwareIssueTracker/issues> | `gh search issues --repo FrameworkComputer/SoftwareFirmwareIssueTracker <terms> --sort updated`. Framework staff replies are primary; user reports are leads. |
| Linux kernel releases | <https://www.kernel.org/releases.json> | JSON, with WebFetch: each of `releases[]`'s `moniker`, `version`, `released.isodate`, and `iseol`. |
| Linux kernel stable changelogs | `https://cdn.kernel.org/pub/linux/kernel/v<major>.x/ChangeLog-<version>` | Text per stable release, with WebFetch; search it for the GPU's terms (`amdgpu`, `gfx11`, the IP versions, `MES`) between the probed and the newest stable. |
| Framework Desktop BIOS and drivers | <https://resources.frame.work/downloads/desktop/amd-ryzen-ai-max-300> | Page; the latest BIOS per board. Compare with the probe's `bios_version`. |
| Framework BIOS announcements | <https://community.frame.work/tag/bios-announcement> | Discourse (`.json` on a topic URL). Framework staff release posts are primary; replies are leads. |

### Arch Linux and Omarchy

| Source | URL | How to read it |
|---|---|---|
| Arch package search | `https://archlinux.org/packages/search/json/?name=<package>` | JSON, with WebFetch (`?name=mesa`): each of `results[]`'s `repo`, `pkgname`, `pkgver`-`pkgrel`, and `last_update`. A `*-testing` repo row is a package not yet released to the stable repos. |
| Arch news | <https://archlinux.org/feeds/news/> | RSS; manual interventions that an upgrade needs. |
| Omarchy releases | <https://api.github.com/repos/basecamp/omarchy/releases> | GitHub releases API, with WebFetch. A tag ending `-rcN` is a release candidate. |
| omarchy-pkgs commits, linux-omarchy | <https://api.github.com/repos/omacom-io/omarchy-pkgs/commits?path=pkgbuilds/linux-omarchy> | GitHub commits API, with WebFetch: each commit's message names the kernel's version and pkgrel. The only machine-readable source for the Omarchy kernel's pkgrel. |

## Engines

| Engine | Source | URL | How to read it |
|---|---|---|---|
| llama.cpp | releases | <https://api.github.com/repos/ggml-org/llama.cpp/releases> | Every build is a release (`bNNNNN`); a semantic `vX.Y.Z` release names its nightly build and carries curated notes. Between two builds, WebFetch `https://api.github.com/repos/ggml-org/llama.cpp/compare/<old>...<new>` for each commit message's first line. |
| llama.cpp | source, at a build | `https://github.com/ggml-org/llama.cpp/blob/<build>/common/arg.cpp` | Raw with WebFetch, `https://raw.githubusercontent.com/ggml-org/llama.cpp/<build>/common/arg.cpp`; every server flag's help text and default, at the probed build. |
| llama.cpp | tracker | <https://github.com/ggml-org/llama.cpp/issues> | `gh search issues --repo ggml-org/llama.cpp <terms> --sort updated`; `gh search prs` likewise. |
| llama.cpp | container images | <https://github.com/ggml-org/llama.cpp/pkgs/container/llama.cpp> | Tags `server-<backend>-<build>`, such as `server-vulkan-b11960`. |
| llama.cpp | ghcr.io manifest check | `https://ghcr.io/v2/ggml-org/llama.cpp/manifests/server-<backend>-<build>` | Whether a build's image was published for a backend: the registry answers the manifest for a published tag and 404 for one that isn't. It needs an anonymous pull token (`https://ghcr.io/token?scope=repository:ggml-org/llama.cpp:pull`) sent as a header, which WebFetch can't send, so until a bundled script carries it, a run reads the package page above for the tag and says the manifest wasn't checked. |
| llama.cpp (HRX) | ggml-hrx builds | <https://github.com/ROCm/ggml-staging-automation/releases> | Releases page or API (`https://api.github.com/repos/ROCm/ggml-staging-automation/releases`), with WebFetch: AMD's HRX backend builds (`hrx-bNNN`), their dates, and their target list. As read 2026-10-30 they ship as tarballs only, "not a stable distribution channel", with no container image. |
| vLLM | releases | <https://api.github.com/repos/vllm-project/vllm/releases> | Release notes group changes by hardware (an "AMD ROCm" paragraph); each change cites its pull request. |
| vLLM | ROCm install doc, at a tag | `https://github.com/vllm-project/vllm/blob/<tag>/docs/getting_started/installation/gpu.rocm.inc.md` | Raw with WebFetch from `https://raw.githubusercontent.com/vllm-project/vllm/<tag>/...`. Lists the supported AMD GPUs by gfx target. `docker/Dockerfile.rocm_base` at the tag names the `PYTORCH_ROCM_ARCH` the published image builds. |
| vLLM | tracker | <https://github.com/vllm-project/vllm/issues> | `gh search issues --repo vllm-project/vllm <gfx target> --sort updated`; `gh search prs` likewise. A pull request's own measurement table is read for its hardware, version, and method. |
| vLLM | container images | <https://hub.docker.com/r/vllm/vllm-openai-rocm/tags> | Docker Hub API, with WebFetch: `https://hub.docker.com/v2/repositories/vllm/vllm-openai-rocm/tags`. |
| SGLang | releases and docker recipes | <https://api.github.com/repos/sgl-project/sglang/releases> | WebFetch `https://api.github.com/repos/sgl-project/sglang/contents/docker?ref=<tag>`: it lists its per-target Dockerfiles; a target with a Dockerfile but no published image is build-it-yourself. |
| SGLang | AMD development images | <https://hub.docker.com/r/rocm/sgl-dev/tags> | Docker Hub API, with WebFetch: `https://hub.docker.com/v2/repositories/rocm/sgl-dev/tags?name=<gfx target>`. AMD's daily development images per gfx target; the release channel `lmsysorg/sglang` may carry no tag for the target. |
| TensorRT-LLM (NVIDIA only) | releases | <https://api.github.com/repos/NVIDIA/TensorRT-LLM/releases> | Weighed only on an NVIDIA backend. Support matrix: <https://nvidia.github.io/TensorRT-LLM/reference/support-matrix.html>. |
| Ollama (packager) | releases | <https://api.github.com/repos/ollama/ollama/releases> | Judged by the llama.cpp build it embeds, named in its release notes or its `llama/` vendoring. |
| LM Studio (packager) | changelog | <https://lmstudio.ai/changelog> | Judged by the runtime (llama.cpp or MLX) build it ships. |
| Lemonade (packager) | pinned backends | `https://raw.githubusercontent.com/lemonade-sdk/lemonade/<tag>/src/cpp/resources/backend_versions.json` | Raw with WebFetch, at the newest release's tag (<https://api.github.com/repos/lemonade-sdk/lemonade/releases>): the llama.cpp build it pins per backend (`vulkan`, `rocm-stable`, HRX). Judged by those builds. |

## Models

| Source | URL | How to read it |
|---|---|---|
| Hugging Face model API | `https://huggingface.co/api/models/<org>/<name>` | JSON, with WebFetch: `pipeline_tag` (what it serves), `cardData.license`, `cardData.base_model` (a fine-tune's base, for the origin rule), `lastModified`, and `siblings` (its files and formats). |
| Hugging Face model card | `https://huggingface.co/<org>/<name>` | The card's own evals settle the floor's path 2 (a publisher's post-training checkpoint), and its quality statement is the one path 1 quotes for a trained-in format. Its base, distillation, and training-data sections are the publisher's own documents for the origin rule. |
| Major publishers | <https://huggingface.co/google>, <https://huggingface.co/openai>, <https://huggingface.co/meta-llama>, <https://huggingface.co/mistralai>, <https://huggingface.co/ibm-granite>, <https://huggingface.co/microsoft>, <https://huggingface.co/nvidia>, <https://huggingface.co/ggml-org> | List a publisher's models with `https://huggingface.co/api/models?author=<org>&sort=lastModified&limit=20`. `ggml-org` publishes conversions, not models: as the uploader it is one level of the origin rule, and its files pass only as models.md, "Origin", says of conversions. |

## Origin and build checks

The sources the origin rule's evidence chain reads (models.md, "Origin"), and the ones that
establish a file's build (models.md, "Quantization floor"), each with WebFetch unless its row
says otherwise. Read the adversary list and the screening list fresh each run (the screening
list as of that day's download), and cite the read date.

| Source | URL | How to read it |
|---|---|---|
| Foreign-adversary list, 15 CFR 791.4 (eCFR) | <https://www.ecfr.gov/current/title-15/subtitle-B/chapter-VII/subchapter-E/part-791/subpart-A/section-791.4> | The page answers WebFetch with a redirect to `unblock.federalregister.gov` (as read 2026-10-30), so read the renderer API instead: `https://www.ecfr.gov/api/renderer/v1/content/enhanced/current/title-15?part=791&section=791.4`. Quote paragraph (a)'s list verbatim and the latest amendment citation it shows. |
| Consolidated Screening List (trade.gov), by `scripts/screen.sh` | <https://www.trade.gov/consolidated-screening-list>; the script reads `https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.json` | The file is too large for WebFetch (33.9 MB as read 2026-10-30, past its 10 MiB), and the search API needs a developer.trade.gov key, so the bundled [scripts/screen.sh](scripts/screen.sh) reads it: run `.claude/skills/hosting-upgrades/scripts/screen.sh "<name>" ...` from the project root, with the publisher, the uploader, and every entity the documents name. It downloads the public JSON once a day into `.state/csl/<YYYY-MM-DD>.json` and matches normalized names (lowercased, punctuation and corporate suffixes dropped) exactly, or one inside the other when the inner form has two words or more. Cite the file's date and the URL its first line prints, and for a match the entry's name, source list, programs, country, start date, and source list URL. The limit: a miss is "no match", never clean. The list holds only what US agencies list, and a normalized match misses transliterations, other spellings, and subsidiaries listed under their own names, so a miss leaves the rest of the evidence chain to settle origin. |
| Hugging Face model record, GGUF metadata | `https://huggingface.co/api/models/<org>/<name>?expand[]=gguf` | JSON: `gguf.total` (the parameter count), `gguf.architecture`, `gguf.context_length`, `gguf.chat_template`, and the BOS and EOS tokens. As read 2026-10-30 it doesn't carry `general.base_model.*`; add `&expand[]=cardData` for `cardData.base_model`, the base the card's model tree names. |
| Hugging Face organization | `https://huggingface.co/api/organizations/<org>/overview` | JSON: `isVerified` (true for a verified organization, such as `google`; false for `ggml-org`), `fullname`, and `details`. A verified organization is the first link of publisher identity; the entity on the publisher's own domain comes next. |
| Hugging Face user | `https://huggingface.co/api/users/<name>/overview` | JSON: `fullname` and the profile's stated details, for an uploader's identity in further research (models.md, "Origin", item 5). List their organizations and their other work at `https://huggingface.co/<name>` and `https://huggingface.co/api/models?author=<name>`. |
| ggml-org source pin, `.src_sha` | `https://huggingface.co/ggml-org/<name>/raw/main/<file>.src_sha`; find the file in the record's `siblings` | Text, with WebFetch: the publisher's repository and commit the conversion was made from. ggml-org's GGUF headers often lack `general.base_model.*`, so this file is the pin for a ggml-org conversion (models.md, "Origin", item 4). |

## Benchmarks

| Source | URL | How to read it | Tier |
|---|---|---|---|
| Phoronix | <https://www.phoronix.com/> | Articles name the system and the kernel; read each for the engine build and the Mesa version, which it often leaves out. OpenBenchmarking result pages (`https://openbenchmarking.org/result/<id>`) carry the full system table. | attributed when the article or its result page names the engine version; else lead |
| A pull request's measurement table | the PR on the engine's tracker | Read the hardware, the commit or version, the tool (`llama-bench`, `vllm bench`, GuideLLM), and the settings. | attributed |
| llama.cpp performance discussions | <https://github.com/ggml-org/llama.cpp/discussions/categories/performance> | Threads collect `llama-bench` tables; each post names its build and backend. | attributed per post that names build, hardware, and command |
| kyuz0, Strix Halo toolboxes | <https://github.com/kyuz0/amd-strix-halo-toolboxes> | README and docs; measured figures name the model, flags, and build; operating advice (flags to use) is a lead until measured. As read 2026-10-30 its README calls its own results "legacy and are no longer updated"; local-llm-benchmarks.dev succeeds it. | per figure; a Vulkan figure with no Mesa version is a lead |
| local-llm-benchmarks.dev | `https://local-llm-benchmarks.dev/data/results.json` | JSON, with WebFetch (7.6 MB as read 2026-10-30, within WebFetch's 10 MiB): each run names its hardware, engine, version, workload, and repeats. Ask for the rows of the probed hardware and the incumbent's engine by name. | attributed per run that names them, Vulkan runs with their driver |
| llama.cpp discussion #27219 (the HRX RFC) | <https://github.com/ggml-org/llama.cpp/discussions/27219> | A per-post benchmark thread: read each reply for its hardware, build (the HRX build too), backend, and command. The RFC itself is primary for what HRX claims. | attributed per post that names all three; else lead |
| The workspace's own same-host measurements | the paths a host descriptor lists under "Measurements" | Read each listed finding for its build, its session, and its cells. Compare only cells from one session. | attributed on that host, by the descriptor's listing |

### Known leads

Sources a run met and the architect ruled leads on 2026-10-30. Each names something to check,
and never carries a verify verdict alone.

| Source | URL | Why it is a lead |
|---|---|---|
| hogeheer499, strix-halo-guide BENCHMARKS.md | <https://github.com/hogeheer499-commits/strix-halo-guide/blob/main/BENCHMARKS.md> | The command is only in the raw CSVs, and the gpt-oss section doesn't name the machine. |
| Zenn, sakuranaga, "Local LLM Performance Improved on Ryzen AI Max+ 395" | <https://zenn.dev/shuzan/articles/72852bb9621b40?locale=en> | It names the hardware and the build, but not the kernel, the Mesa version, or the command. |
| huppiflupp, in llama.cpp discussion #27219 | <https://github.com/ggml-org/llama.cpp/discussions/27219> | It doesn't name the HRX build it measured. |
| Phoronix, "Linux 7.2 vs 7.3" on Strix Halo | <https://www.phoronix.com/news/Linux-7.3-Strix-Halo> | The architect's ruling; the run cited its finding that the two kernels made little difference, and nothing more. |
| pugant, Nemotron 3.5 Lightning ROCmFP4 card | <https://huggingface.co/pugant/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-ROCmFP4-STRIX_LEAN> | Its figures come from a fork with no commit named, on a custom format that stock llama.cpp refuses. |

## Finding a new source

A run may cite a source not listed here when it meets its tier's bar, and the report proposes
adding it under "Proposed changes". A run never cites a blocklisted source
([blocklist.md](blocklist.md)), however well it ranks in a search.
