# Thrash Machine

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE)

**Thrash Machine** is a standard Lua Kristal v0.10 template. It keeps a playable starter map, Dummy battle, and object event while wiring together Simplified Chinese localization, a development-only object editor, and project-local Emacs and Helix configuration.

[简体中文](README.md)

## Quick Start

    git clone --recurse-submodules https://github.com/Bli-AIk/thrash-machine.git
    cd thrash-machine
    git submodule update --init --recursive
    make test
    KRISTAL_ROOT=/path/to/Kristal just run

The template uses thrash-machine as its Mod ID. Change the ID, display name, version, and README badge URLs after creating a repository from the GitHub template.

## Tooling

- Kristal v0.10.0 and LÖVE 11.5 for local runs and standalone builds.
- LuaJIT for syntax checks and runtime support.
- langLib_zh_hans for English and Simplified Chinese localization.
- object-editor for development-only scene editing; release packages exclude it.
- .emacs and .helix for LuaLS, Kristal paths, and launch helpers.

## Builds

    just build
    just build-mod

The standalone builder stages stock Kristal v0.10.0 and changes only target-Mod startup, window identity, and release/debug flags. Production packages keep localization, disable the object editor, and exclude development files.

## License

Repository-authored Lua source and documentation are dual-licensed under Apache-2.0 (LICENSE-APACHE) or MIT (LICENSE-MIT). See third-party notices (THIRD_PARTY.md) for Kristal and submodule license boundaries.
