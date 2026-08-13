# Thrash Machine

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE) <img src="https://img.shields.io/github/repo-size/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/last-commit/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/v/release/Bli-AIk/thrash-machine.svg"/> <br>
<img src="https://img.shields.io/badge/Deltarune-001225?style=for-the-badge&labelColor=001225&logo=undertale&logoColor=ff0000" /> <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge"/> <img src="https://img.shields.io/badge/Kristal-3B3B3B?style=for-the-badge"/>

**Thrash Machine** 是一个开箱即用的标准 Lua Kristal v0.10 模板：自带能跑的 starter 地图、Dummy 战斗和对象事件，中文本地化和开发期工具按子模块组织好。

| 简体中文 | English                 |
| -------- | ----------------------- |
| 简体中文 | [English](README_en.md) |

## Kristal 版本支持

| `kristal`                                                                                                                  | `thrash-machine` |
| -------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| [v0.10.0](https://github.com/KristalTeam/Kristal/commit/752bc0688ba97ca8a256ba9125b7e05a1ca6edbd) (`752bc068`, 2026-06-23) | v0.0.0           |

## 有什么

- 直接可玩：starter 地图 + Dummy 战斗 + 对象事件
- 中英双语（kristal-i18n），游戏内可切换
- 开发期工具按子模块组织，生产包自动剔除

| 子模块                       | 用途                                                 |
| ---------------------------- | ---------------------------------------------------- |
| kristal-i18n                 | 本地化，内置英文/简体中文                            |
| kristal-object-selector-plus | 场景对象编辑器（Blender 风格 G/R/S）                 |
| terminal-cli                 | 终端调试控制台（Linux/POSIX）                        |
| kristal-debug-tools          | 战斗调试启动器（`--encounter` / `--wave` / `--tp`…） |
| .emacs / .helix              | 项目级编辑器配置（LuaLS、Kristal 路径）              |

## 开始

```sh
git clone --recurse-submodules https://github.com/Bli-AIk/thrash-machine.git
cd thrash-machine
./start.sh            # 把模板改成你的项目（--name "My Project"；--yes 免交互）
make test             # 静态断言 + 语法检查
KRISTAL_ROOT=/path/to/Kristal just run   # 运行（自动查找常见 Kristal 路径）
```

运行调试参数直接透传给 kristal-debug-tools：`just run --encounter`、`just run --wave 2 --tp 50`、`just run --lang zh-hans`。

打包所需软件按系统区分（打包由 bash + tar + Lua `build-helper/` 完成，用 LÖVE 自带的 LuaJIT 运行，**所有系统都不需要 Python / rsync**）：

| 系统        | 必需                                                             | 说明                                                                                  |
| ----------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| **Windows** | Git for Windows（安装时选默认 PATH 选项）、LÖVE 11.5             | Git Bash 自带 bash/tar/curl/unzip/sed；Git Bash 不含 `zip`，缺省时由 Lua 助手写入 zip |
| **Linux**   | git、tar、unzip、curl、love（如 Arch：`sudo pacman -S love`）    | `zip` 可选：有则用系统 zip，无则 Lua 助手                                             |
| **macOS**   | Git（Xcode 命令行工具）、LÖVE 11.5（`brew install --cask love`） | tar/unzip/curl/zip 系统自带                                                           |

`just` 仅在命令行打包时需要（GUI 自带内嵌 just）。**LÖVE 需在 PATH 中**（或装在默认位置——脚本会自动检查 Windows 的 `Program Files\LOVE` 与 `%LOCALAPPDATA%\Programs\LOVE`）。Android 打包额外需要 JDK 17 + Android SDK API 34 + NDK 25.2.9519653。

## 构建

### 手动打包

- `just build` —— 同时生成 release/debug `.love` 与 Windows x64 包（老用法，默认固定 Kristal v0.10.0，产出在 `dist/`）
- `just build-win` —— 只生成 Windows x64 包
- `just build-love` —— 只生成 release/debug `.love`，不生成 Windows exe、也不下载 LÖVE
- `just build-mod` —— 可直接放进 mods/ 的 Mod ZIP（自动剔除开发期工具）
- `just build-android` —— 可选 Android APK（首次构建需 JDK 17 + Android SDK API 34 + NDK 25.2.9519653；包名/签名通过环境变量覆盖，详见脚本）

在交互式终端运行 `just build`、`just build-win` 或 `just build-love`（或直接 `./build_standalone.sh`）时，脚本会先询问 Kristal 引擎来源：

1. 使用本地 Kristal（自动检测 `.build/Kristal`、`KRISTAL_ROOT` 和常见路径）
2. 自己输入本地路径（Git 检出或普通目录均可）
3. 从 Git 远程选择 tag（自动列出远程 tag 列表）
4. 从 Git 远程输入完整 commit hash（40 位十六进制）

远程下载一律使用浅克隆（`--depth 1`），默认克隆到 `.build/Kristal`。CI 和非交互环境不会提问，仍使用 v0.10.0。需要跳过提问时可用环境变量指定：

- `THRASH_MACHINE_KRISTAL_SOURCE=local|path|tag|commit` 指定来源
- `THRASH_MACHINE_KRISTAL_DIR` / `KRISTAL_ROOT` 指定本地路径
- `THRASH_MACHINE_KRISTAL_REF` 指定 tag 或 commit hash
- `THRASH_MACHINE_KRISTAL_REPO` 覆盖远程仓库

### GUI 打包

用 kristal-debug-tools GUI 也可以打包（Windows 下 `gui.cmd`，或任意平台 `just gui`）：

1. 展开"运行项列表（高级）"→ **项目构建** 组
2. 点 `build` / `build-mod` / `build-android` —— 任务在独立终端窗口运行，输出实时可见

要求与手动打包相同：Windows 需 Git Bash 在 PATH、LÖVE 已安装；`just` 无需安装（GUI 自带）。

GitHub Actions 在 PR/main 上自动验证构建；release-please 合并发布 PR 后自动上传产物与 SHA-256 清单。

## 自定义图标（可选）

构建脚本按**目录约定**读取 `assets/icon/`，无需配置。图标文件或工具缺失时该步骤自动跳过并警告，默认构建不受影响。

```
assets/icon/
├── window_icon.png      # 游戏窗口图标 → 构建时复制到 mod 根目录并置 setWindowTitleAndIcon=true
├── win/                 # Windows exe 图标
│   ├── icon.ico         #   现成 .ico（可选捷径）
│   └── 16x16.png 32x32.png 48x48.png 64x64.png 128x128.png 256x256.png
└── android/             # Android 启动图标（缺失 density 自动就近回退）
    └── ldpi.png mdpi.png hdpi.png xhdpi.png xxhdpi.png xxxhdpi.png
```

| 目标 | 所需工具 | 说明 |
| ---- | -------- | ---- |
| 游戏窗口 | 无 | 自动复制到 mod 根目录（引擎只认根目录的 `window_icon.png`） |
| Windows exe | `rcedit`（Linux/macOS 需 `wine`）+ `icotool`/ImageMagick 合成 PNG | 工具缺失时跳过并警告，不影响构建 |
| Android APK | 无 | 各 density 独立成图，缺失的自动用最近的补位 |

- `win/` 下放一组尺寸 PNG（至少 32 + 256 效果最佳）或直接放 `icon.ico`；脚本优先用现成 `.ico`。
- `THRASH_MACHINE_ICON_FETCH_TOOLS=1` 时脚本自动下载 rcedit 到 `.tools/rcedit/`。
- 完整 `assets/icon/` 目录会被排除出 `.love` / mod 包；`window_icon.png` 会在构建时复制到 mod 根目录后进包。
- 可用环境变量覆盖路径：`THRASH_MACHINE_ICON_DIR`、`THRASH_MACHINE_WINDOW_ICON`、`THRASH_MACHINE_WIN_ICON_DIR`、`THRASH_MACHINE_RCEDit`、`THRASH_MACHINE_ANDROID_ICON_DIR`、`THRASH_MACHINE_ANDROID_ICON`。

## 提交规范

用 Conventional Commits（feat/fix 驱动 release-please 的版本与变更日志）：

    feat: 添加新的 Lua 战斗波次
    fix: 修复地图切换后的对象事件

## 许可证

自研 Lua 源码与文档为 MIT / Apache-2.0 双许可（LICENSE-MIT / LICENSE-APACHE）。Kristal 与子模块的许可边界见 THIRD_PARTY.md。
