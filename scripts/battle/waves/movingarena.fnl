(local (MovingArena super) (Class Wave))

(fn MovingArena.init [self]
  (super.init self)
  (set self.siner 0))

(fn MovingArena.onStart [self]
  (let [arena Game.battle.arena]
    (: self :spawnBulletTo Game.battle.arena "arenahazard" (/ arena.width 2) 0 (math.rad 0))
    (: self :spawnBulletTo Game.battle.arena "arenahazard" (/ arena.width 2) arena.height (math.rad 180))
    (set self.arena_start_x arena.x)
    (set self.arena_start_y arena.y)))

(fn MovingArena.update [self]
  (set self.siner (+ self.siner DT))
  (let [offset (* (math.sin (* self.siner 1.5)) 60)]
    (: Game.battle.arena :setPosition self.arena_start_x (+ self.arena_start_y offset)))
  (super.update self))

MovingArena
