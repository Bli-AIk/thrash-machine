default: test

# Run the Mod with a local Kristal checkout and shared debug tools.
run *args:
    @just --justfile libraries/kristal-debug-tools/justfile run {{ args }}

# The kristal-debug-tools GUI is for end users without just:
#   - Windows: run gui.cmd (downloads the release binary on first use).
#   - Developers: just --justfile libraries/kristal-debug-tools/justfile
#     test-go runs the GUI's Go test suite.

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
