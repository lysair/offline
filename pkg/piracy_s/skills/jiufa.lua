local jiufa = fk.CreateSkill {
  name = "ofl__jiufa",
  derived_piles = "ofl__jiufa",
}

Fk:loadTranslationTable{
  ["ofl__jiufa"] = "九伐",
  [":ofl__jiufa"] = "当你使用或打出的牌结算后，若你的武将牌上没有与之牌名相同的牌，你可以将此牌置于你的武将牌上，然后若你武将牌上的牌"..
  "包含至少九种牌名，你移去这些牌，亮出牌堆顶九张牌，获得其中每个重复点数的牌各一张。",

  ["#ofl__jiufa-invoke"] = "九伐：是否将此%arg置为“九伐”牌？",

  ["$ofl__jiufa1"] = "担北伐重托，当兴复汉室，还于旧都！",
  ["$ofl__jiufa2"] = "任将军之职，应厉兵秣马，军出陇右。",
}

local spec = {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiufa.name) and
      not table.find(player:getPile(jiufa.name), function (id)
        return Fk:getCardById(id).trueName == data.card.trueName
      end) and
      table.contains({Card.Processing, Card.PlayerEquip, Card.PlayerJudge}, player.room:getCardArea(data.card))
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jiufa.name,
      prompt = "#ofl__jiufa-invoke:::"..data.card:toLogString(),
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:addToPile(jiufa.name, data.card, true, jiufa.name)
    local names = {}
    for _, id in ipairs(player:getPile(jiufa.name)) do
      table.insertIfNeed(names, Fk:getCardById(id).trueName)
    end
    if #names < 9 then return end
    room:moveCardTo(player:getPile(jiufa.name), Card.DiscardPile, nil, fk.ReasonPut, jiufa.name, nil, true, player)
    if player.dead then return end
    local cards = room:getNCards(9)
    room:turnOverCardsFromDrawPile(player, cards, jiufa.name)
    local get = table.filter(cards, function (id)
      return table.find(cards, function (id2)
        return id ~= id2 and Fk:getCardById(id).number == Fk:getCardById(id2).number
      end)
    end)
    local throw = table.filter(cards, function (id)
      return not table.contains(get, id)
    end)
    if #get > 0 then
      local result = room:askToPoxi(player, {
        poxi_type = "jiufa",
        data = {
          { jiufa.name, cards },
        },
        extra_data = {
          get = get,
          throw = throw,
        },
        cancelable = false,
      })
      if #result == 0 then
        result = get
      end
      if #get > 0 then
        room:moveCardTo(get, Player.Hand, player, fk.ReasonJustMove, jiufa.name, nil, true, player)
      end
    else
      room:delay(1000)
    end
    room:cleanProcessingArea(cards)
  end,
}

jiufa:addEffect(fk.CardUseFinished, spec)
jiufa:addEffect(fk.CardRespondFinished, spec)

return jiufa
