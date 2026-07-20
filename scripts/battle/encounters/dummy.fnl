(local (Dummy super) (Class Encounter))

(fn Dummy.init [self]
  (super.init self)
  (set self.text "* The tutorial begins...?")
  (set self.music "battle")
  (set self.background true)
  (: self :addEnemy "dummy"))

Dummy
