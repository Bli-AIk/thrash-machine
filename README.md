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

| 系统 | 必需 | 说明 |
| ---- | ---- | ---- |
| **Windows** | Git for Windows（安装时选默认 PATH 选项）、LÖVE 11.5 | Git Bash 自带 bash/tar/curl/unzip/sed；Git Bash 不含 `zip`，缺省时由 Lua 助手写入 zip |
| **Linux** | git、tar、unzip、curl、love（如 Arch：`sudo pacman -S love`） | `zip` 可选：有则用系统 zip，无则 Lua 助手 |
| **macOS** | Git（Xcode 命令行工具）、LÖVE 11.5（`brew install --cask love`） | tar/unzip/curl/zip 系统自带 |

`just` 仅在命令行打包时需要（GUI 自带内嵌 just）。**LÖVE 需在 PATH 中**（或装在默认位置——脚本会自动检查 Windows 的 `Program Files\LOVE` 与 `%LOCALAPPDATA%\Programs\LOVE`）。Android 打包额外需要 JDK 17 + Android SDK API 34 + NDK 25.2.9519653。

## 构建

### 手动打包

- `just build` —— release/debug `.love` 与 Windows x64 包（固定 Kristal v0.10.0，产出在 `dist/`）
- `just build-mod` —— 可直接放进 mods/ 的 Mod ZIP（自动剔除开发期工具）
- `just build-android` —— 可选 Android APK（首次构建需 JDK 17 + Android SDK API 34 + NDK 25.2.9519653；包名/签名通过环境变量覆盖，详见脚本）

### GUI 打包

用 kristal-debug-tools GUI 也可以打包（Windows 下 `gui.cmd`，或任意平台 `just gui`）：

1. 展开"运行项列表（高级）"→ **项目构建** 组
2. 点 `build` / `build-mod` / `build-android` —— 任务在独立终端窗口运行，输出实时可见

要求与手动打包相同：Windows 需 Git Bash 在 PATH、LÖVE 已安装；`just` 无需安装（GUI 自带）。

GitHub Actions 在 PR/main 上自动验证构建；release-please 合并发布 PR 后自动上传产物与 SHA-256 清单。

## 提交规范

用 Conventional Commits（feat/fix 驱动 release-please 的版本与变更日志）：

    feat: 添加新的 Lua 战斗波次
    fix: 修复地图切换后的对象事件

## 许可证

自研 Lua 源码与文档为 MIT / Apache-2.0 双许可（LICENSE-MIT / LICENSE-APACHE）。Kristal 与子模块的许可边界见 THIRD_PARTY.md。
