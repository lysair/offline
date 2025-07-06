local xingqi = fk.CreateSkill {
  name = "sxfy__xingqi",
}

Fk:loadTranslationTable{
  ["sxfy__xingqi"] = "星启",
  [":sxfy__xingqi"] = "结束阶段，你可以获得一张本回合进入弃牌堆的牌。",

  ["#sxfy__xingqi-prey"] = "星启：获得其中一张牌",
}

xingqi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingqi.name) and player.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              if table.contains(player.room.discard_pile, info.cardId) then
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
            if table.contains(room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryTurn)
    local card = room:askToChooseCard(player, {
      target = player,
      flag = { card_data = {{ "pile_discard", cards }} },
      skill_name = xingqi.name,
      prompt = "#sxfy__xingqi-prey",
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, xingqi.name, nil, true, player)
  end,
})

return xingqi
