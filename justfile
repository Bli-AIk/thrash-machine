default: test

# Run the Mod with a local Kristal checkout and shared debug tools.
run *args:
    @just --justfile libraries/kristal-debug-tools/justfile run {{ args }}

# --- kristal-debug-tools (libraries/) ---

# Open the debug-tools GUI (single webview window).
gui-run:
    @just --justfile libraries/kristal-debug-tools/justfile gui-run

# Build the GUI + kristal-run for the host platform.
gui-build:
    @just --justfile libraries/kristal-debug-tools/justfile gui-build

# Build Windows GUI + kristal-run.exe (with embedded just).
gui-build-windows:
    @just --justfile libraries/kristal-debug-tools/justfile gui-build-windows

# Run the Go test suite of the debug-tools GUI.
test-go:
    @just --justfile libraries/kristal-debug-tools/justfile test-go

# --- mod build ---

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
