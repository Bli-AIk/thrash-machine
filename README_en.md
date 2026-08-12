# Thrash Machine

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE) <img src="https://img.shields.io/github/repo-size/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/last-commit/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/v/release/Bli-AIk/thrash-machine.svg"/> <br>
<img src="https://img.shields.io/badge/Deltarune-001225?style=for-the-badge&labelColor=001225&logo=undertale&logoColor=ff0000" /> <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge"/> <img src="https://img.shields.io/badge/Kristal-3B3B3B?style=for-the-badge"/>

**Thrash Machine** is a ready-to-use standard Lua Kristal v0.10 template: a playable starter map, Dummy battle and object event out of the box, with Simplified Chinese localization and development tools organized as submodules.

| English | 简体中文                |
| ------- | ----------------------- |
| English | [简体中文](./README.md) |

## Kristal Version Support

| `kristal`                                                                                                                  | `thrash-machine` |
| -------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| [v0.10.0](https://github.com/KristalTeam/Kristal/commit/752bc0688ba97ca8a256ba9125b7e05a1ca6edbd) (`752bc068`, 2026-06-23) | v0.0.0           |

## What's Inside

- Playable starter map + Dummy battle + object event
- English / Simplified Chinese via kristal-i18n, switchable in-game
- Dev tools as submodules, stripped from release packages

| Submodule                    | Purpose                                                    |
| ---------------------------- | ---------------------------------------------------------- |
| kristal-i18n                 | Localization, en/zh_hans built in                          |
| kristal-object-selector-plus | Scene object editor (Blender-style G/R/S)                  |
| terminal-cli                 | Terminal debug console (Linux/POSIX)                       |
| kristal-debug-tools          | Battle debug launcher (`--encounter` / `--wave` / `--tp`…) |
| .emacs / .helix              | Project editor config (LuaLS, Kristal paths)               |

## Quick Start

```sh
git clone --recurse-submodules https://github.com/Bli-AIk/thrash-machine.git
cd thrash-machine
./start.sh            # rename the template to your project (--name "My Project"; --yes non-interactive)
make test             # static assertions + syntax checks
KRISTAL_ROOT=/path/to/Kristal just run   # run (common local Kristal paths are auto-detected)
```

Debug arguments pass straight to kristal-debug-tools: `just run --encounter`, `just run --wave 2 --tp 50`, `just run --lang zh-hans`.

Software requirements by OS (packaging is bash + tar + Lua `build-helper/`, run by LÖVE's bundled LuaJIT — **no Python or rsync on any OS**):

| OS          | Required                                                               | Notes                                                                                                             |
| ----------- | ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| **Windows** | Git for Windows (default PATH option at install), LÖVE 11.5            | Git Bash provides bash/tar/curl/unzip/sed; Git Bash has no `zip`, so the Lua helper writes zips when it's missing |
| **Linux**   | git, tar, unzip, curl, love (e.g. Arch: `sudo pacman -S love`)         | `zip` optional: system zip when present, Lua helper otherwise                                                     |
| **macOS**   | Git (Xcode Command Line Tools), LÖVE 11.5 (`brew install --cask love`) | tar/unzip/curl/zip are built in                                                                                   |

`just` is only needed for command-line packaging (the GUI embeds its own). **LÖVE must be on PATH** (or installed in the default locations — the scripts check Windows' `Program Files\LOVE` and `%LOCALAPPDATA%\Programs\LOVE` automatically). Android packaging additionally needs JDK 17 + Android SDK API 34 + NDK 25.2.9519653.

## Builds

### Manual packaging

- `just build` — release/debug `.love` and Windows x64 packages (pinned to Kristal v0.10.0, output in `dist/`)
- `just build-mod` — a mod ZIP for `mods/` (dev tools stripped)
- `just build-android` — optional Android APK (first build needs JDK 17 + Android SDK API 34 + NDK 25.2.9519653; package/signing overrides via env vars, see scripts)

### Packaging from the GUI

The kristal-debug-tools GUI can package too (run `gui.cmd` on Windows, or `just gui` anywhere):

1. Expand the "RUN LIST (ADVANCED)" panel → **PROJECT BUILDS** group
2. Click `build` / `build-mod` / `build-android` — the task runs in a separate terminal window with live output

Same requirements as manual packaging: Git Bash on PATH on Windows and LÖVE installed; `just` itself is not needed (the GUI embeds it).

GitHub Actions verifies builds on PR/main; after a release-please PR merges, assets and SHA-256 manifests are uploaded automatically.

## Commit Convention

Use Conventional Commits (feat/fix drive release-please versions and changelogs):

    feat: add a new Lua battle wave
    fix: fix object events after room transitions

## License

Repository-authored Lua source and docs are dual-licensed under MIT (LICENSE-MIT) or Apache-2.0 (LICENSE-APACHE). Kristal and submodule license boundaries: THIRD_PARTY.md.
