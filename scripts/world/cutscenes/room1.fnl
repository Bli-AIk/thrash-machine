{:wall
 (fn [cutscene event]
   (: cutscene :text "* The wall seems cracked." nil nil
      {:id "world_room1_wall_cracked"})
   (let [susie (: cutscene :getCharacter "susie")]
     (when susie
       (: cutscene :detachCamera)
       (: cutscene :detachFollowers)
       (: cutscene :setSpeaker susie)
       (: cutscene :text "* Hey,[wait:5] think I can break\nthis wall?" "smile" nil
          {:id "world_room1_wall_susie_break"})
       (let [x (+ event.x (/ event.width 2))
             y (+ event.y (/ event.height 2))]
         (: cutscene :walkTo susie x (+ y 40) 0.75 "up")
         (: cutscene :walkTo Game.world.player x (+ y 100) 0.75 "up")
         (when (: cutscene :getCharacter "ralsei")
           (: cutscene :walkTo "ralsei" (+ x 60) (+ y 100) 0.75 "up"))
         (when (: cutscene :getCharacter "noelle")
           (: cutscene :walkTo "noelle" (- x 60) (+ y 100) 0.75 "up"))
         (: cutscene :wait 1.5)
         (: cutscene :wait (: cutscene :walkTo susie x (+ y 60) 0.5 "up" true))
         (: cutscene :wait (: cutscene :walkTo susie x (+ y 20) 0.2))
         (Assets.playSound "impact")
         (: susie :shake 4)
         (: susie :setSprite "shock_up")
         (: cutscene :slideTo susie x (+ y 40) 0.1)
         (: cutscene :wait 1.5)
         (: susie :setAnimation ["away_scratch" 0.25 true])
         (: susie :shake 4)
         (Assets.playSound "wing")
         (: cutscene :wait 1)
         (: cutscene :text "* Guess not." "nervous" nil
            {:id "world_room1_wall_guess_not"})
         (: susie :resetSprite)
         (: cutscene :attachCamera)
         (: cutscene :alignFollowers)
         (: cutscene :attachFollowers)
         (: Game :setFlag "wall_hit" true)))))}
