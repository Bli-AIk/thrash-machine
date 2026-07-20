# 开发说明

## Fennel 结构

FUMOS 会加载以下作者维护的文件：

| 路径 | 用途 |
| --- | --- |
| `mod.fnl` | Mod 生命周期方法。 |
| `fnl/**/*.fnl` | 普通 Fennel 模块。 |
| `fnl/**/*.fnlm` | 宏模块。 |
| `scripts/**/*.fnl` | Kristal Registry 发现的脚本。 |

`flsproject.fnl` 是 Fennel CLI、fennel-ls 和 FUMOS 共用的搜索路径配置。不要为同一个作者脚本同时维护 `.lua` 与 `.fnl`；FUMOS 会拒绝生命周期方法冲突，`make test` 也会检查作者目录是否残留 Lua。

## Emacs

项目 `.emacs` 是 `kristal-emacs-config` 子模块。安装固定 Fennel LSP：

```sh
sh .emacs/tools/install-fennel-ls.sh
```

载入 `.emacs/init.el` 后，启动开发模式 Kristal，再执行 `M-x fumos-connect`。常用标准键位为：

| 键位 | 操作 |
| --- | --- |
| `C-x C-e` | 求值 point 前的表达式。 |
| `C-M-x` | 异步求值当前顶层 form。 |
| `C-c C-r` | 求值 region。 |
| `C-c C-k` | 重载已保存的当前文件。 |
| `C-c C-z` | 显示 FUMOS REPL。 |

Doom 用户可使用 `SPC m e e`、`SPC m c c`、`SPC m r i`。求值、重载和中断均需显式触发；保存永远不会改变游戏状态。

## Helix

项目 `.helix` 是 `kristal-helix-config` 子模块，负责 LuaLS、Kristal 路径和启动快捷键。Helix 自带 Fennel language definition，但需要在 `PATH` 中找到 `fennel-ls`：

```sh
command -v fennel-ls
hx --health fennel
```

若使用 `.emacs` 的固定安装器，其输出目录不会自动写入 shell `PATH`；可自行安装发行版提供的 `fennel-ls`，或将安装器输出的 `bin/` 目录加入环境变量。`hx --health fennel` 应显示 parser、formatter 和 language server 均可用。

## 子模块升级

先在依赖仓库完成测试和发布，再更新本仓库的 gitlink：

```sh
git submodule update --init --recursive
git -C libraries/fumos fetch origin
git -C libraries/fumos checkout --detach origin/main
git add libraries/fumos
git commit -m "build: pin FUMOS runtime"
```

不要在生产包中保留 `.emacs`、`.helix` 或 `libraries/object-editor`。构建脚本已执行这些排除规则。
