(local (actor super) (Class Actor "dummy"))

(fn actor.init [self]
  (super.init self)
  (set self.name "Dummy")
  (set self.width 27)
  (set self.height 45)
  (set self.hitbox [0 25 19 14])
  (set self.color [1 0 0])
  (set self.flip nil)
  (set self.path "enemies/dummy")
  (set self.default "idle")
  (set self.voice nil)
  (set self.portrait_path nil)
  (set self.portrait_offset nil)
  (set self.can_blush false)
  (set self.talk_sprites {})
  (set self.animations {:idle ["idle" 0.25 true]})
  (set self.offsets {:idle [0 0]}))

actor
