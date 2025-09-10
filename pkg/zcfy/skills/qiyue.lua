local qiyue = fk.CreateSkill {
  name = "qiyue",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["qiyue"] = "起钺",
  [":qiyue"] = "锁定技，游戏开始时，你获得<a href=':xuanhua_axe'>【宣花斧】</a>。",
}

qiyue:addEffect(fk.GameStart, {
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(qiyue.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = room:printCard("xuanhua_axe", Card.Diamond, 5)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, qiyue.name, nil, true, player)
  end,
})

return qiyue