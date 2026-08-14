#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# Scripts live in tools/; the mod root is one level up.
THRASH_MACHINE_MOD_DIR="${THRASH_MACHINE_MOD_DIR:-$(CDPATH= cd -- "$(dirname -- "$SCRIPT_DIR")" && pwd -P)}"
THRASH_MACHINE_MOD_DIR="$(CDPATH= cd -- "$THRASH_MACHINE_MOD_DIR" && pwd -P)"
THRASH_MACHINE_OUTPUT_DIR="${THRASH_MACHINE_OUTPUT_DIR:-$THRASH_MACHINE_MOD_DIR/dist}"
THRASH_MACHINE_ANDROID_WORK_DIR="${THRASH_MACHINE_ANDROID_WORK_DIR:-$THRASH_MACHINE_MOD_DIR/.build/android}"
THRASH_MACHINE_ANDROID_CACHE_DIR="${THRASH_MACHINE_ANDROID_CACHE_DIR:-$THRASH_MACHINE_MOD_DIR/.build/cache/love-android-11.5}"

THRASH_MACHINE_ANDROID_REPO="${THRASH_MACHINE_ANDROID_REPO:-https://github.com/love2d/love-android.git}"
THRASH_MACHINE_ANDROID_REF="${THRASH_MACHINE_ANDROID_REF:-11.5}"
THRASH_MACHINE_ANDROID_APPLICATION_ID="${THRASH_MACHINE_ANDROID_APPLICATION_ID:-org.thrashmachine.template}"
THRASH_MACHINE_ANDROID_NAME="${THRASH_MACHINE_ANDROID_NAME:-Thrash Machine}"
THRASH_MACHINE_ANDROID_ORIENTATION="${THRASH_MACHINE_ANDROID_ORIENTATION:-landscape}"
THRASH_MACHINE_ANDROID_VERSION_CODE="${THRASH_MACHINE_ANDROID_VERSION_CODE:-1}"
THRASH_MACHINE_ANDROID_VERSION_NAME="${THRASH_MACHINE_ANDROID_VERSION_NAME:-}"
THRASH_MACHINE_ANDROID_ICON="${THRASH_MACHINE_ANDROID_ICON:-}"
# Directory mode takes precedence over the single-file THRASH_MACHINE_ANDROID_ICON:
# icons named <density>.png (ldpi/mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi); a missing
# density falls back to the nearest available one.
THRASH_MACHINE_ANDROID_ICON_DIR="${THRASH_MACHINE_ANDROID_ICON_DIR:-$THRASH_MACHINE_MOD_DIR/assets/icon/android}"
THRASH_MACHINE_ANDROID_NDK_DIR="${THRASH_MACHINE_ANDROID_NDK_DIR:-}"
THRASH_MACHINE_OUTPUT_BASENAME="${THRASH_MACHINE_OUTPUT_BASENAME:-thrash-machine}"

log() {
    printf '[android-build] %s\n' "$*" >&2
}

fail() {
    printf '[android-build] %s\n' "$*" >&2
    exit 1
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

# shellcheck source=build-helper/lib.sh
source "$THRASH_MACHINE_MOD_DIR/build-helper/lib.sh"

read_mod_version() {
    version="$(sed -n 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
        "$THRASH_MACHINE_MOD_DIR/mod.json" | head -n 1)"
    [ -n "$version" ] || fail "Could not find mod.json version"
    printf '%s\n' "${version#v}"
}

check_inputs() {
    local java_home java_version android_sdk ndk_dir

    need_cmd git
    need_cmd java
    need_cmd find

    java_home="${THRASH_MACHINE_ANDROID_JAVA_HOME:-${JAVA_HOME:-}}"
    if [ -n "$java_home" ]; then
        [ -x "$java_home/bin/java" ] || fail \
            "Configured Java home does not contain a Java executable: $java_home"
        export JAVA_HOME="$java_home"
        export PATH="$JAVA_HOME/bin:$PATH"
    fi

    java_version="$(java -version 2>&1 | sed -n 's/.*version "\([0-9][0-9]*\).*/\1/p' | head -n 1)"
    [ "$java_version" = "17" ] || fail \
        "LÖVE Android 11.5 requires JDK 17; detected ${java_version:-unknown}. Set JAVA_HOME or THRASH_MACHINE_ANDROID_JAVA_HOME to a JDK 17 installation."

    android_sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
    [ -n "$android_sdk" ] || fail \
        "Set ANDROID_SDK_ROOT to an Android SDK containing API 34 and NDK 25.2.9519653"
    export ANDROID_SDK_ROOT="$android_sdk"
    [ -d "$ANDROID_SDK_ROOT/platforms/android-34" ] || fail \
        "Missing Android SDK platform android-34 under $ANDROID_SDK_ROOT"
    [ -d "$ANDROID_SDK_ROOT/build-tools/34.0.0" ] || fail \
        "Missing Android Build Tools 34.0.0 under $ANDROID_SDK_ROOT"

    ndk_dir="${THRASH_MACHINE_ANDROID_NDK_DIR:-$ANDROID_SDK_ROOT/ndk/25.2.9519653}"
    [ -d "$ndk_dir" ] || fail \
        "Missing Android NDK 25.2.9519653 under $ndk_dir"
    [ -f "$ndk_dir/source.properties" ] || fail \
        "Android NDK source.properties is missing under $ndk_dir"
    grep -Eq '^Pkg\.Revision[[:space:]]*=[[:space:]]*25\.2\.9519653[[:space:]]*$' \
        "$ndk_dir/source.properties" || fail \
        "Android NDK under $ndk_dir is not version 25.2.9519653"
    THRASH_MACHINE_ANDROID_NDK_DIR="$ndk_dir"

    if [ -n "${THRASH_MACHINE_ANDROID_SIGNING_KEYSTORE:-}" ]; then
        [ -f "$THRASH_MACHINE_ANDROID_SIGNING_KEYSTORE" ] || fail \
            "Android signing keystore does not exist: $THRASH_MACHINE_ANDROID_SIGNING_KEYSTORE"
        [ -n "${THRASH_MACHINE_ANDROID_SIGNING_STORE_PASSWORD:-}" ] || fail \
            "THRASH_MACHINE_ANDROID_SIGNING_STORE_PASSWORD is required with a custom Android keystore"
        [ -n "${THRASH_MACHINE_ANDROID_SIGNING_KEY_ALIAS:-}" ] || fail \
            "THRASH_MACHINE_ANDROID_SIGNING_KEY_ALIAS is required with a custom Android keystore"
        [ -n "${THRASH_MACHINE_ANDROID_SIGNING_KEY_PASSWORD:-}" ] || fail \
            "THRASH_MACHINE_ANDROID_SIGNING_KEY_PASSWORD is required with a custom Android keystore"

        THRASH_MACHINE_ANDROID_SIGNING_KEYSTORE="$(CDPATH= cd -- "$(dirname -- "$THRASH_MACHINE_ANDROID_SIGNING_KEYSTORE")" && pwd -P)/$(basename -- "$THRASH_MACHINE_ANDROID_SIGNING_KEYSTORE")"
        export THRASH_MACHINE_ANDROID_SIGNING_KEYSTORE
    fi

    printf '%s' "$THRASH_MACHINE_ANDROID_APPLICATION_ID" \
        | grep -Eq '^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$' || fail \
        "Invalid Android application id: $THRASH_MACHINE_ANDROID_APPLICATION_ID"
    [ -n "$THRASH_MACHINE_ANDROID_NAME" ] || fail "Android application name cannot be empty"
    case "$THRASH_MACHINE_ANDROID_ORIENTATION" in
        landscape|portrait|sensorLandscape|sensorPortrait) ;;
        *) fail "Unsupported Android orientation: $THRASH_MACHINE_ANDROID_ORIENTATION" ;;
    esac
    printf '%s' "$THRASH_MACHINE_ANDROID_VERSION_CODE" | grep -Eq '^[1-9][0-9]*$' || fail \
        "Android version code must be a positive integer"

    if [ -z "$THRASH_MACHINE_ANDROID_VERSION_NAME" ]; then
        THRASH_MACHINE_ANDROID_VERSION_NAME="$(read_mod_version)"
    fi
    [ -n "$THRASH_MACHINE_ANDROID_VERSION_NAME" ] || fail "Android version name cannot be empty"
}

ensure_android_source() {
    if [ -d "$THRASH_MACHINE_ANDROID_CACHE_DIR/.git" ]; then
        if ! git -C "$THRASH_MACHINE_ANDROID_CACHE_DIR" rev-parse --verify --quiet \
            "${THRASH_MACHINE_ANDROID_REF}^{commit}" >/dev/null; then
            git -C "$THRASH_MACHINE_ANDROID_CACHE_DIR" fetch --depth 1 origin \
                "refs/tags/${THRASH_MACHINE_ANDROID_REF}:refs/tags/${THRASH_MACHINE_ANDROID_REF}"
        fi
    elif [ -e "$THRASH_MACHINE_ANDROID_CACHE_DIR" ]; then
        fail "Android cache path exists but is not a Git checkout: $THRASH_MACHINE_ANDROID_CACHE_DIR"
    else
        mkdir -p "$(dirname "$THRASH_MACHINE_ANDROID_CACHE_DIR")"
        log "Cloning LÖVE Android ${THRASH_MACHINE_ANDROID_REF}"
        git clone --recurse-submodules --depth 1 --branch "$THRASH_MACHINE_ANDROID_REF" \
            "$THRASH_MACHINE_ANDROID_REPO" "$THRASH_MACHINE_ANDROID_CACHE_DIR"
    fi

    git -C "$THRASH_MACHINE_ANDROID_CACHE_DIR" checkout --detach "$THRASH_MACHINE_ANDROID_REF" >/dev/null
    git -C "$THRASH_MACHINE_ANDROID_CACHE_DIR" submodule update --init --recursive
}

android_density_dpi() {
    case "$1" in
        ldpi) echo 120 ;; mdpi) echo 160 ;; hdpi) echo 240 ;;
        xhdpi) echo 320 ;; xxhdpi) echo 480 ;; xxxhdpi) echo 640 ;;
    esac
}

# Print the path of the density icon nearest to $1 (smallest dpi difference),
# or nothing when the icon dir has no usable png at all.
pick_android_icon() {
    local target="$1" d best="" best_d=999999 diff
    for d in ldpi mdpi hdpi xhdpi xxhdpi xxxhdpi; do
        [ -f "$THRASH_MACHINE_ANDROID_ICON_DIR/$d.png" ] || continue
        diff=$(( $(android_density_dpi "$target") - $(android_density_dpi "$d") ))
        diff=${diff#-}
        if [ "$diff" -lt "$best_d" ]; then best="$d"; best_d="$diff"; fi
    done
    [ -n "$best" ] && printf '%s\n' "$THRASH_MACHINE_ANDROID_ICON_DIR/$best.png"
}

# Copy launcher icons into res/drawable-<density>/love.png. Directory mode wins
# when the dir holds any <density>.png (only density-named files count — a
# stray png must not hijack the mode); otherwise fall back to the legacy
# single-file mode; if neither is configured, love-android's default stays.
stage_android_icons() {
    local stage="$1" density source
    local density_dir_has_icon=0

    for density in ldpi mdpi hdpi xhdpi xxhdpi xxxhdpi; do
        [ -f "$THRASH_MACHINE_ANDROID_ICON_DIR/$density.png" ] && density_dir_has_icon=1
    done

    if [ -n "$THRASH_MACHINE_ANDROID_ICON_DIR" ] && [ "$density_dir_has_icon" = "1" ]; then
        for density in ldpi mdpi hdpi xhdpi xxhdpi xxxhdpi; do
            # pick_android_icon returns non-zero when no density matches; keep
            # the build going (set -e) and let the nearest-density fallback
            # fill any gap from the files that do exist.
            source="$(pick_android_icon "$density" || true)"
            [ -n "$source" ] || continue
            mkdir -p "$stage/app/src/main/res/drawable-$density"
            cp "$source" "$stage/app/src/main/res/drawable-$density/love.png"
        done
        return 0
    fi

    if [ -n "$THRASH_MACHINE_ANDROID_ICON" ]; then
        [ -f "$THRASH_MACHINE_ANDROID_ICON" ] || fail \
            "Android icon does not exist: $THRASH_MACHINE_ANDROID_ICON"
        for density in ldpi mdpi hdpi xhdpi xxhdpi xxxhdpi; do
            mkdir -p "$stage/app/src/main/res/drawable-$density"
            cp "$THRASH_MACHINE_ANDROID_ICON" \
                "$stage/app/src/main/res/drawable-$density/love.png"
        done
    fi
}

stage_android_source() {
    local stage_dir="$THRASH_MACHINE_ANDROID_WORK_DIR/project"

    rm -rf "$stage_dir"
    mkdir -p "$stage_dir"
    # tar instead of rsync (rsync is not available in Git Bash on Windows).
    tar -cf - --exclude='*.git' \
        -C "$THRASH_MACHINE_ANDROID_CACHE_DIR" . | tar -xf - -C "$stage_dir"
    mkdir -p "$stage_dir/app/src/embed/assets"
    cp "$THRASH_MACHINE_ANDROID_WORK_DIR/love/${THRASH_MACHINE_OUTPUT_BASENAME}-release.love" \
        "$stage_dir/app/src/embed/assets/game.love"

    stage_android_icons "$stage_dir"

    run_helper patch-android-properties \
        "$stage_dir/gradle.properties" \
        "$THRASH_MACHINE_ANDROID_APPLICATION_ID" \
        "$THRASH_MACHINE_ANDROID_NAME" \
        "$THRASH_MACHINE_ANDROID_ORIENTATION" \
        "$THRASH_MACHINE_ANDROID_VERSION_CODE" \
        "$THRASH_MACHINE_ANDROID_VERSION_NAME"
    run_helper patch-android-gradle \
        "$stage_dir/app/build.gradle"
    run_helper patch-android-game-activity \
        "$stage_dir/love/src/main/java/org/love2d/android/GameActivity.java"
    run_helper patch-android-local-properties \
        "$stage_dir/local.properties" \
        "$ANDROID_SDK_ROOT"
}

build_love_archive() {
    local love_output="$THRASH_MACHINE_ANDROID_WORK_DIR/love"

    rm -rf "$love_output"
    mkdir -p "$love_output"
    THRASH_MACHINE_MOD_DIR="$THRASH_MACHINE_MOD_DIR" \
        THRASH_MACHINE_ANDROID_TOUCH_SKIP_INTRO=1 \
        THRASH_MACHINE_BUILD_VARIANTS=release \
        THRASH_MACHINE_BUILD_WINDOWS_EXE=0 \
        THRASH_MACHINE_OUTPUT_DIR="$love_output" \
        "$THRASH_MACHINE_MOD_DIR/tools/build_standalone.sh"
    [ -s "$love_output/${THRASH_MACHINE_OUTPUT_BASENAME}-release.love" ] || fail \
        "The release .love archive was not created"
}

build_apk() {
    local stage_dir="$THRASH_MACHINE_ANDROID_WORK_DIR/project"
    local apk_source apk_output apksigner

    (cd "$stage_dir" && ./gradlew --no-daemon assembleEmbedNoRecordRelease)

    apk_source="$(find "$stage_dir/app/build/outputs/apk" -type f -name '*.apk' \
        -path '*/embedNoRecord/release/*' | sort | tail -n 1)"
    [ -n "$apk_source" ] || fail "Gradle completed without producing an APK"

    apk_output="$THRASH_MACHINE_OUTPUT_DIR/${THRASH_MACHINE_OUTPUT_BASENAME}-android.apk"
    mkdir -p "$THRASH_MACHINE_OUTPUT_DIR"
    cp "$apk_source" "$apk_output"
    test -s "$apk_output"
    # Use the jar directly instead of the apksigner shell wrapper: the wrapper
    # has no .bat counterpart on Windows (only apksigner.bat exists there), so
    # `java -jar` is the portable way to run it on every host.
    apksigner_jar="$ANDROID_SDK_ROOT/build-tools/34.0.0/lib/apksigner.jar"
    [ -f "$apksigner_jar" ] || fail \
        "Android build-tools apksigner.jar is missing: $apksigner_jar"
    java -jar "$apksigner_jar" verify "$apk_output" >/dev/null 2>&1 || fail \
        "Generated APK is not signed or failed Android signature verification: $apk_output"
    log "Created Android APK: $apk_output"
}

check_inputs
build_love_archive
ensure_android_source
stage_android_source
build_apk
