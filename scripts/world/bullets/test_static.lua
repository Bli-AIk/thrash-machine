-- Static test bullet (damage 1, no movement), spawned at the battle area
-- centers of room1/room3 via the Map:onEnter hook in mod.lua. For UI testing.
local bullet, super = Class(WorldBullet, "test_static")

function bullet:init(x, y)
    super.init(self, x, y, "effects/yellowsoul/shot_undertale")
    self.damage = 1
    self.inv_frames = 60
    self.destroy_on_hit = false
end

-- Intentionally no movement behavior: the bullet sits at its spawn point.

return bullet
