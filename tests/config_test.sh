#!/usr/bin/env bash

set -euo pipefail

readonly REPOSITORY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly CONFIG_FILE="$REPOSITORY_DIR/config"
readonly SWAY_BIN="${SWAY_BIN:-sway}"

assert_config_contains() {
  local expected="$1"

  if ! grep -Fqx -- "$expected" "$CONFIG_FILE"; then
    printf 'Expected config to contain: %s\n' "$expected" >&2
    return 1
  fi
}

for script in start-apps scratchpad notepad docs dock; do
  if [[ ! -x "$REPOSITORY_DIR/scripts/$script" ]]; then
    printf 'Expected scripts/%s to be executable.\n' "$script" >&2
    exit 1
  fi
done

assert_config_contains 'bindsym $mod+s exec $HOME/.config/sway/scripts/scratchpad'
assert_config_contains 'bindsym $mod+w exec $HOME/.config/sway/scripts/notepad'
assert_config_contains 'bindsym $mod+x exec $HOME/.config/sway/scripts/docs'
assert_config_contains 'exec $HOME/.config/sway/scripts/start-apps'

if grep -Eq '\$HOME/\.scripts/(scratchpad|notepad|docs)' "$CONFIG_FILE"; then
  printf 'Expected Sway scratchpad bindings not to depend on shared scripts.\n' >&2
  exit 1
fi

if [[ -x "$SWAY_BIN" ]] || command -v "$SWAY_BIN" >/dev/null 2>&1; then
  "$SWAY_BIN" --validate --config "$CONFIG_FILE"
else
  printf 'SKIP: sway is unavailable; path checks passed without parser validation.\n'
fi
