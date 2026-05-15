#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$REPO_ROOT/.tmp"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

download() {
  local url="$1"
  local out="$2"
  curl -sSf --retry 3 --connect-timeout 10 "$url" -o "$out"
}

normalize_rule_lines() {
  sed -e 's/\r$//' \
  | grep -vE '^[[:space:]]*$' \
  | grep -vE '^[[:space:]]*#' \
  | grep -E '^(DOMAIN-SUFFIX|DOMAIN-KEYWORD|IP-CIDR),' || true
}

merge_sorted_unique() {
  sort | uniq
}

write_clash_yaml_from_list() {
  local list_file="$1"
  local target_yaml="$2"

  mkdir -p "$(dirname "$target_yaml")"

  {
    echo "payload:"
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      echo "  - $line"
    done < "$list_file"
  } > "$target_yaml"
}

merge_category() {
  local category="$1"
  local subdir="$2"
  local upstream_file="$3"
  local custom_file="$4"

  local surge_target="$REPO_ROOT/surge/rules/$subdir/${category}.list"
  local loon_target="$REPO_ROOT/loon/rules/$subdir/${category}.list"
  local clash_target="$REPO_ROOT/clash/rules/$subdir/${category}.yaml"

  mkdir -p "$(dirname "$surge_target")" "$(dirname "$loon_target")" "$(dirname "$clash_target")"

  local tmp_list=""
  tmp_list="$(mktemp)"
  trap 'rm -f "$tmp_list"' RETURN

  {
    [ -f "$surge_target" ] && cat "$surge_target" | normalize_rule_lines || true
    [ -f "$custom_file" ] && cat "$custom_file" | normalize_rule_lines || true
    cat "$upstream_file" | normalize_rule_lines
  } | merge_sorted_unique > "$tmp_list"

  cp "$tmp_list" "$surge_target"
  cp "$tmp_list" "$loon_target"
  write_clash_yaml_from_list "$tmp_list" "$clash_target"
}

main() {
  require_cmd curl
  require_cmd sed
  require_cmd grep
  require_cmd sort
  require_cmd uniq

  mkdir -p "$TMP_DIR"

  declare -A UPSTREAM_SURGE=(
    [ai]="https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Surge/OpenAI/OpenAI.list"
    [streaming]="https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Surge/GlobalMedia/GlobalMedia.list"
    [dev]="https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Surge/GitHub/GitHub.list"
    [ads]="https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Surge/AdvertisingLite/AdvertisingLite.list"
    [cn-domain]="https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Surge/China/China.list"
  )

  local key url upstream_file subdir custom_file
  for key in "${!UPSTREAM_SURGE[@]}"; do
    url="${UPSTREAM_SURGE[$key]}"
    upstream_file="$TMP_DIR/${key}_upstream.list"

    if ! download "$url" "$upstream_file"; then
      echo "warning: download failed: $key ($url)" >&2
      continue
    fi

    case "$key" in
      ai|streaming|dev)
        subdir="proxy"
        custom_file="$REPO_ROOT/surge/rules/custom/my-proxy.list"
        ;;
      ads)
        subdir="reject"
        custom_file="/dev/null"
        ;;
      cn-domain)
        subdir="direct"
        custom_file="$REPO_ROOT/surge/rules/custom/my-direct.list"
        ;;
      *)
        echo "warning: unknown category: $key" >&2
        continue
        ;;
    esac

    merge_category "$key" "$subdir" "$upstream_file" "$custom_file"
  done

  rm -rf "$TMP_DIR"
}

main "$@"
