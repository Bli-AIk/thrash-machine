(local (actor super) (Class Actor "wall"))

(fn actor.init [self]
  (super.init self)
  (set self.name "Wall")
  (set self.width 60)
  (set self.height 70)
  (set self.hitbox [0 50 60 20])
  (set self.color [1 0 0])
  (set self.flip nil)
  (set self.path "npcs/wall")
  (set self.default "")
  (set self.voice nil)
  (set self.portrait_path nil)
  (set self.portrait_offset nil)
  (set self.can_blush false)
  (set self.talk_sprites {"" 0.2})
  (set self.animations {})
  (set self.offsets {}))

actor
