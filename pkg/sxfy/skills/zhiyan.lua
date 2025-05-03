local zhiyan = fk.CreateSkill {
  name = "sxfy__zhiyan",
}

Fk:loadTranslationTable{
  ["sxfy__zhiyan"] = "直言",
  [":sxfy__zhiyan"] = "结束阶段，你可以获得一张本回合进入弃牌堆的装备牌。",

  ["#sxfy__zhiyan-prey"] = "直言：获得其中一张牌",
}

zhiyan:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhiyan.name) and player.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              if Fk:getCardById(info.cardId).type == Card.TypeEquip and
                table.contains(player.room.discard_pile, info.cardId) then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).type == Card.TypeEquip and
              table.contains(player.room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryTurn)
    local card = room:askToChooseCard(player, {
      target = player,
      flag = { card_data = {{ "pile_discard", cards }} },
      skill_name = zhiyan.name,
      prompt = "#sxfy__zhiyan-prey",
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, zhiyan.name, nil, true, player)
  end,
})

return zhiyan
