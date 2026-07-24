KRISTAL ?=

.PHONY: test test-static test-docs test-kristal

test: test-static test-docs

test-static:
	sh tests/assert-lua-template.sh
	find . -path ./.git -prune -o -path ./.emacs -prune -o -path ./.helix -prune -o \
		-path ./libraries -prune -o -path ./.build -prune -o -path ./dist -prune -o \
		-path ./.worktrees -prune -o -type f -name '*.lua' -exec \
		luajit -b {} /dev/null \;

test-docs:
	sh tests/docs-smoke.sh

test-kristal:
	KRISTAL="$(KRISTAL)" sh tests/run-kristal.sh
