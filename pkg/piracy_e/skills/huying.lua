local huying = fk.CreateSkill {
  name = "huying",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["huying"] = "狐影",
  [":huying"] = "锁定技，游戏开始时/其他角色死亡后，你从游戏外获得两张/一张<a href=':caning_whip'>【刑鞭】</a>，【刑鞭】不计入你的手牌上限，"..
  "你场上每有一张【刑鞭】，其他角色计算与你的距离便+1。",
}

huying:addEffect(fk.GameStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huying.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _ = 1, 2 do
      local card = room:printCard("caning_whip", Card.Spade, 9)
      table.insert(cards, card)
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, huying.name, nil, true, player)
  end,
})

huying:addEffect(fk.Deathed, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huying.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:printCard("caning_whip", Card.Spade, 9)
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, huying.name, nil, true, player)
  end,
})

huying:addEffect("maxcards", {
  exclude_from = function(self, player, card)
    return player:hasSkill(huying.name) and card.name == "caning_whip"
  end,
})

huying:addEffect("distance", {
  correct_func = function(self, from, to)
    if to:hasSkill(huying.name) then
      return #table.filter(to:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
    end
  end,
})

return huying
