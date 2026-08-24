# Thrash Machine

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE) <img src="https://img.shields.io/github/repo-size/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/last-commit/Bli-AIk/thrash-machine.svg"/> <img src="https://img.shields.io/github/v/release/Bli-AIk/thrash-machine.svg"/> <br>
<img src="https://img.shields.io/badge/Deltarune-001225?style=for-the-badge&labelColor=001225&logo=undertale&logoColor=ff0000" /> <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" /> <img src="https://img.shields.io/badge/Kristal-FF6B35?style=for-the-badge&logo=love2d&logoColor=white" />

**Thrash Machine** — a Kristal template for getting work done: the utility packages I maintain (localization, object editor, debug tools...) are all wired up as submodules, so you can start building right away.

| English | 简体中文                |
| ------- | ----------------------- |
| English | [简体中文](./README.md) |

## Kristal Version Support

| `kristal`                                                                                                                     | `thrash-machine` |
| ----------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| [v0.11.0-dev](https://github.com/KristalTeam/Kristal/commit/f62afea63ccab02f468c24ac0d096bd8a2c9aa81) (`f62afea`, 2026-08-16) | v0.2.0 - v0.3.0  |
| [v0.10.0](https://github.com/KristalTeam/Kristal/commit/752bc0688ba97ca8a256ba9125b7e05a1ca6edbd) (`752bc068`, 2026-06-23)    | v0.0.0 – v0.1.0  |

## What's Inside

- **Utility libraries**: localization, object editor, battle debug launcher, terminal console — integrated as submodules, pruned per config (see the list below)
- **Build scripts**: .love for Linux, Windows executable and Android APK packaging, with automatic icon handling
- **GUI launcher**: `gui.cmd` opens a graphical launcher that fetches the release matching your engine version (SHA256-verified) and runs build tasks with one click
- **Automated releases**: via [release-please](https://github.com/googleapis/release-please) — merge the release PR and assets are packaged and uploaded automatically

### Library List

| Library                      | Purpose                                                                            | Note       |
| ---------------------------- | ---------------------------------------------------------------------------------- | ---------- |
| kristal-i18n                 | Localization, en/zh_hans built in, switchable in-game                              |            |
| kristal-object-selector-plus | Scene object editor (Blender-style G/R/S transforms)                               |            |
| terminal-cli                 | Terminal debug console (Linux/POSIX)                                               |            |
| kristal-debug-tools          | Battle debug launcher: jump into an encounter, wave, TP or mercy of your choice    |            |
| MagicalGlassRedux            | UT-style light world battle content pack (fork)                                    | (optional) |
| UndertaleMonstersRecreation  | UT monster content examples: Froggit, Moldsmal, a shop; requires MagicalGlassRedux | (optional) |
| .emacs / .helix              | Project-level editor config (LuaLS, Kristal paths)                                 |            |

## Optional Extensions

Want to build UT-style light world battles and monster content? MagicalGlassRedux (light world battles) and UndertaleMonstersRecreation (monster content examples: Froggit, Moldsmal, a shop; depends on the former) are optional extensions for exactly that — toggle them in the top-level `optionalLibraries` of `mod.json` (IDs come from each `lib.json`):

```jsonc
"optionalLibraries": {
    "magical-glass": true,
    "undertale_monsters_recreation": true
}
```

`undertale_monsters_recreation` depends on `magical-glass`: disabling MGR also disables UMR (even if UMR is still `true`); disabling UMR alone does not affect MGR. Initialize the submodules before use:

```sh
git submodule update --init libraries/MagicalGlassRedux libraries/UndertaleMonstersRecreation
```

## Quick Start

**1. Get the template**

**Option 1: Direct download (quick)**

Download `thrash-machine-<version>-full-source.zip` (or `.tar.gz`) from the [Releases](https://github.com/Bli-AIk/thrash-machine/releases) page — the complete source with all submodules already checked out, ready to unpack.

**Option 2: Version control**

This is a **template repository**: click **Use this template** on the repo page to create your own copy (submodule references come along), then clone your own repo — your version history and releases stay yours. Cloning directly works too:

```sh
git clone --recurse-submodules https://github.com/Bli-AIk/thrash-machine.git
cd thrash-machine
```

**2. Make it yours**

Rename the cloned folder to your project name and run it directly — without `--name` the folder name is used automatically:

```sh
# Linux / Git Bash
./tools/start.sh --yes
./tools/start.sh --name "My Project" --yes
```

```powershell
# Windows (PowerShell; no Git Bash needed)
.\tools\start.ps1 --yes
.\tools\start.ps1 --name "My Project" --yes
```

The script renames the project ID and name and pulls all submodules (`--yes` skips prompts; see `./tools/start.sh --help` for details).

**3. Run it**

```sh
make test                                  # static assertions + syntax check
just run                                   # launch — Kristal engine found automatically
```

The launcher walks up from the project directory looking for the engine (a folder containing `main.lua` and `src/kristal.lua`) — putting the project under the engine's `mods/` (`<Kristal>/mods/<your-project>`) needs no setup at all. If the project is not inside an engine tree, the error tells you exactly what to do: `Kristal engine not found. Set KRISTAL_ROOT=/path/to/Kristal.`

```sh
# Linux: this command only
KRISTAL_ROOT=/path/to/Kristal just run
```

```powershell
# Windows: this session
$env:KRISTAL_ROOT = "C:\path\to\Kristal"; just run
```

For a permanent setup, add `KRISTAL_ROOT` to your environment (Windows system settings, Linux shell config).

Debug arguments pass straight to kristal-debug-tools: `just run --encounter` (jump straight into an encounter), `just run --wave 2 --tp 50` (pick the wave and starting TP), `just run --lang zh-hans` (startup language for this run).

Prefer a GUI? Windows users can double-click `gui.cmd` (or `just gui` elsewhere) to open the graphical launcher — run items, debug arguments and chapter config are all visual, and build tasks work there too (see "Packaging → GUI packaging" below).

## Packaging

### Command line

Windows and Linux/CI use separate entry points, same output:

```powershell
# Windows: native PowerShell entry, no Git Bash needed
tools\build.cmd all      # everything (love + win + mod)
tools\build.cmd love     # .love package
tools\build.cmd win      # Windows x64 package
tools\build.cmd mod      # project ZIP ready for mods/
```

```sh
# Linux / CI
just build                # release/debug .love + Windows x64 (output in dist/)
just build-win            # Windows x64 only
just build-love           # .love only
just build-mod            # project ZIP (dev tools stripped)
```

Linux needs git, tar, unzip, curl, love (Arch: `sudo pacman -S love`); Windows needs Git, PowerShell, LÖVE 11.5.

### Android: two modes

- **Wrap build**: `just build-android-wrap`, no Android SDK/NDK needed — JDK 17, the official LÖVE shell APK and build-tools are fetched automatically; good for quick personal usage; the trade-off is a fixed package name/icon/app name, and no Google Play publishing.
- **Compile build**: `just build-android`, builds the APK from source with custom package name/icon; use this for real distribution.

On Windows, double-click `tools\build_android.cmd` and follow the prompts (arguments also work: `build_android.cmd wrap` / `build_android.cmd compile`); neither path needs Git Bash. JDK resolution order: `THRASH_MACHINE_ANDROID_JAVA_HOME` / `JAVA_HOME` (explicit) → a version-matching `java` on PATH → auto-downloaded portable Temurin 17 (`THRASH_MACHINE_FETCH_JDK=0` disables the download).

### GUI packaging

Double-click `gui.cmd` in the repo root on Windows (`just gui` elsewhere) to open the kristal-debug-tools graphical launcher:

1. Expand "Run item list (advanced)" → **Project Build** group
2. Click `build` / `build-mod` / `build-android` — each task runs in a separate terminal window with live output

The launcher only downloads the fixed release matching the current engine version (SHA256-verified), never `latest`; retry later if the target release is not uploaded yet. The launcher itself needs no just / Rust / Node.

### Engine source

Builds pin Kristal `f62afea63ccab02f468c24ac0d096bd8a2c9aa81` (`0.11.0-dev`, shallow-cloned to `.build/Kristal`). To change the source: run `THRASH_MACHINE_KRISTAL_SOURCE=ask just build` in an interactive terminal and pick (local path / remote tag / full commit), or set environment variables:

- `THRASH_MACHINE_KRISTAL_SOURCE=local|path|tag|commit` — source type
- `THRASH_MACHINE_KRISTAL_DIR` / `KRISTAL_ROOT` — local path
- `THRASH_MACHINE_KRISTAL_REF` — tag or commit hash
- `THRASH_MACHINE_KRISTAL_REPO` — override the remote repository

### Automatic releases

GitHub checks that the project packages correctly on every push and merge; after merging a release PR, the Windows x64 package, the .love package and the compiled APK are uploaded to the GitHub Release page automatically. **The wrap APK is not built by default** — when triggering a build manually on GitHub, tick `build_android_wrap` to include it.

## Custom Icons (optional)

The build scripts read `assets/icon/` by directory convention, no configuration needed:

- `window_icon.png` — game window icon
- `win/` — Windows exe icon (a set of PNG sizes, or a ready-made `icon.ico`)
- `android/` — launcher icons per density; missing sizes fall back to the nearest

Missing tools (such as `rcedit`) are skipped with a warning and never break the default build.

## Commit Conventions

Write conventional commits (feat/fix drive release-please versions and changelogs):

    feat: add a new Lua battle wave
    fix: fix object events after map transition

## License

Repository-authored Lua source and docs are dual-licensed under MIT ([LICENSE-MIT](LICENSE-MIT)) or Apache-2.0 ([LICENSE-APACHE](LICENSE-APACHE)). Kristal and submodule license boundaries: [THIRD_PARTY.md](THIRD_PARTY.md).
