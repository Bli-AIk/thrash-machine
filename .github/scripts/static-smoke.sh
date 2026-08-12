#!/bin/sh
set -eu

root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)
found=$(find "$root" \
    -path "$root/.git" -prune -o \
    -path "$root/.emacs" -prune -o \
    -path "$root/.helix" -prune -o \
    -path "$root/libraries" -prune -o \
    -path "$root/.build" -prune -o \
    -path "$root/dist" -prune -o \
    -type f -name '*.lua' -print)
test -z "$found" || {
    printf 'Author-owned Lua remains:\n%s\n' "$found" >&2
    exit 1
}

test -f "$root/mod.fnl"
test -f "$root/flsproject.fnl"
test -f "$root/fnl/thrash_machine/bridge.fnl"
test -f "$root/libraries/fumos/lib.lua"
test -f "$root/libraries/kristal-i18n/lib.lua"
test -f "$root/libraries/kristal-object-selector-plus/lib.lua"
test -f "$root/libraries/kristal-debug-tools/lib.lua"
test -f "$root/.emacs/init.el"
test -f "$root/.helix/languages.toml"
test "$(git -C "$root" config -f .gitmodules --get submodule.libraries/fumos.url)" = \
    https://github.com/Bli-AIk/fumos.git
test "$(git -C "$root" config -f .gitmodules --get submodule.libraries/kristal-object-selector-plus.url)" = \
    https://github.com/Bli-AIk/kristal-object-selector-plus.git
