# Thrash Machine

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE) <img src="https://img.shields.io/github/repo-size/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/last-commit/Bli-AIk/thrash-machine.svg"/>
<img src="https://img.shields.io/badge/Fennel-4D2B8C?style=for-the-badge"/> <img src="https://img.shields.io/badge/Kristal-3B3B3B?style=for-the-badge"/>

> 当前状态：可作为新 Kristal Mod 的开发模板使用。

**Thrash Machine** 是一个以 Fennel 为作者语言的 Kristal v0.10 模板。它保留可运行的 starter map、Dummy 战斗和对象事件，并将常用的 FUMOS、简体中文语言库、开发期 object-editor、Emacs 和 Helix 配置组织为可更新的子模块。

| 简体中文 | English |
| --- | --- |
| 简体中文 | [English](README_en.md) |

## 特性

- 作者维护的 Mod 代码全部使用 `.fnl`；FUMOS 在 Kristal 中直接加载 Fennel。
- `langLib_zh_hans` 预置英文/简体中文和系统语言自动选择。
- `object-editor` 仅在开发模式启用，生产包自动禁用并移除。
- `.emacs` 提供 FUMOS live REPL、Fennel LSP 和 Kristal LuaLS 集成。
- `.helix` 提供项目级 Kristal/Lua 配置；Helix 内置 Fennel grammar 可直接使用 `fennel-ls`。
- release-please、Mod ZIP、release/debug `.love`、Windows x64 包和 SHA-256 清单。

## 使用

### 克隆

```sh
git clone --recurse-submodules https://github.com/Bli-AIk/thrash-machine.git
cd thrash-machine
git submodule update --init --recursive
```

模板在 `mod.json` 中使用 ID `thrash-machine`。从 GitHub 的 **Use this template** 创建新仓库后，应先修改该 ID、显示名称、版本和 README 徽章地址。

### 依赖

| 工具 | 用途 |
| --- | --- |
| Git | 获取模板和子模块。 |
| LÖVE 11.5 | 运行 Kristal。 |
| Kristal v0.10.0 | 本地运行与独立包基线。 |
| Fennel 1.6.1、LuaJIT | 静态检查和 Fennel 工具链。 |
| `rsync`、`zip`、`unzip`、Python 3 | 构建发行包。 |
| Emacs 30+ 或 Helix、`fennel-ls` | 可选编辑器支持。 |

FUMOS 自带运行时编译器；系统 Fennel CLI 仅用于 `make test` 和编辑器工具。

### 开发

```sh
make test
KRISTAL_ROOT=/path/to/Kristal just run
```

`just run` 也会查找常见的本地 Kristal 路径。要在独立的干净 Kristal checkout 中跑启动 smoke test：

```sh
KRISTAL=/path/to/Kristal make test-kristal
```

FUMOS 的 REPL 只在 `mod.json` 的 `"dev": true` 时启动，并且只监听本机 loopback。保存 Fennel 文件不会自动求值或重载。

### 编辑器

Emacs：加载项目 `.emacs/init.el`，执行 `sh .emacs/tools/install-fennel-ls.sh` 后以开发模式启动游戏，并用 `M-x fumos-connect` 附着到运行中的 FUMOS REPL。

Helix：安装 `fennel-ls` 并确保其在 `PATH` 中。项目的 `.helix` 子模块保留 Kristal/LuaLS 配置，Helix 的 Fennel language definition 会自动发现该 LSP。

完整操作见 [开发说明](docs/development.zh-hans.md)。

## 构建与发行

```sh
just build
just build-mod
```

`just build` 固定使用 Kristal `v0.10.0`，生成 release/debug `.love`、Windows x64 包；它仅修改暂存引擎副本的目标 Mod、自动启动、窗口标识和 release/debug 标志。`just build-mod` 生成可放入 Kristal `mods/` 的生产 Mod ZIP。

生产资产会保留 FUMOS 和语言库，禁用并剔除 object-editor、编辑器配置、测试和构建文件。GitHub Actions 会在 PR/`main` 上验证构建；release-please 合并发布 PR 后，标签工作流会上传所有资产与 `SHA256SUMS`。

## 提交规范

使用 KRISIS 风格的 Conventional Commits，摘要以简洁中文表达：

```text
feat: 添加新的 Fennel 战斗波次
fix: 修复地图切换后的对象事件
refactor: 整理战斗模块
docs: 补充 Helix 配置说明
chore(main): release v0.1.0
```

`feat` 与 `fix` 会被 release-please 用于版本与变更日志；发布提交由自动化生成。

## 许可证

本仓库自有的 Fennel 源码与文档可任选以下许可证使用：

- [Apache License, Version 2.0](LICENSE-APACHE)
- [MIT License](LICENSE-MIT)

Kristal starter 内容和子模块具有各自的许可边界，详见 [第三方声明](THIRD_PARTY.md)。
