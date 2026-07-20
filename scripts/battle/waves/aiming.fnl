(local (Aiming super) (Class Wave))

(fn Aiming.onStart [self]
  (: self.timer :every (/ 1 2)
     (fn []
       (let [attackers (: self :getAttackers)]
         (each [_ attacker (ipairs attackers)]
           (let [(x y) (: attacker :getRelativePos (/ attacker.width 2) (/ attacker.height 2))
                 angle (MathUtils.angle x y Game.battle.soul.x Game.battle.soul.y)]
             (: self :spawnBullet "smallbullet" x y angle 8)))))))

(fn Aiming.update [self]
  (super.update self))

Aiming
