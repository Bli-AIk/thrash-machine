# Run the mod with a local Kristal checkout and shared debug tools.
# zh_hans: 用本地 Kristal 引擎启动 mod（带共享调试工具）
default: test

# Run the mod with debug launcher arguments.
# zh_hans: 启动游戏，可带调试参数（如 -w 波次、-tp 初始 TP）
run *args:
    @just --justfile libraries/kristal-debug-tools/justfile run {{ args }}

# Run the debug-tools GUI (end users: downloads release binaries on first use).
# zh_hans: 启动调试工具图形界面（首次自动下载，无需 just/Rust/Node）
gui:
    @just --justfile libraries/kristal-debug-tools/justfile gui

# Run the mod's test suite.
# zh_hans: 运行 mod 测试
test:
    @make test

# Run Kristal's own test suite.
# zh_hans: 运行 Kristal 引擎测试
test-kristal:
    @make test-kristal

# Build the standalone distribution (`bash` prefix: Git Bash on Windows).
# zh_hans: 构建独立分发版（Windows 下需要 Git Bash）
build:
    @bash ./build_standalone.sh

# Build the Android distribution.
# zh_hans: 构建 Android 分发版
build-android:
    @bash ./build_android.sh

# Build the mod-only distribution.
# zh_hans: 构建 mod 单包分发版
build-mod:
    @bash ./.github/scripts/build_mod.sh

# Remove build artifacts.
# zh_hans: 清理构建产物
clean-build:
    rm -rf .build dist
