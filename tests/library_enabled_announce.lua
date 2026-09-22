-- Every library announces itself with the same English line, and kristal-i18n
-- recognizes exactly that line to translate it.
--
-- The wording is a cross-repository contract: each library emits its own copy
-- (they are separate repositories and must keep working without kristal-i18n),
-- while the translation lives in kristal-i18n's localizeConsoleSegments. A
-- drifted literal in one library would silently stay untranslated, so this
-- test pins the wording, the matching pattern and both lang files together.
--
-- Run from the project root:
--   luajit tests/library_enabled_announce.lua

local ANNOUNCE = 'Logging.info("Enabled library "'

local ANNOUNCERS = {
    "libraries/kristal-i18n/modules/lifecycle.lua",
    "libraries/kristal-object-selector-plus/lib.lua",
    "libraries/kristal-debug-tools/lib.lua",
    "libraries/virtualkeyboard/lib.lua",
    "libraries/MagicalGlassRedux/lib.lua",
    "libraries/terminal-cli/lib.lua",
    "libraries/UndertaleMonstersRecreation/lib.lua",
}

-- Written out rather than assembled from ANNOUNCE: this is the shape the
-- pattern below is expected to match, not the shape the sources are read with.
local ENGLISH = "[System] [INFO] Enabled library magical-glass."

local failures = 0
local function check(name, cond, detail)
    if cond then
        print("ok   " .. name)
    else
        failures = failures + 1
        print("FAIL " .. name .. (detail and (": " .. detail) or ""))
    end
end

local function read_file(path)
    local file = assert(io.open(path, "rb"), "cannot read " .. path)
    local content = file:read("*a")
    file:close()
    return content
end

-- Flat key -> string reader: the lang files are flat maps.
local function read_lang(path)
    local out = {}
    for key, value in read_file(path):gmatch('"([%w_]+)"%s*:%s*"([^"]*)"') do
        out[key] = value
    end
    return out
end

for _, path in ipairs(ANNOUNCERS) do
    local source = read_file(path)
    check(path .. " announces itself", source:find(ANNOUNCE, 1, true) ~= nil)
end

-- The pattern is pulled out of the library rather than restated here, so this
-- test fails when the matcher is edited and the wording is not (or vice versa).
local text_source = read_file("libraries/kristal-i18n/modules/text.lua")
local pattern_literal = text_source:match('plain:match%("([^"]*Enabled library[^"]*)"%)')
check("kristal-i18n matches the announce line", pattern_literal ~= nil)

if not pattern_literal then
    print("\n1 check(s) failed")
    os.exit(1)
end

local pattern = assert(loadstring('return "' .. pattern_literal .. '"'))()
local captured = ENGLISH:match(pattern)
check("captured name is the library id", captured == "magical-glass", tostring(captured))

local en = read_lang("libraries/kristal-i18n/lang/en.json")
local zh = read_lang("libraries/kristal-i18n/lang/zh_hans.json")
local key = "console_logger_library_enabled"

check("en.json defines " .. key, en[key] ~= nil)
check("zh_hans.json defines " .. key, zh[key] ~= nil)

if en[key] then
    local rendered = en[key]:gsub("%[var:name%]", "magical-glass")
    check("english template round-trips to the emitted line", rendered == ENGLISH, rendered)
    check("english template still matches the pattern", rendered:match(pattern) == "magical-glass")
end

if zh[key] then
    -- The other System lines keep the prefix inside the translation, which is
    -- what makes the whole line render in the System logger's color.
    check("zh_hans keeps the [System] [INFO] prefix", zh[key]:find("[System] [INFO] ", 1, true) == 1, zh[key])
    check(
        "zh_hans substitutes the library name",
        zh[key]:gsub("%[var:name%]", "magical-glass"):find("magical-glass", 1, true) ~= nil,
        zh[key]
    )
end

if failures > 0 then
    print(("\n%d check(s) failed"):format(failures))
    os.exit(1)
end

print("\nall checks passed")
