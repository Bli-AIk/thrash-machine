local OPTIONAL_LIBRARY_ENV = "THRASH_MACHINE_OPTIONAL_LIBS"

-- Every name the override accepts, for the error message when one is unknown.
local function library_names(info)
    local names = {}
    for id in pairs(info.libs) do
        names[#names + 1] = id
    end
    table.sort(names)
    for index, id in ipairs(names) do
        local alias = info.libs[id].alias
        if alias then
            names[index] = id .. " (" .. alias .. ")"
        end
    end
    return table.concat(names, ", ")
end

-- Names resolve against every library the engine scanned, not just the ones
-- optionalLibraries lists, so any library can be toggled for a launch.
local function resolve_library(info, name)
    if info.libs[name] then
        return name
    end
    for id, lib in pairs(info.libs) do
        if lib.alias == name then
            return id
        end
    end
    return nil
end

-- Launch-time override, e.g. THRASH_MACHINE_OPTIONAL_LIBS="mgr,umr" or "mgr,-umr".
-- Bare names and "+name" force a library on, "-name" forces it off. Nothing is
-- persisted: optionalLibraries in mod.json stays the source of truth.
local function applyOptionalLibraryOverride(info, selection)
    local spec = os.getenv(OPTIONAL_LIBRARY_ENV)
    if spec == nil or spec:match("^%s*$") then
        return
    end

    -- Dependencies are pulled in only for libraries this override turned on, so
    -- a library that mod.json leaves off for its own reasons still stays off.
    local queue = {}
    local queued = {}
    local function force_on(id)
        selection[id] = true
        if not queued[id] then
            queued[id] = true
            queue[#queue + 1] = id
        end
    end

    -- Conflicts only consider libraries this override turned off, so a "false"
    -- inherited from mod.json never blocks enabling something that needs it.
    local forced_off = {}

    for entry in spec:gmatch("[^,]+") do
        entry = entry:match("^%s*(.-)%s*$")
        if entry ~= "" then
            local on = entry:sub(1, 1) ~= "-"
            local id = resolve_library(info, on and entry:gsub("^%+", "") or entry:sub(2))
            if not id then
                error(OPTIONAL_LIBRARY_ENV .. " names an unknown library: " .. entry ..
                    "\nvalid names: " .. library_names(info))
            end
            if on then
                force_on(id)
            else
                selection[id] = false
                forced_off[id] = true
            end
        end
    end

    local index = 1
    while index <= #queue do
        local id = queue[index]
        index = index + 1
        for _, dependency in ipairs((info.libs[id] or {}).dependencies or {}) do
            if forced_off[dependency] then
                error(id .. " requires disabled library: " .. dependency)
            end
            force_on(dependency)
        end
    end

    if #queue == 0 and not next(forced_off) then
        return
    end
    local applied = {}
    for _, id in ipairs(queue) do
        applied[#applied + 1] = id .. "=on"
    end
    for id in pairs(forced_off) do
        applied[#applied + 1] = id .. "=off"
    end
    table.sort(applied)
    print("[thrash-machine] " .. OPTIONAL_LIBRARY_ENV .. '="' .. spec .. '" -> ' ..
        table.concat(applied, ", "))
end

local function applyOptionalLibrarySelection(info)
    local selection = info.optionalLibraries
    if selection == nil then
        return
    end
    if type(selection) ~= "table" then
        error("mod.json optionalLibraries must be an object")
    end

    -- Runs before the disabled set is built, so libraries this override turns
    -- on are not left behind as disabled. The loop below then validates the
    -- merged selection exactly as it validates a hand-written optionalLibraries.
    applyOptionalLibraryOverride(info, selection)

    local disabled = {}
    for id, enabled in pairs(selection) do
        if type(id) ~= "string" or id == "" or type(enabled) ~= "boolean" then
            error("mod.json optionalLibraries must map library IDs to booleans")
        end
        if enabled then
            if not info.libs[id] then
                error("enabled optional library is missing: " .. id)
            end
        else
            disabled[id] = true
        end
    end

    -- A retained library cannot run without one of its required dependencies.
    -- optionalDependencies only affect ordering and do not participate here.
    local changed = true
    while changed do
        changed = false
        for id, lib in pairs(info.libs) do
            if not disabled[id] then
                for _, dependency in ipairs(lib.dependencies or {}) do
                    if disabled[dependency] then
                        disabled[id] = true
                        changed = true
                        break
                    end
                end
            end
        end
    end

    for id in pairs(disabled) do
        info.libs[id] = nil
    end

    local lib_order = {}
    for _, id in ipairs(info.lib_order or {}) do
        if info.libs[id] then
            lib_order[#lib_order + 1] = id
        end
    end
    info.lib_order = lib_order
end

applyOptionalLibrarySelection(Mod.info)

function Mod:init()
    Mod.logger = Logger("Thrash Machine", ConsoleFormats.GREEN)
    Game:registerEvent("squeak", function(data)
        return Squeak(data.x, data.y, {data.width, data.height, data.polygon})
    end)
    Mod.logger:info("Loaded " .. self.info.name .. "!")

    -- Test static bullet at each battle area's center (UI testing).
    local TEST_BULLET_SPOTS = {
        room1 = { 140, 820 }, -- battle area rect (40,720,200,200) center
        room3 = { 100, 260 }, -- battle area rect (40,120,120,280) center
    }
    HookSystem.hook(Map, "onEnter", function(orig, self, ...)
        local r = orig(self, ...)
        local spot = TEST_BULLET_SPOTS[self.id]
        if spot and not self.test_bullet_spawned then
            self.test_bullet_spawned = true
            Game.world:spawnBullet("test_static", spot[1], spot[2])
        end
        return r
    end)

    if os.getenv("KRISTAL_MOD_SMOKE") == "1" then
        print("KRISTAL_MOD_SMOKE=PASS")
        love.event.quit()
    end
end

    -- Starwalker (light world): each interaction shuffles the light inventory,
    -- force-replacing 6 slots, cycling through 3 rounds of light items.
    local LIGHT_ITEM_ROUNDS = {
        { "light/cards", "light/ball_of_junk", "light/pencil", "light/eraser", "light/hot_chocolate", "light/bandage" },
        { "light/halloween_pencil", "light/holiday_pencil", "light/mech_pencil", "light/lucky_pencil", "light/cactusneedle", "light/quillpen" },
        { "light/blackshard", "light/glass", "light/box_of_heart_candy", "light/egg", "light/bouquet", "light/wristwatch" },
    }

    -- Shuffles the current (light) inventory and returns the dialogue line.
    local function shuffleLightInventory()
        local inv = Game.inventory
        if not inv or not Game:isLight() then
            return nil
        end
        local round = ((Game:getFlag("starwalker_round", 0) or 0) % #LIGHT_ITEM_ROUNDS) + 1
        Game:setFlag("starwalker_round", round)
        for i = 1, 6 do
            inv:setItem("items", i, LIGHT_ITEM_ROUNDS[round][i])
        end
        return Game:loc("starwalker_shuffle_header", { round = round })
    end

    HookSystem.hook(NPC, "onInteract", function(orig, self, player, dir)
        local actor_id = self.actor and (self.actor.id or self.actor.name)
        if actor_id ~= "starwalker" or not Game:isLight() then
            return orig(self, player, dir)
        end
        local line = shuffleLightInventory()
        if not line then
            return orig(self, player, dir)
        end
        -- No original starwalker text: show only the shuffle line.
        self.world:showText(line)
        return true
    end)
