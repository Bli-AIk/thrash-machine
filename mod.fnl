(local map-name-key
  (fn [id]
    (.. "map_" (string.gsub (tostring id) "[^%w_]" "_") "_name")))

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
   (let [bridge (assert (self.libs.fumos.require "thrash_machine.bridge"))]
     (print (bridge.describe "Thrash Machine")))

   (: Game :registerEvent "squeak"
      (fn [data]
        (Squeak data.x data.y [data.width data.height data.polygon])))
   (print (: Game :loc "Loaded [var:name]!" "mod.loaded" {:name self.info.name}))

   (when (= (os.getenv "THRASH_MACHINE_SMOKE") "1")
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
