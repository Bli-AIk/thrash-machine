# 开发说明

## Lua 结构

这是标准 Kristal Lua Mod 结构：

| 路径 | 用途 |
| --- | --- |
| mod.lua | Mod 生命周期方法和全局事件注册。 |
| scripts/**/*.lua | Kristal Registry 自动发现的战斗、世界和数据脚本。 |
| libraries/langLib_zh_hans | 语言资源与本地化 hooks。 |
| libraries/object-editor | 仅开发模式启用的对象编辑器。 |

Kristal 会按路径加载 Lua 文件。不要把作者脚本同时保存为多个源语言版本，避免重复注册。

## 编辑器

项目 .emacs 和 .helix 是 kristal-emacs-config、kristal-helix-config 子模块，负责 LuaLS、Kristal API 路径和启动快捷键。

确保 lua-language-server 在 PATH 中，并设置 Kristal 路径：

    command -v lua-language-server
    export KRISTAL_ROOT=/path/to/Kristal

Helix：

    hx --health lua

Emacs：加载 .emacs/init.el，然后从项目根目录启动 Kristal。LuaLS 会使用项目配置和 Kristal 的 Lua API 文档。

## 子模块升级

先在依赖仓库完成测试和发布，再更新本仓库的 gitlink：

    git submodule update --init --recursive
    git -C libraries/langLib_zh_hans fetch origin
    git -C libraries/langLib_zh_hans checkout --detach origin/main
    git add libraries/langLib_zh_hans
    git commit -m "build: pin localization library"

main 使用 .emacs 的 stable/lua 分支。生产包会排除 .emacs、.helix 和 libraries/object-editor。
