#!/usr/bin/env bash
# Probes one host's serving stack, read-only and without root, for the hosting-upgrades skill.
# It runs on the host, fed over ssh from the machine running the skill:
#
#   ssh <host> bash -s < probe.sh
#
# It prints plain labeled sections (== name ==): the OS, the kernel, firmware, the GPU, memory,
# the container runtime, the engine containers and units, each serving engine's build and models,
# the models in the host's local stores, and what the host has fallen behind on (package sources,
# pending package and firmware updates, failed units, docker's disk). A probe whose command is
# absent prints "skipped:" and the run goes on; the last section lists every skip. It never calls
# sudo and prints no network address, so its output can be committed as is.
#
# See .claude/skills/hosting-upgrades/setup.md#3-probe
# See .claude/skills/hosting-upgrades/scripts.md#probesh
set -u

section() { printf '\n== %s ==\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }
skip() {
  printf 'skipped: %s\n' "$1"
  skipped+=("$1")
}
show_file() {
  if [[ -r $1 ]]; then
    printf '%s: %s\n' "$1" "$(tr -d '\n' <"$1")"
  else
    printf '%s: absent\n' "$1"
  fi
}
gib() { awk -v b="$1" 'BEGIN { printf "%.1f GiB", b / 1073741824 }'; }

serving_flags() {
  awk '
    BEGIN {
      n = split("--ctx-size -c --parallel -np --cont-batching -cb --no-cont-batching -nocb " \
        "--batch-size -b --ubatch-size -ub --n-gpu-layers --gpu-layers -ngl --flash-attn -fa " \
        "--cache-type-k -ctk --cache-type-v -ctv --kv-unified -kvu --no-kv-unified " \
        "--kv-unified-per-slot --load-mode -lm --cache-reuse --swa-full --n-cpu-moe -ncmoe " \
        "--cpu-moe --no-mmap --mlock --threads -t " \
        "--max-num-seqs --max-model-len --gpu-memory-utilization --max-num-batched-tokens " \
        "--enable-chunked-prefill --no-enable-chunked-prefill --enable-prefix-caching " \
        "--no-enable-prefix-caching --kv-cache-dtype --tensor-parallel-size -tp --quantization " \
        "--dtype --max-running-requests --mem-fraction-static --chunked-prefill-size " \
        "--attention-backend --enforce-eager " \
        "--cache-ram -cram --cache-idle-slots --no-cache-idle-slots --ctx-checkpoints " \
        "--swa-checkpoints --checkpoint-min-step " \
        "--cache-prompt --no-cache-prompt --context-shift --no-context-shift --keep " \
        "--models-max --sleep-idle-seconds --mmproj-offload --no-mmproj-offload " \
        "--draft-max --draft-min --draft-p-min --n-predict -n --jinja --no-jinja " \
        "--reasoning-format --reasoning-budget --temp --top-k --top-p --min-p --typical " \
        "--top-nsigma --repeat-penalty --repeat-last-n --presence-penalty " \
        "--frequency-penalty --dry-multiplier --xtc-probability --xtc-threshold --seed", w, " ")
      for (i = 1; i <= n; i++) want[w[i]] = 1
    }
    {
      if ($0 !~ /^[-{]/ && $0 ~ /[[:space:]]/) {
        if (n_t && t[n_t] == "-c") n_t--
        n = split($0, w, /[[:space:]]+/)
        for (i = 1; i <= n; i++) if (w[i] != "") t[++n_t] = w[i]
      } else t[++n_t] = $0
    }
    END {
      out = ""
      for (i = 1; i <= n_t; i++) {
        f = t[i]; v = ""
        if (f ~ /^-[^=]*=/) { v = " " substr(f, index(f, "=") + 1); f = substr(f, 1, index(f, "=") - 1) }
        else if (i < n_t && t[i + 1] !~ /^-/) v = " " t[i + 1]
        if (!(f in want) && f ~ /^--/ && substr(f, 2) in want) f = substr(f, 2)
        if (f in want) out = out " " f v
      }
      print (out == "" ? " none of the serving flags" : out)
    }'
}

run_flags() {
  local hc err
  if ! hc=$(docker inspect "$1" --format '{{with .HostConfig}}{{range .DeviceRequests}}gpus {{.Count}}{{range .DeviceIDs}},{{.}}{{end}}
{{end}}{{range .Devices}}device {{.PathOnHost}}
{{end}}ipc {{.IpcMode}}
pid {{.PidMode}}
shm-size {{.ShmSize}}
{{range .Ulimits}}ulimit {{.Name}}={{.Soft}}:{{.Hard}}
{{end}}memory {{.Memory}}
memory-swap {{.MemorySwap}}
cpus {{.NanoCpus}}
cpuset-cpus {{.CpusetCpus}}
network {{.NetworkMode}}
runtime {{.Runtime}}
privileged {{.Privileged}}
{{range .CapAdd}}cap-add {{.}}
{{end}}{{range .GroupAdd}}group-add {{.}}
{{end}}{{end}}' 2>&1); then
    err=$(grep -m 1 . <<<"$hc")
    printf '  run flags not readable: %s\n' "${err:-docker inspect failed}"
    printf '  run env not readable: %s\n' "${err:-docker inspect failed}"
    return
  fi
  printf '  run flags%s\n' "$(awk '
    $1 == "gpus" {
      sub(/^gpus /, ""); sub(/,/, " device=")
      if ($0 ~ /^-1( |$)/) sub(/^-1/, "all")
      out = out " --gpus " $0; next }
    $1 == "device" { out = out " --device " $2; next }
    $1 == "ipc" && $2 != "" && $2 != "private" && $2 != "shareable" { out = out " --ipc " $2 }
    $1 == "pid" && $2 != "" { out = out " --pid " $2 }
    $1 == "shm-size" && $2 != "" && $2 != 0 && $2 != 67108864 {
      out = out sprintf(" --shm-size %.0fm", $2 / 1048576) }
    $1 == "ulimit" { out = out " --ulimit " $2 }
    $1 == "memory" && $2 != 0 { out = out sprintf(" --memory %.0fm", $2 / 1048576) }
    $1 == "memory-swap" && $2 != 0 { out = out " --memory-swap " $2 }
    $1 == "cpus" && $2 != 0 { out = out sprintf(" --cpus %g", $2 / 1e9) }
    $1 == "cpuset-cpus" && $2 != "" { out = out " --cpuset-cpus " $2 }
    $1 == "network" && $2 != "" && $2 != "default" && $2 != "bridge" { out = out " --network " $2 }
    $1 == "runtime" && $2 != "" && $2 != "runc" { out = out " --runtime " $2 }
    $1 == "privileged" && $2 == "true" { out = out " --privileged" }
    $1 == "cap-add" { out = out " --cap-add " $2 }
    $1 == "group-add" { out = out " --group-add " $2 }
    END { print (out == "" ? " docker'\''s defaults" : out) }' <<<"$hc")"
  local image_env run_env line name value shown=()
  image_env=$(docker image inspect --format '{{range .Config.Env}}{{println .}}{{end}}' \
    "$(docker inspect --format '{{.Image}}' "$1")" 2>/dev/null)
  if ! run_env=$(docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$1" 2>&1); then
    err=$(grep -m 1 . <<<"$run_env")
    printf '  run env not readable: %s\n' "${err:-docker inspect failed}"
    return
  fi
  while IFS= read -r line; do
    [[ -n $line ]] || continue
    grep -qxF -- "$line" <<<"$image_env" && continue
    name=${line%%=*} value=${line#*=}
    if [[ $name =~ ^(LLAMA_ARG_|VLLM_|GGML_|CUDA_|NVIDIA_|HIP_|HSA_|ROCR_|OMP_) &&
      ! $name =~ (KEY|TOKEN|SECRET|PASS|AUTH|CRED|HOST|ADDR|URL|MODEL|REPO|PATH|DIR|FILE|ALIAS|HOME) &&
      $value =~ ^[A-Za-z0-9._,:=+-]{0,64}$ ]]; then
      shown+=("$name=$value")
    else
      shown+=("$name (value not shown)")
    fi
  done <<<"$run_env"
  if ((${#shown[@]})); then
    local joined
    printf -v joined '%s; ' "${shown[@]}"
    printf '  run env %s\n' "${joined%; }"
  else
    echo "  run env none beyond the image's"
  fi
}

drafters() {
  awk '
    function name(v, as_file) {
      gsub(/^[[:space:]"\047]+|[[:space:]"\047]+$/, "", v)
      if (as_file || v ~ /^[\/~.]/ || v ~ /:\/\// ||
        v ~ /\.(gguf|safetensors|bin|pt|pth|ckpt)$/) {
        sub(/\/+$/, "", v); sub(/.*\//, "", v)
      }
      return v
    }
    function key(f) {
      s = substr(f, 2)
      if (f ~ /^--/ && !(f in file) && !(f in repo) && (s in file || s in repo)) return s
      return f
    }
    BEGIN {
      n = split("--spec-draft-model -md --model-draft", w, " ")
      for (i = 1; i <= n; i++) file[w[i]] = 1
      n = split("--spec-draft-hf -hfd -hfrd --hf-repo-draft --speculative-model", w, " ")
      for (i = 1; i <= n; i++) repo[w[i]] = 1
    }
    {
      p = (n_t ? key(t[n_t]) : "")
      if ($0 !~ /^[-{]/ && $0 ~ /[[:space:]]/ &&
        !(p in file) && !(p in repo) && p != "--speculative-config") {
        n = split($0, w, /[[:space:]]+/)
        for (i = 1; i <= n; i++) if (w[i] != "") t[++n_t] = w[i]
      } else t[++n_t] = $0
    }
    END {
      out = ""; keys = ""
      for (i = 1; i <= n_t; i++) {
        f = t[i]; v = ""; has = 0
        if (f !~ /^-/) continue
        if (f ~ /^-[^=]*=/) {
          v = substr(f, index(f, "=") + 1); f = substr(f, 1, index(f, "=") - 1); has = 1
        } else if (i < n_t && t[i + 1] !~ /^-/) { v = t[i + 1]; has = 1 }
        f = key(f)
        if (f in file || f in repo) {
          d = (has ? name(v, f in file) : "")
          if (d == "") { d = f; sub(/^-+/, "", d); d = d " (value unread)" }
          out = out ", " d
        }
        else if (f == "--speculative-config") {
          if (match(v, /"model"[[:space:]]*:[[:space:]]*"[^"]*"/)) {
            m = substr(v, RSTART, RLENGTH); sub(/^"model"[[:space:]]*:[[:space:]]*"/, "", m)
            sub(/"$/, "", m); m = name(m, 0)
            out = out ", " (m == "" ? "speculative-config model (value unread)" : m)
          } else keys = keys ", speculative-config"
        }
        else if (f ~ /^--?(spec-|speculative-)/ || f ~ /draft/) {
          sub(/^-+/, "", f); if (index(keys ", ", ", " f ", ") == 0) keys = keys ", " f
        }
      }
      line = (out == "" ? "none" : substr(out, 3))
      if (keys != "") line = line " (speculative keys: " substr(keys, 3) ")"
      print " " line
    }'
}

preset_file() {
  local line section="" args=() parsed
  flush() {
    if [[ -n $section ]] || ((${#args[@]})); then
      printf '      [%s] flags%s\n' "${section:-top level}" \
        "$(printf '%s\n' "${args[@]}" | serving_flags)"
      printf '      [%s] drafter%s\n' "${section:-top level}" \
        "$(printf '%s\n' "${args[@]}" | drafters)"
    fi
    args=()
  }
  parsed=$(awk '
    /^[[:space:]]*([#;]|$)/ { next }
    /^[[:space:]]*\[.*\][[:space:]]*$/ {
      s = $0; sub(/^[[:space:]]*\[/, "", s); sub(/\][[:space:]]*$/, "", s)
      if (s ~ /^[\/~.]/) sub(/.*\//, "", s)
      print "S " s; sections++; next
    }
    match($0, /^[[:space:]]*-*[A-Za-z0-9_.-]+[[:space:]]*[=:]/) {
      k = substr($0, 1, RLENGTH - 1); v = substr($0, RLENGTH + 1)
      gsub(/^[[:space:]-]+|[[:space:]]+$/, "", k); gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      gsub(/^["\047]|["\047]$/, "", v)
      if (k ~ /^LLAMA_ARG_/) { k = tolower(substr(k, 11)); gsub(/_/, "-", k) }
      print "A --" k "=" v; keys++; next
    }
    /^[[:space:]]*-/ {
      k = $1; v = $0; sub(/^[[:space:]]*[^[:space:]]+[[:space:]]*/, "", v)
      print "A " k (v == "" ? "" : "=" v); keys++; next
    }
    { other++ }
    END { printf "F %d sections, %d keys, %d lines unread\n", sections, keys, other }
  ' "$1" 2>/dev/null)
  printf '    file %s: %s\n' "$2" "$(sed -n 's/^F //p' <<<"$parsed")"
  while IFS= read -r line; do
    case $line in
      'S '*)
        flush
        section=${line#S }
        ;;
      'A '*) args+=("${line#A }") ;;
    esac
  done <<<"$parsed"
  flush
}

print_entries_of_directory_without_small_files() {
  echo "    no regular file under 1 MiB; entries (name, kind, kind through a link):"
  find "$1" -mindepth 1 -maxdepth 3 -printf '      %P %y %Y\n' 2>/dev/null
}

presets() {
  local cname=$1 src dest file found=0
  while IFS=$'\t' read -r src dest; do
    [[ ${src,,} == *preset* || ${dest,,} == *preset* ]] || continue
    found=1
    if [[ -f $src && -r $src ]]; then
      printf '  preset %s (file):\n' "$dest"
      if [[ -n $(find -L "$src" -maxdepth 0 -size -1024k 2>/dev/null) ]]; then
        preset_file "$src" "$(basename "$src")"
      else
        printf '    file %s: 1 MiB or larger, not read\n' "$(basename "$src")"
      fi
    elif [[ -d $src && -r $src && -x $src ]]; then
      printf '  preset %s (directory):\n' "$dest"
      local files=()
      mapfile -t files < <(find -L "$src" -maxdepth 3 -type f -size -1024k -printf '%P\n' \
        2>/dev/null | sort)
      if ((${#files[@]} == 0)); then
        print_entries_of_directory_without_small_files "$src"
      fi
      for file in "${files[@]}"; do
        if [[ -r $src/$file ]]; then
          preset_file "$src/$file" "$file"
        else
          printf '    file %s: unreadable without root\n' "$file"
        fi
      done
    else
      skip "preset $dest (container $cname): its host-side source is unreadable without root"
    fi
    preset_clone "$src"
  done < <(docker inspect "$cname" \
    --format '{{range .Mounts}}{{.Source}}{{"\t"}}{{.Destination}}{{"\n"}}{{end}}')
  ((found)) || echo "  preset none mounted"
}

preset_clone() {
  local dir=$1 top head branch changed
  [[ -d $dir ]] || dir=$(dirname "$1") || return
  if ! have git; then
    echo "  preset clone not readable: git absent"
    return
  fi
  if ! top=$(git -C "$dir" rev-parse --show-toplevel 2>&1); then
    if [[ $top == *"not a git repository"* ]]; then
      echo "  preset clone none: not in a git clone"
    else
      printf '  preset clone not readable: %s\n' "$(head -n 1 <<<"$top")"
    fi
    return
  fi
  [[ $seen_clones == *" $top "* ]] && return
  seen_clones+="$top "
  head=$(git -C "$top" rev-parse --short HEAD 2>/dev/null)
  branch=$(git -C "$top" symbolic-ref --short -q HEAD 2>/dev/null || echo "detached") || return
  changed=$(GIT_OPTIONAL_LOCKS=0 git -C "$top" status --porcelain --untracked-files=no \
    2>/dev/null | wc -l) || return
  printf '  preset clone %s: commit %s, branch %s, %s tracked files changed\n' \
    "$top" "${head:-unknown}" "$branch" "$changed"
}

packages() {
  if have pacman; then
    local name
    for name in "$@"; do
      pacman -Q 2>/dev/null | awk -v re="^${name//\*/.*}\$" '$1 ~ re { print "package:", $0 }'
    done
  elif have dpkg-query; then
    dpkg-query -W -f '${db:Status-Abbrev} ${Package} ${Version}\n' "$@" 2>/dev/null |
      awk '$1 == "ii" { print "package:", $2, $3 }'
  else
    skip "packages ($*): no pacman or dpkg-query"
  fi
}

bind_class() {
  local ip=${1#[}
  ip=${ip%]}
  ip=${ip,,}
  ip=${ip#::ffff:}
  local IFS=.
  # shellcheck disable=SC2086 # split the dotted quad on the IFS above
  set -- $ip
  if [[ -z $ip || $ip == 0.0.0.0 || $ip == :: ]]; then
    echo all
  elif [[ $ip == 127.* || $ip == ::1 ]]; then
    echo loopback
  elif [[ $ip == fd7a:115c:a1e0:* ]]; then
    echo tailnet6
  elif [[ $# -eq 4 && $1 == 100 && $2 =~ ^[0-9]+$ ]] && ((10#$2 >= 64 && 10#$2 <= 127)); then
    echo tailnet4
  else
    echo other
  fi
}

fetch() {
  local where=$1 port=$2 path=$3
  if [[ $where == host ]]; then
    curl -s -m 3 "http://127.0.0.1:$port$path" 2>/dev/null
  else
    docker exec "$where" curl -s -m 3 "http://127.0.0.1:$port$path" 2>/dev/null
  fi
}

print_router_models() {
  local models=$1
  if have jq; then
    local id
    while read -r id; do
      jq -r --arg id "$id" \
        '.data[] | select(.id == $id) | "  model \(.id)  status \(.status.value // "served")"' \
        <<<"$models"
      if jq -e --arg id "$id" '.data[] | select(.id == $id) | .status.args | length > 0' \
        <<<"$models" >/dev/null 2>&1; then
        local margs
        margs=$(jq -r --arg id "$id" '.data[] | select(.id == $id) | .status.args[]' <<<"$models") ||
          return
        printf '    flags%s\n' "$(serving_flags <<<"$margs")"
        printf '    drafter%s\n' "$(drafters <<<"$margs")"
      fi
    done < <(jq -r '.data[].id' <<<"$models")
  else
    grep -o '"id":"[^"]*"' <<<"$models" | cut -d'"' -f4 | sed 's/^/  model /'
  fi
}

identify() {
  local where=$1 port=$2 label=$3 body models
  models=$(fetch "$where" "$port" /v1/models)
  [[ $models == *'"data"'* ]] || return 1
  printf 'endpoint %s, port %s:\n' "$label" "$port"
  if body=$(fetch "$where" "$port" /props) && [[ $body == *'"build_info"'* ]]; then
    printf '  engine llama.cpp, build %s\n' \
      "$(grep -o '"build_info":"[^"]*"' <<<"$body" | cut -d'"' -f4)"
    grep -o '"role":"[^"]*"' <<<"$body" | cut -d'"' -f4 | sed 's/^/  role /'
  elif body=$(fetch "$where" "$port" /get_server_info) && [[ $body == *'"version"'* ]]; then
    printf '  engine SGLang, version %s\n' \
      "$(grep -o '"version":"[^"]*"' <<<"$body" | head -n 1 | cut -d'"' -f4)"
  elif body=$(fetch "$where" "$port" /version) && [[ $body == *'"version"'* ]]; then
    printf '  engine vLLM, version %s\n' \
      "$(grep -o '"version":"[^"]*"' <<<"$body" | cut -d'"' -f4)"
  else
    echo "  engine unidentified (no /props, /get_server_info, or /version)"
  fi
  print_router_models "$models"
}

first_bytes() {
  local store=$1 rel hex n=0
  printf 'first 4 bytes of each GGUF in %s (hex, as text, path in the store):\n' "$store"
  while IFS= read -r rel; do
    [[ -n $rel ]] || continue
    n=$((n + 1))
    if [[ -L $store/$rel && ! -e $store/$rel ]]; then
      printf '  magic missing (a broken link)  %s\n' "$rel"
    elif [[ -r $store/$rel ]]; then
      hex=$(head -c 4 "$store/$rel" | od -An -tx1 -v | tr -s ' \n' ' ') || return
      hex=${hex# }
      printf '  magic %s  %s  %s\n' "${hex% }" \
        "$(head -c 4 "$store/$rel" | LC_ALL=C tr -c '[:print:]' '.')" "$rel"
    else
      printf '  magic unreadable without root  %s\n' "$rel"
    fi
  done
  ((n)) || echo "  none"
}

print_dgx_release_without_serial() {
  if [[ -r /etc/dgx-release ]]; then
    grep -v -e '^DGX_SERIAL_NUMBER=' -e '^$' /etc/dgx-release
  else
    skip "dgx-release: /etc/dgx-release absent"
  fi
}

print_os() {
  section os
  if [[ -r /etc/os-release ]]; then
    grep -E '^(NAME|PRETTY_NAME|ID|VERSION|VERSION_ID|BUILD_ID|IMAGE_VERSION)=' /etc/os-release
  else
    skip "os-release: /etc/os-release absent"
  fi
  print_dgx_release_without_serial
  if have omarchy-version; then
    printf 'omarchy: %s\n' "$(omarchy-version 2>&1)"
  else
    skip "omarchy: omarchy-version absent"
  fi
  printf 'arch: %s\n' "$(uname -m)"
}

print_whether_reboot_pending() {
  local running=$1
  if [[ -e /var/run/reboot-required ]]; then
    echo "reboot: pending (/var/run/reboot-required)"
    [[ -r /var/run/reboot-required.pkgs ]] && sed 's/^/  for: /' /var/run/reboot-required.pkgs
  elif [[ ! -d /usr/lib/modules/$running ]]; then
    echo "reboot: pending (the running kernel's module tree is gone)"
  else
    echo "reboot: none pending"
  fi
}

print_kernel() {
  section kernel
  local running
  running=$(uname -r) || return
  printf 'running: %s\n' "$running"
  printf 'booted: %s\n' "$(uptime -s 2>/dev/null || echo unknown)"
  echo "installed packages:"
  if have pacman; then
    pacman -Q 2>/dev/null |
      awk '$1 ~ /^linux(-[a-z0-9]+)?$/ && $1 !~ /firmware|headers|api/ { print "package:", $0 }'
  else
    packages 'linux-image-*'
  fi
  printf 'module trees: %s\n' \
    "$(find /usr/lib/modules -mindepth 1 -maxdepth 1 -printf '%f\n' 2>/dev/null | sort | tr '\n' ' ')"
  print_whether_reboot_pending "$running"
}

print_world_readable_dmi_fields() {
  local field
  for field in sys_vendor product_name product_version board_name bios_vendor bios_version \
    bios_date; do
    show_file "/sys/class/dmi/id/$field"
  done
}

print_firmware() {
  section firmware
  print_world_readable_dmi_fields
  echo "firmware packages:"
  packages 'linux-firmware*'
}

print_gpu() {
  section gpu
  if have lspci; then
    lspci -nn | grep -Ei 'vga|3d controller|display controller'
  else
    skip "lspci: absent"
  fi
  if have nvidia-smi; then
    nvidia-smi --query-gpu=name,driver_version,compute_cap,vbios_version,memory.total \
      --format=csv,noheader 2>&1 | sed 's/^/nvidia-smi: /'
    nvidia-smi 2>/dev/null | grep -o 'CUDA Version: [0-9.]*' | sed 's/^/nvidia-smi: /'
  else
    skip "nvidia-smi: absent"
  fi
  if have vulkaninfo; then
    vulkaninfo --summary 2>/dev/null |
      grep -E '^\s*(GPU[0-9]+:|apiVersion|driverVersion|deviceName|driverName|driverInfo)'
  else
    skip "vulkaninfo: absent"
  fi
  [[ -r /opt/rocm/.info/version ]] && printf 'rocm: %s\n' "$(cat /opt/rocm/.info/version)"
  echo "driver and graphics packages:"
  packages mesa 'vulkan-radeon' 'vulkan-icd-loader' 'rocm-core' 'mesa-vulkan-drivers' \
    'nvidia-driver-*' 'libnvidia-compute-*' 'cuda-toolkit-[0-9]*' 'nvidia-utils' 'amdgpu_top'
}

note_unified_gpu_memory() {
  if have nvidia-smi && nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null |
    grep -q 'N/A'; then
    echo "note: nvidia-smi reports no GPU memory (unified memory); the GPU-reachable memory is"
    echo "      the system memory above (MemTotal, MemAvailable)"
  fi
}

print_memory() {
  section memory
  grep -E '^(MemTotal|MemFree|MemAvailable|Cached|SwapTotal|SwapFree):' /proc/meminfo
  local pages card total
  if [[ -r /sys/module/ttm/parameters/pages_limit ]]; then
    pages=$(cat /sys/module/ttm/parameters/pages_limit)
    if ((pages)); then
      printf 'ttm pages_limit: %s pages (%s at 4 KiB pages)\n' "$pages" \
        "$(gib $((pages * 4096)))"
    else
      echo "ttm pages_limit: 0 (unset, the kernel's default)"
    fi
  else
    skip "ttm pages_limit: /sys/module/ttm/parameters/pages_limit absent"
  fi
  [[ -r /sys/module/amdgpu/parameters/gttsize ]] &&
    printf 'amdgpu gttsize: %s MiB (-1 is the kernel default)\n' \
      "$(cat /sys/module/amdgpu/parameters/gttsize)"
  for card in /sys/class/drm/card*/device; do
    [[ -r $card/mem_info_gtt_total ]] || continue
    total=$(cat "$card/mem_info_gtt_total")
    printf '%s: GTT total %s, VRAM total %s\n' "${card%/device}" "$(gib "$total")" \
      "$(gib "$(cat "$card/mem_info_vram_total" 2>/dev/null || echo 0)")"
  done
  note_unified_gpu_memory
}

print_nonlocal_bind() {
  if [[ -r /proc/sys/net/ipv4/ip_nonlocal_bind ]]; then
    printf 'net.ipv4.ip_nonlocal_bind: %s\n' "$(cat /proc/sys/net/ipv4/ip_nonlocal_bind)"
  else
    skip "net.ipv4.ip_nonlocal_bind: /proc/sys/net/ipv4/ip_nonlocal_bind unreadable"
  fi
  if [[ -r /proc/sys/net/ipv6/ip_nonlocal_bind ]]; then
    printf 'net.ipv6.ip_nonlocal_bind: %s\n' "$(cat /proc/sys/net/ipv6/ip_nonlocal_bind)"
  else
    echo "net.ipv6.ip_nonlocal_bind: absent"
  fi
}

print_container_runtime() {
  section container-runtime
  if have docker; then
    if docker version --format 'docker: client {{.Client.Version}}, server {{.Server.Version}}' \
      2>&1; then
      docker_ok=1
      docker info 2>&1 \
        --format 'docker: default runtime {{.DefaultRuntime}}, cgroup {{.CgroupVersion}}'
    fi
  else
    skip "docker: absent"
  fi
  if have nvidia-ctk; then
    nvidia-ctk --version 2>&1 | head -n 1
    if [[ -e /var/run/cdi/nvidia.yaml ]]; then
      printf 'cdi spec: /var/run/cdi/nvidia.yaml, modified %s\n' \
        "$(date -r /var/run/cdi/nvidia.yaml '+%F %T')"
    else
      echo "cdi spec: /var/run/cdi/nvidia.yaml absent"
    fi
  else
    skip "nvidia-ctk: absent"
  fi
  print_nonlocal_bind
}

print_container_flags() {
  local cmdline
  cmdline=$(docker inspect "$1" \
    --format '{{range .Config.Entrypoint}}{{println .}}{{end}}{{range .Config.Cmd}}{{println .}}{{end}}')
  printf '  flags%s\n' "$(serving_flags <<<"$cmdline")"
  printf '  drafter%s\n' "$(drafters <<<"$cmdline")"
}

print_container_ports() {
  local name=$1 mapping host_ip published=() networks
  networks=$(docker inspect --format '{{json .NetworkSettings.Networks}}' "$name")
  if [[ $networks != '{}' ]]; then
    while read -r mapping; do
      [[ -n $mapping ]] || continue
      host_ip=${mapping#* -> }
      published+=("${mapping%% *} $(bind_class "${host_ip%:*}")")
    done < <(docker port "$name" 2>/dev/null)
  fi
  if ((${#published[@]})); then
    printf '  published ports %s\n' "$(printf '%s\n' "${published[@]}" | sort -u | paste -sd, - |
      sed 's/,/, /g')"
  elif [[ $networks == '{}' ]]; then
    echo "  published ports none (no network)"
  else
    echo "  published ports none"
  fi
  local bindings=()
  while read -r mapping host_ip; do
    [[ -n $mapping ]] || continue
    bindings+=("$mapping $(bind_class "$host_ip")")
  done < <(docker inspect "$name" --format \
    '{{range $p, $b := .HostConfig.PortBindings}}{{range $b}}{{$p}} {{.HostIp}}{{"\n"}}{{end}}{{end}}')
  if ((${#bindings[@]})); then
    printf '  configured binds %s\n' "$(printf '%s\n' "${bindings[@]}" | sort -u | paste -sd, - |
      sed 's/,/, /g')"
  else
    echo "  configured binds none"
  fi
}

print_container() {
  local name=$1
  printf 'container %s:\n' "$name"
  docker inspect --format '  image id {{.Image}}' "$name"
  docker image inspect --format '  image created {{.Created}}' \
    "$(docker inspect --format '{{.Config.Image}}' "$name")" 2>/dev/null
  docker inspect "$name" \
    --format '{{range .Mounts}}  mount {{.Source}} -> {{.Destination}}{{"\n"}}{{end}}' |
    sed '/^$/d'
  print_container_flags "$name"
  presets "$name"
  docker inspect --format '  restart policy {{.HostConfig.RestartPolicy.Name}}' "$name"
  run_flags "$name"
  print_container_ports "$name"
}

print_engine_units() {
  local scope unit
  for scope in system user; do
    local flag=()
    [[ $scope == user ]] && flag=(--user)
    while read -r unit _; do
      [[ -n $unit ]] || continue
      printf 'unit (%s) %s: enabled=%s active=%s\n' "$scope" "$unit" \
        "$(systemctl "${flag[@]}" is-enabled "$unit" 2>/dev/null)" \
        "$(systemctl "${flag[@]}" is-active "$unit" 2>/dev/null)"
    done < <(systemctl "${flag[@]}" list-unit-files --no-legend --type=service \
      '*llama*' '*vllm*' '*sglang*' '*ollama*' '*tensorrt*' '*trtllm*' 2>/dev/null)
  done
}

print_engines() {
  section engines
  local name
  if ((docker_ok)); then
    echo "containers (name, image, state, status):"
    docker ps -a --format '  {{.Names}}  {{.Image}}  {{.State}}  {{.Status}}'
    mapfile -t names < <(docker ps -a --format '{{.Names}}')
    for name in "${names[@]}"; do
      print_container "$name"
    done
  else
    skip "containers: docker unavailable"
  fi
  if have systemctl; then
    print_engine_units
  else
    skip "systemd units: systemctl absent"
  fi
}

identify_container_endpoints() {
  local name mapping cport hport
  for name in "${names[@]}"; do
    [[ $(docker inspect --format '{{.State.Running}}' "$name") == true ]] || continue
    while read -r mapping; do
      cport=${mapping%%/*}
      hport=${mapping##*:}
      [[ $seen == *" $hport "* ]] && continue
      seen+="$hport "
      if identify host "$hport" "container $name (host port)" ||
        identify "$name" "$cport" "container $name (inside, container port)"; then
        found=1
      else
        printf 'container %s port %s: no OpenAI-compatible endpoint\n' "$name" "$cport"
      fi
    done < <(docker port "$name" 2>/dev/null | grep -v '^$')
  done
}

identify_host_process_endpoints() {
  local port
  if have ss; then
    while read -r port; do
      [[ $seen == *" $port "* ]] && continue
      identify host "$port" "host process" && found=1
    done < <(ss -Hltn | awk '{ n = split($4, a, ":"); print a[n] }' | sort -un)
  else
    skip "listening sockets: ss absent"
  fi
}

print_endpoints() {
  section endpoints
  if ! have curl; then
    skip "endpoints: curl absent"
  else
    local found=0 seen=" "
    identify_container_endpoints
    identify_host_process_endpoints
    ((found)) || echo "no engine serving: nothing OpenAI-compatible answered on loopback"
  fi
}

collect_model_stores() {
  local name src
  stores=("$HOME/.cache/huggingface/hub" "$HOME/.cache/llama.cpp" "$HOME/models" \
    /srv/models "$HOME/.ollama/models")
  if ((docker_ok)); then
    for name in "${names[@]}"; do
      while read -r src; do
        [[ -d $src ]] && stores+=("$src")
      done < <(docker inspect --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' "$name")
    done
  fi
}

print_hf_cache_store() {
  local store=$1 dir
  printf 'store %s (Hugging Face cache; snapshot size, links followed, last modified):\n' \
    "$store"
  for dir in "$store"/models--*; do
    printf '  %s  %s  %s\n' "$(du -sLh "$dir/snapshots" 2>/dev/null | cut -f1)" \
      "$(find "$dir" -printf '%TF\n' 2>/dev/null | sort | tail -n 1)" \
      "$(basename "$dir" | sed 's/^models--//; s/--/\//')"
  done
  find "$store" -mindepth 4 -maxdepth 5 -name '*.gguf' -printf '%P\n' 2>/dev/null |
    grep '^models--[^/]*/snapshots/' | sort | first_bytes "$store"
}

print_gguf_store() {
  local store=$1
  printf 'store %s (GGUF files; size, last modified):\n' "$store"
  find "$store" -maxdepth 4 -name '*.gguf' -printf '%s %TF %P\n' 2>/dev/null | sort -k3 |
    awk '{ printf "  %.1fG  %s  %s\n", $1 / 1073741824, $2, $3 }'
  find "$store" -maxdepth 4 -name '*.gguf' -printf '%P\n' 2>/dev/null | sort |
    first_bytes "$store"
}

print_models() {
  section models
  local stores=() store
  collect_model_stores
  local listed=" "
  for store in "${stores[@]}"; do
    [[ -d $store && $listed != *" $store "* ]] || continue
    listed+="$store "
    if compgen -G "$store/models--*" >/dev/null; then
      print_hf_cache_store "$store"
    elif [[ -n $(find "$store" -maxdepth 4 -name '*.gguf' -print -quit 2>/dev/null) ]]; then
      print_gguf_store "$store"
    fi
  done
  [[ $listed == " " ]] && echo "no model store found"
  if have ollama; then
    ollama list 2>&1
  else
    skip "ollama list: ollama absent"
  fi
}

print_omarchy_channel() {
  local omarchy_dir="" channel file matched installed
  for omarchy_dir in "${OMARCHY_PATH:-}" /usr/share/omarchy "$HOME/.local/share/omarchy"; do
    [[ -n $omarchy_dir && -d $omarchy_dir/default/pacman ]] && break
    omarchy_dir=""
  done
  if [[ -n $omarchy_dir ]]; then
    for file in /etc/pacman.d/mirrorlist /etc/pacman.conf; do
      matched=""
      for channel in stable rc edge; do
        if [[ $file == */mirrorlist ]]; then
          cmp -s "$file" "$omarchy_dir/default/pacman/mirrorlist-$channel" && matched+=" $channel"
        else
          cmp -s "$file" "$omarchy_dir/default/pacman/pacman-$channel.conf" && matched+=" $channel"
        fi
      done
      if [[ -n $matched ]]; then
        printf 'omarchy channel: %s matches the template of%s\n' "$file" "$matched"
      else
        printf "omarchy channel: %s matches no channel's template (edited since)\n" "$file"
      fi
    done
    installed=$(pacman -Q omarchy omarchy-dev 2>/dev/null | paste -sd, - | sed 's/,/, /g') ||
      return
    printf 'omarchy channel: package %s\n' "${installed:-none installed}"
  else
    skip "omarchy channel: no Omarchy pacman templates (default/pacman) found"
  fi
}

print_pacman_sources() {
  local lines=()
  if [[ -r /etc/pacman.d/mirrorlist ]]; then
    mapfile -t lines < <(grep -E '^[[:space:]]*Server[[:space:]]*=' /etc/pacman.d/mirrorlist |
      sed -E 's/^[[:space:]]+//')
    printf 'mirrorlist: %d servers (/etc/pacman.d/mirrorlist)\n' "${#lines[@]}"
    ((${#lines[@]})) && printf 'mirror: %s\n' "${lines[@]}"
  else
    skip "mirrorlist: /etc/pacman.d/mirrorlist unreadable"
  fi
  if [[ -r /etc/pacman.conf ]]; then
    awk '
      /^[[:space:]]*\[/ { r = $0; gsub(/[][[:space:]]/, "", r); next }
      r != "" && r != "options" && /^[[:space:]]*(Server|Include)[[:space:]]*=/ {
        l = $0; sub(/^[[:space:]]+/, "", l); print "repo " r ": " l
      }' /etc/pacman.conf
  else
    skip "pacman.conf: /etc/pacman.conf unreadable"
  fi
  print_omarchy_channel
}

print_deb822_sources() {
  awk -v f="$1" '
    function flush() {
      if (u != "") print "apt source " f ": " (t == "" ? "deb" : t) " " u " suites " s \
        (c == "" ? "" : " components " c) (e ~ /^[Nn]o$/ ? " (disabled)" : "")
      t = u = s = c = e = ""
    }
    /^[[:space:]]*$/ { flush(); next }
    /^[[:space:]]*#/ { next }
    { k = tolower($1); v = $0; sub(/^[^:]*:[[:space:]]*/, "", v) }
    k == "types:" { t = v } k == "uris:" { u = v } k == "suites:" { s = v }
    k == "components:" { c = v } k == "enabled:" { e = v }
    END { flush() }' "$1"
}

print_one_line_sources() {
  awk -v f="$1" '
    /^[[:space:]]*deb(-src)?[[:space:]]/ {
      l = $0; gsub(/\[[^]]*\]/, "", l); sub(/[[:space:]]*#.*$/, "", l)
      sub(/[[:space:]]+$/, "", l); n = split(l, w, /[[:space:]]+/)
      i = (w[1] == "" ? 2 : 1)
      out = "apt source " f ": " w[i] " " w[i + 1] " suites " w[i + 2]
      if (n >= i + 3) { out = out " components"; for (j = i + 3; j <= n; j++) out = out " " w[j] }
      print out
    }' "$1"
}

print_apt_sources() {
  local src
  for src in /etc/apt/sources.list /etc/apt/sources.list.d/*.list \
    /etc/apt/sources.list.d/*.sources; do
    [[ -e $src ]] || continue
    if [[ ! -r $src ]]; then
      skip "apt source $src: unreadable"
      continue
    fi
    if [[ $src == *.sources ]]; then
      print_deb822_sources "$src"
    else
      print_one_line_sources "$src"
    fi
  done
}

print_package_sources() {
  if have pacman; then
    print_pacman_sources
  elif have apt; then
    print_apt_sources
  else
    skip "package channel: no pacman or apt"
  fi
}

print_apt_pending() {
  local lines=() now
  now=$(date +%s) || return
  if [[ -d /var/lib/apt/lists ]]; then
    printf 'apt lists: last refreshed %s (%d days ago); the run never refreshes them\n' \
      "$(date -r /var/lib/apt/lists '+%F %T')" \
      $(((now - $(date -r /var/lib/apt/lists +%s)) / 86400))
  else
    echo "apt lists: /var/lib/apt/lists absent"
  fi
  mapfile -t lines < <(apt list --upgradable 2>/dev/null | grep '/')
  printf 'pending: %d packages (apt, from the cached lists)\n' "${#lines[@]}"
  printf '%s\n' "${lines[@]}" | awk 'NF {
    split($1, p, "/"); old = $NF; sub(/\]$/, "", old)
    print "update:", p[1], old, "->", $2, "(" p[2] ")"
  }'
}

print_checkupdates_pending() {
  local lines=() out rc
  out=$(timeout 90 checkupdates 2>&1)
  rc=$?
  case $rc in
    0)
      mapfile -t lines < <(grep -E '^[^ ]+ [^ ]+ -> [^ ]+$' <<<"$out")
      printf 'pending: %d packages (checkupdates, a fresh sync of the databases)\n' \
        "${#lines[@]}"
      ((${#lines[@]})) && printf 'update: %s\n' "${lines[@]}"
      grep -vE '^[^ ]+ [^ ]+ -> [^ ]+$|^$' <<<"$out" | sed 's/^/checkupdates: /'
      ;;
    2) echo "pending: 0 packages (checkupdates, a fresh sync of the databases)" ;;
    *) skip "pending updates: checkupdates failed (exit $rc): $(head -n 1 <<<"$out")" ;;
  esac
}

print_pending_updates() {
  if have apt; then
    print_apt_pending
  elif have checkupdates; then
    print_checkupdates_pending
  elif have pacman; then
    skip "pending updates: checkupdates absent (pacman-contrib)"
  else
    skip "pending updates: no apt or checkupdates"
  fi
}

print_updates() {
  section updates
  print_package_sources
  print_pending_updates
}

print_firmware_updates() {
  section firmware-updates
  if have fwupdmgr; then
    local fw meta
    meta=$(find /var/lib/fwupd/metadata -type f -printf '%TF\n' 2>/dev/null | sort | tail -n 1) ||
      return
    printf 'fwupd metadata: last refreshed %s\n' "${meta:-unknown}"
    fw=$(timeout 60 fwupdmgr get-updates --json --no-unreported-check --no-metadata-check \
      2>/dev/null)
    if have jq && jq -e '.Devices' >/dev/null 2>&1 <<<"$fw"; then
      jq -r '.Devices | if length == 0 then "firmware: no updates" else .[] |
        "firmware: \(.Name) \(.Version // "?") -> \([.Releases[]?.Version] | join(", "))" end' \
        <<<"$fw"
    else
      timeout 60 fwupdmgr get-updates --no-unreported-check --no-metadata-check 2>&1 |
        grep -viE 'serial|guid|device ?id|checksum' | sed '/^\s*$/d; s/^/fwupdmgr: /' | head -n 40
    fi
  else
    skip "firmware updates: fwupdmgr absent"
  fi
}

print_failed_units() {
  section units
  if have systemctl; then
    local scope state lines=()
    for scope in system user; do
      local flag=()
      [[ $scope == user ]] && flag=(--user)
      state=$(systemctl "${flag[@]}" is-system-running 2>/dev/null)
      if [[ -z $state ]]; then
        skip "failed units ($scope): no $scope manager reachable"
        continue
      fi
      printf 'systemd (%s): %s\n' "$scope" "$state"
      mapfile -t lines < <(systemctl "${flag[@]}" --failed --no-legend --plain 2>/dev/null |
        awk 'NF { print $1, "load=" $2, "active=" $3, "sub=" $4 }')
      if ((${#lines[@]})); then
        local line
        for line in "${lines[@]}"; do
          printf 'failed (%s): %s\n' "$scope" "$line"
        done
      else
        printf 'failed (%s): none\n' "$scope"
      fi
    done
  else
    skip "failed units: systemctl absent"
  fi
}

print_dangling_images() {
  local id bytes=0 lines=()
  mapfile -t lines < <(docker image ls -q --no-trunc -f dangling=true 2>/dev/null | sort -u)
  for id in "${lines[@]}"; do
    bytes=$((bytes + $(docker image inspect --format '{{.Size}}' "$id" 2>/dev/null || echo 0)))
  done
  printf 'dangling images: %d, %s\n' "${#lines[@]}" "$(gib "$bytes")"
}

print_images_no_container_uses() {
  local name id used=" " ref size unused=()
  for name in "${names[@]}"; do
    used+="$(docker inspect --format '{{.Image}}' "$name") "
  done
  while IFS=$'\t' read -r id ref size; do
    [[ -n $id && $used != *" $id "* ]] && unused+=("$ref  $size")
  done < <(docker image ls --no-trunc -f dangling=false \
    --format '{{.ID}}{{"\t"}}{{.Repository}}:{{.Tag}}{{"\t"}}{{.Size}}' 2>/dev/null)
  printf 'images no container uses: %d\n' "${#unused[@]}"
  ((${#unused[@]})) && printf '  %s\n' "${unused[@]}"
}

print_docker_disk() {
  section docker-disk
  if ((docker_ok)); then
    docker system df 2>&1
    print_dangling_images
    print_images_no_container_uses
  else
    skip "docker disk: docker unavailable"
  fi
}

print_skipped() {
  section skipped
  if ((${#skipped[@]})); then
    printf '%s\n' "${skipped[@]}"
  else
    echo "none"
  fi
}

probe() {
  local skipped=() docker_ok=0 names=() seen_clones=" "
  print_os
  print_kernel
  print_firmware
  print_gpu
  print_memory
  print_container_runtime
  print_engines
  print_endpoints
  print_models
  print_updates
  print_firmware_updates
  print_failed_units
  print_docker_disk
  print_skipped
}

redact() {
  sed -E \
    -e 's/(^|[^0-9.])100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])(\.[0-9]{1,3}){2}/\1[tailnet-ipv4]/g' \
    -e '/^(package|update): /!{' -e ':a' \
    -e 's/(^|[^0-9.])([0-9]{1,3}\.){3}[0-9]{1,3}($|[^0-9.]|\.$|\.[^0-9])/\1[ipv4]\3/' -e 'ta' -e '}' \
    -e 's/[Ff][Dd]7[Aa]:115[Cc]:[Aa]1[Ee]0:[0-9a-fA-F:]*/[tailnet-ipv6]/g' \
    -e 's/[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[Tt][Ss]\.[Nn][Ee][Tt]/[magicdns-name]/g' \
    -e 's/\.[Tt][Ss]\.[Nn][Ee][Tt]/[magicdns-suffix]/g'
}

home_to_tilde() {
  local home=${HOME%/}
  if [[ -z $home ]]; then
    cat
    return
  fi
  HOME_PREFIX=$home awk '
    BEGIN { h = ENVIRON["HOME_PREFIX"]; n = length(h) }
    {
      rest = $0; out = ""
      while ((i = index(rest, h)) > 0) {
        before = (i > 1) ? substr(rest, i - 1, 1) : (out == "" ? "" : substr(out, length(out), 1))
        after = substr(rest, i + n, 1)
        if (before !~ /[A-Za-z0-9._\/~-]/ && after !~ /[A-Za-z0-9._~-]/) {
          out = out substr(rest, 1, i - 1) "~"
        } else {
          out = out substr(rest, 1, i - 1 + n)
        }
        rest = substr(rest, i + n)
      }
      print out rest
    }'
}

probe </dev/null 2>&1 | redact | home_to_tilde
