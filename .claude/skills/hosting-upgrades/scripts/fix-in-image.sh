#!/usr/bin/env bash
# Reads whether an upstream fix is in the newest engine build that has a published image for a
# host class, for the hosting-upgrades skill's blocker register (survey.md, "Blocker register").
# It runs on the machine running the skill, from the project root, never over ssh:
#
#   .claude/skills/hosting-upgrades/scripts/fix-in-image.sh "<owner>/<repo>" "<fix>" "<class>"
#
#   <owner>/<repo>  the engine's repository; today only ggml-org/llama.cpp, whose images are
#                   ghcr.io/ggml-org/llama.cpp:server-<flavor>-<build>
#   <fix>           a pull request number (#30137 or 30137), or a merge commit's SHA (7 to 40 hex)
#   <class>         the host class: gb10 (its image flavor cuda13) or strix-halo (vulkan), the
#                   flavors spike-model-engines' scripts/currency.sh reads for each class
#
# Three reads, each read-only:
#
# 1. A pull request's state and merge commit, with `gh pr view --json state,mergedAt,mergeCommit`.
#    A pull request that isn't merged stops here: no build can carry it.
# 2. The newest b-build with the class's image: ghcr.io's tag list for the image, read whole (the
#    registry's /v2/<repo>/tags/list, a GET, a page at a time by its Link header), and the highest
#    <N> among its server-<flavor>-b<N> tags. The registry needs an anonymous pull token sent as a
#    header, which WebFetch can't send, so the script fetches it with curl, as currency.sh does.
#    The tag list, not the releases list, because an image can be published for a build with no
#    GitHub release (server-cuda13-b12169 had none); llama.cpp publishes images only nightly and
#    on manual runs, so its newest release often has none either. The git tag b<N> exists either
#    way, and step 3 compares against it.
# 3. GitHub's compare API, `gh api repos/<owner>/<repo>/compare/<fix>...<build>` (a GET): the
#    build carries the fix when its status is "ahead" or "identical", and not when it is "behind"
#    or "diverged".
#
# It makes no write: `gh api` runs with --method GET and no fields, and curl only reads the token
# and the tag list. It prints the fix, its state and merge commit, the class's newest imaged
# build and its image, the compare's status, the answer ("in image: yes", "no", or "no (not
# merged)"), and the read time (UTC). It exits 0 whenever it answers, 2 when an argument is
# refused, and 1 when a read fails (the network, GitHub, or the registry), naming the read.
set -u
# The allowlist's ranges mean ASCII only in the C locale.
export LC_ALL=C

fail() {
  echo "fix-in-image.sh: $*" >&2
  exit 1
}

refuse() {
  echo "fix-in-image.sh: $*" >&2
  exit 2
}

if (($# != 3)); then
  refuse 'usage: fix-in-image.sh "<owner>/<repo>" "<pr number or merge commit>" "<gb10|strix-halo>"'
fi
repo=$1 fix=${2#\#} class=$3

part='[A-Za-z0-9_][A-Za-z0-9._-]*'
[[ $repo =~ ^$part/$part$ && $repo != *..* ]] ||
  refuse "refused repository \"$repo\": give <owner>/<repo>, letters, digits, \".\", \"_\", \"-\" only"
case $repo in
  ggml-org/llama.cpp) registry=ggml-org/llama.cpp ;;
  *) refuse "no image check is known for $repo: today only ggml-org/llama.cpp's ghcr.io images" ;;
esac
case $class in
  gb10) flavor=cuda13 ;;
  strix-halo) flavor=vulkan ;;
  *) refuse "refused class \"$class\": give gb10 or strix-halo" ;;
esac

# 1. The fix: a pull request's merge commit, or a commit given as is.
if [[ $fix =~ ^[0-9]{1,7}$ ]]; then
  pr=$(gh pr view "$fix" --repo "$repo" --json state,mergedAt,mergeCommit \
    --jq '[.state, (.mergedAt // "-"), (.mergeCommit.oid // "-")] | @tsv') ||
    fail "gh pr view $fix --repo $repo failed"
  IFS=$'\t' read -r state merged sha <<<"$pr"
  printf 'fix: %s#%s, %s' "$repo" "$fix" "$state"
  if [[ $state != MERGED || $sha == - ]]; then
    printf '\nin image: no (not merged)\nread: %s\n' "$(date -u +%Y-%m-%dT%H:%MZ)"
    exit 0
  fi
  printf ', merged %s, merge commit %s\n' "$merged" "$sha"
elif [[ $fix =~ ^[0-9a-f]{7,40}$ ]]; then
  sha=$fix
  printf 'fix: %s@%s (a commit)\n' "$repo" "$sha"
else
  refuse "refused fix \"$2\": give a pull request number (#30137) or a commit SHA (7 to 40 hex)"
fi

# 2. The newest b-build whose server image exists for the class's flavor.
token=$(curl -q -fsS --max-time 30 --proto =https \
  "https://ghcr.io/token?scope=repository:$registry:pull" |
  sed -n 's/.*"token":"\([^"]*\)".*/\1/p') && [[ -n $token ]] ||
  fail "ghcr.io gives no pull token for $registry"
headers=$(mktemp) || fail "no temporary file for the registry's headers"
trap 'rm -f "$headers"' EXIT
# Each page names the next in its Link header (rel="next"), a path on ghcr.io; the last has none.
# The page bound stops a registry that never ends its list.
page="/v2/$registry/tags/list?n=1000" pages=0 newest=0
while [[ -n $page ]]; do
  ((++pages <= 200)) || fail "ghcr.io's tag list for $registry runs past 200 pages"
  body=$(curl -q -fsS --max-time 30 --proto =https -D "$headers" \
    -H "Authorization: Bearer $token" "https://ghcr.io$page") ||
    fail "ghcr.io's tag list for $registry can't be read (page $pages)"
  while read -r n; do
    ((10#$n > newest)) && newest=$((10#$n))
  done < <(grep -oE "\"server-$flavor-b[0-9]+\"" <<<"$body" | sed 's/.*-b\([0-9]*\)"$/\1/')
  page=$(tr -d '\r' <"$headers" | sed -n 's/^[Ll]ink: *<\([^>]*\)>; *rel="next".*/\1/p')
  [[ -z $page || $page == /v2/* ]] || fail "ghcr.io's next page \"$page\" is not a registry path"
done
((newest > 0)) || fail "ghcr.io has no image server-$flavor-b<build> for $registry"
build=b$newest
printf 'class: %s, flavor %s; newest imaged build: %s (ghcr.io/%s:server-%s-%s)\n' \
  "$class" "$flavor" "$build" "$registry" "$flavor" "$build"

# 3. Whether that build carries the fix.
cmp=$(gh api --method GET "repos/$repo/compare/$sha...$build" \
  --jq '[.status, .ahead_by, .behind_by] | @tsv') || fail "the compare $sha...$build can't be read"
IFS=$'\t' read -r status ahead behind <<<"$cmp"
printf 'compare %s...%s: %s (ahead by %s, behind by %s)\n' "${sha:0:12}" "$build" "$status" \
  "$ahead" "$behind"
case $status in
  ahead | identical) answer=yes ;;
  behind | diverged) answer=no ;;
  *) fail "the compare's status \"$status\" is none of ahead, identical, behind, diverged" ;;
esac
printf 'in image: %s\nread: %s\n' "$answer" "$(date -u +%Y-%m-%dT%H:%MZ)"
