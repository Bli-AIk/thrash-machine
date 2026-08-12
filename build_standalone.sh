#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
THRASH_MACHINE_MOD_DIR="${THRASH_MACHINE_MOD_DIR:-$SCRIPT_DIR}"
THRASH_MACHINE_MOD_DIR="$(CDPATH= cd -- "$THRASH_MACHINE_MOD_DIR" && pwd -P)"
THRASH_MACHINE_BUILD_ROOT="${THRASH_MACHINE_BUILD_ROOT:-$THRASH_MACHINE_MOD_DIR/.build/standalone}"
THRASH_MACHINE_OUTPUT_DIR="${THRASH_MACHINE_OUTPUT_DIR:-$THRASH_MACHINE_MOD_DIR/dist}"
THRASH_MACHINE_CACHE_DIR="${THRASH_MACHINE_CACHE_DIR:-$THRASH_MACHINE_MOD_DIR/.build/cache}"

# Remember what the user actually set before we fill in defaults. This lets
# the interactive prompt treat an explicit KRISTAL_ROOT/THRASH_MACHINE_KRISTAL_DIR
# as a deliberate local source while still asking when nothing is configured.
THRASH_MACHINE_KRISTAL_REF_ENV="${THRASH_MACHINE_KRISTAL_REF:-}"
THRASH_MACHINE_KRISTAL_EXPECTED_VERSION_ENV="${THRASH_MACHINE_KRISTAL_EXPECTED_VERSION:-}"
THRASH_MACHINE_KRISTAL_DIR_ENV="${THRASH_MACHINE_KRISTAL_DIR:-}"
KRISTAL_ROOT_ENV="${KRISTAL_ROOT:-}"
THRASH_MACHINE_KRISTAL_VERIFY_VERSION_ENV="${THRASH_MACHINE_KRISTAL_VERIFY_VERSION:-}"

THRASH_MACHINE_KRISTAL_REPO="${THRASH_MACHINE_KRISTAL_REPO:-https://github.com/KristalTeam/Kristal.git}"
THRASH_MACHINE_KRISTAL_REF="${THRASH_MACHINE_KRISTAL_REF:-v0.10.0}"
THRASH_MACHINE_KRISTAL_EXPECTED_VERSION="${THRASH_MACHINE_KRISTAL_EXPECTED_VERSION:-0.10.0}"
THRASH_MACHINE_KRISTAL_DIR="${THRASH_MACHINE_KRISTAL_DIR:-${KRISTAL_ROOT:-$THRASH_MACHINE_MOD_DIR/.build/Kristal}}"
THRASH_MACHINE_KRISTAL_SOURCE="${THRASH_MACHINE_KRISTAL_SOURCE:-}"
THRASH_MACHINE_KRISTAL_VERIFY_VERSION="${THRASH_MACHINE_KRISTAL_VERIFY_VERSION:-1}"

THRASH_MACHINE_MOD_ID="${THRASH_MACHINE_MOD_ID:-thrash-machine}"
THRASH_MACHINE_PROJECT_TITLE="${THRASH_MACHINE_PROJECT_TITLE:-Thrash Machine}"
THRASH_MACHINE_OUTPUT_BASENAME="${THRASH_MACHINE_OUTPUT_BASENAME:-thrash-machine}"
THRASH_MACHINE_EXE_BASENAME="${THRASH_MACHINE_EXE_BASENAME:-THRASH-MACHINE}"
THRASH_MACHINE_LOVE_VERSION="${THRASH_MACHINE_LOVE_VERSION:-11.5}"
THRASH_MACHINE_LOVE_ARCH="${THRASH_MACHINE_LOVE_ARCH:-win64}"
THRASH_MACHINE_LOVE_WINDOWS_ZIP_URL="${THRASH_MACHINE_LOVE_WINDOWS_ZIP_URL:-https://github.com/love2d/love/releases/download/${THRASH_MACHINE_LOVE_VERSION}/love-${THRASH_MACHINE_LOVE_VERSION}-${THRASH_MACHINE_LOVE_ARCH}.zip}"
THRASH_MACHINE_BUILD_VARIANTS="${THRASH_MACHINE_BUILD_VARIANTS:-release debug}"
THRASH_MACHINE_BUILD_WINDOWS_EXE="${THRASH_MACHINE_BUILD_WINDOWS_EXE:-1}"
THRASH_MACHINE_BUILD_LOVE="${THRASH_MACHINE_BUILD_LOVE:-1}"
THRASH_MACHINE_UPDATE_REPOS="${THRASH_MACHINE_UPDATE_REPOS:-0}"

log() {
    printf '[build] %s\n' "$*" >&2
}

fail() {
    printf '[build] %s\n' "$*" >&2
    exit 1
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        printf 'Missing required command: %s\n' "$1" >&2
        exit 1
    }
}

detect_kristal_path() {
    local candidates=() candidate
    [ -n "$THRASH_MACHINE_KRISTAL_DIR_ENV" ] && candidates+=("$THRASH_MACHINE_KRISTAL_DIR_ENV")
    [ -n "$KRISTAL_ROOT_ENV" ] && candidates+=("$KRISTAL_ROOT_ENV")
    candidates+=(
        "$THRASH_MACHINE_MOD_DIR/.build/Kristal"
        "$THRASH_MACHINE_MOD_DIR/../Kristal"
        "$THRASH_MACHINE_MOD_DIR/../kristal"
        "$HOME/Kristal"
        "$HOME/kristal"
    )
    for candidate in "${candidates[@]}"; do
        [ -n "$candidate" ] || continue
        if [ -f "$candidate/main.lua" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

choose_kristal_tag() {
    local tags=() tag answer default_tag found i

    while IFS= read -r tag; do
        tags+=("$tag")
    done < <(git ls-remote --tags --refs "$THRASH_MACHINE_KRISTAL_REPO" \
        | sed -n 's#.*refs/tags/##p' | sort -V)

    if [ "${#tags[@]}" -eq 0 ]; then
        printf 'Could not list tags from %s\n' "$THRASH_MACHINE_KRISTAL_REPO" >&2
        return 1
    fi

    default_tag="${THRASH_MACHINE_KRISTAL_REF_ENV:-v0.10.0}"
    found=0
    for tag in "${tags[@]}"; do
        if [ "$tag" = "$default_tag" ]; then
            found=1
            break
        fi
    done
    if [ "$found" -eq 0 ]; then
        default_tag="${tags[0]}"
    fi

    printf '远程 tag 列表：\n'
    for i in "${!tags[@]}"; do
        printf '  %2d) %s\n' "$((i + 1))" "${tags[$i]}"
    done
    printf '输入编号或 tag 名 [%s]: ' "$default_tag"
    IFS= read -r answer || return 1
    answer="${answer:-$default_tag}"

    case "$answer" in
        *[!0-9]*)
            for tag in "${tags[@]}"; do
                if [ "$tag" = "$answer" ]; then
                    THRASH_MACHINE_KRISTAL_REF="$tag"
                    return 0
                fi
            done
            printf 'Unknown tag: %s\n' "$answer" >&2
            return 1
            ;;
        *)
            if [ "$answer" -ge 1 ] && [ "$answer" -le "${#tags[@]}" ]; then
                THRASH_MACHINE_KRISTAL_REF="${tags[$((answer - 1))]}"
                return 0
            fi
            printf 'Invalid tag number: %s\n' "$answer" >&2
            return 1
            ;;
    esac
}

choose_kristal_commit() {
    local hash

    printf '输入完整 commit hash（40 位十六进制；GitHub 不支持用短 hash 直接获取）: '
    IFS= read -r hash || return 1
    hash="$(printf '%s' "$hash" | tr -d '[:space:]')"
    case "$hash" in
        '')
            printf 'Commit hash 不能为空。\n' >&2
            return 1
            ;;
        *[!0-9a-fA-F]*)
            printf 'Commit hash 只能包含十六进制字符。\n' >&2
            return 1
            ;;
    esac
    if [ "${#hash}" -ne 40 ]; then
        printf 'Commit hash 需要完整 40 位。\n' >&2
        return 1
    fi
    THRASH_MACHINE_KRISTAL_REF="$hash"
}

choose_kristal_source() {
    local local_path choice default_choice custom_path

    local_path="$(detect_kristal_path || true)"
    default_choice=3
    if [ -n "$local_path" ]; then
        default_choice=1
    fi

    while :; do
        printf '\n选择 Kristal 引擎来源：\n'
        if [ -n "$local_path" ]; then
            printf '  1) 使用本地 Kristal（%s）\n' "$local_path"
        else
            printf '  1) 使用本地 Kristal（未检测到，先选 2 输入路径）\n'
        fi
        printf '  2) 自己输入本地路径\n'
        printf '  3) 从 Git 远程选择 tag（列出远程 tag）\n'
        printf '  4) 从 Git 远程输入 commit hash\n'
        printf '请选择 [1-4，默认 %s]: ' "$default_choice"
        IFS= read -r choice || return 1
        choice="${choice:-$default_choice}"

        case "$choice" in
            1)
                if [ -z "$local_path" ]; then
                    printf '没有找到可用的本地 Kristal。\n' >&2
                    continue
                fi
                THRASH_MACHINE_KRISTAL_SOURCE=local
                THRASH_MACHINE_KRISTAL_DIR="$local_path"
                if [ -z "$THRASH_MACHINE_KRISTAL_REF_ENV" ]; then
                    THRASH_MACHINE_KRISTAL_REF=HEAD
                fi
                ;;
            2)
                printf '本地 Kristal 路径: '
                IFS= read -r custom_path || return 1
                custom_path="${custom_path#"${custom_path%%[![:space:]]*}"}"
                custom_path="${custom_path%"${custom_path##*[![:space:]]}"}"
                custom_path="${custom_path//\\//}"
                case "$custom_path" in
                    '~'|'~/'*) custom_path="$HOME${custom_path#\~}" ;;
                esac
                [ -n "$custom_path" ] || {
                    printf '路径不能为空。\n' >&2
                    continue
                }
                custom_path="$(CDPATH= cd -- "$custom_path" && pwd -P)" || {
                    printf '无法解析路径: %s\n' "$custom_path" >&2
                    continue
                }
                if [ ! -f "$custom_path/main.lua" ]; then
                    printf '路径不是有效的 Kristal 目录（缺少 main.lua）: %s\n' "$custom_path" >&2
                    continue
                fi
                THRASH_MACHINE_KRISTAL_SOURCE=path
                THRASH_MACHINE_KRISTAL_DIR="$custom_path"
                if [ -z "$THRASH_MACHINE_KRISTAL_REF_ENV" ]; then
                    THRASH_MACHINE_KRISTAL_REF=HEAD
                fi
                ;;
            3)
                THRASH_MACHINE_KRISTAL_SOURCE=tag
                if ! choose_kristal_tag; then
                    continue
                fi
                ;;
            4)
                THRASH_MACHINE_KRISTAL_SOURCE=commit
                if ! choose_kristal_commit; then
                    continue
                fi
                ;;
            *)
                printf '无效选项: %s\n' "$choice" >&2
                continue
                ;;
        esac
        break
    done

    if [ -z "$THRASH_MACHINE_KRISTAL_EXPECTED_VERSION_ENV" ] \
        && [ -z "$THRASH_MACHINE_KRISTAL_VERIFY_VERSION_ENV" ]; then
        case "$THRASH_MACHINE_KRISTAL_SOURCE:$THRASH_MACHINE_KRISTAL_REF" in
            tag:v0.10.0) THRASH_MACHINE_KRISTAL_VERIFY_VERSION=1 ;;
            *) THRASH_MACHINE_KRISTAL_VERIFY_VERSION=0 ;;
        esac
    fi
}

resolve_kristal_source() {
    if [ "$THRASH_MACHINE_KRISTAL_SOURCE" = "ask" ]; then
        THRASH_MACHINE_KRISTAL_SOURCE=
    fi

    if [ -n "$THRASH_MACHINE_KRISTAL_SOURCE" ]; then
        case "$THRASH_MACHINE_KRISTAL_SOURCE" in
            local|path)
                if [ -z "$THRASH_MACHINE_KRISTAL_REF_ENV" ]; then
                    THRASH_MACHINE_KRISTAL_REF=HEAD
                fi
                ;;
            commit)
                case "$THRASH_MACHINE_KRISTAL_REF" in
                    ''|*[!0-9a-fA-F]*)
                        fail "THRASH_MACHINE_KRISTAL_SOURCE=commit requires a 40-hex THRASH_MACHINE_KRISTAL_REF"
                        ;;
                esac
                if [ "${#THRASH_MACHINE_KRISTAL_REF}" -ne 40 ]; then
                    fail "THRASH_MACHINE_KRISTAL_SOURCE=commit requires a 40-hex THRASH_MACHINE_KRISTAL_REF"
                fi
                ;;
            tag)
                [ -n "$THRASH_MACHINE_KRISTAL_REF" ] \
                    || fail "THRASH_MACHINE_KRISTAL_SOURCE=tag requires THRASH_MACHINE_KRISTAL_REF"
                ;;
        esac
        if [ -z "$THRASH_MACHINE_KRISTAL_EXPECTED_VERSION_ENV" ] \
            && [ -z "$THRASH_MACHINE_KRISTAL_VERIFY_VERSION_ENV" ]; then
            case "$THRASH_MACHINE_KRISTAL_SOURCE:$THRASH_MACHINE_KRISTAL_REF" in
                tag:v0.10.0) THRASH_MACHINE_KRISTAL_VERIFY_VERSION=1 ;;
                *) THRASH_MACHINE_KRISTAL_VERIFY_VERSION=0 ;;
            esac
        fi
        return 0
    fi

    # Ask only when the terminal is interactive. CI and `build_android.sh`
    # (which runs this script as a subprocess) stay non-interactive and keep
    # the pinned default below.
    if [ -t 0 ] && [ -t 1 ]; then
        choose_kristal_source
        return 0
    fi

    if [ -n "$THRASH_MACHINE_KRISTAL_REF_ENV" ] \
        && [ "$THRASH_MACHINE_KRISTAL_REF_ENV" != "v0.10.0" ]; then
        case "$THRASH_MACHINE_KRISTAL_REF_ENV" in
            *[!0-9a-fA-F]*)
                THRASH_MACHINE_KRISTAL_SOURCE=tag
                ;;
            *)
                THRASH_MACHINE_KRISTAL_SOURCE=commit
                ;;
        esac
    elif [ -n "$THRASH_MACHINE_KRISTAL_DIR_ENV" ] || [ -n "$KRISTAL_ROOT_ENV" ]; then
        THRASH_MACHINE_KRISTAL_SOURCE=local
        if [ -z "$THRASH_MACHINE_KRISTAL_REF_ENV" ]; then
            THRASH_MACHINE_KRISTAL_REF=HEAD
        fi
    else
        THRASH_MACHINE_KRISTAL_SOURCE=tag
    fi

    if [ -z "$THRASH_MACHINE_KRISTAL_EXPECTED_VERSION_ENV" ] \
        && [ -z "$THRASH_MACHINE_KRISTAL_VERIFY_VERSION_ENV" ]; then
        case "$THRASH_MACHINE_KRISTAL_SOURCE:$THRASH_MACHINE_KRISTAL_REF" in
            tag:v0.10.0) THRASH_MACHINE_KRISTAL_VERIFY_VERSION=1 ;;
            *) THRASH_MACHINE_KRISTAL_VERIFY_VERSION=0 ;;
        esac
    fi
}

fetch_kristal_ref() {
    local dir="$1" ref="$2" remote

    remote="$(git -C "$dir" remote | head -n 1)"
    [ -n "$remote" ] || fail "No Git remote configured in $dir"

    if [ "$THRASH_MACHINE_KRISTAL_SOURCE" = "tag" ]; then
        git -C "$dir" fetch --depth 1 "$remote" "refs/tags/${ref}:refs/tags/${ref}"
    else
        git -C "$dir" fetch --depth 1 "$remote" "$ref"
    fi
}

ensure_kristal() {
    local dir="$THRASH_MACHINE_KRISTAL_DIR"

    case "$THRASH_MACHINE_KRISTAL_SOURCE" in
        local|path)
            [ -d "$dir" ] || fail "Kristal local path does not exist: $dir"
            [ -f "$dir/main.lua" ] || fail "Kristal local path is missing main.lua: $dir"
            if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
                THRASH_MACHINE_KRISTAL_IS_GIT=1
                git -C "$dir" rev-parse --verify --quiet "${THRASH_MACHINE_KRISTAL_REF}^{commit}" >/dev/null \
                    || fail "Local Kristal checkout does not contain ${THRASH_MACHINE_KRISTAL_REF}: $dir"
                if [ "$THRASH_MACHINE_UPDATE_REPOS" = "1" ]; then
                    local remote
                    remote="$(git -C "$dir" remote | head -n 1)"
                    if [ -n "$remote" ]; then
                        git -C "$dir" fetch --depth 1 --tags "$remote"
                    fi
                fi
            else
                THRASH_MACHINE_KRISTAL_IS_GIT=0
            fi
            ;;
        tag|commit)
            if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
                THRASH_MACHINE_KRISTAL_IS_GIT=1
                if [ "$THRASH_MACHINE_UPDATE_REPOS" = "1" ]; then
                    local remote
                    remote="$(git -C "$dir" remote | head -n 1)"
                    if [ -n "$remote" ]; then
                        git -C "$dir" fetch --depth 1 --tags "$remote"
                    fi
                fi
                if ! git -C "$dir" rev-parse --verify --quiet "${THRASH_MACHINE_KRISTAL_REF}^{commit}" >/dev/null; then
                    fetch_kristal_ref "$dir" "$THRASH_MACHINE_KRISTAL_REF"
                fi
                git -C "$dir" -c advice.detachedHead=false checkout --detach "$THRASH_MACHINE_KRISTAL_REF" >/dev/null
            elif [ -e "$dir" ]; then
                fail "Kristal path exists but is not a Git checkout: $dir"
            else
                THRASH_MACHINE_KRISTAL_IS_GIT=1
                mkdir -p "$(dirname "$dir")"
                if [ "$THRASH_MACHINE_KRISTAL_SOURCE" = "tag" ]; then
                    log "Shallow-cloning Kristal tag ${THRASH_MACHINE_KRISTAL_REF} from $THRASH_MACHINE_KRISTAL_REPO"
                    git -c advice.detachedHead=false clone --depth 1 --branch "$THRASH_MACHINE_KRISTAL_REF" --single-branch \
                        "$THRASH_MACHINE_KRISTAL_REPO" "$dir"
                else
                    log "Shallow-fetching Kristal commit ${THRASH_MACHINE_KRISTAL_REF} from $THRASH_MACHINE_KRISTAL_REPO"
                    git init -q "$dir"
                    git -C "$dir" remote add origin "$THRASH_MACHINE_KRISTAL_REPO"
                    fetch_kristal_ref "$dir" "$THRASH_MACHINE_KRISTAL_REF"
                fi
                if ! git -C "$dir" -c advice.detachedHead=false checkout --detach "$THRASH_MACHINE_KRISTAL_REF" >/dev/null 2>&1; then
                    git -C "$dir" -c advice.detachedHead=false checkout --detach HEAD >/dev/null
                    THRASH_MACHINE_KRISTAL_REF=HEAD
                fi
            fi
            ;;
        *)
            fail "Unknown Kristal source: ${THRASH_MACHINE_KRISTAL_SOURCE:-<empty>}"
            ;;
    esac

    if [ "$THRASH_MACHINE_KRISTAL_IS_GIT" = "1" ]; then
        version="$(git -C "$dir" show "${THRASH_MACHINE_KRISTAL_REF}:VERSION" | tr -d '\r\n')"
    elif [ -f "$dir/VERSION" ]; then
        version="$(sed -n '1p' "$dir/VERSION" | tr -d '\r\n')"
    else
        version=""
    fi

    if [ "$THRASH_MACHINE_KRISTAL_VERIFY_VERSION" = "1" ]; then
        if [ "$version" != "$THRASH_MACHINE_KRISTAL_EXPECTED_VERSION" ]; then
            fail "Kristal ${THRASH_MACHINE_KRISTAL_REF} reports VERSION=$version, expected $THRASH_MACHINE_KRISTAL_EXPECTED_VERSION"
        fi
    else
        log "Using Kristal VERSION=$version (${THRASH_MACHINE_KRISTAL_REF:+ref ${THRASH_MACHINE_KRISTAL_REF}})"
    fi
}

export_kristal() {
    stage_dir="$1"
    rm -rf "$stage_dir"
    mkdir -p "$stage_dir"
    if [ "$THRASH_MACHINE_KRISTAL_IS_GIT" = "1" ]; then
        git -C "$THRASH_MACHINE_KRISTAL_DIR" archive --format=tar "$THRASH_MACHINE_KRISTAL_REF" \
            | tar -x -C "$stage_dir"
    else
        tar -cf - --exclude='./.git' -C "$THRASH_MACHINE_KRISTAL_DIR" . | tar -xf - -C "$stage_dir"
    fi
    rm -rf "$stage_dir/.github" "$stage_dir/mods" "$stage_dir/build" "$stage_dir/output"
}

copy_mod() {
    stage_mod="$1"
    variant="$2"
    mkdir -p "$stage_mod"
    # Stage with tar instead of rsync (rsync is not available in Git Bash
    # on Windows; tar is). Member names are "./…", so a leading "./" pins a
    # pattern to the mod root, while slash-free patterns match basenames
    # anywhere (like rsync's unanchored patterns).
    tar -cf - \
        --exclude='*.git' \
        --exclude='./.github' \
        --exclude='./.build' \
        --exclude='./dist' \
        --exclude='./.tools' \
        --exclude='./.emacs' \
        --exclude='./.helix' \
        --exclude='./.vscode' \
        --exclude='./.worktrees' \
        --exclude='./tests' \
        --exclude='./docs' \
        --exclude='./Makefile' \
        --exclude='./justfile' \
        --exclude='./build_standalone.sh' \
        --exclude='./build_android.sh' \
        --exclude='./build-helper' \
        --exclude='__pycache__' \
        --exclude='*.pyc' \
        --exclude='*.pyo' \
        --exclude='./release-please-config.json' \
        --exclude='./.release-please-manifest.json' \
        --exclude='./.gitmodules' \
        --exclude='./.gitignore' \
        --exclude='*.tiled-project' \
        --exclude='*.tiled-session' \
        --exclude='./libraries/kristal-debug-tools/gui' \
        --exclude='./libraries/kristal-debug-tools-gui' \
        --exclude='./libraries/kristal-debug-tools/just.cmd' \
        --exclude='./libraries/kristal-debug-tools/dist' \
        --exclude='./libraries/kristal-debug-tools/.tools' \
        -C "$THRASH_MACHINE_MOD_DIR" . | tar -xf - -C "$stage_mod"

    if [ "$variant" = "release" ]; then
        rm -rf "$stage_mod/libraries/kristal-object-selector-plus"
        rm -rf "$stage_mod/libraries/terminal-cli"
        rm -rf "$stage_mod/libraries/kristal-debug-tools"
    fi
}

prepare_stage() {
    variant="$1"
    case "$variant" in
        release)
            release_mode=true
            mod_dev=false
            object_editor=false
            ;;
        debug)
            release_mode=false
            mod_dev=true
            object_editor=true
            ;;
        *)
            printf 'Unknown build variant: %s\n' "$variant" >&2
            exit 1
            ;;
    esac

    stage_dir="$THRASH_MACHINE_BUILD_ROOT/$variant/source"
    export_kristal "$stage_dir"
    stage_mod="$stage_dir/mods/$THRASH_MACHINE_MOD_ID"
    copy_mod "$stage_mod" "$variant"
    if [ "$variant" = "release" ]; then
        identity="$THRASH_MACHINE_MOD_ID"
        title="$THRASH_MACHINE_PROJECT_TITLE"
    else
        identity="${THRASH_MACHINE_MOD_ID}_debug"
        title="${THRASH_MACHINE_PROJECT_TITLE} Debug"
    fi
    run_helper patch-lua-config \
        "$stage_dir" "$THRASH_MACHINE_MOD_ID" "$release_mode" \
        "$identity" "$title"
    if [ "${THRASH_MACHINE_ANDROID_TOUCH_SKIP_INTRO:-0}" = "1" ]; then
        run_helper patch-android-loading-touch \
            "$stage_dir/src/engine/loadstate.lua"
    fi
    run_helper patch-mod-manifest \
        "$stage_mod/mod.json" "$mod_dev" "$object_editor"
    printf '%s\n' "$stage_dir"
}

ensure_love_windows() {
    [ "$THRASH_MACHINE_BUILD_WINDOWS_EXE" = "1" ] || return 0
    mkdir -p "$THRASH_MACHINE_CACHE_DIR"
    love_zip="$THRASH_MACHINE_CACHE_DIR/love-${THRASH_MACHINE_LOVE_VERSION}-${THRASH_MACHINE_LOVE_ARCH}.zip"
    love_dir="$THRASH_MACHINE_CACHE_DIR/love-${THRASH_MACHINE_LOVE_VERSION}-${THRASH_MACHINE_LOVE_ARCH}"
    if [ ! -f "$love_zip" ]; then
        log "正在下载 LÖVE ${THRASH_MACHINE_LOVE_VERSION} ${THRASH_MACHINE_LOVE_ARCH}，用于生成 Windows 可执行文件"
        curl --fail --location --output "$love_zip" "$THRASH_MACHINE_LOVE_WINDOWS_ZIP_URL"
    fi
    if [ ! -d "$love_dir" ]; then
        extract_dir="$THRASH_MACHINE_CACHE_DIR/love-${THRASH_MACHINE_LOVE_VERSION}-${THRASH_MACHINE_LOVE_ARCH}.extract"
        rm -rf "$extract_dir"
        mkdir -p "$extract_dir"
        unzip -q "$love_zip" -d "$extract_dir"
        extracted="$(find "$extract_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
        [ -n "$extracted" ] || {
            printf 'Could not locate the extracted LÖVE directory\n' >&2
            exit 1
        }
        mv "$extracted" "$love_dir"
        rm -rf "$extract_dir"
    fi
    test -f "$love_dir/love.exe"
}

build_variant() {
    variant="$1"
    stage_dir="$(prepare_stage "$variant")"
    if [ "$THRASH_MACHINE_BUILD_LOVE" = "1" ]; then
        love_output_dir="$THRASH_MACHINE_OUTPUT_DIR"
    else
        love_output_dir="$THRASH_MACHINE_BUILD_ROOT/love"
    fi
    love_file="$love_output_dir/${THRASH_MACHINE_OUTPUT_BASENAME}-${variant}.love"
    zip_dir "$love_file" "$stage_dir"

    if [ "$THRASH_MACHINE_BUILD_WINDOWS_EXE" = "1" ]; then
        love_dir="$THRASH_MACHINE_CACHE_DIR/love-${THRASH_MACHINE_LOVE_VERSION}-${THRASH_MACHINE_LOVE_ARCH}"
        package_name="${THRASH_MACHINE_OUTPUT_BASENAME}-${variant}-${THRASH_MACHINE_LOVE_ARCH}"
        package_dir="$THRASH_MACHINE_OUTPUT_DIR/$package_name"
        exe_name="${THRASH_MACHINE_EXE_BASENAME}-${variant}.exe"
        rm -rf "$package_dir"
        mkdir -p "$package_dir"
        cat "$love_dir/love.exe" "$love_file" > "$package_dir/$exe_name"
        cp "$love_dir"/*.dll "$package_dir/"
        test ! -f "$love_dir/license.txt" || cp "$love_dir/license.txt" "$package_dir/"
        zip_dir "$THRASH_MACHINE_OUTPUT_DIR/${package_name}.zip" "$package_dir" "$package_name"
    fi

    if [ "$THRASH_MACHINE_BUILD_LOVE" != "1" ] \
        && [ "$THRASH_MACHINE_BUILD_WINDOWS_EXE" = "1" ]; then
        rm -f "$love_file"
    fi
}

need_cmd git
need_cmd tar
need_cmd unzip
need_cmd curl
# `zip` is optional: when missing, zip_dir falls back to the build-helper
# (LÖVE) which writes stored zips.
# shellcheck source=build-helper/lib.sh
source "$THRASH_MACHINE_MOD_DIR/build-helper/lib.sh"
if [ "$THRASH_MACHINE_BUILD_LOVE" != "1" ] \
    && [ "$THRASH_MACHINE_BUILD_WINDOWS_EXE" != "1" ]; then
    fail "Nothing to build: set THRASH_MACHINE_BUILD_LOVE=1 and/or THRASH_MACHINE_BUILD_WINDOWS_EXE=1"
fi
resolve_kristal_source
ensure_kristal
mkdir -p "$THRASH_MACHINE_OUTPUT_DIR"
ensure_love_windows
for variant in $THRASH_MACHINE_BUILD_VARIANTS; do
    build_variant "$variant"
done
