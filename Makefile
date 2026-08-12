KRISTAL ?=

.PHONY: test test-static test-debug-tools test-kristal build build-love build-win build-android

test: test-static test-debug-tools

test-static:
	sh .github/scripts/static-smoke.sh
	find . -path ./.git -prune -o -path ./.emacs -prune -o -path ./.helix -prune -o \
		-path ./libraries -prune -o -path ./.build -prune -o -path ./dist -prune -o \
		-path ./.worktrees -prune -o -type f -name '*.lua' -exec \
		luajit -b {} /dev/null \;

test-debug-tools:
	sh .github/scripts/template-justfile-smoke.sh

test-kristal:
	KRISTAL="$(KRISTAL)" sh .github/scripts/run-kristal-smoke.sh

build-love:
	THRASH_MACHINE_BUILD_LOVE=1 THRASH_MACHINE_BUILD_WINDOWS_EXE=0 ./build_standalone.sh

build-win:
	THRASH_MACHINE_BUILD_LOVE=0 THRASH_MACHINE_BUILD_WINDOWS_EXE=1 ./build_standalone.sh

build:
	THRASH_MACHINE_BUILD_LOVE=1 THRASH_MACHINE_BUILD_WINDOWS_EXE=1 ./build_standalone.sh

build-android:
	./build_android.sh
