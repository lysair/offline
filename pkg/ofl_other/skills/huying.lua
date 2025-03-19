local huying = fk.CreateSkill {
  name = "huying"
}

Fk:loadTranslationTable{
  ['huying'] = '狐影',
  [':huying'] = '锁定技，游戏开始时/其他角色死亡后，你从游戏外获得两张/一张<a href=>【刑鞭】</a>，【刑鞭】不计入你的手牌上限，你场上每有一张【刑鞭】，其他角色计算与你的距离便+1。',
}

huying:addEffect(fk.GameStart, {
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return player:hasSkill(huying)
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local cards = {}
    if event == fk.GameStart then
      for i = 1, 2 do
        local card = room:printCard("caning_whip", Card.Spade, 9)
        table.insert(cards, card)
      end
    else
      cards = {room:printCard("caning_whip", Card.Spade, 9)}
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, huying.name, nil, true, player.id)
  end,
})

huying:addEffect(fk.Deathed, {
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player)
    return player:hasSkill(huying)
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local cards = {}
    if event == fk.GameStart then
      for i = 1, 2 do
        local card = room:printCard("caning_whip", Card.Spade, 9)
        table.insert(cards, card)
      end
    else
      cards = {room:printCard("caning_whip", Card.Spade, 9)}
    end
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, huying.name, nil, true, player.id)
  end,
})

huying:addEffect('maxcards', {
  frequency = Skill.Compulsory,
  exclude_from = function(self, player, card)
    return player:hasSkill(huying) and card.name == "caning_whip"
  end,
})

huying:addEffect('distance', {
  frequency = Skill.Compulsory,
  correct_func = function(self, from, to)
    if to:hasSkill(huying) then
      return #table.filter(to:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
    end
    return 0
  end,
})

return huying
