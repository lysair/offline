local sanshi = fk.CreateSkill {
  name = "qshm__sanshi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["qshm__sanshi"] = "散士",
  [":qshm__sanshi"] = "锁定技，游戏开始时，你声明一个点数，该点数的所有牌标记为“死士”牌。每个回合结束时，若本回合有“死士”牌进入弃牌堆："..
  "若不因你使用或打出，你获得这些牌；否则将这些牌移出游戏。你使用“死士”牌不能被响应。",

  ["#qshm__sanshi-choice"] = "散士：请声明一个点数，该点数的所有牌标记为“死士”牌",
  ["@qshm__sanshi"] = "散士",
  ["@@qshm__sanshi-inhand"] = "死士",

  ["$qshm__sanshi1"] = "布暗流于冰下，散死士于市井。",
  ["$qshm__sanshi2"] = "鸡鸣狗盗之士，胜满堂之朱紫。",
}

sanshi:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sanshi.name) and
      (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      not data.card:isVirtual() and data.card.number == player:getMark("@qshm__sanshi")
  end,
  on_use = function(self, event, target, player, data)
    data.disresponsiveList = table.simpleClone(player.room.players)
  end,
})

sanshi:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(sanshi.name) and player:getMark("@qshm__sanshi") ~= 0 then
      local room = player.room
      local ids = {}
      room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              if Fk:getCardById(info.cardId).number == player:getMark("@qshm__sanshi") and
                table.contains(room.discard_pile, info.cardId) then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          end
        end
      end, Player.HistoryTurn)
      if #ids > 0 then
        event:setCostData(self, {cards = ids})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(event:getCostData(self).cards)
    local cards1, cards2 = {}, {}
    room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(cards, info.cardId) then
              if move.moveReason == fk.ReasonUse then
                local use_event = e:findParent(GameEvent.UseCard)
                if not use_event or use_event.data.from ~= player then
                  table.insert(cards1, info.cardId)
                else
                  table.insert(cards2, info.cardId)
                end
              elseif move.moveReason == fk.ReasonResponse then
                local use_event = e:findParent(GameEvent.RespondCard)
                if not use_event or use_event.data.from ~= player then
                  table.insert(cards1, info.cardId)
                else
                  table.insert(cards2, info.cardId)
                end
              else
                table.insert(cards1, info.cardId)
              end
            end
          end
        end
      end
    end, nil, Player.HistoryTurn)
    local moves = {}
    if #cards1 > 0 then
      table.insert(moves, {
        ids = cards1,
        to = player,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        skillName = sanshi.name,
        proposer = player,
        moveVisible = true,
      })
    end
    if #cards2 > 0 then
      local mark = player:getTableMark("qshm__sanshi_removed")
      table.insertTableIfNeed(mark, cards2)
      room:setPlayerMark(player, "qshm__sanshi_removed", mark)
      table.insert(moves, {
        ids = cards2,
        toArea = Card.Void,
        moveReason = fk.ReasonJustMove,
        skillName = sanshi.name,
        proposer = player,
        moveVisible = true,
      })
    end
    room:moveCards(table.unpack(moves))
  end,
})

sanshi:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sanshi.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = room:askToNumber(player, {
      skill_name = sanshi.name,
      prompt = "#qshm__sanshi-choice",
      min = 1,
      max = 13,
    })
    room:setPlayerMark(player, "@qshm__sanshi", num)
  end,
})

sanshi:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@qshm__sanshi") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if card.number == player:getMark("@qshm__sanshi") then
        room:setCardMark(card, "@@qshm__sanshi-inhand", 1)
      end
    end
  end,
})

sanshi:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if not player:hasSkill("qshm__chenlue", true, true) then
    room:setPlayerMark(player, "@qshm__sanshi", 0)
    room:setPlayerMark(player, "qshm__sanshi_removed", 0)
  end
end)

return sanshi
