#!/usr/bin/env bash
# Reads the first 4 bytes of one file in a Hugging Face model repository, for the hosting-upgrades
# skill's artifact integrity gate. It runs on the machine running the skill, from the project
# root, never over ssh:
#
#   .claude/skills/hosting-upgrades/scripts/magic.sh "<org>/<repo>" "<file>"
#
# It takes a repository and a file path within it, never a URL: letters, digits, ".", "_", and
# "-", with one "/" in the repository and "/" between the file's path parts. It builds the file's
# resolve URL itself (https://huggingface.co/<org>/<repo>/resolve/main/<file>), reads bytes 0-3,
# following redirects, and prints the resolve URL and the read date, the 4 bytes as hex, and the
# format they name:
#
#   47 47 55 46        GGUF
#   80 02 to 80 05     pickle, protocol 2 to 5
#   50 4b 03 04        zip, which is how torch saves a checkpoint, with a pickle inside it
#   anything else      unknown, safetensors among them
#
# It exits nonzero when an argument is refused, when the request fails (the file is missing,
# gated, or the network is down), or when fewer than 4 bytes come back.
#
# See .claude/skills/hosting-upgrades/models.md#artifact-integrity
# See .claude/skills/hosting-upgrades/scripts.md#magicsh
set -u
export LC_ALL=C

first_4_bytes_hex() {
  curl -q -fsSL -r 0-3 --max-time 30 --max-filesize 64 --proto =https --proto-redir =https \
    "$1" | od -An -tx1 -v | tr -s ' \n' ' '
  return "${PIPESTATUS[0]}"
}

magic() {
  if (($# != 2)); then
    echo 'usage: magic.sh "<org>/<repo>" "<file>"' >&2
    return 2
  fi
  local repo=$1 file=$2
  local part='[A-Za-z0-9_][A-Za-z0-9._-]*'
  if [[ ! $repo =~ ^$part/$part$ || $repo == *..* ]]; then
    echo "magic.sh: refused repository \"$repo\": give <org>/<repo>, letters, digits, \".\", \"_\", \"-\" only" >&2
    return 2
  fi
  if [[ ! $file =~ ^$part(/$part)*$ || $file == *..* ]]; then
    echo "magic.sh: refused file \"$file\": give a path in the repository, letters, digits, \".\", \"_\", \"-\", and \"/\" between parts only" >&2
    return 2
  fi
  local url="https://huggingface.co/$repo/resolve/main/$file" hex rc
  hex=$(first_4_bytes_hex "$url")
  rc=$?
  hex=${hex# }
  hex=${hex% }
  if ((rc == 63)); then
    echo "magic.sh: the server ignored the range and offered the whole file: $url" >&2
    return 1
  elif ((rc != 0)); then
    echo "magic.sh: request failed (curl exit $rc): $url" >&2
    return 1
  fi
  local bytes=()
  read -r -a bytes <<<"$hex"
  if ((${#bytes[@]} < 4)); then
    echo "magic.sh: short read, ${#bytes[@]} of 4 bytes${hex:+ ($hex)}: $url" >&2
    return 1
  fi
  local first="${bytes[0]} ${bytes[1]} ${bytes[2]} ${bytes[3]}" format
  case $first in
    '47 47 55 46') format=GGUF ;;
    '80 02 '* | '80 03 '* | '80 04 '* | '80 05 '*) format="pickle, protocol $((16#${bytes[1]}))" ;;
    '50 4b 03 04') format="zip (a torch checkpoint, with a pickle inside it)" ;;
    *) format="unknown (safetensors can't be told from 4 bytes, which are only its header length's low bytes; the Hub's per-file scan settles it)" ;;
  esac
  printf 'file: %s, read %s\n' "$url" "$(date +%F)"
  printf 'first 4 bytes: %s\n' "$first"
  printf 'format: %s\n' "$format"
}

magic "$@"
