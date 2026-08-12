default: test

# Run the Mod with a local Kristal checkout and shared debug tools.
run *args:
    @just --justfile libraries/kristal-debug-tools/justfile run {{ args }}

# Build and run the debug-tools GUI (developer convenience; end users run
# gui.cmd or the release binary instead).
gui:
    @just --justfile libraries/kristal-debug-tools/justfile gui

# Run the GUI's Go test suite.
test-go:
    @just --justfile libraries/kristal-debug-tools/justfile test-go

test:
    @make test

test-kristal:
    @make test-kristal

build:
    @./build_standalone.sh

build-android:
    @./build_android.sh

build-mod:
    @./.github/scripts/build_mod.sh

clean-build:
    rm -rf .build dist
