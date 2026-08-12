# Changelog

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
