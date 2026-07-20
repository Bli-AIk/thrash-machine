(local (Squeak super) (Class Event))

(fn Squeak.init [self x y shape]
  (super.init self x y shape))

(fn Squeak.onInteract [self player dir]
  (Assets.playSound "squeak")
  true)

Squeak
