local yirang = fk.CreateSkill {
  name = "sxfy__yirang",
}

Fk:loadTranslationTable{
  ["sxfy__yirang"] = "揖让",
  [":sxfy__yirang"] = "出牌阶段开始时，你可以展示所有手牌，将这些牌交给一名手牌数最少的其他角色，然后你摸等同于交出类别数的牌。",

  ["#sxfy__yirang-choose"] = "揖让：你可以将所有手牌展示并交给手牌数最少的角色，你摸交出类别数的牌",
}

yirang:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yirang.name) and player.phase == Player.Play and
      not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self,event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return table.every(room:getOtherPlayers(player, false), function (q)
        return q:getHandcardNum() >= p:getHandcardNum()
      end)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = yirang.name,
      prompt = "#sxfy__yirang-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = player:getCardIds("h")
    player:showCards(cards)
    if player.dead or to.dead then return end
    cards = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards > 0 then
      local types = {}
      for _, id in ipairs(cards) do
        table.insertIfNeed(types, Fk:getCardById(id).type)
      end
      room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, yirang.name, nil, true, player)
      if not player.dead then
        player:drawCards(#types, yirang.name)
      end
    end
  end,
})

return yirang
