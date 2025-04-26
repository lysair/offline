local yure = fk.CreateSkill {
  name = "ofl__yure",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl__yure"] = "余热",
  [":ofl__yure"] = "限定技，当你弃置牌后，你可以将所有弃置的牌交给任意名其他角色。",

  ["#ofl__yure-give"] = "余热：你可以将弃置的牌分配给其他角色",
}

yure:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yure.name) and #player.room:getOtherPlayers(player, false) > 0 and
      player:usedSkillTimes(yure.name, Player.HistoryGame) == 0 then
      local cards = {}
      for _, move in ipairs(data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
      cards = table.filter(cards, function(id)
        return table.contains(player.room.discard_pile, id)
      end)
      cards = player.room.logic:moveCardsHoldingAreaCheck(cards)
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local result = room:askToYiji(player, {
      cards = cards,
      targets = room:getOtherPlayers(player, false),
      skill_name = yure.name,
      min_num = 0,
      max_num = #cards,
      prompt = "#ofl__yure-give",
      expand_pile = cards,
      skip = true,
    })
    for _, ids in pairs(result) do
      if #ids > 0 then
        event:setCostData(self, {extra_data = result})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:doYiji(event:getCostData(self).extra_data, player, yure.name)
  end,
})

return yure
