KRISTAL ?=

.PHONY: test test-static test-debug-tools test-kristal build build-love build-win build-android build-android-wrap

test: test-static test-debug-tools

test-static:
	sh .github/scripts/static-smoke.sh
	luajit tests/optional_libraries.lua
	luajit tests/i18n_item_key_api.lua
	sh tests/build_helper_manifest.sh
	sh tests/refactor_boundaries.sh
	if command -v pwsh >/dev/null 2>&1; then pwsh -NoProfile -File tests/windows_build.ps1; else printf '%s\n' 'pwsh unavailable: skipping Windows build smoke'; fi
	find . -path ./.git -prune -o -path ./.emacs -prune -o -path ./.helix -prune -o \
		-path ./libraries -prune -o -path ./.build -prune -o -path ./dist -prune -o \
		-path ./.worktrees -prune -o -type f -name '*.lua' -print0 | \
		xargs -0 -I{} luajit -b -l {} >/dev/null
	find libraries/kristal-i18n libraries/MagicalGlassRedux libraries/UndertaleMonstersRecreation \
		-type f -name '*.lua' -print0 | xargs -0 -I{} luajit -b -l {} >/dev/null

test-debug-tools:
	sh .github/scripts/template-justfile-smoke.sh

test-kristal:
	KRISTAL="$${KRISTAL:-$$(sh .github/scripts/find-kristal.sh 2>/dev/null)}" sh .github/scripts/run-kristal-smoke.sh

build-love:
	THRASH_MACHINE_BUILD_LOVE=1 THRASH_MACHINE_BUILD_WINDOWS_EXE=0 ./tools/build_standalone.sh

build-win:
	THRASH_MACHINE_BUILD_LOVE=0 THRASH_MACHINE_BUILD_WINDOWS_EXE=1 ./tools/build_standalone.sh

build:
	THRASH_MACHINE_BUILD_LOVE=1 THRASH_MACHINE_BUILD_WINDOWS_EXE=1 ./tools/build_standalone.sh

build-android:
	./tools/build_android.sh

build-android-wrap:
	./tools/build_android_wrap.sh
