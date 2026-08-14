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
- GUI launcher: double-click `gui.cmd` on Windows to open it (the GUI auto-downloads into the shared `.tools\gui\` next to the Kristal engine, no manual install); run the game, pass debug args, and package — all by clicking buttons
- English / Simplified Chinese via kristal-i18n, switchable in-game
- Dev tools as submodules, stripped from release packages

| Submodule                    | Purpose                                                    |
| ---------------------------- | ---------------------------------------------------------- |
| kristal-i18n                 | Localization, en/zh_hans built in                          |
| kristal-object-selector-plus | Scene object editor (Blender-style G/R/S)                  |
| terminal-cli                 | Terminal debug console (Linux/POSIX)                       |
| kristal-debug-tools          | Battle debug launcher (`--encounter` / `--wave` / `--tp`…) |
| .emacs / .helix              | Project editor config (LuaLS, Kristal paths)               |

This is a **template repository**: click **Use this template** on the repo page to create your own copy (the submodule references come along), then clone your own repo before you start — your version history and releases stay independent.

## Quick Start

```sh
git clone --recurse-submodules https://github.com/Bli-AIk/thrash-machine.git
cd thrash-machine
./tools/start.sh       # rename the template to your project (--name "My Project"; --yes non-interactive)
make test             # static assertions + syntax checks
KRISTAL_ROOT=/path/to/Kristal just run   # run (common local Kristal paths are auto-detected)
```

Debug arguments pass straight to kristal-debug-tools: `just run --encounter`, `just run --wave 2 --tp 50`, `just run --lang zh-hans`.

Software requirements by OS:

| OS          | Required                                                               | Notes                                                                                                             |
| ----------- | ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| **Windows** | Git for Windows (default PATH option at install), LÖVE 11.5            | Git Bash provides bash/tar/curl/unzip/sed; Git Bash has no `zip`, so the Lua helper writes zips when it's missing |
| **Linux**   | git, tar, unzip, curl, love (e.g. Arch: `sudo pacman -S love`)         | `zip` optional: system zip when present, Lua helper otherwise                                                     |

`just` is only needed for command-line packaging (the GUI embeds its own). **LÖVE must be on PATH** (or installed in the default locations — the scripts check Windows' `Program Files\LOVE` and `%LOCALAPPDATA%\Programs\LOVE` automatically).

Android packaging has **two modes**:

- **Wrap build (recommended for casual users)**: `just build-android-wrap` — only needs a JDK (the official LÖVE shell APK and Android build-tools are downloaded automatically); an APK is ready in minutes, **but** the package id/icon/name cannot be customized and it cannot be published on Google Play.
- **Compile build**: `just build-android` — compiles a native APK from source and needs JDK 17 + Android SDK API 34 + NDK 25.2.9519653 (more setup involved, and the JDK/SDK/NDK must be fetched over the network).

## Builds

### Build tools

**Windows**: install **LÖVE** yourself (the desktop build you develop with — add it to PATH or use a default install location; the scripts find it automatically). Everything else — Git (with bash), `just`, JDK 17, Android packaging tools, the Kristal engine — is downloaded automatically by the build scripts. The Android build also downloads LÖVE, but that is the **mobile LÖVE** (the official shell APK) that goes inside the APK — not the desktop LÖVE you develop with.

**Linux**: install git, love and `just` yourself (the scripts print the install commands if something is missing). JDK 17, Android packaging tools, the official shell APK and the Kristal engine are downloaded automatically by the build scripts. The compile-build APK additionally needs the Android SDK/NDK installed by hand.

(Optional) Customizing the Windows exe icon uses `rcedit`: runs directly on Windows, needs `wine` on Linux; without it the icon is skipped and the build is unaffected.

### Manual packaging

- `just build` — release/debug `.love` plus Windows x64 packages (original behavior; Kristal v0.10.0 by default, output in `dist/`)
- `just build-win` — Windows x64 package only
- `just build-love` — release/debug `.love` only, without Windows executables or a LÖVE download
- `just build-mod` — a mod ZIP for `mods/` (dev tools stripped)
- `just build-android` — **compile-build** Android APK (needs JDK 17 + Android SDK API 34 + NDK 25.2.9519653; package/signing overrides via env vars, see scripts)
- `just build-android-wrap` — **wrap-build** Android APK (official LÖVE shell + game.love; tools auto-downloaded and re-signed; only a JDK is required and it is faster, **but** the package id/icon/name cannot be customized and it cannot be published on Google Play)

When `just build`, `just build-win`, or `just build-love` (or `./tools/build_standalone.sh`) runs in an interactive terminal, the script first asks where the Kristal engine should come from:

1. Use a local Kristal checkout (auto-detects `.build/Kristal`, `KRISTAL_ROOT`, and common paths)
2. Enter a local path yourself (a Git checkout or a plain directory both work)
3. Pick a tag from the Git remote (the tag list is fetched and shown)
4. Enter a full commit hash from the Git remote (40 hex characters)

All remote downloads use shallow clones (`--depth 1`), and the default checkout location is `.build/Kristal`. CI and non-interactive environments do not prompt and keep using v0.10.0. To skip the prompt, set:

- `THRASH_MACHINE_KRISTAL_SOURCE=local|path|tag|commit`
- `THRASH_MACHINE_KRISTAL_DIR` / `KRISTAL_ROOT` for a local path
- `THRASH_MACHINE_KRISTAL_REF` for a tag or commit hash
- `THRASH_MACHINE_KRISTAL_REPO` to override the remote repository

### No standalone `just`? Use `tools/just` (Windows: zero-install, GUI-embedded)

The build scripts are driven by `just`, but on Windows **no separate just install is needed**: `tools/just` (Git Bash) or `tools/just.cmd` (cmd/PowerShell) automatically uses the just embedded in the kristal-debug-tools GUI — the `kristal-run` sidecar's `just-task` mode (just 1.58.0 compiled in). When the sidecar is missing it is downloaded on demand into the shared `.tools/gui/` (next to the Kristal engine) using the same URL/SHA256 scheme as `gui.cmd`, so a pristine machine works out of the box.

```sh
tools/just build-love     # Git Bash
tools\just.cmd build      # cmd / PowerShell
```

- Resolution order: `$JUST` (explicit) → GUI sidecar on Windows (`kristal-run just-task <justfile> <task>`) → `just` on PATH.
- Linux has no sidecar, so `tools/just` requires `just` on PATH (`scoop install just` or the official installer).
- To point at a specific sidecar: `KRISTAL_RUN=/path/to/kristal-run.exe tools/just build`.
- Output is identical to running `just build` directly (the wrapper cd's to the project root first, so recipes behave the same).

### Packaging from the GUI

The kristal-debug-tools GUI can package too (run `gui.cmd` on Windows, or `just gui` anywhere):

1. Expand the "RUN LIST (ADVANCED)" panel → **PROJECT BUILDS** group
2. Click `build` / `build-mod` / `build-android` — the task runs in a separate terminal window with live output

Same requirements as manual packaging: Git Bash on PATH on Windows and LÖVE installed; `just` itself is not needed (the GUI embeds it). If the latest release was just cut while CI is still building (assets not uploaded yet), the script falls back to the previous release; if the previous release was already downloaded, it asks before using the cached copy.

GitHub's automated builds check that the project packages correctly on every push and merge; when a new version is released, the packaged files (including the Windows x64 package, the .love package, and the **compiled APK**) are uploaded to the GitHub Release page automatically. The **wrap APK is not built automatically by default** — enable it by checking `build_android_wrap` when triggering a build manually on GitHub. Don't want to install JDK or Android SDK on your own machine? Just merge the version-release PR on GitHub — packaging and uploading are fully automatic.

## Android Packaging

### Distribution matrix

|                                      | Windows            | `.love`                | Mod                            | Android compile                           | Android wrap                        |
| ------------------------------------ | ------------------ | ---------------------- | ------------------------------ | ----------------------------------------- | ----------------------------------- |
| Recipe                               | `just build-win`   | `just build-love`      | `just build-mod`               | `just build-android`                      | `just build-android-wrap`           |
| Output                               | `dist/*-win64.zip` | `dist/*.love`          | `dist/*-mod.zip`               | `dist/*-android.apk`                      | `dist/*-android-wrap.apk`           |
| Runs on                              | Windows            | Any platform with LÖVE | Kristal `mods/` (any platform) | Android                                   | Android                             |
| Build deps                           | git, LÖVE, curl    | LÖVE                   | git, LÖVE                      | JDK 17 + SDK/NDK                          | A JDK only                          |
| Custom package id / icon / name      | —                  | —                      | —                              | ✅ env overrides                          | ❌ official shell                   |
| Modify the LÖVE engine / native code | —                  | —                      | —                              | ✅                                        | ❌                                  |
| Best for                             | Desktop players    | Unix users/developers  | Players installing mods        | Official distribution, deep customization | Casual users, quick personal builds |

### One-click packaging on Windows

Double-click **`tools\build_android.cmd`** in the project root and pick:

1. **Quick wrap build** — automatically installs whatever is missing into the shared `.tools\` next to the Kristal engine (PortableGit Git Bash, JDK 17, LÖVE 11.5; the mod root is the fallback) and produces the APK;
2. **Full compile build** — additionally downloads the Android cmdline-tools/SDK/NDK (first run ~1.5 GB).

It also accepts arguments: `tools\build_android.cmd wrap` or `tools\build_android.cmd compile`. When the build finishes it opens the `dist\` folder.

Equivalent commands on any platform:

```sh
just build-android-wrap   # wrap build (only a JDK is needed; a missing JDK auto-downloads Temurin 17 into the shared .tools/jdk17)
just build-android        # compile build (needs the full Android SDK/NDK; the JDK is auto-supplemented too)
```

JDK resolution order: `THRASH_MACHINE_ANDROID_JAVA_HOME` / `JAVA_HOME` (explicit; a version mismatch fails fast) → a version-matching `java` on PATH → an auto-downloaded portable Temurin JDK 17 in the shared `.tools/jdk17/` (next to the Kristal engine, shared across mods; the mod root `.tools` is the fallback when no engine is found. `THRASH_MACHINE_FETCH_JDK=0` disables the download; `THRASH_MACHINE_JDK_VERSION` changes the version).

## Custom Icons (Optional)

The build scripts read custom icons from `assets/icon/` by **directory convention** — no configuration needed. Any icon step is skipped (with a warning) when the file or the required tool is missing, so the default build is unchanged.

```
assets/icon/
├── window_icon.png      # Game window icon → copied to the mod root + setWindowTitleAndIcon=true
├── win/                 # Windows exe icon
│   ├── icon.ico         #   ready-made .ico (optional shortcut)
│   └── 16x16.png 32x32.png 48x48.png 64x64.png 128x128.png 256x256.png
└── android/             # Android launcher icons (missing densities fall back to the nearest)
    └── ldpi.png mdpi.png hdpi.png xhdpi.png xxhdpi.png xxxhdpi.png
```

| Target      | Tools required                                                                 | Notes                                                                                |
| ----------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| Game window | none                                                                           | copied to the mod root automatically (the engine only reads `window_icon.png` there) |
| Windows exe | `rcedit` (needs `wine` on Linux) + `icotool`/ImageMagick to combine PNGs | skipped with a warning when missing                                                  |
| Android APK | none                                                                           | per-density icons with automatic nearest-density fallback                            |

- Under `win/` drop a set of size-named PNGs (32 + 256 gives the best result) or a ready-made `icon.ico`; the script prefers an existing `.ico`.
- `THRASH_MACHINE_ICON_FETCH_TOOLS=1` makes the script download rcedit into the shared `.tools/rcedit/` (next to the Kristal engine; the mod root is the fallback) automatically.
- The whole `assets/icon/` directory is excluded from `.love` / mod packages; `window_icon.png` is copied to the mod root during the build and then packaged.
- Paths can be overridden: `THRASH_MACHINE_ICON_DIR`, `THRASH_MACHINE_WINDOW_ICON`, `THRASH_MACHINE_WIN_ICON_DIR`, `THRASH_MACHINE_RCEDit`, `THRASH_MACHINE_ANDROID_ICON_DIR`, `THRASH_MACHINE_ANDROID_ICON`.

## Commit Convention

Use Conventional Commits (feat/fix drive release-please versions and changelogs):

    feat: add a new Lua battle wave
    fix: fix object events after room transitions

## License

Repository-authored Lua source and docs are dual-licensed under MIT (LICENSE-MIT) or Apache-2.0 (LICENSE-APACHE). Kristal and submodule license boundaries: THIRD_PARTY.md.
