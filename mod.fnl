(local map-name-key
  (fn [id]
    (.. "map_" (string.gsub (tostring id) "[^%w_]" "_") "_name")))

(local power-stat-labels {})
(tset power-stat-labels "Guts:" "guts_stat")
(tset power-stat-labels "Rudeness" "rudeness_stat")
(tset power-stat-labels "Fluffiness" "fluffiness_stat")
(tset power-stat-labels "Coldness" "coldness_stat")
(tset power-stat-labels "Boldness" "boldness_stat")

(local item-bonus-names {})
(tset item-bonus-names "GrazeTime" "graze_time_bonus")

(local noelle-special-title-keys {})
(tset noelle-special-title-keys "Ice Trancer" "chara_noelle_title_ice_trancer")
(tset noelle-special-title-keys "Frostmancer" "chara_noelle_title_frostmancer")

(local hook-power-stat-labels
  (fn [party-member]
    (when party-member
      (HookSystem.hook party-member "drawPowerStat"
        (fn [orig self index x y menu]
          (if (not= (: Game :getLanguage) "zh_hans")
              (orig self index x y menu)
              (let [original-print love.graphics.print]
                (set love.graphics.print
                  (fn [text ...]
                    (let [key (. power-stat-labels text)
                          translated-text (if key (: Game :loc text key) text)]
                      (original-print translated-text ...))))
                (let [(ok result) (xpcall
                                    (fn [] (orig self index x y menu))
                                    debug.traceback)]
                  (set love.graphics.print original-print)
                  (if (not ok)
                      (error result)
                      result)))))))))

(local hook-item-bonus-names
  (fn []
    (HookSystem.hook Item "getBonusName"
      (fn [orig item ...]
        (let [bonus-name (orig item ...)]
          (if (not= (: Game :getLanguage) "zh_hans")
              bonus-name
              (let [key (. item-bonus-names bonus-name)]
                (if key
                    (: Game :loc bonus-name key)
                    bonus-name))))))))

(local localize-victory-text
  (fn [text]
    (if (or (not= (: Game :getLanguage) "zh_hans")
            (not= (type text) "string"))
        text
        (let [(xp money currency)
              (string.match text "^%* You won!\n%* Got (.-) EXP and (.-) (.-)%.$")]
          (if xp
              (: Game :loc "* You won!\n* Got [var:xp] EXP and [var:money] [var:currency]."
                 "battle_victory_with_exp"
                 {:xp xp :money money :currency currency})
              (let [(stronger-money stronger-currency stronger)
                    (string.match text "^%* You won!\n%* Got (.-) (.-)%.\n%* (.-) became stronger%.$")]
                (if stronger-money
                    (let [translated-stronger (if (= stronger "You") "你" stronger)]
                      (: Game :loc "* You won!\n* Got [var:money] [var:currency].\n* [var:stronger] became stronger."
                         "battle_victory_stronger"
                         {:money stronger-money :currency stronger-currency :stronger translated-stronger}))
                    text)))))))

(local hook-victory-text
  (fn []
    (HookSystem.hook Battle "battleText"
      (fn [orig battle text ...]
        (orig battle (localize-victory-text text) ...)))))

(local hook-noelle-title
  (fn []
    (let [noelle (Registry.getPartyMember "noelle")]
      (when noelle
        (HookSystem.hook noelle "getTitle"
          (fn [orig self ...]
            (let [title (orig self ...)]
              (if (or (not= (: Game :getLanguage) "zh_hans")
                      (not= (type title) "string"))
                  title
                  (do
                    (var translated nil)
                    (each [english-title key (pairs noelle-special-title-keys)]
                      (when (and (not translated)
                                 (title:find english-title 1 true))
                        (set translated
                          (: Game :loc "LV[var:lv] [var:title]" "chara_getTitle"
                             {:lv (: self :getLevel)
                              :title (: Game :loc
                                       (title:gsub "^LV%d+ " "") key)}))))
                    (or translated title))))))))))

(local hook-frozen-enemy-text
  (fn []
    (HookSystem.hook Interactable "onInteract"
      (fn [orig self ...]
        (when (and self.text (= (. self.text 1) "* (It's frozen solid...)"))
          (set self.text_id (or self.text_id {}))
          (tset self.text_id 1 "frozen_enemy_text"))
        (orig self ...)))))

(local update-map-name
  (fn [_self]
    (when (and Game.world Game.world.map Game.world.map.id Game.loc)
      (let [map Game.world.map
            properties (or (and map.data map.data.properties) {})
            name-key (or properties.name_id (map-name-key map.id))
            default-name (or properties.name map.name map.id)]
        (set map.name (: Game :loc default-name name-key))))))

(local update-battle-localization
  (fn [_self]
    (when Game.battle
      (each [_ enemy (ipairs (or Game.battle.enemies []))]
        (when enemy.applyLocalization
          (: enemy :applyLocalization true))))))

{:init
 (fn [self]
   (hook-item-bonus-names)
   (hook-victory-text)
   (hook-noelle-title)
   (hook-frozen-enemy-text)
   (each [_ id (ipairs ["kris" "susie" "ralsei" "noelle"])]
     (hook-power-stat-labels (Registry.getPartyMember id)))

   (let [bridge (assert (self.libs.fumos.require "thrash_machine.bridge"))]
     (print (bridge.describe "Thrash Machine")))

   (: Game :registerEvent "squeak"
      (fn [data]
        (Squeak data.x data.y [data.width data.height data.polygon])))
   (print (: Game :loc "Loaded [var:name]!" "mod.loaded" {:name self.info.name}))

   (when (= (os.getenv "KRISTAL_MOD_SMOKE") "1")
     (let [smoke (assert (self.libs.fumos.require "thrash_machine.smoke"))]
       (smoke.run))))

 :postUpdate
 (fn [self]
   (update-map-name self))

 :onKeyPressed
 (fn [self key is-repeat]
   (when (and (not is-repeat) (= key "f7") Game.setLanguage)
     (let [next-language (if (= (: Game :getLanguage) "zh_hans") "en" "zh_hans")]
       (when (: Game :setLanguage next-language)
         (update-map-name self)
         (update-battle-localization self)
         (let [message (: Game :loc "* Language switched to [var:language]." "mod.language_switched"
                              {:language (: Game :getLanguageName)})]
           (print message)
           (when (and Game.world Game.world.player
                      (not (: Game.world :hasCutscene))
                      (not Game.world.menu))
             (: Game.world :showText message)))
         true))))}
