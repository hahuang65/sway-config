#!/usr/bin/env bash

set -euo pipefail

readonly REPOSITORY_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly LEGACY_SCRIPT_DIR="$(cd -- "$REPOSITORY_DIR/../scripts/linux" && pwd)"
readonly TEST_ROOT="$(mktemp -d)"
readonly MOCK_BIN="$TEST_ROOT/bin"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$MOCK_BIN"
cat >"$MOCK_BIN/sudo" <<'MOCK'
#!/bin/sh
exit 0
MOCK
chmod +x "$MOCK_BIN/sudo"

run_installer() {
  local test_home="$1"

  (
    cd "$REPOSITORY_DIR"
    HOME="$test_home" PATH="$MOCK_BIN:$PATH" ./install.sh
  )
}

assert_link_target() {
  local link_path="$1"
  local expected_target="$2"

  [[ -L "$link_path" ]]
  [[ "$(readlink "$link_path")" == "$expected_target" ]]
}

readonly MIGRATION_HOME="$TEST_ROOT/migration-home"
mkdir -p "$MIGRATION_HOME/.scripts"
for script in scratchpad notepad docs dock; do
  ln -s "$LEGACY_SCRIPT_DIR/$script" "$MIGRATION_HOME/.scripts/$script"
done

run_installer "$MIGRATION_HOME"

assert_link_target "$MIGRATION_HOME/.config/sway/config" "$REPOSITORY_DIR/config"
assert_link_target "$MIGRATION_HOME/.config/sway/scripts" "$REPOSITORY_DIR/scripts"
[[ -x "$MIGRATION_HOME/.config/sway/scripts/start-apps" ]]
[[ ! -e "$MIGRATION_HOME/.scripts/scratchpad" && ! -L "$MIGRATION_HOME/.scripts/scratchpad" ]]
[[ ! -e "$MIGRATION_HOME/.scripts/notepad" && ! -L "$MIGRATION_HOME/.scripts/notepad" ]]
[[ ! -e "$MIGRATION_HOME/.scripts/docs" && ! -L "$MIGRATION_HOME/.scripts/docs" ]]
assert_link_target "$MIGRATION_HOME/.scripts/dock" "$REPOSITORY_DIR/scripts/dock"

readonly SAFETY_HOME="$TEST_ROOT/safety-home"
readonly UNRELATED_TARGET="$TEST_ROOT/unrelated"
mkdir -p "$SAFETY_HOME/.scripts"
printf 'keep scratchpad\n' >"$SAFETY_HOME/.scripts/scratchpad"
printf 'keep dock\n' >"$SAFETY_HOME/.scripts/dock"
printf 'unrelated\n' >"$UNRELATED_TARGET"
ln -s "$UNRELATED_TARGET" "$SAFETY_HOME/.scripts/notepad"
ln -s "$TEST_ROOT/missing-unrelated" "$SAFETY_HOME/.scripts/docs"

run_installer "$SAFETY_HOME"

grep -Fqx 'keep scratchpad' "$SAFETY_HOME/.scripts/scratchpad"
grep -Fqx 'keep dock' "$SAFETY_HOME/.scripts/dock"
assert_link_target "$SAFETY_HOME/.scripts/notepad" "$UNRELATED_TARGET"
assert_link_target "$SAFETY_HOME/.scripts/docs" "$TEST_ROOT/missing-unrelated"
