# Thrash Machine

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE) <img src="https://img.shields.io/github/repo-size/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/last-commit/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/v/release/Bli-AIk/thrash-machine.svg"/> <br>
<img src="https://img.shields.io/badge/Deltarune-001225?style=for-the-badge&labelColor=001225&logo=undertale&logoColor=ff0000" /> <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" /> <img src="https://img.shields.io/badge/Kristal-FF6B35?style=for-the-badge&logo=love2d&logoColor=white" />

**Thrash Machine** — 一个便于开发的 Kristal 模板：把我维护的本地化、对象编辑器、调试工具等实用包都整合成了子模块，拿来就能开工。

| 简体中文 | English                 |
| -------- | ----------------------- |
| 简体中文 | [English](README_en.md) |

## Kristal 版本支持

| `kristal`                                                                                                                     | `thrash-machine` |
| ----------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| [v0.11.0-dev](https://github.com/KristalTeam/Kristal/commit/f62afea63ccab02f468c24ac0d096bd8a2c9aa81) (`f62afea`, 2026-08-16) | v0.2.0 - v0.3.0  |
| [v0.10.0](https://github.com/KristalTeam/Kristal/commit/752bc0688ba97ca8a256ba9125b7e05a1ca6edbd) (`752bc068`, 2026-06-23)    | v0.0.0 – v0.1.0  |

## 里面有什么

- **实用库**：本地化、对象编辑器、战斗调试启动器、终端控制台——按子模块整合，打包按配置取舍（见下方库列表）
- **构建脚本**：Linux 的 .love、Windows 可执行程序、Android APK 三种打包，自动进行图标处理
- **GUI 启动器**：`gui.cmd` 打开图形化启动器，自动按引擎版本下载对应 release（SHA256 校验），点选构建任务就能跑
- **自动化发版**：通过 [release-please](https://github.com/googleapis/release-please) 合并发版 PR，自动打包并上传 Release

### 库列表

| 库                           | 作用                                                           | 备注     |
| ---------------------------- | -------------------------------------------------------------- | -------- |
| kristal-i18n                 | 本地化，内置英文/简体中文，游戏内可切换                        |          |
| kristal-object-selector-plus | 场景对象编辑器，Blender 风格 G/R/S 变换                        |          |
| terminal-cli                 | 终端调试控制台（Linux/POSIX）                                  |          |
| kristal-debug-tools          | 战斗调试启动器：直接指定遭遇、波次、TP、仁慈值                 |          |
| MagicalGlassRedux            | UT 风格光世界战斗内容库（fork）                                | （可选） |
| UndertaleMonstersRecreation  | 蛙吉特、小模怪、商店等 UT 怪物内容示例，依赖 MagicalGlassRedux | （可选） |
| .emacs / .helix              | 项目级编辑器配置（LuaLS、Kristal 路径）                        |          |

## 可选拓展

想写 UT 风格的光世界战斗和怪物内容吗？MagicalGlassRedux（光世界战斗）和 UndertaleMonstersRecreation（蛙吉特、小模怪、商店等怪物内容示例，依赖前者）就是为此准备的可选拓展，在 `mod.json` 顶层的 `optionalLibraries` 里开关（ID 取自各自 `lib.json`）：

```jsonc
"optionalLibraries": {
    "magical-glass": true,
    "undertale_monsters_recreation": true
}
```

`undertale_monsters_recreation` 依赖 `magical-glass`：关掉 MGR 会连带关掉 UMR（哪怕 UMR 还是 `true`）；单独关 UMR 则不影响 MGR。用之前先初始化子模块：

```sh
git submodule update --init libraries/MagicalGlassRedux libraries/UndertaleMonstersRecreation
```

## 快速开始

**1. 获取模板**

**方式一：直接下载（快捷）**

去 [Releases](https://github.com/Bli-AIk/thrash-machine/releases) 页下载 `thrash-machine-<版本>-full-source.zip`（或 `.tar.gz`）——已经拉好全部子模块的完整源码，解压即用。

**方式二：版本管理**

这是**模板仓库**：建议先点仓库主页的 **Use this template** 创建你自己的仓库（子模块引用会一并带上），再克隆你的仓库开始开发——版本历史和 Release 都归你自己。直接克隆也可以：

```sh
git clone --recurse-submodules https://github.com/Bli-AIk/thrash-machine.git
cd thrash-machine
```

**2. 改成你的项目**

把克隆下来的文件夹改成你的项目名，然后直接跑（不传 `--name` 时自动用文件夹名）：

```sh
# Linux / Git Bash
./tools/start.sh --yes
./tools/start.sh --name "My Project" --yes
```

```powershell
# Windows（PowerShell，不需要 Git Bash）
.\tools\start.ps1 --yes
.\tools\start.ps1 --name "My Project" --yes
```

脚本会一并改掉项目 ID、名字，并拉齐全部子模块（`--yes` 免交互；详细选项见 `./tools/start.sh --help`）。

**3. 跑起来**

```sh
make test                                  # 静态断言 + 语法检查
just run                                   # 启动（自动查找 Kristal 引擎）
```

启动器从项目目录逐级向上找引擎（含 `main.lua` 和 `src/kristal.lua` 的目录）——把项目放进引擎的 `mods/` 下（`<Kristal>/mods/<你的项目>`）就完全不用配。项目不在引擎目录里时，运行时报错并告诉你怎么做：`Kristal engine not found. Set KRISTAL_ROOT=/path/to/Kristal.`，照做即可：

```sh
# Linux：只对当前命令生效
KRISTAL_ROOT=/path/to/Kristal just run
```

```powershell
# Windows：当前会话生效
$env:KRISTAL_ROOT = "C:\path\to\Kristal"; just run
```

想一劳永逸，就把 `KRISTAL_ROOT` 配进环境变量（Windows 系统设置、Linux shell 配置）。

调试参数直接透传给 kristal-debug-tools：`just run --encounter`（直接进遭遇）、`just run --wave 2 --tp 50`（指定波次和初始 TP）、`just run --lang zh-hans`（选本次启动语言）。

不想敲命令？GUI 也能用——Windows 双击 `gui.cmd`（其他平台 `just gui`）打开图形化启动器：运行项、调试参数、章节配置都是可视化点选，也能跑构建任务（见下文「打包 → GUI 打包」）。

## 打包

### 命令行打包

Windows 和 Linux/CI 各走各的入口，产物一样：

```powershell
# Windows：原生 PowerShell 入口，不需要 Git Bash
tools\build.cmd all      # 全部（love + win + mod）
tools\build.cmd love     # .love 包
tools\build.cmd win      # Windows x64 包
tools\build.cmd mod      # 可直接放进 mods/ 的项目 ZIP
```

```sh
# Linux / CI
just build                # release/debug .love + Windows x64（产出在 dist/）
just build-win            # 只要 Windows x64
just build-love           # 只要 .love
just build-mod            # 项目 ZIP（自动剔除开发期工具）
```

Linux 需要 git、tar、unzip、curl、love（Arch：`sudo pacman -S love`）；Windows 需要 Git、PowerShell、LÖVE 11.5。

### Android：两种模式

- **套包构建**：`just build-android-wrap`，不需要 Android SDK/NDK——JDK 17、官方 LÖVE 壳和 build-tools 都自动准备；适合快速自用；代价是包名/图标/名称不能自定义，也上不了 Google Play。
- **编译构建**：`just build-android`，从源码编译 APK，包名/图标可自定义，正式分发用它。

Windows 上双击 `tools\build_android.cmd` 按提示选择即可（也支持参数：`build_android.cmd wrap` / `build_android.cmd compile`），两条路径都不用 Git Bash。JDK 解析顺序：`THRASH_MACHINE_ANDROID_JAVA_HOME` / `JAVA_HOME` 显式指定 → PATH 里版本匹配的 `java` → 自动下载便携 Temurin 17（`THRASH_MACHINE_FETCH_JDK=0` 可关闭）。

### GUI 打包

Windows 双击仓库根目录的 `gui.cmd`（其他平台 `just gui`）打开 kristal-debug-tools 的图形化启动器：

1. 展开「运行项列表（高级）」 → **项目构建** 组
2. 点 `build` / `build-mod` / `build-android`，任务在独立终端窗口运行，输出实时可见

启动器只下载与当前引擎版本匹配的固定 release（SHA256 校验），不会请求 `latest`；目标 release 还没传上去时稍后重试。启动器自身也不需要装 just / Rust / Node。

### 引擎来源

构建默认固定 Kristal `f62afea63ccab02f468c24ac0d096bd8a2c9aa81`（`0.11.0-dev`，远程浅克隆到 `.build/Kristal`）。想换来源：交互终端里 `THRASH_MACHINE_KRISTAL_SOURCE=ask just build` 按提示选（本地路径 / 远程 tag / 完整 commit），或用环境变量直接指定：

- `THRASH_MACHINE_KRISTAL_SOURCE=local|path|tag|commit` —— 来源类型
- `THRASH_MACHINE_KRISTAL_DIR` / `KRISTAL_ROOT` —— 本地路径
- `THRASH_MACHINE_KRISTAL_REF` —— tag 或 commit hash
- `THRASH_MACHINE_KRISTAL_REPO` —— 覆盖远程仓库

### 自动发版

每次推送和合并，GitHub 都会自动检查项目能否正常打包；合并发版 PR 之后，Windows x64、.love、编译版 APK 会自动上传到 GitHub Release 页面。**套包版默认不自动构建**，需要时在 GitHub 上手动触发构建并勾选 `build_android_wrap`。

## 自定义图标（可选）

构建脚本按目录约定读 `assets/icon/`，无需配置：

- `window_icon.png` —— 游戏窗口图标
- `win/` —— Windows exe 图标（一组尺寸 PNG，或现成 `icon.ico`）
- `android/` —— 各 density 的启动图标，缺失会自动用最近的补位

缺工具（如 `rcedit`）时自动跳过并警告，不影响默认构建。

## 提交规范

用 Conventional Commits 写提交信息（feat/fix 会驱动 release-please 的版本号与变更日志）：

    feat: 添加新的 Lua 战斗波次
    fix: 修复地图切换后的对象事件

## 许可证

自研 Lua 源码与文档为 MIT / Apache-2.0 双许可（[LICENSE-MIT](LICENSE-MIT) / [LICENSE-APACHE](LICENSE-APACHE)）。Kristal 与各子模块的许可边界见 [THIRD_PARTY.md](THIRD_PARTY.md)。
