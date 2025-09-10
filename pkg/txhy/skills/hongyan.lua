local hongyan = fk.CreateSkill({
  name = "ofl_tx__hongyan",
  tags = { Skill.Compulsory },
})

Fk:loadTranslationTable{
  ["ofl_tx__hongyan"] = "红颜",
  [":ofl_tx__hongyan"] = "锁定技，你的黑色牌视为<font color='red'>♥</font>牌。",
}

hongyan:addEffect("filter", {
  card_filter = function(self, to_select, player, isJudgeEvent)
    return player:hasSkill(hongyan.name) and to_select.color == Card.Black and
      (table.contains(player:getCardIds("he"), to_select.id) or isJudgeEvent)
  end,
  view_as = function(self, player, to_select)
    return Fk:cloneCard(to_select.name, Card.Heart, to_select.number)
  end,
})

return hongyan
