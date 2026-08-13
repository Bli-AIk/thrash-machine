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

zip_dir() {
    local output="$1" source="$2" prefix="${3:-}" total _count=0

    # The zip invocations below run in a subshell after cd'ing into the
    # source directory, so resolve a relative output path against the caller's
    # working directory first (CI passes e.g. THRASH_MACHINE_OUTPUT_DIR=dist-win).
    case "$output" in
        /*) ;;
        *) output="$(pwd -P)/$output" ;;
    esac

    mkdir -p "$(dirname "$output")"
    rm -f "$output"

    if command -v zip >/dev/null 2>&1; then
        if [ -t 1 ]; then
            total="$(find "$source" -mindepth 1 2>/dev/null | wc -l | tr -d '[:space:]')"
            total="${total:-0}"
            printf '\r[build] zip %s: 0/%s' "$(basename "$output")" "$total" >&2
            if [ -n "$prefix" ]; then
                (cd "$(dirname "$source")" && zip -9 -r "$output" "$(basename "$source")") |
                    while IFS= read -r _; do
                        printf '\r[build] zip %s: %s/%s' "$(basename "$output")" "$((_count += 1))" "$total" >&2
                    done
            else
                (cd "$source" && zip -9 -r "$output" .) |
                    while IFS= read -r _; do
                        printf '\r[build] zip %s: %s/%s' "$(basename "$output")" "$((_count += 1))" "$total" >&2
                    done
            fi
            printf '\r[build] zip %s: done (%s files)\n' "$(basename "$output")" "$total" >&2
        else
            if [ -n "$prefix" ]; then
                (cd "$(dirname "$source")" && zip -9 -q -r "$output" "$(basename "$source")")
            else
                (cd "$source" && zip -9 -q -r "$output" .)
            fi
        fi
    else
        printf '[build] zip not found; using LÖVE stored-zip helper for %s\n' \
            "$(basename "$output")" >&2
        run_helper zip-dir "$output" "$source" "$prefix"
        printf '[build] zip %s: done (LÖVE helper)\n' "$(basename "$output")" >&2
    fi
}
