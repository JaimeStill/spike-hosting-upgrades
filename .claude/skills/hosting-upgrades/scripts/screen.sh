#!/usr/bin/env bash
# Screens names against trade.gov's Consolidated Screening List, for the hosting-upgrades skill's
# origin gate. It runs on the machine running the skill, from the project root, never over ssh:
#
#   .claude/skills/hosting-upgrades/scripts/screen.sh <name>...
#
# Once a day it downloads the list's public JSON (no key needed) into
# <project root>/.state/csl/<YYYY-MM-DD>.json, and every later call that day reads that file. The
# project root is $CLAUDE_PROJECT_DIR, or the current directory when that is unset. Each name is
# matched against each entry's name and alt_names, normalized, and each match prints the entry's
# name, its source list, programs, countries, start date, and the source list's URL. A name with
# no match prints "no match on normalized name: <name>", which is never "clean". It exits nonzero
# only when the download or the parse fails, or the downloaded file holds no list entries.
#
# See .claude/skills/hosting-upgrades/models.md#origin
# See .claude/skills/hosting-upgrades/scripts.md#screensh
set -u

readonly url=https://data.trade.gov/downloadable_consolidated_screening_list/v1/consolidated.json

download_whole_list() {
  local file=$1
  if ! curl -fsSL --proto =https -o "$file.part" "$url"; then
    rm -f "$file.part"
    echo "screen.sh: download failed: $url" >&2
    return 1
  fi
  if ! jq -e '.results | type == "array" and length > 0' "$file.part" >/dev/null 2>&1; then
    rm -f "$file.part"
    echo "screen.sh: download is not the screening list (no results array): $url" >&2
    return 1
  fi
  mv "$file.part" "$file" || return 1
}

screen() {
  if (($# == 0)); then
    echo "usage: screen.sh <name>..." >&2
    return 2
  fi
  local root=${CLAUDE_PROJECT_DIR:-$PWD} dir file
  dir=$root/.state/csl
  file=$dir/$(date +%F).json || return
  if [[ ! -s $file ]]; then
    mkdir -p "$dir" || return 1
    download_whole_list "$file" || return 1
    find "$dir" -maxdepth 1 -name '*.json' ! -name "${file##*/}" -delete
  fi
  printf 'screening list: %s, downloaded %s from %s\n' "${file#"$root"/}" \
    "$(basename "$file" .json)" "$url"

  if ! jq -r '
    def suffixes: ["co", "ltd", "inc", "llc", "corp", "corporation", "company", "limited",
      "gmbh", "sa", "ag", "plc", "group", "holdings", "technology", "technologies", "pte", "sarl",
      "srl", "bv", "nv", "jsc", "ojsc", "pjsc", "cjsc", "ooo", "llp", "liability", "incorporated",
      "cv", "de"];
    def drop_suffix_words_keeping_one: if length > 1 and (.[-1] as $w | suffixes | index($w))
      then .[:-1] | drop_suffix_words_keeping_one else . end;
    def norm: ascii_downcase | gsub("(?<=\\b\\p{L})\\.(?=\\p{L}\\b)"; "")
      | gsub("[\\p{P}\\p{S}]"; " ") | [splits("\\s+") | select(. != "")]
      | drop_suffix_words_keeping_one | join(" ");
    def words: split(" ") | length;
    def contains_words($a; $b): (" " + $a + " ") | contains(" " + $b + " ");
    def matches($q): . as $e | ($q == $e)
      or (($q | words) >= 2 and contains_words($e; $q))
      or (($e | words) >= 2 and contains_words($q; $e));
    [.results[] | {entry: ., forms: ([.name] + (.alt_names // []) | map(select(. != null) | norm)
      | map(select(. != "")))}] as $list
    | $ARGS.positional[] as $name
    | ($name | norm) as $q
    | [$list[] | select(any(.forms[]; matches($q))) | .entry] as $hits
    | if ($hits | length) == 0 then "no match on normalized name: \($name)"
      else "match for \($name) (normalized \"\($q)\"): \($hits | length)",
        ($hits[] | . as $e |
          "  name: \(.name)",
          "    source: \(.source)",
          "    programs: \((.programs // []) | join(", ") | if . == "" then "none" else . end)",
          "    country: \([(.addresses // [])[] | .country // empty] | unique | join(", ")
            | if . != "" then . elif $e.country then "\($e.country) (the entry\u0027s own)"
              else "none given" end)",
          "    start_date: \(.start_date // "none")",
          "    source_list_url: \(.source_list_url // "none")")
      end
  ' "$file" --args -- "$@"; then
    echo "screen.sh: could not parse $file" >&2
    return 1
  fi
}

screen "$@"
