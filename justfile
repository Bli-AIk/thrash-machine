default: test

# Run the Mod with a local Kristal checkout and shared debug tools.
run *args:
    @just --justfile libraries/kristal-debug-tools/justfile run {{ args }}

# Build and run the debug-tools GUI (developer convenience; end users run
# gui.cmd or the release binary instead).
gui:
    @just --justfile libraries/kristal-debug-tools/justfile gui

test:
    @make test

test-kristal:
    @make test-kristal

# `bash` prefix: just runs recipes via cmd on Windows; Git Bash's bash is
# on PATH with the default Git for Windows install.
build:
    @bash ./build_standalone.sh

build-android:
    @bash ./build_android.sh

build-mod:
    @bash ./.github/scripts/build_mod.sh

clean-build:
    rm -rf .build dist
