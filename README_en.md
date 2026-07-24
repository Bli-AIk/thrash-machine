# Thrash Machine

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE)

**Thrash Machine** is a Fennel-first Kristal v0.10 template. It keeps a playable starter map, Dummy battle, and object event while wiring together FUMOS, Simplified Chinese localization, a development-only object editor, and project-local Emacs and Helix configuration.

[简体中文](README.md)

## Quick Start

```sh
git clone --recurse-submodules https://github.com/Bli-AIk/thrash-machine.git
cd thrash-machine
git submodule update --init --recursive
make test
KRISTAL_ROOT=/path/to/Kristal just run
```

This experimental branch uses `thrash-machine-experimental-fumos` as its default Mod ID so it can coexist with the Lua branch in one Kristal mods directory. Change the ID, display name, version, and README badge URLs after creating a repository from the GitHub template.

## Tooling

- Kristal v0.10.0 and LÖVE 11.5 for local runs and standalone builds.
- Fennel 1.6.1 and LuaJIT for static checks and editor tooling.
- FUMOS loads author-owned `.fnl` files directly in Kristal and provides a development-only local REPL for Emacs.
- `.emacs` provides FUMOS/Emacs integration. `.helix` provides Kristal/Lua project settings; install `fennel-ls` on `PATH` for Fennel LSP support.

## Builds

```sh
just build
just build-mod
```

Production packages preserve FUMOS and localization, while disabling and excluding `object-editor`. The standalone builder stages stock Kristal v0.10.0 and changes only target-Mod startup, window identity, and release/debug flags.

## License

Repository-authored Fennel source and documentation are dual-licensed under [Apache-2.0](LICENSE-APACHE) or [MIT](LICENSE-MIT). See [third-party notices](THIRD_PARTY.md) for Kristal and submodule license boundaries.
