(local (Dummy super) (Class Encounter))

(fn Dummy.init [self]
  (super.init self)
  (set self.text (: Game :loc "* The tutorial begins...?" "encounter_dummy_start"))
  (set self.music "battle")
  (set self.background true)
  (: self :addEnemy "dummy"))

Dummy
