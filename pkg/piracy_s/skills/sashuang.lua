local sashuang = fk.CreateSkill {
  name = "ofl__sashuang",
}

Fk:loadTranslationTable{
  ["ofl__sashuang"] = "飒爽",
  [":ofl__sashuang"] = "结束阶段，你可以获得本回合进入弃牌堆的每种颜色各一张牌。",

  ["#ofl__sashuang-prey"] = "飒爽：你可以获得每种颜色各一张牌",
}

Fk:addPoxiMethod{
  name = "ofl__sashuang",
  prompt = "#ofl__sashuang-prey",
  card_filter = function(to_select, selected, data)
    if #selected < 2 then
      if #selected == 0 then
        return true
      else
        return Fk:getCardById(to_select).color ~= Fk:getCardById(selected[1]).color
      end
    end
  end,
  feasible = function(selected)
    return #selected > 0
  end,
}

sashuang:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sashuang.name) and player.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              if table.contains(player.room.discard_pile, info.cardId) and
                Fk:getCardById(info.cardId).color ~= Card.NoColor then
                return true
              end
            end
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(room.discard_pile, info.cardId) and
              Fk:getCardById(info.cardId).color ~= Card.NoColor then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryTurn)
    local result = room:askToPoxi(player, {
      poxi_type = sashuang.name,
      data = { { sashuang.name, ids } },
      cancelable = true,
    })
    if #result > 0 then
      room:moveCardTo(result, Card.PlayerHand, player, fk.ReasonJustMove, sashuang.name, nil, true, player)
    end
  end,
})

return sashuang
