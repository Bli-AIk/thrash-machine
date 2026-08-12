# Shared wiring for the build scripts: locate LÖVE (the user already has it
# to run the mod) and run build-helper/main.lua — no Python needed.
#
# Source this after setting THRASH_MACHINE_MOD_DIR.

resolve_love() {
    if [ -n "${LOVE:-}" ] && command -v "$LOVE" >/dev/null 2>&1; then
        command -v "$LOVE"
        return
    fi
    if command -v love >/dev/null 2>&1; then
        command -v love
        return
    fi
    for dir in "$PROGRAMFILES/LOVE" "$LOCALAPPDATA/Programs/LOVE"; do
        if [ -f "$dir/love.exe" ]; then
            printf '%s\n' "$dir/love.exe"
            return
        fi
    done
    return 1
}

THRASH_MACHINE_LOVE="${THRASH_MACHINE_LOVE:-}"
if [ -z "$THRASH_MACHINE_LOVE" ]; then
    THRASH_MACHINE_LOVE="$(resolve_love)" || {
        printf '%s\n' 'Missing required command: love (LÖVE). Install it from https://love2d.org' >&2
        exit 1
    }
fi

run_helper() {
    # LÖVE 11 drops positional args after the game path, so pass them in a
    # temp file (one argument per line).
    local args_file
    args_file="$(mktemp)" || exit 1
    printf '%s\n' "$@" > "$args_file"
    THRASH_MACHINE_HELPER_ARGS="$args_file" \
        "$THRASH_MACHINE_LOVE" "$THRASH_MACHINE_MOD_DIR/build-helper"
    status=$?
    rm -f "$args_file"
    return $status
}
