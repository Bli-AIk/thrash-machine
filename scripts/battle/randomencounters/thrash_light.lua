local EncGroup, super = Class(RandomEncounter, "thrash_light")

-- Optional light battle demo: uses the Froggit encounters provided by the
-- UndertaleMonstersRecreation library (hard requirement: MagicalGlassRedux).
function EncGroup:init()
    super.init(self)

    self.population = 5
    self.use_population_factor = true

    self.encounters = { "froggit", "froggit2" }
    self.light = true
end

return EncGroup
