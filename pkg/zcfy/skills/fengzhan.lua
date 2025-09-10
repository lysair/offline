local fengzhan = fk.CreateSkill {
  name = "fengzhan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fengzhan"] = "锋展",
  [":fengzhan"] = "锁定技，游戏开始时，你获得<a href=':baibi_dagger'>【百辟双匕】</a>。",
}

fengzhan:addEffect(fk.GameStart, {
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(fengzhan.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = room:printCard("baibi_dagger", Card.Spade, 2)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, fengzhan.name, nil, true, player)
  end,
})

return fengzhan