local difa = fk.CreateSkill {
  name = "sxfy__difa",
}

Fk:loadTranslationTable{
  ["sxfy__difa"] = "地法",
  [":sxfy__difa"] = "每轮限一次，当你得到红色牌后，你可以弃置其中一张牌，然后亮出牌堆顶三张牌并获得其中一张。",

  ["#sxfy__difa-invoke"] = "地法：你可以弃置其中一张红色牌，亮出牌堆顶三张牌并获得其中一张",
}

difa:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(difa.name) and
      player:usedSkillTimes(difa.name, Player.HistoryRound) == 0 then
      local ids = {}
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) and Fk:getCardById(info.cardId).color == Card.Red then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
      if #ids > 0 then
        event:setCostData(self, {cards = ids})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = difa.name,
      cancelable = true,
      pattern = tostring(Exppattern{ id = event:getCostData(self).cards }),
      prompt = "#sxfy__difa-invoke",
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, difa.name, player, player)
    if player.dead then return end
    local cards = room:getNCards(3)
    room:turnOverCardsFromDrawPile(player, cards, difa.name)
    local card = room:askToChooseCard(player, {
      target = player,
      flag = { card_data = {{ "toObtain", cards }} },
      skill_name = difa.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, difa.name, nil, true, player)
    room:cleanProcessingArea(cards)
  end,
})

return difa
