#!/bin/bash

CACHE_FILE="/tmp/quickshell_laptop_info_cache.json"
FALLBACK_LOGO="${HOME}/.config/quickshell/assets/brand.png"
LOGO_CACHE_DIR="${HOME}/.cache/quickshell/logos"

if [ -s "$CACHE_FILE" ]; then
    cat "$CACHE_FILE"
    exit 0
fi

get_brand() {
    local vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$vendor" in
        *lenovo*) echo "lenovo" ;;
        *asus*) echo "asus" ;;
        *dell*) echo "dell" ;;
        *hp*|*hewlett*) echo "hp" ;;
        *acer*) echo "acer" ;;
        *msi*) echo "msi" ;;
        *apple*) echo "apple" ;;
        *samsung*) echo "samsung" ;;
        *toshiba*) echo "toshiba" ;;
        *sony*) echo "sony" ;;
        *razer*) echo "razer" ;;
        *gigabyte*) echo "gigabyte" ;;
        *framework*) echo "framework" ;;
        *) echo "unknown" ;;
    esac
}

get_logo_path() {
    local brand=$1
    mkdir -p "$LOGO_CACHE_DIR"
    local logo_file="${LOGO_CACHE_DIR}/${brand}.png"
    if [ -f "$logo_file" ] && [ -s "$logo_file" ]; then
        echo "$logo_file"; return
    fi
    local domain=""
    case "$brand" in
        lenovo) domain="lenovo.com" ;;
        asus) domain="asus.com" ;;
        dell) domain="dell.com" ;;
        hp) domain="hp.com" ;;
        acer) domain="acer.com" ;;
        msi) domain="msi.com" ;;
        apple) domain="apple.com" ;;
        samsung) domain="samsung.com" ;;
        toshiba) domain="toshiba.com" ;;
        sony) domain="sony.com" ;;
        razer) domain="razer.com" ;;
        gigabyte) domain="gigabyte.com" ;;
        framework) domain="frame.work" ;;
    esac
    if [ -n "$domain" ]; then
        (curl -s -m 10 -o "$logo_file" "https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https%3A%2F%2F${domain}&size=128" 2>/dev/null) &
    fi
    echo "$FALLBACK_LOGO"
}

get_model() {
    local model=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
    if [ -z "$model" ] || [[ "$model" == *"System Product"* ]]; then
        model=$(cat /sys/class/dmi/id/board_name 2>/dev/null)
    fi
    echo "${model:-Unknown}"
}

get_cpu() {
    local name=$(lscpu | grep "Model name" | cut -d':' -f2 | sed -e 's/(R)//g' -e 's/(TM)//g' | xargs)
    local cores=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    local maxfreq=$(lscpu | grep "CPU max MHz" | awk '{printf "%.2f GHz", $4/1000}')
    echo "${name} (${cores}) @ ${maxfreq}"
}

get_gpu() {
    lspci | grep -i 'vga\|3d\|display' | cut -d':' -f3 | sed -e 's/Corporation //g' -e 's/\[.*\]//g' | xargs | tr '\n' ',' | sed 's/,$//'
}

get_ram() {
    free -h | awk '/^Mem:/ {print $2}' | sed 's/i//g'
}

get_swap() {
    free -h | awk '/^Swap:/ {print $2}' | sed 's/i//g'
}

get_disk() {
    local disk=$(df -h / | awk 'NR==2 {print $2}')
    local disk_type="SSD"
    if [ -f "/sys/block/sda/queue/rotational" ]; then
        [ "$(cat /sys/block/sda/queue/rotational)" -eq 1 ] && disk_type="HDD"
    fi
    echo "${disk} ${disk_type}"
}

get_disk_type() {
    local result=""
    for dev in /sys/block/sd* /sys/block/nvme* /sys/block/mmcblk*; do
        [ -d "$dev" ] || continue
        local name=$(basename "$dev")
        local rot=$(cat "$dev/queue/rotational" 2>/dev/null)
        if [[ "$name" == nvme* ]]; then
            result+="NVMe "
        elif [ "$rot" = "0" ]; then
            result+="SSD "
        else
            result+="HDD "
        fi
    done
    echo "${result:-Unknown}"
}

get_display() {
    local res=$(xrandr 2>/dev/null | grep ' connected' | grep -o '[0-9]*x[0-9]*' | head -1)
    local hz=$(xrandr 2>/dev/null | grep '\*' | grep -o '[0-9]*\.[0-9]*\*' | tr -d '*' | head -1 | cut -d'.' -f1)
    if [ -z "$res" ]; then
        res=$(cat /sys/class/drm/*/modes 2>/dev/null | head -1)
    fi
    echo "${res:-Unknown}${hz:+ @ ${hz}Hz}"
}

get_battery() {
    local bat_path=$(find /sys/class/power_supply -name "BAT*" -maxdepth 1 | head -1)
    if [ -z "$bat_path" ]; then
        echo "No Battery"
        return
    fi
    local type=$(cat "$bat_path/technology" 2>/dev/null)
    local model=$(cat "$bat_path/model_name" 2>/dev/null)
    echo "${type:-Unknown}${model:+ | $model}"
}

get_kernel() {
    uname -r
}

get_distro() {
    source /etc/os-release 2>/dev/null
    echo "${PRETTY_NAME:-Unknown}"
}

# --- GENERATE ---
BRAND=$(get_brand)
LOGO_PATH=$(get_logo_path "$BRAND")
MODEL=$(get_model)
CPU=$(get_cpu)
GPU=$(get_gpu)
RAM=$(get_ram)
SWAP=$(get_swap)
DISK=$(get_disk)
DISK_TYPE=$(get_disk_type)
DISPLAY=$(get_display)
BATTERY=$(get_battery)
KERNEL=$(get_kernel)
DISTRO=$(get_distro)

JSON_OUTPUT=$(jq -cn \
  --arg brand "$BRAND" \
  --arg logo_path "$LOGO_PATH" \
  --arg model "$MODEL" \
  --arg cpu "$CPU" \
  --arg gpu "$GPU" \
  --arg ram "$RAM" \
  --arg swap "$SWAP" \
  --arg disk "$DISK" \
  --arg disk_type "$DISK_TYPE" \
  --arg display "$DISPLAY" \
  --arg battery "$BATTERY" \
  --arg kernel "$KERNEL" \
  --arg distro "$DISTRO" \
  '{brand:$brand,logo_path:$logo_path,model:$model,cpu:$cpu,gpu:$gpu,ram:$ram,swap:$swap,disk:$disk,disk_type:$disk_type,display:$display,battery:$battery,kernel:$kernel,distro:$distro}')

echo "$JSON_OUTPUT" > "$CACHE_FILE"
echo "$JSON_OUTPUT"
