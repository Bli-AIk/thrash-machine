# Kristal virtualkeyboard

This is an optional Kristal v0.10 library for Android builds. It provides a
touch joystick or button layout that feeds normal Kristal `Input` key events.

The library is enabled by default only when `love.system.getOS()` returns
`Android`. Desktop builds therefore keep their normal keyboard and gamepad
behavior. To test the controls on another platform, set `only_android` to
`false` in the `virtualkeyboard` section of `mod.json`.

Available configuration:

```json
"virtualkeyboard": {
    "enabled": true,
    "only_android": true,
    "show_on_start": true,
    "layout": "buttons",
    "toggle_key": null,
    "opacity": 0.78,
    "button_scale": 3,
    "button_radius": 44,
    "joystick_scale": 2.5,
    "joystick_radius": 90,
    "joystick_deadzone": 0.35
}
```

Set `layout` to `joystick` to use a directional joystick with the `z`, `x`
and `c` buttons. A mod can also call `VirtualKeyboard:setVisible(false)` or
`VirtualKeyboard:toggle()` at runtime. `toggle_key` is disabled by default;
Android Back is intentionally not used as the control toggle.

The adapter draws in Kristal's existing 640x480 game canvas and converts touch
coordinates through Kristal's game scale and side offsets. It is not an API
compatibility layer for Kristal or LÖVE on Android.

## Attribution

The button and joystick artwork and the original touch-keyboard design were
provided by zzy (Bilibili UID `3546380257724712`) in the accompanying
`virtualkeyboardV3.5.7z` archive. The archive permits modification and
redistribution and requests credit. See the repository's `THIRD_PARTY.md`.
