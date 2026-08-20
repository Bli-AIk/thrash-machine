-- Library globals.
--
-- These names are not defined by this mod: each library registers them as
-- real Lua globals at runtime (Registry.registerGlobal, or a direct _G
-- assignment), so mod code can use them bare, matching the Kristal library
-- semantics described in the official docs. This file only teaches LuaLS
-- about those globals; the types come from the libraries' own lib.lua files
-- via the path-style requires below.
--
-- Keep the module names path-style ("libraries/<id>/lib"): a bare module id
-- like "kristal-object-selector-plus" is not resolvable by LuaLS from this
-- layout, while the explicit path resolves straight to the library source.

---@diagnostic disable-next-line: undefined-global
ObjectEditor = require("libraries/kristal-object-selector-plus/lib")

---@diagnostic disable-next-line: undefined-global
KristalDebugTools = require("libraries/kristal-debug-tools/lib")

---@diagnostic disable-next-line: undefined-global
VirtualKeyboard = require("libraries/virtualkeyboard/lib")
