# Run the mod with a local Kristal checkout and shared debug tools.
# zh_hans: 用本地 Kristal 引擎启动 mod（带共享调试工具）
default: test

# Run the mod with debug launcher arguments.
# zh_hans: 启动游戏，可带调试参数（如 -w 波次、-tp 初始 TP）
run *args:
    @just --justfile libraries/kristal-debug-tools/justfile run {{ args }}

# Run the debug-tools GUI (end users: auto-downloads/updates release binaries).
# zh_hans: 启动调试工具图形界面（自动检测并下载最新 release，无需 just/Rust/Node）
gui:
    @just --justfile libraries/kristal-debug-tools/justfile gui

# Run the debug-tools GUI from source (clones the GUI repo on demand).
# zh_hans: 源码模式运行调试工具图形界面（GUI 仓库按需 clone）
gui-dev:
    @just --justfile libraries/kristal-debug-tools/justfile gui-dev

# Run the debug-tools GUI from source with a Rust release build.
# zh_hans: 源码模式运行调试工具图形界面（Rust release 构建）
gui-dev-release:
    @just --justfile libraries/kristal-debug-tools/justfile gui-dev-release

# Run the mod's test suite.
# zh_hans: 运行 mod 测试
test:
    @make test

# Run Kristal's own test suite.
# zh_hans: 运行 Kristal 引擎测试
test-kristal:
    @make test-kristal

# Build .love only.
# zh_hans: 只打包 .love
build-love:
    @THRASH_MACHINE_BUILD_LOVE=1 THRASH_MACHINE_BUILD_WINDOWS_EXE=0 bash ./tools/build_standalone.sh

# Build Windows only.
# zh_hans: 只打包 Windows
build-win:
    @THRASH_MACHINE_BUILD_LOVE=0 THRASH_MACHINE_BUILD_WINDOWS_EXE=1 bash ./tools/build_standalone.sh

# Build .love + Windows (original behavior).
# zh_hans: 同时打包 .love 和 Windows（老用法）
build:
    @THRASH_MACHINE_BUILD_LOVE=1 THRASH_MACHINE_BUILD_WINDOWS_EXE=1 bash ./tools/build_standalone.sh

# Compile the Android APK from source (full build; needs JDK 17 + Android SDK API 34 + NDK 25.2.9519653).
# A missing JDK 17 or Android SDK (API 34 + build-tools 34.0.0 + NDK 25.2.9519653) is
# auto-downloaded into .tools/jdk17 / .tools/android-sdk on first use.
# zh_hans: 编译构建 Android APK（完整构建，需要 JDK 17 + Android SDK API 34 + NDK 25.2.9519653；缺 JDK/SDK 时首次自动下载到 .tools/jdk17 / .tools/android-sdk）
build-android:
    @bash ./tools/build_android.sh

# Wrap-build a quick Android APK (official LÖVE shell + game.love, re-aligned and re-signed).
# Only needs a JDK (auto-downloaded into .tools/jdk17 when missing); build-tools are
# downloaded automatically. Faster, but cannot change package id/icon/name and
# cannot be published on Google Play.
# zh_hans: 套包构建 Android APK（官方 LÖVE 壳 + game.love，重对齐并重签名；只需 JDK，缺则自动下载到 .tools/jdk17，工具自动下载；不能改包名/图标/名称，不能上 Google Play）
build-android-wrap:
    @bash ./tools/build_android_wrap.sh

# Build the mod-only distribution.
# zh_hans: 构建 mod 单包分发版
build-mod:
    @bash ./.github/scripts/build_mod.sh

# Remove build artifacts.
# zh_hans: 清理构建产物
clean-build:
    rm -rf .build dist
