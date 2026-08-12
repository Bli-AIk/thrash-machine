#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd -P)"
THRASH_MACHINE_MOD_DIR="$ROOT"
THRASH_MACHINE_BUILD_DIR="${THRASH_MACHINE_MOD_BUILD_DIR:-$ROOT/.build/mod}"
THRASH_MACHINE_OUTPUT_DIR="${THRASH_MACHINE_OUTPUT_DIR:-$ROOT/dist}"
THRASH_MACHINE_OUTPUT_FILE="${THRASH_MACHINE_MOD_OUTPUT_FILE:-$THRASH_MACHINE_OUTPUT_DIR/thrash-machine-mod.zip}"
STAGE_DIR="$THRASH_MACHINE_BUILD_DIR/source"

command -v unzip >/dev/null
# `zip` is optional: when missing, the build-helper (LÖVE) writes the zip.

# shellcheck source=build-helper/lib.sh
source "$ROOT/build-helper/lib.sh"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR" "$THRASH_MACHINE_OUTPUT_DIR"
# Stage with tar instead of rsync (rsync is not available in Git Bash on
# Windows; tar is). Member names are "./…": a leading "./" pins a pattern to
# the mod root, slash-free patterns match basenames anywhere.
tar -cf - \
    --exclude='*.git' \
    --exclude='./.github' \
    --exclude='./.build' \
    --exclude='./dist' \
    --exclude='./.tools' \
    --exclude='./.emacs' \
    --exclude='./.helix' \
    --exclude='./.vscode' \
    --exclude='./.worktrees' \
    --exclude='./tests' \
    --exclude='./docs' \
    --exclude='./Makefile' \
    --exclude='./justfile' \
    --exclude='./build_standalone.sh' \
    --exclude='./build_android.sh' \
    --exclude='./build-helper' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='*.pyo' \
    --exclude='./release-please-config.json' \
    --exclude='./.release-please-manifest.json' \
    --exclude='./.gitmodules' \
    --exclude='./.gitignore' \
    --exclude='*.tiled-project' \
    --exclude='*.tiled-session' \
    --exclude='./libraries/kristal-debug-tools/gui' \
    --exclude='./libraries/kristal-debug-tools-gui' \
    --exclude='./libraries/kristal-debug-tools/just.cmd' \
    --exclude='./libraries/kristal-debug-tools/dist' \
    --exclude='./libraries/kristal-debug-tools/.tools' \
    -C "$ROOT" . | tar -xf - -C "$STAGE_DIR"

rm -rf "$STAGE_DIR/libraries/kristal-object-selector-plus"
rm -rf "$STAGE_DIR/libraries/terminal-cli"
rm -rf "$STAGE_DIR/libraries/kristal-debug-tools"
run_helper patch-mod-manifest "$STAGE_DIR/mod.json" false false
zip_dir "$THRASH_MACHINE_OUTPUT_FILE" "$STAGE_DIR" ""
test -s "$THRASH_MACHINE_OUTPUT_FILE"
unzip -t "$THRASH_MACHINE_OUTPUT_FILE" >/dev/null
unzip -Z1 "$THRASH_MACHINE_OUTPUT_FILE" | grep -Fx 'mod.json' >/dev/null
printf 'Created Mod package: %s\n' "$THRASH_MACHINE_OUTPUT_FILE"
