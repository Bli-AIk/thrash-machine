local SeamShop, super = Class(Shop)

function SeamShop:init()
    super.init(self)
    self.encounter_text = "{shop_seam_encounter}"
    self.shop_text = "{shop_seam_main}"
    self.leaving_text = "{shop_seam_leaving}"
    self.buy_menu_text = "{shop_seam_buy_menu}"
    self.buy_confirmation_text = "{shop_seam_buy_confirmation}"
    self.buy_refuse_text = "{shop_seam_buy_refuse}"
    self.buy_text = "{shop_seam_buy}"
    self.buy_storage_text = "{shop_seam_buy_storage}"
    self.buy_too_expensive_text = "{shop_seam_buy_too_expensive}"
    self.buy_no_space_text = "{shop_seam_buy_no_space}"
    self.sell_no_price_text = "{shop_seam_sell_no_price}"
    self.sell_menu_text = "{shop_seam_sell_menu}"
    self.sell_nothing_text = "{shop_seam_sell_nothing}"
    self.sell_confirmation_text = "{shop_seam_sell_confirmation}"
    self.sell_refuse_text = "{shop_seam_sell_refuse}"
    self.sell_text = "{shop_seam_sell}"
    self.sell_everything_text = "{shop_seam_sell_everything}"
    self.sell_no_storage_text = "{shop_seam_sell_no_storage}"
    self.talk_text = "{shop_seam_talk_menu}"

    local sell_items_text = "{shop_seam_sell_items_prompt}"
    local sell_weapons_text = "{shop_seam_sell_weapons_prompt}"
    local sell_armors_text = "{shop_seam_sell_armors_prompt}"
    local sell_storage_text = "{shop_seam_sell_storage_prompt}"
    self.sell_options_text["items"] = sell_items_text
    self.sell_options_text["weapons"] = sell_weapons_text
    self.sell_options_text["armors"] = sell_armors_text
    self.sell_options_text["storage"] = sell_storage_text
    self.sell_options_text["item"] = sell_items_text
    self.sell_options_text["weapon"] = sell_weapons_text
    self.sell_options_text["armor"] = sell_armors_text
    self.sell_options_text["pocket"] = sell_storage_text

    self:registerItem("cd_bagel")
    self:registerItem("darkburger")
    self:registerItem("amber_card")
    self:registerItem("spookysword")

    self:registerTalk("{shop_seam_talk_about}")
    self:registerTalk("{shop_seam_talk_lightners}")
    self:registerTalk("{shop_seam_talk_kingdom}")
    self:registerTalk("{shop_seam_talk_legendary}")

    self.shopkeeper:setActor("shopkeepers/seam")
    self.shopkeeper.sprite:setPosition(-24, 12)
    self.shopkeeper.slide = true

    self.background = "ui/shop/bg_seam"
    self.shop_music = "lantern"
end

function SeamShop:startTalk(talk)
    if talk == Game:loc("shop_seam_talk_about") then
        self:startDialogue({
            "{shop_seam_about_1}",
            "{shop_seam_about_2}",
            "{shop_seam_about_3}",
            "{shop_seam_about_4}",
            "{shop_seam_about_5}"
        })
    elseif talk == Game:loc("shop_seam_talk_lightners") then
        self:startDialogue({
            "{shop_seam_lightners_1}",
            "{shop_seam_lightners_2}",
            "{shop_seam_lightners_3}",
            "{shop_seam_lightners_4}",
            "{shop_seam_lightners_5}"
        })
    elseif talk == Game:loc("shop_seam_talk_kingdom") then
        self:startDialogue({
            "{shop_seam_kingdom_1}",
            "{shop_seam_kingdom_2}",
            "{shop_seam_kingdom_3}",
            "{shop_seam_kingdom_4}",
            "{shop_seam_kingdom_5}"
        })
    elseif talk == Game:loc("shop_seam_talk_legendary") then
        self:startDialogue({
            "{shop_seam_legendary_1}",
            "{shop_seam_legendary_2}",
            "{shop_seam_legendary_3}"
        })
    end
end

return SeamShop
