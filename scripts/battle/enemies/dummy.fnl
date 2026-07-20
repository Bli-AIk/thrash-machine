(local (Dummy super) (Class EnemyBattler))

(fn Dummy.init [self]
  (super.init self)
  (set self.name "Dummy")
  (: self :setActor "dummy")
  (set self.max_health 450)
  (set self.health 450)
  (set self.attack 4)
  (set self.defense 0)
  (set self.money 100)
  (set self.spare_points 20)
  (set self.waves ["basic" "aiming" "movingarena"])
  (set self.dialogue ["..."])
  (set self.check "AT 4 DF 0\n* Cotton heart and button eye\n* Looks just like a fluffy guy.")
  (set self.text
       ["* The dummy gives you a soft\nsmile."
        "* The power of fluffy boys is\nin the air."
        "* Smells like cardboard."])
  (set self.low_health_text "* The dummy looks like it's\nabout to fall over.")
  (: self :registerAct "Smile")
  (: self :registerAct "Tell Story" "" ["ralsei"]))

(fn Dummy.onAct [self battler name]
  (if (= name "Smile")
      (do
        (: self :addMercy 100)
        (set self.dialogue_override "... ^^")
        ["* You smile.[wait:5]\n* The dummy smiles back."
         "* It seems the dummy just wanted\nto see you happy."])
      (= name "Tell Story")
      (do
        (each [_ enemy (ipairs Game.battle.enemies)]
          (: enemy :setTired true))
        "* You and Ralsei told the dummy\na bedtime story.\n* The enemies became [color:blue]TIRED[color:reset]...")
      (= name "Standard")
      (do
        (: self :addMercy 50)
        (if (= battler.chara.id "ralsei")
            "* Ralsei bowed politely.\n* The dummy spiritually bowed\nin return."
            (= battler.chara.id "susie")
            (do
              (: Game.battle :startActCutscene "dummy" "susie_punch")
              nil)
            (.. "* " (: battler.chara :getName) " straightened the\ndummy's hat.")))
      (super.onAct self battler name)))

Dummy
