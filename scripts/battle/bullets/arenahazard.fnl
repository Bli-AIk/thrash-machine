(local (ArenaHazard super) (Class Bullet))

(fn ArenaHazard.init [self x y rot]
  (super.init self x y "bullets/arenahazard")
  (: self :setOrigin 0.5 0)
  (: self :setHitbox 0 0 self.width 8)
  (set self.rotation rot)
  (set self.destroy_on_hit false))

(fn ArenaHazard.update [self]
  (super.update self))

ArenaHazard
