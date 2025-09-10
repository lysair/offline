local manyi = fk.CreateSkill {
  name = "sxfy__manyi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__manyi"] = "蛮裔",
  [":sxfy__manyi"] = "锁定技，【南蛮入侵】对你无效；【南蛮入侵】结算结束后，若造成过伤害，你摸一张牌。",
}

manyi:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(manyi.name) and data.card.trueName == "savage_assault" and data.to == player
  end,
  on_use = function (self, event, target, player, data)
    data.nullified = true
  end,
})

manyi:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(manyi.name) and
      data.card.trueName == "savage_assault" and data.damageDealt
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, manyi.name)
  end,
})

return manyi
