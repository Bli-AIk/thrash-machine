#!/bin/sh
set -eu

root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd -P)
for file in "$root/README.md" "$root/README_en.md" "$root/docs/development.zh-hans.md"; do
    test -s "$file"
done

for needle in \
    'git submodule update --init --recursive' \
    'FUMOS' \
    'fennel-ls' \
    'just build'
do
    grep -Fqs -- "$needle" "$root/README.md" "$root/docs/development.zh-hans.md"
done
