#!/usr/bin/env bash
# Prints `<file>: <tool> <pin> -> <latest>` for each mise tool behind its latest, those of
# mise.toml and of the bench environment (mise.bench.toml), and exits 1 if any; prints nothing when
# all are current. Reads the network.
#
# See docs/tools.md#currency
set -euo pipefail
cd "$(dirname "$0")/.."

trailing=$(MISE_ENV=bench MISE_LOG_LEVEL=error mise outdated --bump --local --json |
  jq -r 'to_entries[] | (.value.bump // .value.latest) as $to | select($to != .value.requested) |
    "\(.value.source.path | split("/") | last): \(.key) \(.value.requested) -> \($to)"' | sort -u)

if [[ -n $trailing ]]; then
  echo "$trailing"
  exit 1
fi
