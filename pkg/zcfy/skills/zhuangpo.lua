local zhuangpo = fk.CreateSkill {
  name = "sxfy__zhuangpo",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__zhuangpo"] = "壮魄",
  [":sxfy__zhuangpo"] = "锁定技，你的牌面信息中有【杀】字的非基本牌手牌视为【决斗】。",
}

zhuangpo:addEffect("filter", {
  anim_type = "offensive",
  card_filter = function(self, to_select, player)
    return player:hasSkill(zhuangpo.name) and
      to_select.type ~= Card.TypeBasic and string.find(Fk:translate(":"..to_select.name, "zh_CN"), "【杀】") and
      table.contains(player:getCardIds("h"), to_select.id)
  end,
  view_as = function(self, player, to_select)
    return Fk:cloneCard("duel", to_select.suit, to_select.number)
  end,
})

return zhuangpo
