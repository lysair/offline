local yuhua = fk.CreateSkill {
  name = "ofl__yuhua",
}

Fk:loadTranslationTable{
  ["ofl__yuhua"] = "羽化",
  [":ofl__yuhua"] = "弃牌阶段开始时，你可以展示任意张非基本牌，这些牌不计入手牌上限。当你于回合外失去非基本牌后，" ..
  "你可以观看牌堆顶的X张牌并以任意顺序置于牌堆顶或牌堆底，然后摸X张牌（X为你此次失去牌的数量且至多为5）。",

  ["#ofl__yuhua-show"] = "羽化：你可以展示任意张非基本牌，令这些牌不计入手牌上限",

  ["$ofl__yuhua1"] = "天下祸乱我归隐，化作闲云野鹤仙。",
  ["$ofl__yuhua2"] = "飘飘兮如遗世独立，羽化而登仙。",
}

yuhua:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yuhua.name) and player.phase == Player.Discard and
      not player:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 999,
      include_equip = false,
      skill_name = yuhua.name,
      pattern = ".|.|.|.|.|^basic",
      prompt = "#ofl__yuhua-show",
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards or {}
    player:showCards(cards)
    cards = table.filter(cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards > 0 then
      for _, id in ipairs(cards) do
        room:setCardMark(Fk:getCardById(id), "ofl__yuhua-inhand", 1)
      end
    end
  end,
})

yuhua:addEffect("maxcards", {
  exclude_from = function (self, player, card)
    return card:getMark("ofl__yuhua-inhand") > 0
  end,
})

yuhua:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yuhua.name) and player.room.current ~= player then
      for _, move in ipairs(data) do
        if move.from == player and move.to ~= player then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).type ~= Card.TypeBasic then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = 0
    for _, move in ipairs(data) do
      if move.from == player then
        num = num + #table.filter(move.moveInfo, function(info)
          return (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip)
        end)
      end
    end
    num = math.min(5, num)
    room:askToGuanxing(player, { cards = room:getNCards(num) })
    player:drawCards(num, yuhua.name)
  end,
})

return yuhua
