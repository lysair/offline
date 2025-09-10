local yuma = fk.CreateSkill{
  name = "yuma",
}

Fk:loadTranslationTable{
  ["yuma"] = "御马",
  [":yuma"] = "每回合限一次，当一张坐骑牌进入弃牌堆后，你可以将之置入一名角色的装备区，然后获得其所有手牌。",

  ["#yuma-invoke"] = "御马：你可以将其中一张坐骑置入一名角色装备区，获得其所有手牌",
}

yuma:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yuma.name) and player:usedSkillTimes(yuma.name, Player.HistoryTurn) == 0 then
      local cards = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if (Fk:getCardById(info.cardId).sub_type == Card.SubtypeDefensiveRide or
              Fk:getCardById(info.cardId).sub_type == Card.SubtypeOffensiveRide) and
              table.contains(player.room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
      cards = player.room.logic:moveCardsHoldingAreaCheck(cards)
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(event:getCostData(self).cards)
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "#yuma_active",
      prompt = "#yuma-invoke",
      cancelable = true,
      extra_data = {
        expand_pile = cards,
      }
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards, tos = dat.targets})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:moveCardIntoEquip(to, event:getCostData(self).cards, yuma.name, false, player)
    if not player.dead and not to.dead and to ~= player and not to:isKongcheng() then
      room:moveCardTo(to:getCardIds("h"), Card.PlayerHand, player, fk.ReasonPrey, yuma.name, nil, false, player)
    end
  end,
})

return yuma
