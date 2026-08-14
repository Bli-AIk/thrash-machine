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

# Native Windows binaries (love.exe) cannot open msys-style paths such as
# /c/Users/... Convert absolute paths to Windows form (C:/...) when running
# under Git Bash / msys; no-op on Linux and for relative or non-path args.
win_path() {
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*)
            case "$1" in
                /*) command -v cygpath >/dev/null 2>&1 && cygpath -m "$1" || printf '%s\n' "$1" ;;
                *) printf '%s\n' "$1" ;;
            esac
            ;;
        *) printf '%s\n' "$1" ;;
    esac
}

run_helper() {
    # LÖVE 11 drops positional args after the game path, so pass them in a
    # temp file (one argument per line). love.exe is a native binary, so msys
    # paths (/c/...) written here must be converted to Windows form first.
    local args_file arg status
    args_file="$(mktemp)" || exit 1
    : > "$args_file"
    for arg in "$@"; do
        win_path "$arg" >> "$args_file"
    done
    THRASH_MACHINE_HELPER_ARGS="$(win_path "$args_file")" \
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

# --- portable JDK (used by the Android build scripts) -------------------------
# A pristine machine usually has no JDK. When the caller did not pin one via
# THRASH_MACHINE_ANDROID_JAVA_HOME/JAVA_HOME and no usable `java` is on PATH,
# ensure_java downloads a portable Temurin JDK into .tools/jdk<version> and
# exports JAVA_HOME/PATH. Disable the download with THRASH_MACHINE_FETCH_JDK=0.
# These functions are self-contained (printf + exit, no log/fail dependency):
# build_mod.sh sources this file before defining those helpers.
THRASH_MACHINE_JDK_VERSION="${THRASH_MACHINE_JDK_VERSION:-17}"
THRASH_MACHINE_JDK_DIR="${THRASH_MACHINE_JDK_DIR:-$THRASH_MACHINE_MOD_DIR/.tools/jdk$THRASH_MACHINE_JDK_VERSION}"
THRASH_MACHINE_FETCH_JDK="${THRASH_MACHINE_FETCH_JDK:-1}"

java_major() {
    # Quoted and unquoted variants: real JDKs print `version "17.0.11"` (with
    # quotes); a few minimal builds omit them. Two POSIX BRE subs instead of an
    # optional-quote token (not portable across BSD/GNU sed).
    "$1" -version 2>&1 \
        | sed -n 's/.*version "\([0-9][0-9]*\).*/\1/p; s/.*version \([0-9][0-9]*\).*/\1/p' \
        | head -n 1
}

# Resolve a JDK and export JAVA_HOME/PATH for the rest of the script.
#   ensure_java            — use any working Java (explicit home or PATH), else
#                            download the default version.
#   ensure_java <major>    — additionally require that major version (an
#                            explicit home or PATH java of a different major is
#                            an error / triggers the download), else download.
# Exits 1 with a clear message when nothing usable is available.
ensure_java() {
    local exact="${1:-}" version="${1:-$THRASH_MACHINE_JDK_VERSION}" java_home major
    java_home="${THRASH_MACHINE_ANDROID_JAVA_HOME:-${JAVA_HOME:-}}"
    if [ -n "$java_home" ]; then
        [ -x "$java_home/bin/java" ] || {
            printf 'Configured Java home has no Java executable: %s\n' "$java_home" >&2
            exit 1
        }
        if [ -n "$exact" ]; then
            major="$(java_major "$java_home/bin/java")"
            [ "$major" = "$exact" ] || {
                printf 'Java %s required, found %s at %s (set THRASH_MACHINE_ANDROID_JAVA_HOME to a JDK %s)\n' \
                    "$exact" "${major:-unknown}" "$java_home" "$exact" >&2
                exit 1
            }
        fi
        export JAVA_HOME="$java_home"
        export PATH="$JAVA_HOME/bin:$PATH"
        return 0
    fi
    if command -v java >/dev/null 2>&1; then
        if [ -n "$exact" ]; then
            major="$(java_major "$(command -v java)")"
            if [ "$major" = "$exact" ]; then
                use_path_java
                return 0
            fi
        else
            use_path_java
            return 0
        fi
    fi
    install_portable_jdk "$version"
    export JAVA_HOME="$THRASH_MACHINE_JDK_DIR"
    export PATH="$JAVA_HOME/bin:$PATH"
}

use_path_java() {
    JAVA_HOME="$(CDPATH= cd -- "$(dirname -- "$(command -v java)")/.." && pwd -P)"
    export JAVA_HOME
    export PATH="$JAVA_HOME/bin:$PATH"
}

# Download + unpack a Temurin JDK of the given major version into
# THRASH_MACHINE_JDK_DIR (archive cached in .build/cache).
install_portable_jdk() {
    local version="$1" dest="$THRASH_MACHINE_JDK_DIR"
    [ "$THRASH_MACHINE_FETCH_JDK" = "1" ] || {
        printf 'No JDK %s found and THRASH_MACHINE_FETCH_JDK=0; install JDK %s or set THRASH_MACHINE_ANDROID_JAVA_HOME\n' \
            "$version" "$version" >&2
        exit 1
    }
    local os arch cache url cd_out archive extract top
    case "$(uname -s)" in
        Linux*) os=linux ;;
        Darwin*) os=mac ;;
        MINGW*|MSYS*|CYGWIN*) os=windows ;;
        *) printf 'Unsupported OS for portable JDK: %s\n' "$(uname -s)" >&2; exit 1 ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64) arch=x64 ;;
        aarch64|arm64) arch=aarch64 ;;
        *) printf 'Unsupported architecture for portable JDK: %s\n' "$(uname -m)" >&2; exit 1 ;;
    esac
    command -v curl >/dev/null 2>&1 || { printf 'curl is required to download the portable JDK\n' >&2; exit 1; }
    command -v unzip >/dev/null 2>&1 || { printf 'unzip is required to unpack the portable JDK\n' >&2; exit 1; }

    cache="$THRASH_MACHINE_MOD_DIR/.build/cache"
    mkdir -p "$cache"
    url="https://api.adoptium.net/v3/binary/latest/${version}/ga/${os}/${arch}/jdk/hotspot/normal/eclipse"
    printf '下载便携 JDK %s（Temurin %s/%s，约 190 MB）…\n' "$version" "$os" "$arch" >&2
    cd_out="$(mktemp)"
    if ! (cd "$cache" && curl --fail --location --remote-name --remote-header-name \
            --write-out '%{filename_effective}' "$url") > "$cd_out" 2>/dev/null; then
        rm -f "$cd_out"
        printf '下载 JDK %s 失败: %s\n' "$version" "$url" >&2
        exit 1
    fi
    archive="$cache/$(cat "$cd_out")"
    rm -f "$cd_out"
    [ -f "$archive" ] || { printf 'JDK 下载未产生文件（%s）\n' "$url" >&2; exit 1; }

    extract="$dest.extract"
    rm -rf "$extract" "$dest"
    mkdir -p "$extract"
    case "$archive" in
        *.zip)
            unzip -q "$archive" -d "$extract" || {
                rm -rf "$extract" "$dest"
                printf '解压 JDK 失败: %s\n' "$archive" >&2
                exit 1
            }
            ;;
        *.tar.gz|*.tgz)
            command -v tar >/dev/null 2>&1 || {
                rm -rf "$extract" "$dest"
                printf 'tar is required to unpack the portable JDK\n' >&2
                exit 1
            }
            tar -xzf "$archive" -C "$extract" || {
                rm -rf "$extract" "$dest"
                printf '解压 JDK 失败: %s\n' "$archive" >&2
                exit 1
            }
            ;;
        *)
            rm -rf "$extract" "$dest"
            printf '无法识别的 JDK 包: %s\n' "$archive" >&2
            exit 1
            ;;
    esac
    top="$(find "$extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    if [ -n "$top" ]; then
        mv "$top" "$dest"
    else
        mv "$extract" "$dest"
    fi
    rm -rf "$extract"
    [ -x "$dest/bin/java" ] || { rm -rf "$dest"; printf 'JDK %s 缺少 bin/java: %s\n' "$version" "$dest" >&2; exit 1; }
    printf 'JDK %s 已就绪: %s\n' "$version" "$dest" >&2
}
