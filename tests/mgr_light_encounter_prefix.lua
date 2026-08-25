local GAME_HOOK = "libraries/MagicalGlassRedux/scripts/hooks/Game/Game.lua"

local old = {
    Game = _G.Game,
    HookSystem = _G.HookSystem,
    Kristal = _G.Kristal,
    LightBattle = _G.LightBattle,
    Mod = _G.Mod,
    StringUtils = _G.StringUtils,
    isClass = _G.isClass,
}

local function load_game_hook()
    local calls = { light_values = {} }
    local game = {
        stage = {
            addChild = function(_, battle)
                calls.added_battle = battle
            end,
        },
    }

    function game:encounter(encounter, transition, enemy, context)
        calls.dark = {
            encounter = encounter,
            transition = transition,
            enemy = enemy,
            context = context,
        }
    end

    function game:setLight(value)
        self.light = value
        table.insert(calls.light_values, value)
    end

    _G.Game = game
    _G.HookSystem = {
        hookScript = function(class)
            local super = {}
            for key, value in pairs(class) do
                super[key] = value
            end
            return class, super
        end,
    }
    _G.Kristal = {
        getLibConfig = function(_, key)
            assert(key == "default_battle_system")
            return { "deltarune", false }
        end,
    }
    _G.LightBattle = function()
        local battle = {
            postInit = function(_, state, encounter)
                calls.light = { state = state, encounter = encounter }
            end,
        }
        calls.created_battle = battle
        return battle
    end
    _G.Mod = {
        libs = {
            ["magical-glass"] = {
                getLightEncounter = function(_, id)
                    return id == "froggit"
                end,
            },
        },
    }
    _G.StringUtils = {
        startsWith = function(value, prefix)
            return value:sub(1, #prefix) == prefix
        end,
        sub = function(value, from, to)
            return value:sub(from, to)
        end,
    }
    _G.isClass = function()
        return false
    end

    local chunk, err = loadfile(GAME_HOOK)
    assert(chunk, err)
    assert(chunk() == game)
    return game, calls
end

local game, calls = load_game_hook()
Mod.libs["magical-glass"].current_battle_system = "deltarune"
game:encounter("light/froggit", false)
assert(game.light == nil, "light/ prefix must not change the current world")
assert(#calls.light_values == 0, "light/ prefix must not call setLight")
assert(calls.light and calls.light.state == "INTRO", "light encounter must use the requested transition")
assert(calls.light.encounter == "froggit", "light/ prefix must be removed before MGR lookup")
assert(calls.created_battle == calls.added_battle, "light battle must be added to the stage")
assert(not calls.dark, "light/ prefix must not enter a dark battle")
assert(Mod.libs["magical-glass"].current_battle_system == "undertale", "light/ prefix must override a cached dark battle system")

game, calls = load_game_hook()
game:encounter("dummy", false)
assert(calls.dark and calls.dark.encounter == "dummy", "dark encounter must still use the base battle path")
assert(calls.dark.transition == false)
assert(calls.light_values[1] == false, "default dark-world launch behavior changed")

game, calls = load_game_hook()
game:encounter("light/froggit", false, nil, nil, false)
assert(calls.dark and calls.dark.encounter == "light/froggit", "explicit light=false must take precedence over the prefix")
assert(not calls.light, "explicit light=false must not start a light battle")

game, calls = load_game_hook()
local ok, message = pcall(game.encounter, game, "light/", false)
assert(not ok and tostring(message):find("without an ID", 1, true), "empty light encounter IDs need a clear error")

game, calls = load_game_hook()
ok, message = pcall(game.encounter, game, "light/missing", false)
assert(not ok and tostring(message):find("non-existent light encounter \"missing\"", 1, true), "missing light encounters need a clear error")

_G.Game = old.Game
_G.HookSystem = old.HookSystem
_G.Kristal = old.Kristal
_G.LightBattle = old.LightBattle
_G.Mod = old.Mod
_G.StringUtils = old.StringUtils
_G.isClass = old.isClass

print("MGR light encounter prefix: PASS")
