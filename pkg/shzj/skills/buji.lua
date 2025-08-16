local buji = fk.CreateSkill {
  name = "buji",
}

Fk:loadTranslationTable{
  ["buji"] = "不戢",
  [":buji"] = "当你获得或弃置牌后，你可以使用其中一张牌（无次数限制），若未造成伤害，你失去1点体力。",

  ["#buji-use"] = "不戢：你可以使用其中一张牌，若未造成伤害则失去体力",
}

buji:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(buji.name) then
      local ids1 = {}
      local ids2 = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                table.contains(player.room.discard_pile, info.cardId) then
                table.insertIfNeed(ids1, info.cardId)
              end
            end
          end
        elseif move.to == player and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) then
              table.insertIfNeed(ids2, info.cardId)
            end
          end
        end
      end
      ids1 = player.room.logic:moveCardsHoldingAreaCheck(ids1)
      if #ids1 > 0 or #ids2 > 0 then
        event:setCostData(self, {ids1 = ids1, ids2 = ids2})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local dat = event:getCostData(self)
    local use = room:askToUseRealCard(player, {
      pattern = tostring(Exppattern{ id = table.connect(dat.ids1, dat.ids2) }),
      skill_name = buji.name,
      prompt = "#buji-use",
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      cancelable = true,
      skip = true,
      expand_pile = dat.ids1,
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = event:getCostData(self).extra_data
    room:useCard(use)
    if not player.dead and use and not use.damageDealt then
      room:loseHp(player, 1, buji.name)
    end
  end,
})

return buji
