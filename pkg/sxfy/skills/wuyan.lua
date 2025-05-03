local wuyan = fk.CreateSkill {
  name = "sxfy__wuyan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__wuyan"] = "无言",
  [":sxfy__wuyan"] = "锁定技，你的锦囊牌视为【无懈可击】。",
}

wuyan:addEffect("filter", {
  anim_type = "control",
  card_filter = function(self, to_select, player)
    return player:hasSkill(wuyan.name) and to_select.type == Card.TypeTrick and
      table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard("nullification", card.suit, card.number)
  end,
})

return wuyan
