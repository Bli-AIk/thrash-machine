(local (actor super) (Class Actor "starwalker"))

(fn actor.init [self]
  (super.init self)
  (set self.name "Starwalker")
  (set self.width 37)
  (set self.height 36)
  (set self.hitbox [2 26 27 10])
  (set self.color [1 1 0])
  (set self.flip nil)
  (set self.path "npcs/starwalker")
  (set self.default "")
  (set self.voice nil)
  (set self.portrait_path nil)
  (set self.portrait_offset nil)
  (set self.can_blush false)
  (set self.talk_sprites {})
  (set self.animations {})
  (set self.offsets {}))

actor
