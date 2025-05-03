local shangjian = fk.CreateSkill {
  name = "sxfy__shangjian",
}

Fk:loadTranslationTable{
  ["sxfy__shangjian"] = "尚俭",
  [":sxfy__shangjian"] = "结束阶段，若你本回合失去的牌数不大于你的体力值，你可以从弃牌堆获得一张本回合你失去的牌。",

  ["#sxfy__shangjian-prey"] = "尚俭：获得其中一张牌",
}

shangjian:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(shangjian.name) and player.phase == Player.Finish then
      local yes, num = false, 0
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from == player then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                num = num + 1
                if not yes and table.contains(player.room.discard_pile, info.cardId) then
                  yes = true
                end
              end
            end
          end
        end
      end, Player.HistoryTurn)
      return num <= player.hp and yes
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryTurn)
    local card = room:askToChooseCard(player, {
      target = player,
      flag = { card_data = {{ "pile_discard", cards }} },
      skill_name = shangjian.name,
      prompt = "#sxfy__shangjian-prey",
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, shangjian.name, nil, true, player)
  end,
})

return shangjian
