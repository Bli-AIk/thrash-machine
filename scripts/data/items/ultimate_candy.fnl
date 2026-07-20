(local (item super) (Class HealItem "ultimate_candy"))

(fn item.init [self]
  (super.init self)
  (set self.name "UltimatCandy")
  (set self.use_name "ULTIMATE CANDY")
  (set self.type "item")
  (set self.icon nil)
  (set self.effect "Best\nhealing")
  (set self.shop "Perfection")
  (set self.description "Sparkles with perfection.\nMust be shared with everyone. +??HP")
  (set self.heal_amount 1)
  (set self.price 100)
  (set self.can_sell true)
  (set self.target "party")
  (set self.usable_in "all")
  (set self.result_item nil)
  (set self.instant false)
  (set self.bonuses {})
  (set self.bonus_name nil)
  (set self.bonus_icon nil)
  (set self.can_equip {})
  (set self.reactions
       {:susie "Hey! It's hollow inside!"
        :ralsei "I like the texture!"
        :noelle "That was underwhelming..."}))

item
