function Mod:init()
    Game:registerEvent("squeak", function(data)
        return Squeak(data.x, data.y, {data.width, data.height, data.polygon})
    end)
    print(Game:locText("Loaded [var:name]!", {name = self.info.name}))

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

