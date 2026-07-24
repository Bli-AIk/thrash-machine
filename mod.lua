function Mod:init()
    Game:registerEvent("squeak", function(data)
        return Squeak(data.x, data.y, {data.width, data.height, data.polygon})
    end)
    print("Loaded " .. self.info.name .. "!")

    if os.getenv("THRASH_MACHINE_SMOKE") == "1" then
        print("THRASH_MACHINE_SMOKE=PASS")
        love.event.quit()
    end
end
