local ROOT = "."

local function new_libraries()
    return {
        ["kristalI18n"] = {},
        ["magical-glass"] = {},
        ["undertale_monsters_recreation"] = {
            dependencies = {"magical-glass"},
        },
        ["unrelated-library"] = {
            optionalDependencies = {"magical-glass"},
        },
    }
end

local function run_selection(selection)
    _G.HookSystem = {hook = function() end}
    _G.Map = {}
    _G.NPC = {}
    _G.Mod = {
        info = {
            optionalLibraries = selection,
            libs = new_libraries(),
            lib_order = {
                "kristalI18n",
                "magical-glass",
                "undertale_monsters_recreation",
                "unrelated-library",
            },
        },
    }

    assert(loadfile(ROOT .. "/mod.lua"))()
    return Mod.info
end

local function expect_present(info, id)
    assert(info.libs[id], "expected library to remain: " .. id)
end

local function expect_absent(info, id)
    assert(not info.libs[id], "expected library to be removed: " .. id)
end

local function expect_order(info, expected)
    assert(#info.lib_order == #expected, "unexpected library order length")
    for index, id in ipairs(expected) do
        assert(info.lib_order[index] == id, "unexpected library order at " .. index)
    end
end

local info = run_selection({
    ["magical-glass"] = true,
    ["undertale_monsters_recreation"] = true,
})
expect_present(info, "magical-glass")
expect_present(info, "undertale_monsters_recreation")
expect_present(info, "unrelated-library")

info = run_selection({
    ["magical-glass"] = true,
    ["undertale_monsters_recreation"] = false,
})
expect_present(info, "magical-glass")
expect_absent(info, "undertale_monsters_recreation")
expect_present(info, "unrelated-library")
expect_order(info, {"kristalI18n", "magical-glass", "unrelated-library"})

info = run_selection({
    ["magical-glass"] = false,
    ["undertale_monsters_recreation"] = true,
})
expect_absent(info, "magical-glass")
expect_absent(info, "undertale_monsters_recreation")
expect_present(info, "unrelated-library")
expect_order(info, {"kristalI18n", "unrelated-library"})

info = run_selection({
    ["missing-disabled-library"] = false,
})
expect_present(info, "magical-glass")
expect_present(info, "undertale_monsters_recreation")

local ok, message = pcall(run_selection, {
    ["missing-enabled-library"] = true,
})
assert(not ok and message:find("enabled optional library is missing", 1, true))

print("optional library selection: PASS")
