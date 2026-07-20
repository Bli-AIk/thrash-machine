{:init
 (fn [self]
   (let [bridge (assert (self.libs.fumos.require "thrash_machine.bridge"))]
     (print (bridge.describe "Thrash Machine")))

   (: Game :registerEvent "squeak"
      (fn [data]
        (Squeak data.x data.y [data.width data.height data.polygon])))
   (print (.. "Loaded " self.info.name "!"))

   (when (= (os.getenv "THRASH_MACHINE_SMOKE") "1")
     (let [smoke (assert (self.libs.fumos.require "thrash_machine.smoke"))]
       (smoke.run))))}
