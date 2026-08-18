# Thrash Machine

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE) <img src="https://img.shields.io/github/repo-size/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/last-commit/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/v/release/Bli-AIk/thrash-machine.svg"/> <br>
<img src="https://img.shields.io/badge/Deltarune-001225?style=for-the-badge&labelColor=001225&logo=undertale&logoColor=ff0000" /> <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge"/> <img src="https://img.shields.io/badge/Kristal-3B3B3B?style=for-the-badge"/>

**Thrash Machine** 是一个开箱即用的 Kristal 模板：自带能跑的 starter 地图、Dummy 战斗和对象事件，中文本地化和开发期工具按子模块组织好。

| 简体中文 | English                 |
| -------- | ----------------------- |
| 简体中文 | [English](README_en.md) |

## Kristal 版本支持

| `kristal`                                                                                                                  | `thrash-machine` |
| -------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| [v0.10.0](https://github.com/KristalTeam/Kristal/commit/752bc0688ba97ca8a256ba9125b7e05a1ca6edbd) (`752bc068`, 2026-06-23) | v0.0.0           |

## 有什么

- 直接可玩：starter 地图 + Dummy 战斗 + 对象事件
- 图形化启动器（GUI）：Windows 双击 `gui.cmd` 打开（GUI 自动下载到 Kristal 引擎旁的共享 `.tools\gui\`，无需手动安装）；按引擎 `VERSION` 固定选择 `0.10.0 -> v0.1.5`、`0.11.0-dev -> v0.2.0`，其他版本会明确报错
- 中英双语（kristal-i18n），游戏内可切换
- 开发期工具按子模块组织，生产包自动剔除

| 子模块                       | 用途                                                 |
| ---------------------------- | ---------------------------------------------------- |
| kristal-i18n                 | 本地化，内置英文/简体中文                            |
| kristal-object-selector-plus | 场景对象编辑器（Blender 风格 G/R/S）                 |
| terminal-cli                 | 终端调试控制台（Linux/POSIX）                        |
| kristal-debug-tools          | 战斗调试启动器（`--encounter` / `--wave` / `--tp`…） |
| .emacs / .helix              | 项目级编辑器配置（LuaLS、Kristal 路径）              |

这是**模板仓库**：建议先点仓库主页的 **Use this template** 按钮创建你自己的仓库（子模块引用会一并带上），再克隆你自己的仓库开始开发——这样版本历史和 Release 各自独立。

## 开始

```sh
git clone --recurse-submodules https://github.com/Bli-AIk/thrash-machine.git
cd thrash-machine
./tools/start.sh       # 把模板改成你的项目（--name "My Project"；--yes 免交互）
make test             # 静态断言 + 语法检查
KRISTAL_ROOT=/path/to/Kristal just run   # 运行（自动查找常见 Kristal 路径）
```

运行调试参数直接透传给 kristal-debug-tools：`just run --encounter`、`just run --wave 2 --tp 50`、`just run --lang zh-hans`。

打包所需软件按系统区分：

| 系统        | 必需                                                             | 说明                                                                                  |
| ----------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| **Windows** | Git for Windows（安装时选默认 PATH 选项）、LÖVE 11.5             | Git Bash 自带 bash/tar/curl/unzip/sed；Git Bash 不含 `zip`，缺省时由 Lua 助手写入 zip |
| **Linux**   | git、tar、unzip、curl、love（如 Arch：`sudo pacman -S love`）    | `zip` 可选：有则用系统 zip，无则 Lua 助手                                             |

`just` 仅在命令行打包时需要（GUI 自带内嵌 just）。**LÖVE 需在 PATH 中**（或装在默认位置——脚本会自动检查 Windows 的 `Program Files\LOVE` 与 `%LOCALAPPDATA%\Programs\LOVE`）。

Android 打包有**两种模式**：

- **套包构建（推荐给普通用户）**：`just build-android-wrap`，只需一个 JDK（脚本自动下载官方 LÖVE 壳 APK 与 Android build-tools），几分钟出包，**但是**不能自定义包名/图标/名称，也不能上架 Google Play。
- **编译构建**：`just build-android`，从源码编译原生 APK，需要 JDK 17 + Android SDK API 34 + NDK 25.2.9519653（配置较麻烦，且需联网获取 JDK/SDK/NDK）。

## 构建

### 构建所需工具

**Windows 用户**：只需手动装 **LÖVE**（开发用的桌面版，加进 PATH 或放默认位置即可，脚本会自动找到）；其他工具（Git 含 bash、just、JDK 17、Android 打包工具、Kristal 引擎）全部由脚本自动下载。安卓打包也会自动下载 LÖVE，但那是**移动端 LÖVE**（官方壳 APK），是打进安卓包用的，不是开发用的桌面 LÖVE。

**Linux 用户**：自己装 git、love、just（缺了脚本会给出安装命令提示）；JDK 17、Android 打包工具、官方壳 APK、Kristal 引擎由脚本自动下载。编译版 APK 还需自己装 Android SDK/NDK。

（可选）给 Windows exe 换图标还要 `rcedit`：Windows 上直接运行，Linux 上需要 `wine`；没有就跳过，不影响打包。

### 手动打包

- `just build` —— 同时生成 release/debug `.love` 与 Windows x64 包（老用法，默认固定 Kristal 0.11.0-dev，产出在 `dist/`）
- `just build-win` —— 只生成 Windows x64 包
- `just build-love` —— 只生成 release/debug `.love`，不生成 Windows exe、也不下载 LÖVE
- `just build-mod` —— 可直接放进 `mods/` 的项目 ZIP（自动剔除开发期工具；recipe 和文件名保留 Kristal 兼容后缀）
- `just build-android` —— **编译构建** Android APK（需 JDK 17 + Android SDK API 34 + NDK 25.2.9519653；包名/签名通过环境变量覆盖，详见脚本）
- `just build-android-wrap` —— **套包构建** Android APK（官方 LÖVE 壳 + 游戏 .love，自动下载工具并重签名；只需 JDK、速度更快，**但是**不能自定义包名/图标/名称，也不能上架 Google Play）

构建默认固定 Kristal `f62afea63ccab02f468c24ac0d096bd8a2c9aa81`（`0.11.0-dev`），远程下载使用浅克隆（`--depth 1`），默认克隆到 `.build/Kristal`。若需改用其他来源，在交互式终端设置 `THRASH_MACHINE_KRISTAL_SOURCE=ask` 后运行 `just build`、`just build-win` 或 `just build-love`：

1. 使用本地 Kristal（自动检测 `.build/Kristal`、`KRISTAL_ROOT` 和常见路径）
2. 自己输入本地路径（Git 检出或普通目录均可）
3. 从 Git 远程选择 tag（自动列出远程 tag 列表）
4. 从 Git 远程输入完整 commit hash（40 位十六进制）

CI 与非交互环境同样使用该固定 commit。也可用环境变量指定其他来源：

- `THRASH_MACHINE_KRISTAL_SOURCE=local|path|tag|commit` 指定来源
- `THRASH_MACHINE_KRISTAL_DIR` / `KRISTAL_ROOT` 指定本地路径
- `THRASH_MACHINE_KRISTAL_REF` 指定 tag 或 commit hash
- `THRASH_MACHINE_KRISTAL_REPO` 覆盖远程仓库

### 没有安装 just？用 `tools/just`（Windows 免装，走 GUI 内嵌版）

构建脚本通过 `just` 调用，但 Windows 上**不需要单独安装 just**：仓库里的 `tools/just`（Git Bash）或 `tools/just.cmd`（cmd / PowerShell）会自动使用 kristal-debug-tools GUI 内嵌的 just——`kristal-run` sidecar 的 `just-task` 模式，just 1.58.0 编译在内部。sidecar 缺失时按 `gui.cmd` 相同的固定版本映射和 URL/SHA256 方案下载到共享 `.tools/gui/`（Kristal 引擎旁）：`0.10.0 -> v0.1.5`，`0.11.0-dev -> v0.2.0`；其他引擎版本会停止并说明原因。

```sh
tools/just build-love     # Git Bash
tools\just.cmd build      # cmd / PowerShell
```

- 解析顺序：`$JUST`（显式指定）→ Windows 上 GUI sidecar（`kristal-run just-task <justfile> <task>`）→ PATH 里的 `just`。
- Linux 没有 sidecar，`tools/just` 要求 PATH 里有 `just`（`scoop install just` 或官方安装包）。
- 想手动指定 sidecar：`KRISTAL_RUN=/path/to/kristal-run.exe tools/just build`。
- 产物与直接 `just build` 完全一致（wrapper 先 `cd` 到项目根目录，recipe 行为不变）。

### GUI 打包

用 kristal-debug-tools GUI 也可以打包（Windows 下 `gui.cmd`，或任意平台 `just gui`）：

1. 展开"运行项列表（高级）"→ **项目构建** 组
2. 点 `build` / `build-mod` / `build-android` —— 任务在独立终端窗口运行，输出实时可见

要求与手动打包相同：Windows 需 Git Bash 在 PATH、LÖVE 已安装；`just` 无需安装（GUI 自带）。启动器只下载当前引擎版本对应的固定 GUI release，不会请求 `latest`，也不会回退到另一个 release；目标 release 尚未上传时请稍后重试。

GitHub 的自动构建会在每次推送和合并时自动检查项目能否正常打包；发布新版本时，打包好的文件（包括 Windows x64 包、.love 包、编译版 APK）会自动上传到 GitHub 的 Release 页面。**套包版默认不会自动构建**，需要时可在 GitHub 上手动触发构建并勾选 `build_android_wrap`。不想在自己电脑上安装 JDK、Android SDK 这些环境？直接合并 GitHub 上的版本发布 PR 就行，打包和上传全自动完成。

## Android 打包

### 分发产物对比

|                         | Windows 版         | `.love` 版           | Project 版                  | Android 编译版       | Android 套包版            |
| ----------------------- | ------------------ | -------------------- | --------------------------- | -------------------- | ------------------------- |
| 命令                    | `just build-win`   | `just build-love`    | `just build-mod`            | `just build-android` | `just build-android-wrap` |
| 产物                    | `dist/*-win64.zip` | `dist/*.love`        | `dist/*-mod.zip`            | `dist/*-android.apk` | `dist/*-android-wrap.apk` |
| 运行平台                | Windows            | 装有 LÖVE 的任意平台 | Kristal `mods/`（任意平台） | Android              | Android                   |
| 构建依赖                | git、LÖVE、curl    | LÖVE                 | git、LÖVE                   | JDK 17 + SDK/NDK     | 只需 JDK                  |
| 自定义包名/图标/名称    | —                  | —                    | —                           | ✅ 环境变量可覆盖    | ❌ 沿用官方壳             |
| 修改 LÖVE 引擎/原生代码 | —                  | —                    | —                           | ✅ 可改              | ❌ 不能                   |
| 适合                    | 桌面玩家           | Unix 系用户/开发者   | 玩家安装项目                | 正式分发、深度定制   | 普通玩家快速自用          |

### Windows 一键打包

双击项目根目录的 **`tools\build_android.cmd`**，按提示选择：

1. **快速套包构建** —— 自动下载/安装缺失的 Git Bash（PortableGit）、JDK 17、LÖVE 到 Kristal 引擎旁的共享 `.tools\`（无引擎时回退项目根），然后直接出包；
2. **完整编译构建** —— 额外自动下载 Android cmdline-tools/SDK/NDK（首次约 1.5 GB）。

也支持带参数运行：`tools\build_android.cmd wrap` 或 `tools\build_android.cmd compile`。构建完成后会自动打开 `dist\` 目录。

命令行（任意平台）等价用法：

```sh
just build-android-wrap   # 套包构建（只需 JDK，缺 JDK 时自动下载 Temurin 17 到共享 .tools/jdk17）
just build-android        # 编译构建（需完整 Android SDK/NDK；JDK 同样自动补齐）
```

JDK 解析顺序：`THRASH_MACHINE_ANDROID_JAVA_HOME` / `JAVA_HOME`（显式指定，版本不符会直接报错）→ PATH 里版本匹配的 `java` → 自动下载便携 Temurin JDK 17 到共享 `.tools/jdk17/`（位于 Kristal 引擎旁，多项目共享；无引擎时回退项目根 `.tools`。`THRASH_MACHINE_FETCH_JDK=0` 禁用自动下载；`THRASH_MACHINE_JDK_VERSION` 改版本号）。

## 自定义图标（可选）

构建脚本按**目录约定**读取 `assets/icon/`，无需配置。图标文件或工具缺失时该步骤自动跳过并警告，默认构建不受影响。

```
assets/icon/
├── window_icon.png      # 游戏窗口图标 → 构建时复制到项目根目录并置 setWindowTitleAndIcon=true
├── win/                 # Windows exe 图标
│   ├── icon.ico         #   现成 .ico（可选捷径）
│   └── 16x16.png 32x32.png 48x48.png 64x64.png 128x128.png 256x256.png
└── android/             # Android 启动图标（缺失 density 自动就近回退）
    └── ldpi.png mdpi.png hdpi.png xhdpi.png xxhdpi.png xxxhdpi.png
```

| 目标        | 所需工具                                                          | 说明                                                        |
| ----------- | ----------------------------------------------------------------- | ----------------------------------------------------------- |
| 游戏窗口    | 无                                                                | 自动复制到项目根目录（引擎只认根目录的 `window_icon.png`） |
| Windows exe | `rcedit`（Linux 需 `wine`）+ `icotool`/ImageMagick 合成 PNG | 工具缺失时跳过并警告，不影响构建                            |
| Android APK | 无                                                                | 各 density 独立成图，缺失的自动用最近的补位                 |

- `win/` 下放一组尺寸 PNG（至少 32 + 256 效果最佳）或直接放 `icon.ico`；脚本优先用现成 `.ico`。
- `THRASH_MACHINE_ICON_FETCH_TOOLS=1` 时脚本自动下载 rcedit 到共享 `.tools/rcedit/`（Kristal 引擎旁，无引擎时回退项目根）。
- 完整 `assets/icon/` 目录会被排除出 `.love` / 项目包；`window_icon.png` 会在构建时复制到项目根目录后进包。
- 可用环境变量覆盖路径：`THRASH_MACHINE_ICON_DIR`、`THRASH_MACHINE_WINDOW_ICON`、`THRASH_MACHINE_WIN_ICON_DIR`、`THRASH_MACHINE_RCEDit`、`THRASH_MACHINE_ANDROID_ICON_DIR`、`THRASH_MACHINE_ANDROID_ICON`。

## 提交规范

用 Conventional Commits（feat/fix 驱动 release-please 的版本与变更日志）：

    feat: 添加新的 Lua 战斗波次
    fix: 修复地图切换后的对象事件

## 许可证

自研 Lua 源码与文档为 MIT / Apache-2.0 双许可（LICENSE-MIT / LICENSE-APACHE）。Kristal 与子模块的许可边界见 THIRD_PARTY.md。
