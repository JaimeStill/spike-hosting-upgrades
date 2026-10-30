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
| amdgpu issue tracker | <https://gitlab.freedesktop.org/drm/amd/-/issues> | GitLab; upstream reports of amdgpu regressions. |
| Linux kernel releases | <https://www.kernel.org/releases.json> | JSON, with WebFetch: each of `releases[]`'s `moniker`, `version`, `released.isodate`, and `iseol`. |
| Framework Desktop BIOS and drivers | <https://resources.frame.work/downloads/desktop/amd-ryzen-ai-max-300> | Page; the latest BIOS per board. Compare with the probe's `bios_version`. |
| Framework BIOS announcements | <https://community.frame.work/tag/bios-announcement> | Discourse (`.json` on a topic URL). Framework staff release posts are primary; replies are leads. |

### Arch Linux and Omarchy

| Source | URL | How to read it |
|---|---|---|
| Arch package search | `https://archlinux.org/packages/search/json/?name=<package>` | JSON, with WebFetch (`?name=mesa`): each of `results[]`'s `repo`, `pkgname`, `pkgver`-`pkgrel`, and `last_update`. A `*-testing` repo row is a package not yet released to the stable repos. |
| Arch news | <https://archlinux.org/feeds/news/> | RSS; manual interventions that an upgrade needs. |
| Omarchy releases | <https://api.github.com/repos/basecamp/omarchy/releases> | GitHub releases API, with WebFetch. A tag ending `-rcN` is a release candidate. |

## Engines

| Engine | Source | URL | How to read it |
|---|---|---|---|
| llama.cpp | releases | <https://api.github.com/repos/ggml-org/llama.cpp/releases> | Every build is a release (`bNNNNN`); a semantic `vX.Y.Z` release names its nightly build and carries curated notes. Between two builds, WebFetch `https://api.github.com/repos/ggml-org/llama.cpp/compare/<old>...<new>` for each commit message's first line. |
| llama.cpp | source, at a build | `https://github.com/ggml-org/llama.cpp/blob/<build>/common/arg.cpp` | Raw with WebFetch, `https://raw.githubusercontent.com/ggml-org/llama.cpp/<build>/common/arg.cpp`; every server flag's help text and default, at the probed build. |
| llama.cpp | tracker | <https://github.com/ggml-org/llama.cpp/issues> | `gh search issues --repo ggml-org/llama.cpp <terms> --sort updated`; `gh search prs` likewise. |
| llama.cpp | container images | <https://github.com/ggml-org/llama.cpp/pkgs/container/llama.cpp> | Tags `server-<backend>-<build>`, such as `server-vulkan-b11960`. |
| vLLM | releases | <https://api.github.com/repos/vllm-project/vllm/releases> | Release notes group changes by hardware (an "AMD ROCm" paragraph); each change cites its pull request. |
| vLLM | ROCm install doc, at a tag | `https://github.com/vllm-project/vllm/blob/<tag>/docs/getting_started/installation/gpu.rocm.inc.md` | Raw with WebFetch from `https://raw.githubusercontent.com/vllm-project/vllm/<tag>/...`. Lists the supported AMD GPUs by gfx target. `docker/Dockerfile.rocm_base` at the tag names the `PYTORCH_ROCM_ARCH` the published image builds. |
| vLLM | tracker | <https://github.com/vllm-project/vllm/issues> | `gh search issues --repo vllm-project/vllm <gfx target> --sort updated`; `gh search prs` likewise. A pull request's own measurement table is read for its hardware, version, and method. |
| vLLM | container images | <https://hub.docker.com/r/vllm/vllm-openai-rocm/tags> | Docker Hub API, with WebFetch: `https://hub.docker.com/v2/repositories/vllm/vllm-openai-rocm/tags`. |
| SGLang | releases and docker recipes | <https://api.github.com/repos/sgl-project/sglang/releases> | WebFetch `https://api.github.com/repos/sgl-project/sglang/contents/docker?ref=<tag>`: it lists its per-target Dockerfiles; a target with a Dockerfile but no published image is build-it-yourself. |
| TensorRT-LLM (NVIDIA only) | releases | <https://api.github.com/repos/NVIDIA/TensorRT-LLM/releases> | Weighed only on an NVIDIA backend. Support matrix: <https://nvidia.github.io/TensorRT-LLM/reference/support-matrix.html>. |
| Ollama (packager) | releases | <https://api.github.com/repos/ollama/ollama/releases> | Judged by the llama.cpp build it embeds, named in its release notes or its `llama/` vendoring. |
| LM Studio (packager) | changelog | <https://lmstudio.ai/changelog> | Judged by the runtime (llama.cpp or MLX) build it ships. |

## Models

| Source | URL | How to read it |
|---|---|---|
| Hugging Face model API | `https://huggingface.co/api/models/<org>/<name>` | JSON, with WebFetch: `pipeline_tag` (what it serves), `cardData.license`, `cardData.base_model` (a fine-tune's base, for the origin rule), `lastModified`, and `siblings` (its files and formats). |
| Hugging Face model card | `https://huggingface.co/<org>/<name>` | The card's own evals settle the floor's path 2 (a publisher's post-training checkpoint), and its quality statement is the one path 1 quotes for a trained-in format. Its base, distillation, and training-data sections are the publisher's own documents for the origin rule. |
| Major publishers | <https://huggingface.co/google>, <https://huggingface.co/openai>, <https://huggingface.co/meta-llama>, <https://huggingface.co/mistralai>, <https://huggingface.co/ibm-granite>, <https://huggingface.co/microsoft>, <https://huggingface.co/nvidia>, <https://huggingface.co/ggml-org> | List a publisher's models with `https://huggingface.co/api/models?author=<org>&sort=lastModified&limit=20`. `ggml-org` publishes conversions, not models: as the uploader it is one level of the origin rule, and its files pass only as models.md, "Origin", says of conversions. |

## Provenance

The sources the origin rule's evidence chain reads (models.md, "Origin"), each with WebFetch.
Read the adversary list and the screening list fresh each run, and cite the read date.

| Source | URL | How to read it |
|---|---|---|
| Foreign-adversary list, 15 CFR 791.4 (eCFR) | <https://www.ecfr.gov/current/title-15/subtitle-B/chapter-VII/subchapter-E/part-791/subpart-A/section-791.4> | The page answers WebFetch with a redirect to `unblock.federalregister.gov` (as read 2026-10-30), so read the renderer API instead: `https://www.ecfr.gov/api/renderer/v1/content/enhanced/current/title-15?part=791&section=791.4`. Quote paragraph (a)'s list verbatim and the latest amendment citation it shows. |
| Consolidated Screening List (trade.gov) | <https://www.trade.gov/consolidated-screening-list>; files at `https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.json` (also `.csv`, `.tsv`) | The downloadable files need no key (as read 2026-10-30), but they are too large for WebFetch, which stops at 10 MiB: the JSON was 33.9 MB and the CSV 16.8 MB. The search API (`https://data.trade.gov/consolidated_screening_list/v1/search?name=<name>`, documented at <https://developer.trade.gov/>) answers 401 without a subscription key, which takes a developer.trade.gov account. Until the project holds a key or another reading is agreed, the run can't read this list: it says so on every origin pass ("screening list not read"), and names the gap under "Proposed changes". |
| Hugging Face model record, GGUF metadata | `https://huggingface.co/api/models/<org>/<name>?expand[]=gguf` | JSON: `gguf.total` (the parameter count), `gguf.architecture`, `gguf.context_length`, `gguf.chat_template`, and the BOS and EOS tokens. As read 2026-10-30 it doesn't carry `general.base_model.*`; add `&expand[]=cardData` for `cardData.base_model`, the base the card's model tree names. |
| Hugging Face organization | `https://huggingface.co/api/organizations/<org>/overview` | JSON: `isVerified` (true for a verified organization, such as `google`; false for `ggml-org`), `fullname`, and `details`. A verified organization is the first link of publisher identity; the entity on the publisher's own domain comes next. |
| Hugging Face user | `https://huggingface.co/api/users/<name>/overview` | JSON: `fullname` and the profile's stated details, for an uploader's identity in further research (models.md, "Origin", item 5). List their organizations and their other work at `https://huggingface.co/<name>` and `https://huggingface.co/api/models?author=<name>`. |

## Benchmarks

| Source | URL | How to read it | Tier |
|---|---|---|---|
| Phoronix | <https://www.phoronix.com/> | Articles name the system and the kernel; read each for the engine build and the Mesa version, which it often leaves out. OpenBenchmarking result pages (`https://openbenchmarking.org/result/<id>`) carry the full system table. | attributed when the article or its result page names the engine version; else lead |
| A pull request's measurement table | the PR on the engine's tracker | Read the hardware, the commit or version, the tool (`llama-bench`, `vllm bench`, GuideLLM), and the settings. | attributed |
| llama.cpp performance discussions | <https://github.com/ggml-org/llama.cpp/discussions/categories/performance> | Threads collect `llama-bench` tables; each post names its build and backend. | attributed per post that names build, hardware, and command |
| kyuz0, Strix Halo toolboxes | <https://github.com/kyuz0/amd-strix-halo-toolboxes> | README and docs; measured figures name the model, flags, and build; operating advice (flags to use) is a lead until measured. | per figure |

## Finding a new source

A run may cite a source not listed here when it meets its tier's bar, and the report proposes
adding it under "Proposed changes". A run never cites a blocklisted source
([blocklist.md](blocklist.md)), however well it ranks in a search.
