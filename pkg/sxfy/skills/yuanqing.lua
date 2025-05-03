
local yuanqing = fk.CreateSkill {
  name = "sxfy__yuanqing",
}

Fk:loadTranslationTable{
  ["sxfy__yuanqing"] = "渊清",
  [":sxfy__yuanqing"] = "回合结束时，你可以令所有角色依次选择并获得弃牌堆中因其此回合失去而置入的一张牌。",

  ["#sxfy__yuanqing-prey"] = "渊清：获得其中一张牌",
}

yuanqing:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yuanqing.name) and
      table.find(player.room.alive_players, function (p)
        return #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if move.from == p then
              for _, info in ipairs(move.moveInfo) do
                if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                  table.contains(player.room.discard_pile, info.cardId) then
                  return true
                end
              end
            end
          end
        end, Player.HistoryTurn) > 0
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if not p.dead then
        local cards = {}
        room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if move.from == p then
              for _, info in ipairs(move.moveInfo) do
                if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                  table.contains(room.discard_pile, info.cardId) then
                  table.insertIfNeed(cards, info.cardId)
                end
              end
            end
          end
        end, Player.HistoryTurn)
        if #cards > 0 then
          local card = room:askToChooseCard(p, {
            target = p,
            flag = { card_data = {{ "discard_pile", cards }} },
            skill_name = yuanqing.name,
            prompt = "#sxfy__yuanqing-prey",
          })
          room:moveCardTo(card, Card.PlayerHand, p, fk.ReasonJustMove, yuanqing.name, nil, true, p)
        end
      end
    end
  end,
})

return yuanqing
