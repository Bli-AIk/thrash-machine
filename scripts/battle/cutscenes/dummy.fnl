{:susie_punch
 (fn [cutscene battler enemy]
   (: cutscene :text "* Susie threw a punch at\nthe dummy.")
   (Assets.playSound "damage")
   (: enemy :hurt 1 battler)
   (: cutscene :wait 1)
   (: cutscene :text "* You,[wait:5] uh,[wait:5] look like a weenie.[wait:5]\n* I don't like beating up\npeople like that." "nervous_side" "susie")
   (when (: cutscene :getCharacter "ralsei")
     (: cutscene :text "* Aww,[wait:5] Susie!" "blush_pleased" "ralsei")))}
