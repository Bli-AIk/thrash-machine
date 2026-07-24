(local (Dummy super) (Class EnemyBattler))

(fn Dummy.init [self]
  (super.init self)
  (: self :applyLocalization)
  (: self :setActor "dummy")
  (set self.max_health 450)
  (set self.health 450)
  (set self.attack 4)
  (set self.defense 0)
  (set self.money 100)
  (set self.spare_points 20)
  (set self.waves ["basic" "aiming" "movingarena"])
  (set self.dialogue ["..."])
  (: self :registerAct self.act_smile)
  (: self :registerAct self.act_tell_story "" ["ralsei"]))

(fn Dummy.applyLocalization [self update-acts]
  (local old-check self.act_check)
  (local old-smile self.act_smile)
  (local old-tell-story self.act_tell_story)
  (set self.name (: Game :loc "Dummy" "enemy_dummy_name"))
  (set self.check (: Game :loc
                         "AT 4 DF 0\n* Cotton heart and button eye\n* Looks just like a fluffy guy."
                         "enemy_dummy_check"))
  (set self.text
       [(: Game :loc "* The dummy gives you a soft\nsmile." "enemy_dummy_turn_1")
        (: Game :loc "* The power of fluffy boys is\nin the air." "enemy_dummy_turn_2")
        (: Game :loc "* Smells like cardboard." "enemy_dummy_turn_3")])
  (set self.low_health_text
       (: Game :loc "* The dummy looks like it's\nabout to fall over." "enemy_dummy_low_health"))
  (set self.act_check (: Game :loc "Check" "act_check"))
  (set self.act_smile (: Game :loc "Smile" "act_dummy_smile"))
  (set self.act_tell_story (: Game :loc "Tell Story" "act_dummy_tell_story"))
  (when (and self.acts (. self.acts 1))
    (tset (. self.acts 1) :name self.act_check))
  (when update-acts
    (each [_ act (ipairs (or self.acts []))]
      (if (= act.name old-check)
          (set act.name self.act_check)
          (= act.name old-smile)
          (set act.name self.act_smile)
          (= act.name old-tell-story)
          (set act.name self.act_tell_story)))))

(fn Dummy.onAct [self battler name]
  (if (= name self.act_check)
      (super.onAct self battler "Check")
      (= name self.act_smile)
      (do
        (: self :addMercy 100)
        (set self.dialogue_override "... ^^")
        [(: Game :loc "* You smile.[wait:5]\n* The dummy smiles back." "act_dummy_smile_1")
         (: Game :loc "* It seems the dummy just wanted\nto see you happy." "act_dummy_smile_2")])
      (= name self.act_tell_story)
      (do
        (each [_ enemy (ipairs Game.battle.enemies)]
          (: enemy :setTired true))
        (: Game :loc
           "* You and Ralsei told the dummy\na bedtime story.\n* The enemies became [color:blue]TIRED[color:reset]..."
           "act_dummy_tell_story_text"))
      (= name "Standard")
      (do
        (: self :addMercy 50)
        (if (= battler.chara.id "ralsei")
            (: Game :loc "* Ralsei bowed politely.\n* The dummy spiritually bowed\nin return."
               "act_dummy_ralsei_standard")
            (= battler.chara.id "susie")
            (do
              (: Game.battle :startActCutscene "dummy" "susie_punch")
              nil)
            (: Game :loc "* [var:name] straightened the\ndummy's hat."
               "act_dummy_other_standard"
               {:name (: battler.chara :getName)})))
      (super.onAct self battler name)))

Dummy
