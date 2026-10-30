#!/usr/bin/env bash
# Probes one host's serving stack, read-only and without root, for the hosting-upgrades skill.
# It runs on the host, fed over ssh from the machine running the skill:
#
#   ssh <host> bash -s < probe.sh
#
# It prints plain labeled sections (== name ==): the OS, the kernel, firmware and BIOS, the GPU
# and its driver or Mesa stack, memory and the GPU-reachable ceiling, the container runtime, the
# engine containers (with their presets' serving keys) and systemd units, each running engine's
# build and served models, the models in the host's local stores, and what the host has fallen
# behind on: pending package and firmware updates, failed units, and docker's disk. A probe whose
# command is absent prints "skipped:" and the run goes on; the last section lists every skip.
#
# It never calls sudo and prints no network address. It runs no ip, tailscale, or hostname -I;
# it reads listening ports from ss -Hltn and docker port and drops the address from each, and
# reports a container's published and configured ports by bind class (tailnet4, tailnet6, all,
# loopback, other), never by address. Engine endpoints are reached on 127.0.0.1 only, from the
# host or from inside the engine's container. A final guard redacts any IPv4 address, tailnet
# IPv6 address, or MagicDNS name that slips through, so the output can be committed as is.
#
# The whole script is one function, called on its last line with stdin from /dev/null: bash reads
# the script from stdin, so a command that reads stdin (docker exec) would otherwise eat the rest.
set -u

probe() {
  local skipped=()

  section() { printf '\n== %s ==\n' "$1"; }
  have() { command -v "$1" >/dev/null 2>&1; }
  skip() {
    printf 'skipped: %s\n' "$1"
    skipped+=("$1")
  }
  # Prints a file's contents under its path, or says it is absent.
  show_file() {
    if [[ -r $1 ]]; then
      printf '%s: %s\n' "$1" "$(tr -d '\n' <"$1")"
    else
      printf '%s: absent\n' "$1"
    fi
  }
  gib() { awk -v b="$1" 'BEGIN { printf "%.1f GiB", b / 1073741824 }'; }

  # Reads an engine's launch arguments, one per line, and prints on one line only the flags that
  # shape serving (context, parallel slots, batching, offload, attention, KV cache and its
  # checkpoints, memory, sampling), each with its value. Only these flags print, so no model path,
  # address, alias, or key on the command line reaches the output. Both --flag value and
  # --flag=value forms are read.
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
          "--cache-ram -cram --ctx-checkpoints --swa-checkpoints --checkpoint-min-step " \
          "--cache-prompt --no-cache-prompt --context-shift --no-context-shift --keep " \
          "--models-max --sleep-idle-seconds --mmproj-offload --no-mmproj-offload " \
          "--draft-max --draft-min --draft-p-min --n-predict -n --jinja --no-jinja " \
          "--reasoning-format --reasoning-budget --temp --top-k --top-p --min-p --typical " \
          "--top-nsigma --repeat-penalty --repeat-last-n --presence-penalty " \
          "--frequency-penalty --dry-multiplier --xtc-probability --xtc-threshold --seed", w, " ")
        for (i = 1; i <= n; i++) want[w[i]] = 1
      }
      { t[NR] = $0 }
      END {
        out = ""
        for (i = 1; i <= NR; i++) {
          f = t[i]; v = ""
          if (f ~ /^-[^=]*=/) { v = " " substr(f, index(f, "=") + 1); f = substr(f, 1, index(f, "=") - 1) }
          else if (i < NR && t[i + 1] !~ /^-/) v = " " t[i + 1]
          # A preset key reaches here as --<key>, so a short key (c, np) arrives as --c: read it
          # as its short flag.
          if (!(f in want) && f ~ /^--/ && substr(f, 2) in want) f = substr(f, 2)
          if (f in want) out = out " " f v
        }
        print (out == "" ? " none of the serving flags" : out)
      }'
  }

  # Reads one preset file (a llama.cpp router's --models-preset INI: [section] headers, each a
  # model the router lists or [*] for every model, over key = value lines whose keys are the
  # long flag names without their dashes) and prints its shape, then each section's keys through
  # serving_flags, so no key outside the filter prints its value. A section prints by its name, the
  # model the router lists; a name that is a path (/..., ~/..., ./...) prints by its last part only.
  # A key may also be a flag (--ctx-size) or its environment name (LLAMA_ARG_CTX_SIZE); both are
  # read as the flag. A line in no form above is counted as unread, never printed.
  preset_file() {
    local line section="" args=() parsed
    flush() {
      if [[ -n $section ]] || ((${#args[@]})); then
        printf '      [%s] flags%s\n' "${section:-top level}" \
          "$(printf '%s\n' "${args[@]}" | serving_flags)"
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

  # Prints each preset an engine container mounts (a mount whose source or destination names a
  # preset), read from the host-side source without root: a file, or each file in a directory.
  presets() {
    local cname=$1 src dest file found=0
    while IFS=$'\t' read -r src dest; do
      [[ ${src,,} == *preset* || ${dest,,} == *preset* ]] || continue
      found=1
      if [[ -f $src && -r $src ]]; then
        printf '  preset %s (file):\n' "$dest"
        # The same bound as a directory's files: a preset is small, and anything larger is not one.
        if [[ -n $(find -L "$src" -maxdepth 0 -size -1024k 2>/dev/null) ]]; then
          preset_file "$src" "$(basename "$src")"
        else
          printf '    file %s: 1 MiB or larger, not read\n' "$(basename "$src")"
        fi
      elif [[ -d $src && -r $src && -x $src ]]; then
        printf '  preset %s (directory):\n' "$dest"
        # Links are followed: a preset directory may link its files from elsewhere.
        local files=()
        mapfile -t files < <(find -L "$src" -maxdepth 3 -type f -size -1024k -printf '%P\n' \
          2>/dev/null | sort)
        # With none, each entry's name and kind, by find's letters (f file, d directory, l link,
        # and through a link N for a missing target): never a link's target, which is a path.
        if ((${#files[@]} == 0)); then
          echo "    no regular file under 1 MiB; entries (name, kind, kind through a link):"
          find "$src" -mindepth 1 -maxdepth 3 -printf '      %P %y %Y\n' 2>/dev/null
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
    done < <(docker inspect "$cname" \
      --format '{{range .Mounts}}{{.Source}}{{"\t"}}{{.Destination}}{{"\n"}}{{end}}')
    ((found)) || echo "  preset none mounted"
  }

  # Prints the installed version of each named package (globs allowed), on pacman or dpkg hosts,
  # as "package: <name> <version>" lines, which the guard reads as versions, not addresses.
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

  section os
  if [[ -r /etc/os-release ]]; then
    grep -E '^(NAME|PRETTY_NAME|ID|VERSION|VERSION_ID|BUILD_ID|IMAGE_VERSION)=' /etc/os-release
  else
    skip "os-release: /etc/os-release absent"
  fi
  # DGX OS's release file names the software build and OTA version; its serial number stays out.
  if [[ -r /etc/dgx-release ]]; then
    grep -v -e '^DGX_SERIAL_NUMBER=' -e '^$' /etc/dgx-release
  else
    skip "dgx-release: /etc/dgx-release absent"
  fi
  if have omarchy-version; then
    printf 'omarchy: %s\n' "$(omarchy-version 2>&1)"
  else
    skip "omarchy: omarchy-version absent"
  fi
  printf 'arch: %s\n' "$(uname -m)"

  section kernel
  local running
  running=$(uname -r)
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
  # Debian and Ubuntu leave a marker; elsewhere an upgraded kernel removes the running one's
  # module tree, which says a reboot is pending just as well.
  if [[ -e /var/run/reboot-required ]]; then
    echo "reboot: pending (/var/run/reboot-required)"
    [[ -r /var/run/reboot-required.pkgs ]] && sed 's/^/  for: /' /var/run/reboot-required.pkgs
  elif [[ ! -d /usr/lib/modules/$running ]]; then
    echo "reboot: pending (the running kernel's module tree is gone)"
  else
    echo "reboot: none pending"
  fi

  section firmware
  # Only the world-readable DMI fields; the serial-number fields need root and stay out.
  local field
  for field in sys_vendor product_name product_version board_name bios_vendor bios_version \
    bios_date; do
    show_file "/sys/class/dmi/id/$field"
  done
  echo "firmware packages:"
  packages 'linux-firmware*'

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
  # GB10's GPU shares the system memory and nvidia-smi reports none of it, so its ceiling is
  # MemTotal and MemAvailable above.
  if have nvidia-smi && nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null |
    grep -q 'N/A'; then
    echo "note: nvidia-smi reports no GPU memory (unified memory); the GPU-reachable memory is"
    echo "      the system memory above (MemTotal, MemAvailable)"
  fi

  section container-runtime
  local docker_ok=0
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

  # Whether a process may bind an address the host doesn't hold yet, one key per address family:
  # 1 lets a container that binds the tailnet address of that family start before Tailscale has
  # assigned it. The IPv6 key is absent on a kernel without IPv6.
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

  section engines
  local name names=()
  # The kind of address a published port binds, never the address: tailnet4 (100.64.0.0/10),
  # tailnet6 (fd7a:115c:a1e0::/48), all (0.0.0.0, ::, or no address given), loopback
  # (127.0.0.0/8, ::1), or other. The family matters because each has its own ip_nonlocal_bind
  # key. The address is dropped here, before anything prints; the redact guard is the backstop.
  bind_class() {
    local ip=${1#[}
    ip=${ip%]}
    ip=${ip,,}
    ip=${ip#::ffff:} # an IPv4-mapped IPv6 address classes as its IPv4 address
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
  if ((docker_ok)); then
    echo "containers (name, image, state, status):"
    docker ps -a --format '  {{.Names}}  {{.Image}}  {{.State}}  {{.Status}}'
    mapfile -t names < <(docker ps -a --format '{{.Names}}')
    for name in "${names[@]}"; do
      printf 'container %s:\n' "$name"
      docker inspect --format '  image id {{.Image}}' "$name"
      docker image inspect --format '  image created {{.Created}}' \
        "$(docker inspect --format '{{.Config.Image}}' "$name")" 2>/dev/null
      docker inspect "$name" \
        --format '{{range .Mounts}}  mount {{.Source}} -> {{.Destination}}{{"\n"}}{{end}}' |
        sed '/^$/d'
      # The container's command line, filtered to its serving flags (an engine's configuration).
      printf '  flags%s\n' "$(docker inspect "$name" \
        --format '{{range .Config.Entrypoint}}{{println .}}{{end}}{{range .Config.Cmd}}{{println .}}{{end}}' |
        serving_flags)"
      presets "$name"
      # Its restart policy: a container set to restart (always, unless-stopped) is meant to run.
      docker inspect --format '  restart policy {{.HostConfig.RestartPolicy.Name}}' "$name"
      # Its ports: what it publishes now (docker port), and the bindings it is configured with
      # (HostConfig.PortBindings), each by bind class. A running container that publishes nothing,
      # or has no network at all, is the boot-order failure: healthy, but unreachable.
      local mapping host_ip published=() networks
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
    done
  else
    skip "containers: docker unavailable"
  fi
  if have systemctl; then
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
  else
    skip "systemd units: systemctl absent"
  fi

  section endpoints
  # Fetches a path from 127.0.0.1:port, on the host or, given a container, inside it.
  fetch() {
    local where=$1 port=$2 path=$3
    if [[ $where == host ]]; then
      curl -s -m 3 "http://127.0.0.1:$port$path" 2>/dev/null
    else
      docker exec "$where" curl -s -m 3 "http://127.0.0.1:$port$path" 2>/dev/null
    fi
  }
  # Prints the engine and build behind a port, and its served models; returns 1 when nothing
  # OpenAI-compatible answers there.
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
    # The router's model list carries each model's launch arguments; the id and status print, and
    # under each, its serving flags only (no path, address, or alias).
    if have jq; then
      local id
      while read -r id; do
        jq -r --arg id "$id" \
          '.data[] | select(.id == $id) | "  model \(.id)  status \(.status.value // "served")"' \
          <<<"$models"
        if jq -e --arg id "$id" '.data[] | select(.id == $id) | .status.args | length > 0' \
          <<<"$models" >/dev/null 2>&1; then
          printf '    flags%s\n' "$(jq -r --arg id "$id" \
            '.data[] | select(.id == $id) | .status.args[]' <<<"$models" | serving_flags)"
        fi
      done < <(jq -r '.data[].id' <<<"$models")
    else
      grep -o '"id":"[^"]*"' <<<"$models" | cut -d'"' -f4 | sed 's/^/  model /'
    fi
  }
  if ! have curl; then
    skip "endpoints: curl absent"
  else
    local found=0 mapping cport hport seen=" "
    # A running container's published ports: reach the host port on 127.0.0.1, or, when the
    # binding excludes loopback (a tailnet-only bind), the container port from inside it.
    for name in "${names[@]}"; do
      [[ $(docker inspect --format '{{.State.Running}}' "$name") == true ]] || continue
      while read -r mapping; do
        cport=${mapping%%/*}
        hport=${mapping##*:}
        # docker lists a port once per address family; probe it once.
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
    # Every other listening TCP port, for engines run outside containers. Only the port is read.
    local port
    if have ss; then
      while read -r port; do
        [[ $seen == *" $port "* ]] && continue
        identify host "$port" "host process" && found=1
      done < <(ss -Hltn | awk '{ n = split($4, a, ":"); print a[n] }' | sort -un)
    else
      skip "listening sockets: ss absent"
    fi
    ((found)) || echo "no engine serving: nothing OpenAI-compatible answered on loopback"
  fi

  section models
  # The common stores, plus every directory an engine container mounts that holds models.
  local stores=("$HOME/.cache/huggingface/hub" "$HOME/.cache/llama.cpp" "$HOME/models" \
    /srv/models "$HOME/.ollama/models") store dir src
  if ((docker_ok)); then
    for name in "${names[@]}"; do
      while read -r src; do
        [[ -d $src ]] && stores+=("$src")
      done < <(docker inspect --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' "$name")
    done
  fi
  local listed=" "
  for store in "${stores[@]}"; do
    [[ -d $store && $listed != *" $store "* ]] || continue
    listed+="$store "
    if compgen -G "$store/models--*" >/dev/null; then
      printf 'store %s (Hugging Face cache; snapshot size, links followed, last modified):\n' \
        "$store"
      for dir in "$store"/models--*; do
        printf '  %s  %s  %s\n' "$(du -sLh "$dir/snapshots" 2>/dev/null | cut -f1)" \
          "$(find "$dir" -printf '%TF\n' 2>/dev/null | sort | tail -n 1)" \
          "$(basename "$dir" | sed 's/^models--//; s/--/\//')"
      done
    elif [[ -n $(find "$store" -maxdepth 4 -name '*.gguf' -print -quit 2>/dev/null) ]]; then
      # A file's last-modified date is when it was written: a model can sit unused long after it.
      printf 'store %s (GGUF files; size, last modified):\n' "$store"
      find "$store" -maxdepth 4 -name '*.gguf' -printf '%s %TF %P\n' 2>/dev/null | sort -k3 |
        awk '{ printf "  %.1fG  %s  %s\n", $1 / 1073741824, $2, $3 }'
    fi
  done
  [[ $listed == " " ]] && echo "no model store found"
  if have ollama; then
    ollama list 2>&1
  else
    skip "ollama list: ollama absent"
  fi

  section updates
  # Pending package updates, read without root and without refreshing anything root keeps: apt's
  # cached lists (apt-get update is root's, and never run), or Arch's checkupdates, which syncs a
  # temporary copy of the databases as this user. Each update is an "update:" line, whose versions
  # the guard keeps, as it keeps a "package:" line's.
  local lines=() now
  now=$(date +%s)
  if have apt; then
    if [[ -d /var/lib/apt/lists ]]; then
      printf 'apt lists: last refreshed %s (%d days ago); the run never refreshes them\n' \
        "$(date -r /var/lib/apt/lists '+%F %T')" \
        $(((now - $(date -r /var/lib/apt/lists +%s)) / 86400))
    else
      echo "apt lists: /var/lib/apt/lists absent"
    fi
    mapfile -t lines < <(apt list --upgradable 2>/dev/null | grep '/')
    printf 'pending: %d packages (apt, from the cached lists)\n' "${#lines[@]}"
    # apt's line: name/suite new-version arch [upgradable from: old-version]
    printf '%s\n' "${lines[@]}" | awk 'NF {
      split($1, p, "/"); old = $NF; sub(/\]$/, "", old)
      print "update:", p[1], old, "->", $2, "(" p[2] ")"
    }'
  elif have checkupdates; then
    local out rc
    out=$(timeout 90 checkupdates 2>&1)
    rc=$?
    case $rc in
      0)
        # Only a line in checkupdates' own form (name old -> new) is an update, so a warning on
        # stderr never takes the "update:" prefix and its exemption from the IPv4 guard.
        mapfile -t lines < <(grep -E '^[^ ]+ [^ ]+ -> [^ ]+$' <<<"$out")
        printf 'pending: %d packages (checkupdates, a fresh sync of the databases)\n' \
          "${#lines[@]}"
        ((${#lines[@]})) && printf 'update: %s\n' "${lines[@]}"
        grep -vE '^[^ ]+ [^ ]+ -> [^ ]+$|^$' <<<"$out" | sed 's/^/checkupdates: /'
        ;;
      2) echo "pending: 0 packages (checkupdates, a fresh sync of the databases)" ;;
      *) skip "pending updates: checkupdates failed (exit $rc): $(head -n 1 <<<"$out")" ;;
    esac
  elif have pacman; then
    skip "pending updates: checkupdates absent (pacman-contrib)"
  else
    skip "pending updates: no apt or checkupdates"
  fi

  section firmware-updates
  # fwupd's view of the devices it can update, by name and version only: no serial numbers or
  # device IDs. "No updates" is an answer, not a skip. The metadata is never refreshed here.
  if have fwupdmgr; then
    local fw meta
    meta=$(find /var/lib/fwupd/metadata -type f -printf '%TF\n' 2>/dev/null | sort | tail -n 1)
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

  section units
  # Failed units, system and user. An engine's own units, enabled or not, are under == engines ==.
  if have systemctl; then
    local scope state
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

  section docker-disk
  # What docker holds on disk, and what of it nothing uses: dangling images (untagged layers a
  # newer pull left behind), and tagged images no container, running or stopped, was made from.
  if ((docker_ok)); then
    docker system df 2>&1
    local id bytes=0 used=" " ref size unused=()
    mapfile -t lines < <(docker image ls -q --no-trunc -f dangling=true 2>/dev/null | sort -u)
    for id in "${lines[@]}"; do
      bytes=$((bytes + $(docker image inspect --format '{{.Size}}' "$id" 2>/dev/null || echo 0)))
    done
    printf 'dangling images: %d, %s\n' "${#lines[@]}" "$(gib "$bytes")"
    for name in "${names[@]}"; do
      used+="$(docker inspect --format '{{.Image}}' "$name") "
    done
    while IFS=$'\t' read -r id ref size; do
      [[ -n $id && $used != *" $id "* ]] && unused+=("$ref  $size")
    done < <(docker image ls --no-trunc -f dangling=false \
      --format '{{.ID}}{{"\t"}}{{.Repository}}:{{.Tag}}{{"\t"}}{{.Size}}' 2>/dev/null)
    printf 'images no container uses: %d\n' "${#unused[@]}"
    ((${#unused[@]})) && printf '  %s\n' "${unused[@]}"
  else
    skip "docker disk: docker unavailable"
  fi

  section skipped
  if ((${#skipped[@]})); then
    printf '%s\n' "${skipped[@]}"
  else
    echo "none"
  fi
}

# The guard: redacts every IPv4 address, tailnet IPv6 address (fd7a:115c:a1e0::/48), and
# MagicDNS name or suffix still in the output. A "package:" or "update:" line comes from the
# package database and its four-part versions (vulkan-icd-loader 1.4.363.0) read as addresses, so
# only tailnet addresses are redacted there; every other line loses every IPv4 address, version
# or not. An address ending a sentence ("10.0.0.1.") is still an address: only a dot followed by a
# digit makes it part of a longer version. Hex and DNS names are matched in either case.
redact() {
  sed -E \
    -e 's/(^|[^0-9.])100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])(\.[0-9]{1,3}){2}/\1[tailnet-ipv4]/g' \
    -e '/^(package|update): /!{' -e ':a' \
    -e 's/(^|[^0-9.])([0-9]{1,3}\.){3}[0-9]{1,3}($|[^0-9.]|\.$|\.[^0-9])/\1[ipv4]\3/' -e 'ta' -e '}' \
    -e 's/[Ff][Dd]7[Aa]:115[Cc]:[Aa]1[Ee]0:[0-9a-fA-F:]*/[tailnet-ipv6]/g' \
    -e 's/[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[Tt][Ss]\.[Nn][Ee][Tt]/[magicdns-name]/g' \
    -e 's/\.[Tt][Ss]\.[Nn][Ee][Tt]/[magicdns-suffix]/g'
}

probe </dev/null 2>&1 | redact
