default: test

# Run the Mod with a local Kristal checkout.
run *args:
    #!/usr/bin/env bash
    set -euo pipefail
    mod_root=$(pwd -P)
    engine_root="${KRISTAL_ROOT:-}"
    if [ -z "$engine_root" ]; then
      for candidate in "$mod_root/../../Kristal" "$mod_root/../Kristal" "$HOME/Projects/LuaProjects/Kristal" "$HOME/Projects/Kristal" "$HOME/Kristal"; do
        if [ -f "$candidate/main.lua" ]; then
          engine_root=$(CDPATH= cd "$candidate" && pwd -P)
          break
        fi
      done
    fi
    if [ -z "$engine_root" ] || [ ! -f "$engine_root/main.lua" ]; then
      printf '%s\n' 'Kristal was not found; set KRISTAL_ROOT=/path/to/Kristal.' >&2
      exit 1
    fi
    exec love "$engine_root" --mod thrash-machine --auto-mod-start {{args}}

test:
    @make test

test-kristal:
    @make test-kristal

build:
    @./build_standalone.sh

build-mod:
    @./.github/scripts/build_mod.sh

clean-build:
    rm -rf .build dist
