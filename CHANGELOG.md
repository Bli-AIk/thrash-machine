# Changelog

## [0.1.0](https://github.com/Bli-AIk/thrash-machine/compare/v0.0.0...v0.1.0) (2026-08-15)


### Features

* add build-time custom icon support (window / win-exe / android) ([011bf8d](https://github.com/Bli-AIk/thrash-machine/commit/011bf8d8e30eada6a4dd030e8daa43d0aad0abd9))
* add gui.cmd launcher for users without just; slim the justfile ([a484895](https://github.com/Bli-AIk/thrash-machine/commit/a484895865732ddec931f0eea8d480c01f24ef0e))
* add kristal-debug-tools-gui submodule, wire up just gui ([0b2489e](https://github.com/Bli-AIk/thrash-machine/commit/0b2489ef31e62b379257835b7ce3f6470281a22c))
* add wrap Android build and Windows one-click launcher ([eb79484](https://github.com/Bli-AIk/thrash-machine/commit/eb79484bdd276be061164e05a369fc0f0cec1c65))
* bilingual doc comments for GUI task list (# zh_hans: / en) ([3412bc9](https://github.com/Bli-AIk/thrash-machine/commit/3412bc9e2c55d6f5362197b36bf96e5e81413095))
* **build:** add branch source and Android Kristal source selection ([9ad77e8](https://github.com/Bli-AIk/thrash-machine/commit/9ad77e87a3b5e38151205e1844fd07a44c7972f6))
* **build:** auto-install the Android SDK on first use ([00a35b8](https://github.com/Bli-AIk/thrash-machine/commit/00a35b87dad8f8d2b18d11ce3832621834bb8e8a))
* **build:** helpful install hint when git is missing ([4f7e582](https://github.com/Bli-AIk/thrash-machine/commit/4f7e5824f03df0048512075b66e888bd8a47748b))
* **build:** label warnings/errors and open output dir after builds ([36a509f](https://github.com/Bli-AIk/thrash-machine/commit/36a509f10129d2b2badaf81072afa54fb3fdc46e))
* **build:** tools/just interface (GUI-embedded just) + auto-JDK bootstrap ([d408614](https://github.com/Bli-AIk/thrash-machine/commit/d40861434b92a47c8628bef0cccb26c8efc69e3f))
* **gui:** fall back to previous release in gui.cmd when latest is still building ([e934291](https://github.com/Bli-AIk/thrash-machine/commit/e9342912347a7c72db5f095f9575a9bb2424be44))
* **icons:** add GUI-generated default app icons ([d4e73ce](https://github.com/Bli-AIk/thrash-machine/commit/d4e73cecbf5a20587455e58be800c2344329bde3))
* split build commands and add interactive Kristal source selection ([de4934d](https://github.com/Bli-AIk/thrash-machine/commit/de4934d7ba97c6503ce7b4eb9be7e3974114354d))
* support startup language selection in just run ([7df2e22](https://github.com/Bli-AIk/thrash-machine/commit/7df2e22801d6e5c5fc24ae40455aa88bacf492b3))


### Bug Fixes

* **android-wrap:** fall back to the JDK's jar tool when zip is missing ([25ff007](https://github.com/Bli-AIk/thrash-machine/commit/25ff007ba9b66a76b5c0a49867b0c6fc7b8dbdc3))
* **android:** repair wrap-build APK — game.love now actually swapped in ([6325f84](https://github.com/Bli-AIk/thrash-machine/commit/6325f8495b5d0870cd852dece3c15ea49cdc806b))
* **build:** clean partial variant output on failure and harden LÖVE download ([3d2adb1](https://github.com/Bli-AIk/thrash-machine/commit/3d2adb1a844788c261e85c8212682798116426a7))
* **build:** exclude dist-* outputs from staged packages ([8c78b19](https://github.com/Bli-AIk/thrash-machine/commit/8c78b19faf10206485197fbabe3a92a4b2e18035))
* **build:** exclude engine mods/ from staging to stop recursive copy ([1a53cae](https://github.com/Bli-AIk/thrash-machine/commit/1a53cae1538247a6992528c20916186cb2f11f9a))
* **build:** hand love.exe Windows paths instead of msys /c/... paths ([bacba41](https://github.com/Bli-AIk/thrash-machine/commit/bacba41f05fc15359b6620555542e89872da4405))
* **build:** never stage the engine's shared .tools into the build ([f02333d](https://github.com/Bli-AIk/thrash-machine/commit/f02333d27d0c058619ffcf035086986ac565b946))
* **build:** open output dir on Windows with backslash path for explorer ([d379f6d](https://github.com/Bli-AIk/thrash-machine/commit/d379f6da4a3e97f0eea0556b04c138dce02ad1e1))
* **build:** resolve relative output paths in zip_dir ([0fdd2d6](https://github.com/Bli-AIk/thrash-machine/commit/0fdd2d6b18a1aefb57ee4796312b86462919fdd8))
* **build:** restrict Windows dir /s /b to files in helper file_list ([e45a76d](https://github.com/Bli-AIk/thrash-machine/commit/e45a76d0be01ff5a22e660e4d87bb29c9dc45ed8))
* **build:** reuse an existing portable JDK instead of re-downloading ([95eb050](https://github.com/Bli-AIk/thrash-machine/commit/95eb050118983daad31a1339caaf836981976893))
* **build:** show download progress in build_android.ps1 ([2f29683](https://github.com/Bli-AIk/thrash-machine/commit/2f29683805b1b84d7ec3a0c45e0aba2d2f2a1ec1))
* **build:** use LuaJIT bit library in LÖVE build helper ([452d417](https://github.com/Bli-AIk/thrash-machine/commit/452d41788eb5408018e08595143dd729f60b47a3))
* **debug-tools:** pin gui.cmd paren-escape fix ([cd93da5](https://github.com/Bli-AIk/thrash-machine/commit/cd93da5fb7c3ee206d92581bf71fed93caa1d59d))
* detect a Kristal engine above the mod root during builds ([0c755ca](https://github.com/Bli-AIk/thrash-machine/commit/0c755cae9ab5d7334fab68146ce60b8e1a66c6fc))
* exclude the debug-tools GUI dev files from standalone packages ([d3463b2](https://github.com/Bli-AIk/thrash-machine/commit/d3463b2359937ba10ffd6e57c6da7293c7452e8e))
* **gui:** show per-file download progress in gui.cmd ([b9d23b2](https://github.com/Bli-AIk/thrash-machine/commit/b9d23b22cda6a078b6388915dda549e51e266d86))
* keep the wine prefix outside the mod tree ([b6df63f](https://github.com/Bli-AIk/thrash-machine/commit/b6df63f9cf6b430759167618676cce06073ecafb))
* **mod:** strip submodule CI (.github) directories from the mod package ([6fe16b9](https://github.com/Bli-AIk/thrash-machine/commit/6fe16b9205d12c5928d8fca52246666226dd98ec))
* reset project version to 0.0.0 in start.sh ([71ce030](https://github.com/Bli-AIk/thrash-machine/commit/71ce0304916c6e8b5c4ce51a4ff7de0fe907efc8))
* **test:** make test-kristal work on Windows Git Bash ([8602f17](https://github.com/Bli-AIk/thrash-machine/commit/8602f17080f98a61c92bd3e70f76c45a7bc6e0b8))


### Code Refactoring

* **build:** drop unpacked package folders from dist after zipping ([d577af9](https://github.com/Bli-AIk/thrash-machine/commit/d577af91fb2a5ebd66affb6a017e9068c900a841))
* host auto-downloaded tools in &lt;kristal-root&gt;/.tools ([9bdf325](https://github.com/Bli-AIk/thrash-machine/commit/9bdf32575aa12d0273be7a7a35b32ee9c678d8d4))
* 将构建脚本统一移入 tools/ 目录 ([8761874](https://github.com/Bli-AIk/thrash-machine/commit/8761874ef9898cfc519a5f47cd6b94e827535f0c))

## 0.0.0 (2026-08-11)

### ⚠ BREAKING CHANGES

- migrate thrash-machine to kristal-i18n 0.1.0

### Features

- always enable light-world CELL menu (has_cell_phone + phone key item) ([ae2ccdf](https://github.com/Bli-AIk/thrash-machine/commit/ae2ccdfeaeef3c9dd663ce8e6e32b9b5f5cfa757))
- **android:** add Android packaging and touch controls ([226512a](https://github.com/Bli-AIk/thrash-machine/commit/226512a322e6348fefbd9be22ad2705ed4899af2))
- extract battle debug tools into library ([a8e0520](https://github.com/Bli-AIk/thrash-machine/commit/a8e05203c9f5d396ea4fe95c4d50499f65dbf57b))
- **i18n:** 本地化 Lua Kristal 模板 ([417c747](https://github.com/Bli-AIk/thrash-machine/commit/417c747d18695a0c1b9cf45e6d8d000638caab27))
- migrate thrash-machine to kristal-i18n 0.1.0 ([3cd6f17](https://github.com/Bli-AIk/thrash-machine/commit/3cd6f17ae3ab5e577f4833c2b33c7a9416fec086))
- starwalker light-world inventory shuffle (3 rounds), i18n lib bump ([0e0f0dd](https://github.com/Bli-AIk/thrash-machine/commit/0e0f0dd8d0b4d83ed496f7b36597744e2adf55f3))
- 接入终端调试库 ([9ebf258](https://github.com/Bli-AIk/thrash-machine/commit/9ebf25821b196a9428d5afda3479409cd04830f1))

### Bug Fixes

- **android:** add touch control edge margins ([70a28f0](https://github.com/Bli-AIk/thrash-machine/commit/70a28f069cdfacef3f46c054b6e24e7fcbc0f92b))
- **android:** close button texture outlines ([6e57513](https://github.com/Bli-AIk/thrash-machine/commit/6e5751369c490baed87be9ed2487479af571a89d))
- **android:** improve touch controls ([a5e102a](https://github.com/Bli-AIk/thrash-machine/commit/a5e102a4fd07c2776e38226c1e70e3a929ee2fb0))
- **android:** preserve touch margins on narrow layouts ([726acac](https://github.com/Bli-AIk/thrash-machine/commit/726acac10538270c840fb5b94db2c9541eb1ec0f))
- **android:** refine touch control layout ([a23f19e](https://github.com/Bli-AIk/thrash-machine/commit/a23f19ec33be8c950da39a7a02c0adcef49bba89))
- **android:** restore button outlines ([6da0c9a](https://github.com/Bli-AIk/thrash-machine/commit/6da0c9a660dd925df2c3de589ee36cd1e9665389))
- **ci:** 在用户 rock tree 安装 Fennel ([9f0a7b5](https://github.com/Bli-AIk/thrash-machine/commit/9f0a7b5851dd5689a2f6cad540bd09022441f673))
- **i18n:** align reference translations ([35919fe](https://github.com/Bli-AIk/thrash-machine/commit/35919fe9dde54d2649836a248f5f41a5f52ac575))
- **i18n:** bump kristal-i18n submodule to v0.3.1 ([4eaa6b2](https://github.com/Bli-AIk/thrash-machine/commit/4eaa6b20e2813268796aa23c4188fb63ab5a5950))
- **i18n:** localize remaining character names ([63b5505](https://github.com/Bli-AIk/thrash-machine/commit/63b550538c4c2b79281249f65a34685db53ba89e))
- **i18n:** remove misspelled 'raisel' name entry ([fa42c04](https://github.com/Bli-AIk/thrash-machine/commit/fa42c0414fbdb183d17ab1219e769b46328f8fd1))
- **i18n:** 修复物品中文本地化加载时序 ([77901ed](https://github.com/Bli-AIk/thrash-machine/commit/77901ed2275bd5dad810944c0d51bbd91bff07ee))
- **i18n:** 校正中文本地化术语 ([37d9b4a](https://github.com/Bli-AIk/thrash-machine/commit/37d9b4a6e9a867b806eff39052194e5f7afc31c1))
- **i18n:** 校正中文本地化术语 ([39c5149](https://github.com/Bli-AIk/thrash-machine/commit/39c51495a570477761245ad9d34bbbb4279b0654))
- **i18n:** 校正中文本地化术语 ([9446cd7](https://github.com/Bli-AIk/thrash-machine/commit/9446cd75b20cedcd66c18d8aea52942270d1c385))
- **i18n:** 校正中文本地化术语 ([1271f1e](https://github.com/Bli-AIk/thrash-machine/commit/1271f1e2ba58b7fc077dcd137e7e2e0e7d890548))
- **i18n:** 校正中文本地化术语 ([7977bf4](https://github.com/Bli-AIk/thrash-machine/commit/7977bf42dfdcfa31ba2092ce67f17c5e33fea50d))
- use {id} interpolation in tiled dialogue, drop id props ([75753c3](https://github.com/Bli-AIk/thrash-machine/commit/75753c3d43826455bdcc1b319f0d897e6c4f3f06))

### Code Refactoring

- **ci:** hide template-only checks ([e9de186](https://github.com/Bli-AIk/thrash-machine/commit/e9de186ab026f5c2a26d77be0f277fb2bf085710))
- **i18n:** simplify localized name references ([a7a93b3](https://github.com/Bli-AIk/thrash-machine/commit/a7a93b388987d0fdf5e080849c812874477f2c14))
- **i18n:** use shared Chinese language library ([52ca0b9](https://github.com/Bli-AIk/thrash-machine/commit/52ca0b99a5bce9111993012ca4eb7d5f117ff4c9))
- 恢复标准 Lua Kristal 模板 ([4d451a6](https://github.com/Bli-AIk/thrash-machine/commit/4d451a6a9b02eaabf1d272f0513318ea0ae4e1bb))

### Reverts

- no invented phone content (engine has no default calls); keep starwalker shuffle only ([5531d7d](https://github.com/Bli-AIk/thrash-machine/commit/5531d7d9f7afdb25f4966f12a5afe8ce32a6ee63))

## Changelog

All notable changes are documented here by release-please.
