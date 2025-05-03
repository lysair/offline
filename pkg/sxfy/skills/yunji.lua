local yunji = fk.CreateSkill {
  name = "sxfy__yunji",
}

Fk:loadTranslationTable{
  ["sxfy__yunji"] = "运机",
  [":sxfy__yunji"] = "你可以将一张装备牌当【借刀杀人】使用。",

  ["#sxfy__yunji"] = "运机：你可以将一张装备牌当【借刀杀人】使用",
}

yunji:addEffect("viewas", {
  anim_type = "control",
  pattern = "collateral",
  prompt = "#sxfy__yunji",
  handly_pile = true,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("collateral")
    card.skillName = yunji.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

return yunji
