#!/bin/sh
set -eu

root=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd -P)

test -f "$root/mod.lua"
test -f "$root/scripts/world/maps/room1.lua"
test -f "$root/libraries/kristal-i18n/lib.lua"
test -f "$root/libraries/object-editor/lib.lua"
test -f "$root/libraries/terminal-cli/lib.lua"
test -f "$root/libraries/kristal-debug-tools/lib.lua"
test -f "$root/libraries/virtualkeyboard/lib.lua"
test -f "$root/libraries/virtualkeyboard/lib.json"
luajit -b "$root/libraries/virtualkeyboard/lib.lua" /dev/null
