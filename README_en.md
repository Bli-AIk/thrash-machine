# Thrash Machine

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE) <img src="https://img.shields.io/github/repo-size/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/last-commit/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/v/release/Bli-AIk/thrash-machine.svg"/> <br>
<img src="https://img.shields.io/badge/Deltarune-001225?style=for-the-badge&labelColor=001225&logo=undertale&logoColor=ff0000" /> <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge"/> <img src="https://img.shields.io/badge/Kristal-3B3B3B?style=for-the-badge"/>

**Thrash Machine** is a ready-to-use Kristal template: a playable starter map, Dummy battle and object event out of the box, with Simplified Chinese localization and development tools organized as submodules.

| English | 简体中文                |
| ------- | ----------------------- |
| English | [简体中文](./README.md) |

## Kristal Version Support

| `kristal`                                                                                                                    | `thrash-machine` |
| -------------------------------------------------------------------------------------------------------------------------------| ------ |
| [v0.11.0-dev](https://github.com/KristalTeam/Kristal/commit/f62afea63ccab02f468c24ac0d096bd8a2c9aa81) (`f62afea`, 2026-08-16) | v0.2.0 - v0.3.0 |
| [v0.10.0](https://github.com/KristalTeam/Kristal/commit/752bc0688ba97ca8a256ba9125b7e05a1ca6edbd) (`752bc068`, 2026-06-23)    | v0.0.0 – v0.1.0 |

## What's Inside

- Playable starter map + Dummy battle + object event
- GUI launcher: double-click `gui.cmd` on Windows to open it (the GUI auto-downloads into the shared `.tools\gui\` next to the Kristal engine, no manual install); it selects `0.10.0 -> v0.1.5` or `0.11.0-dev -> v0.2.0` from the engine `VERSION` and clearly rejects other versions
- English / Simplified Chinese via kristal-i18n, switchable in-game
- Dev tools as submodules, stripped from release packages

| Submodule                    | Purpose                                                    |
| ---------------------------- | ---------------------------------------------------------- |
| kristal-i18n                 | Localization, en/zh_hans built in                          |
| kristal-object-selector-plus | Scene object editor (Blender-style G/R/S)                  |
| terminal-cli                 | Terminal debug console (Linux/POSIX)                       |
| kristal-debug-tools          | Battle debug launcher (`--encounter` / `--wave` / `--tp`…) |
| MagicalGlassRedux            | **Optional** UT light battle pack (fork, Kristal 0.11-dev) |
| UndertaleMonstersRecreation  | **Optional** UT monster content; requires MGR             |
| .emacs / .helix              | Project editor config (LuaLS, Kristal paths)               |

## Optional UT content pack

`libraries/MagicalGlassRedux` and `libraries/UndertaleMonstersRecreation` are
optional content submodules, not development tools. Select them through the
top-level `optionalLibraries` object in `mod.json`; its keys are the real
library IDs from `lib.json`, not submodule directory names:

```jsonc
"optionalLibraries": {
    "magical-glass": true,
    "undertale_monsters_recreation": true
}
```

`undertale_monsters_recreation` requires `magical-glass`. Disabling MGR also
disables UMR even when UMR remains `true`; disabling UMR alone leaves MGR
enabled. Initialize the submodules when you want the optional content:

```sh
git submodule update --init libraries/MagicalGlassRedux libraries/UndertaleMonstersRecreation
```

Release artifacts and `build-mod` project packages physically remove disabled
libraries. Debug artifacts retain their files, but disabled libraries are not
initialized, registered, or exposed through `Mod.libs` at runtime. That runtime
boundary does not promise that Kristal never compiles their Lua source before
startup.

Both libraries are forks maintained by this project (upstream:
FireRainV/Noelle-Libraries-Pack). See their `LICENSE-UPSTREAM.md` files:
upstream code retains all rights; fork additions are MIT or Apache-2.0.

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
| **Windows** | Git, PowerShell, LÖVE 11.5                                             | Use the native PowerShell build entry point; Git Bash is not required. Git is used for cloning or targets that fetch source. |
| **Linux**   | git, tar, unzip, curl, love (e.g. Arch: `sudo pacman -S love`)         | `zip` optional: system zip when present, Lua helper otherwise                                                     |

Linux/CI command-line packaging uses `just`. Windows can use the native entry
point below without installing `just`. **LÖVE must be on PATH** (or installed
in the default locations — the scripts check Windows' `Program Files\LOVE` and
`%LOCALAPPDATA%\Programs\LOVE` automatically).

Android packaging has **two modes**:

- **Wrap build (recommended for casual users)**: `just build-android-wrap` — no Android SDK/NDK is needed; the script downloads JDK 17, the official LÖVE shell APK, and Android build-tools. It still uses a local Kristal checkout or Git to obtain the pinned engine. The package id/icon/name cannot be customized and it cannot be published on Google Play.
- **Compile build**: `just build-android` — compiles a native APK from source. The script provisions JDK 17, Android SDK API 34, NDK 25.2.9519653, and the Gradle wrapper; the first run downloads them, while obtaining Kristal and love-android source still needs Git.

## Builds

### Build tools

**Windows**: install the desktop **LÖVE** you develop with (add it to PATH or use a default install location; the scripts find it automatically), then use the native PowerShell entry point. Git Bash is not a build prerequisite; targets that need Git to fetch source check it explicitly. The LÖVE used for Android packaging is the **mobile LÖVE** official shell APK, not the desktop LÖVE used for development.

**Linux**: install git, love and `just` yourself (the scripts print the install commands if something is missing). JDK 17, Android packaging tools, the official shell APK and the Kristal engine are downloaded automatically by the build scripts.

(Optional) Customizing the Windows exe icon uses `rcedit`: runs directly on Windows, needs `wine` on Linux; without it the icon is skipped and the build is unaffected.

### Command-line packaging

On Windows, run the native entry point directly:

```powershell
tools\build.cmd all
tools\build.cmd love
tools\build.cmd win
tools\build.cmd mod

# Or call PowerShell directly.
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build.ps1 all
```

`tools\build.cmd` and `tools\build.ps1` accept `all`, `love`, `win`, and
`mod`; they do not invoke Git Bash. Linux/CI continue to use POSIX shell and
the following `just` commands:

- `just build` — release/debug `.love` plus Windows x64 packages (original behavior; Kristal 0.11.0-dev by default, output in `dist/`)
- `just build-win` — Windows x64 package only
- `just build-love` — release/debug `.love` only, without Windows executables or a LÖVE download
- `just build-mod` — a project ZIP for `mods/` (dev tools stripped; the recipe and filename keep Kristal's compatibility suffix)
- `just build-android` — **compile-build** Android APK (automatically provisions JDK 17, Android SDK API 34, NDK 25.2.9519653, and the Gradle wrapper; package/signing overrides via env vars, see scripts)
- `just build-android-wrap` — **wrap-build** Android APK (official LÖVE shell + game.love; tools auto-downloaded and re-signed; no Android SDK/NDK is needed, **but** the package id/icon/name cannot be customized and it cannot be published on Google Play)

Builds pin Kristal `f62afea63ccab02f468c24ac0d096bd8a2c9aa81` (`0.11.0-dev`), shallow-clone remote sources (`--depth 1`), and use `.build/Kristal` by default. To choose another source interactively, run `just build`, `just build-win`, or `just build-love` with `THRASH_MACHINE_KRISTAL_SOURCE=ask`:

1. Use a local Kristal checkout (auto-detects `.build/Kristal`, `KRISTAL_ROOT`, and common paths)
2. Enter a local path yourself (a Git checkout or a plain directory both work)
3. Pick a tag from the Git remote (the tag list is fetched and shown)
4. Enter a full commit hash from the Git remote (40 hex characters)

CI and non-interactive environments use the same pinned commit. To select another source explicitly, set:

- `THRASH_MACHINE_KRISTAL_SOURCE=local|path|tag|commit`
- `THRASH_MACHINE_KRISTAL_DIR` / `KRISTAL_ROOT` for a local path
- `THRASH_MACHINE_KRISTAL_REF` for a tag or commit hash
- `THRASH_MACHINE_KRISTAL_REPO` to override the remote repository

### Packaging from the GUI

The kristal-debug-tools GUI can package too (run `gui.cmd` on Windows, or `just gui` anywhere):

1. Expand the "RUN LIST (ADVANCED)" panel → **PROJECT BUILDS** group
2. Click `build` / `build-mod` / `build-android` — the task runs in a separate terminal window with live output

The GUI only launches this project's build tasks; packaging rules remain in this
repository. Windows tasks use native PowerShell and do not require Git Bash;
LÖVE and the selected target's other dependencies still apply. The launcher
downloads only the fixed GUI release for the current engine version: it never
requests `latest` or falls back to a different release. Retry later when the
selected release has not uploaded its assets yet.

GitHub's automated builds check that the project packages correctly on every push and merge; when a new version is released, the packaged files (including the Windows x64 package, the .love package, and the **compiled APK**) are uploaded to the GitHub Release page automatically. The **wrap APK is not built automatically by default** — enable it by checking `build_android_wrap` when triggering a build manually on GitHub. Don't want to install JDK or Android SDK on your own machine? Just merge the version-release PR on GitHub — packaging and uploading are fully automatic.

## Android Packaging

### Distribution matrix

|                                      | Windows            | `.love`                | Project                        | Android compile                           | Android wrap                        |
| ------------------------------------ | ------------------ | ---------------------- | ------------------------------ | ----------------------------------------- | ----------------------------------- |
| Recipe                               | `just build-win`   | `just build-love`      | `just build-mod`               | `just build-android`                      | `just build-android-wrap`           |
| Output                               | `dist/*-win64.zip` | `dist/*.love`          | `dist/*-mod.zip`               | `dist/*-android.apk`                      | `dist/*-android-wrap.apk`           |
| Runs on                              | Windows            | Any platform with LÖVE | Kristal `mods/` (any platform) | Android                                   | Android                             |
| Build deps                           | git, LÖVE, curl    | LÖVE                   | git, LÖVE                      | Git, JDK 17 (SDK/NDK auto-provisioned)    | Git, JDK 17 (no SDK/NDK)            |
| Custom package id / icon / name      | —                  | —                      | —                              | ✅ env overrides                          | ❌ official shell                   |
| Modify the LÖVE engine / native code | —                  | —                      | —                              | ✅                                        | ❌                                  |
| Best for                             | Desktop players    | Unix users/developers  | Players installing projects    | Official distribution, deep customization | Casual users, quick personal builds |

### One-click packaging on Windows

Double-click **`tools\build_android.cmd`** in the project root, or run
`powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_android.ps1`, and pick:

1. **Quick wrap build** — a native PowerShell flow with no Android SDK/NDK; it provisions JDK 17, the official LÖVE shell, and build-tools, while a missing local Kristal checkout still requires Git to obtain the pinned engine;
2. **Full compile build** — a native PowerShell flow that provisions JDK 17, the Android SDK, NDK, and Gradle wrapper; Git obtains Kristal and love-android source.

It also accepts arguments: `tools\build_android.cmd wrap` or `tools\build_android.cmd compile`. Neither path invokes Git Bash. When the build finishes it opens the `dist\` folder.

Equivalent commands on any platform:

```sh
just build-android-wrap   # wrap build (no Android SDK/NDK; a missing JDK auto-downloads Temurin 17 into the shared .tools/jdk17)
just build-android        # compile build (JDK and Android SDK/NDK are auto-provisioned)
```

JDK resolution order: `THRASH_MACHINE_ANDROID_JAVA_HOME` / `JAVA_HOME` (explicit; a version mismatch fails fast) → a version-matching `java` on PATH → an auto-downloaded portable Temurin JDK 17 in the shared `.tools/jdk17/` (next to the Kristal engine, shared across projects; the project root `.tools` is the fallback when no engine is found). `THRASH_MACHINE_FETCH_JDK=0` disables the download.

## Custom Icons (Optional)

The build scripts read custom icons from `assets/icon/` by **directory convention** — no configuration needed. Any icon step is skipped (with a warning) when the file or the required tool is missing, so the default build is unchanged.

```
assets/icon/
├── window_icon.png      # Game window icon → copied to the project root + setWindowTitleAndIcon=true
├── win/                 # Windows exe icon
│   ├── icon.ico         #   ready-made .ico (optional shortcut)
│   └── 16x16.png 32x32.png 48x48.png 64x64.png 128x128.png 256x256.png
└── android/             # Android launcher icons (missing densities fall back to the nearest)
    └── ldpi.png mdpi.png hdpi.png xhdpi.png xxhdpi.png xxxhdpi.png
```

| Target      | Tools required                                                                 | Notes                                                                                |
| ----------- | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| Game window | none                                                                           | copied to the project root automatically (the engine only reads `window_icon.png` there) |
| Windows exe | `rcedit` (needs `wine` on Linux) + `icotool`/ImageMagick to combine PNGs | skipped with a warning when missing                                                  |
| Android APK | none                                                                           | per-density icons with automatic nearest-density fallback                            |

- Under `win/` drop a set of size-named PNGs (32 + 256 gives the best result) or a ready-made `icon.ico`; the script prefers an existing `.ico`.
- `THRASH_MACHINE_ICON_FETCH_TOOLS=1` makes the script download rcedit into the shared `.tools/rcedit/` (next to the Kristal engine; the project root is the fallback) automatically.
- The whole `assets/icon/` directory is excluded from `.love` / project packages; `window_icon.png` is copied to the project root during the build and then packaged.
- Paths can be overridden: `THRASH_MACHINE_ICON_DIR`, `THRASH_MACHINE_WINDOW_ICON`, `THRASH_MACHINE_WIN_ICON_DIR`, `THRASH_MACHINE_RCEDit`, `THRASH_MACHINE_ANDROID_ICON_DIR`, `THRASH_MACHINE_ANDROID_ICON`.

## Commit Convention

Use Conventional Commits (feat/fix drive release-please versions and changelogs):

    feat: add a new Lua battle wave
    fix: fix object events after room transitions

## License

Repository-authored Lua source and docs are dual-licensed under MIT (LICENSE-MIT) or Apache-2.0 (LICENSE-APACHE). Kristal and submodule license boundaries: THIRD_PARTY.md.
