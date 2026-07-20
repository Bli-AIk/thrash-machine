(local (Basic super) (Class Wave))

(fn Basic.onStart [self]
  (: self.timer :every (/ 1 3)
     (fn []
       (let [x (+ SCREEN_WIDTH 20)
             y (MathUtils.random Game.battle.arena.top Game.battle.arena.bottom)
             bullet (: self :spawnBullet "smallbullet" x y (math.rad 180) 8)]
         (set bullet.remove_offscreen false)))))

(fn Basic.update [self]
  (super.update self))

Basic
