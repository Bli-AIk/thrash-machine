# Third-party notices

This repository contains a Kristal starter project and ships dependencies through Git submodules.

| Component                                                                               | License                                                      | Distribution boundary                                                              |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| [Kristal](https://github.com/KristalTeam/Kristal) starter content and standalone engine | BSD-3-Clause                                                 | Starter assets/source and staged standalone builds.                                |
| [kristal-i18n](https://github.com/Bli-AIk/kristal-i18n)                                 | MIT or Apache-2.0                                            | Runtime submodule and production packages.                                         |
| [kristal-object-selector-plus](https://github.com/Bli-AIk/kristal-object-selector-plus) | MIT or Apache-2.0                                            | Development-only submodule; excluded from production packages.                     |
| [kristal-terminal-cli](https://github.com/Bli-AIk/kristal-terminal-cli)                 | MIT or Apache-2.0                                            | Development-only submodule; excluded from production packages.                     |
| [kristal-emacs-config](https://github.com/Bli-AIk/kristal-emacs-config)                 | Mixed; see its repository                                    | Development-only submodule; excluded from production packages.                     |
| [kristal-helix-config](https://github.com/Bli-AIk/kristal-helix-config)                 | MIT or Apache-2.0                                            | Development-only submodule; excluded from production packages.                     |
| [MagicalGlassRedux](https://github.com/Bli-AIk/MagicalGlassRedux)                       | Upstream: all rights reserved © original authors; fork additions MIT or Apache-2.0 | Optional UT content library; see `libraries/MagicalGlassRedux/LICENSE-UPSTREAM.md`. |
| [UndertaleMonstersRecreation](https://github.com/Bli-AIk/UndertaleMonstersRecreation)   | Upstream: all rights reserved © original authors; fork additions MIT or Apache-2.0 | Optional UT content library; see `libraries/UndertaleMonstersRecreation/LICENSE-UPSTREAM.md`. |
| `libraries/virtualkeyboard` artwork and original touch-control design                   | Permission to modify and redistribute; attribution requested | Bundled optional Android library; see `libraries/virtualkeyboard/ATTRIBUTION.txt`. |

MagicalGlassRedux and UndertaleMonstersRecreation are selected by the top-level
`optionalLibraries` object in `mod.json`, using the actual library IDs
`magical-glass` and `undertale_monsters_recreation`. The latter requires the
former. Disabled optional libraries are removed from release and project/mod
packages; debug packages retain their files but do not initialize, register, or
expose those libraries through `Mod.libs` at runtime.

The Lua source and documentation authored in this repository are available under either
`LICENSE-MIT` or `LICENSE-APACHE`, at your option. This dual license does not replace the
licenses above.
