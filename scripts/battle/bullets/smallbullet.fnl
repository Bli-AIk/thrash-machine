(local (SmallBullet super) (Class Bullet))

(fn SmallBullet.init [self x y dir speed]
  (super.init self x y "bullets/smallbullet")
  (set self.physics.direction dir)
  (set self.physics.speed speed))

(fn SmallBullet.update [self]
  (super.update self))

SmallBullet
