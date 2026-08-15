#!/usr/bin/env bash
set -euo pipefail

# Package the full source tree (including all checked-out git submodules) for
# a release. Unlike GitHub's auto-generated source archives, these archives
# contain the submodule contents, so the mod is complete and usable as-is.
#
# Usage: package_full_source.sh <tag>
#   Outputs thrash-machine-<tag>-full-source.tar.gz / .zip into $ROOT/dist
#   (override with THRASH_MACHINE_OUTPUT_DIR).

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd -P)"
TAG="${1:?usage: package_full_source.sh <tag>}"
OUTPUT_DIR="${THRASH_MACHINE_OUTPUT_DIR:-$ROOT/dist}"
mkdir -p "$OUTPUT_DIR"

# Exclude VCS metadata and local build artifacts; patterns without a slash
# match the basename at any depth (GNU tar).
TAR_EXCLUDES=(
  --exclude='.git'
  --exclude='.build'
  --exclude='dist*'
  --exclude='.tools'
  --exclude='.worktrees'
)

tar "${TAR_EXCLUDES[@]}" -czf "$OUTPUT_DIR/thrash-machine-$TAG-full-source.tar.gz" -C "$ROOT" .
test -s "$OUTPUT_DIR/thrash-machine-$TAG-full-source.tar.gz"

# zip is optional but preferred for Windows users; -x patterns without a slash
# match any path component.
( cd "$ROOT" && zip -qr "$OUTPUT_DIR/thrash-machine-$TAG-full-source.zip" . \
    -x '.git*' '.build*' 'dist*' '.tools*' '.worktrees*' )
test -s "$OUTPUT_DIR/thrash-machine-$TAG-full-source.zip"

printf 'Created full source packages:\n  %s\n  %s\n' \
  "$OUTPUT_DIR/thrash-machine-$TAG-full-source.tar.gz" \
  "$OUTPUT_DIR/thrash-machine-$TAG-full-source.zip"
