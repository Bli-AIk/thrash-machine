# Custom icons (optional)

The build scripts pick up custom icons from this directory by **convention** —
no configuration needed. Every icon step is skipped (with a warning) when the
file or the required tool is missing, so the default build is unchanged.

## Layout

```
assets/icon/
├── window_icon.png      # Game window icon → copied to the mod root + setWindowTitleAndIcon
├── win/                 # Windows .exe icon
│   ├── icon.ico         #   ready-made icon (optional shortcut)
│   ├── 16x16.png        #   ...or a set of sizes (16/32/48/64/128/256 px)
│   ├── 32x32.png
│   ├── 48x48.png
│   ├── 64x64.png
│   ├── 128x128.png
│   └── 256x256.png
└── android/             # Android launcher icon per density
    ├── ldpi.png         #   36×36
    ├── mdpi.png         #   48×48
    ├── hdpi.png         #   72×72
    ├── xhdpi.png        #   96×96
    ├── xxhdpi.png       #   144×144
    └── xxxhdpi.png      #   192×192
```

## Requirements

| Target | Tool | Notes |
|---|---|---|
| Game window | none | copied automatically |
| Windows .exe | `rcedit` (Linux/macOS: via `wine`) + `icotool`/ImageMagick to combine PNGs | skipped if missing |
| Android APK | none | density fallback is automatic |

- Windows: run `rcedit` directly. Linux/macOS: `sudo apt install wine icoutils` (or equivalent).
- `THRASH_MACHINE_ICON_FETCH_TOOLS=1` auto-downloads rcedit into `.tools/rcedit/`.
- Missing Android densities fall back to the nearest available one.
- The whole `assets/icon/` directory is excluded from `.love` / mod packages;
  `window_icon.png` is copied to the mod root during the build so the engine
  can find it.
