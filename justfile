# Run the project with a local Kristal checkout and shared debug tools.
# zh_hans: 用本地 Kristal 引擎启动项目（带共享调试工具）
default: test

# Run the project with debug launcher arguments.
# zh_hans: 启动项目，可带调试参数（如 -w 波次、-tp 初始 TP）
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

# Run the project's test suite.
# zh_hans: 运行项目测试
test:
    @make test

# Run Kristal's own test suite.
# zh_hans: 运行 Kristal 引擎测试
test-kristal:
    @make test-kristal

# Build .love only.
# zh_hans: 只打包 .love
build-love:
    @{{ if os() == "windows" { "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"" + justfile_directory() + "/tools/build.ps1\" love" } else { "THRASH_MACHINE_BUILD_LOVE=1 THRASH_MACHINE_BUILD_WINDOWS_EXE=0 bash ./tools/build_standalone.sh" } }}

# Build Windows only.
# zh_hans: 只打包 Windows
build-win:
    @{{ if os() == "windows" { "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"" + justfile_directory() + "/tools/build.ps1\" win" } else { "THRASH_MACHINE_BUILD_LOVE=0 THRASH_MACHINE_BUILD_WINDOWS_EXE=1 bash ./tools/build_standalone.sh" } }}

# Build .love + Windows (original behavior).
# zh_hans: 同时打包 .love 和 Windows（老用法）
build:
    @{{ if os() == "windows" { "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"" + justfile_directory() + "/tools/build.ps1\" all" } else { "THRASH_MACHINE_BUILD_LOVE=1 THRASH_MACHINE_BUILD_WINDOWS_EXE=1 bash ./tools/build_standalone.sh" } }}

# Compile the Android APK from source (full build; needs JDK 17 + Android SDK API 34 + NDK 25.2.9519653).
# A missing JDK 17 or Android SDK (API 34 + build-tools 34.0.0 + NDK 25.2.9519653) is
# auto-downloaded into the shared tools dir next to the Kristal engine on first use
# (<kristal-root>/.tools/jdk17 / <kristal-root>/.tools/android-sdk; project-root .tools as fallback).
# Uses the pinned Kristal commit by default; set THRASH_MACHINE_KRISTAL_SOURCE=ask
# to choose a local path, tag, commit, or branch interactively.
# zh_hans: 编译构建 Android APK（完整构建，需要 JDK 17 + Android SDK API 34 + NDK 25.2.9519653；缺 JDK/SDK 时首次自动下载到 Kristal 根 .tools/jdk17 / .tools/android-sdk，无引擎时回退 project 根 .tools；默认使用固定 Kristal commit；设 THRASH_MACHINE_KRISTAL_SOURCE=ask 可交互选择本地路径、tag、commit 或分支）
build-android:
    @{{ if os() == "windows" { "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"" + justfile_directory() + "/tools/build_android.ps1\" compile" } else { "bash ./tools/build_android.sh" } }}

# Wrap-build a quick Android APK (official LÖVE shell + game.love, re-aligned and re-signed).
# Needs no Android SDK/NDK; JDK 17 is auto-downloaded into the shared tools dir
# when missing (see build-android). The normal Git/Kristal source requirement still applies;
# build-tools are downloaded automatically. Faster, but cannot change package id/icon/name and
# cannot be published on Google Play.
# zh_hans: 套包构建 Android APK（官方 LÖVE 壳 + game.love，重对齐并重签名；不需 Android SDK/NDK，缺 JDK 17 时自动下载到 Kristal 根 .tools/jdk17；仍需常规 Git/Kristal 源；不能改包名/图标/名称，不能上 Google Play）
build-android-wrap:
    @{{ if os() == "windows" { "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"" + justfile_directory() + "/tools/build_android.ps1\" wrap" } else { "bash ./tools/build_android_wrap.sh" } }}

# Build the project-only distribution (recipe name retained for Kristal compatibility).
# zh_hans: 构建项目单包分发版（recipe 名称为兼容 Kristal 保留）
build-mod:
    @{{ if os() == "windows" { "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"" + justfile_directory() + "/tools/build.ps1\" mod" } else { "bash ./.github/scripts/build_mod.sh" } }}

# Remove build artifacts.
# zh_hans: 清理构建产物
clean-build:
    @{{ if os() == "windows" { "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \"Remove-Item -LiteralPath '.build','dist' -Recurse -Force -ErrorAction SilentlyContinue\"" } else { "rm -rf .build dist" } }}
