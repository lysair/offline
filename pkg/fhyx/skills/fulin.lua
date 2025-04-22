local fulin = fk.CreateSkill {
  name = "fhyx__fulin"
}

Fk:loadTranslationTable{
  ['fhyx__fulin'] = '腹鳞',
  ['#fhyx__fulin-invoke'] = '腹鳞：你可以将其中任意张牌以任意顺序置于牌堆顶，回合结束时摸等量的牌',
  ['@fhyx__fulin-turn'] = '腹鳞',
  ['#fhyx__fulin_delay'] = '腹鳞',
  [':fhyx__fulin'] = '当你于回合内获得牌后，你可以将其中任意张牌以任意顺序置于牌堆顶；回合结束时，你摸X张牌（X为本回合你以此法失去的牌数）。',
  ['$fhyx__fulin1'] = '我的才学，蜀中何人能比？',
  ['$fhyx__fulin2'] = '生此乱世，腹中鳞甲可保我周全。',
}

-- 主技能
fulin:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(fulin) and player.phase ~= Player.NotActive and not player:isKongcheng() then
      local cards = {}
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
      U.moveCardsHoldingAreaCheck(player.room, cards)
      if #cards > 0 then
        event:setCostData(self, cards)
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local cards = player.room:askToCards(player, {
      min_num = 1,
      max_num = 999,
      include_equip = false,
      pattern = ".|.|.|.|.|." .. table.concat(event:getCostData(self), ","),
      prompt = "#fhyx__fulin-invoke",
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@fhyx__fulin-turn", #event:getCostData(self).cards)
    if #event:getCostData(self).cards == 1 then
      room:moveCards({
        ids = event:getCostData(self).cards,
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = fulin.name,
        proposer = player.id,
      })
    else
      local result = room:askToGuanxing(player, {
        cards = event:getCostData(self).cards,
        top_limit = {0, 0},
        skill_name = fulin.name,
        skip = true,
      })
      room:moveCards({
        ids = table.reverse(result.top),
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = fulin.name,
        proposer = player.id,
      })
    end
  end,
})

-- 延迟技能
fulin:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@fhyx__fulin-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("fhyx__fulin")
    player.room:notifySkillInvoked(player, "fhyx__fulin", "drawcard")
    player:drawCards(player:getMark("@fhyx__fulin-turn"), fulin.name)
  end,
})

return fulin
