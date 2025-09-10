local fuxiang = fk.CreateSkill {
  name = "fuxiang",
}

Fk:loadTranslationTable {
  ["fuxiang"] = "付相",
  [":fuxiang"] = "出牌阶段开始前，你可以跳过此阶段，然后弃牌阶段结束时，你可以将此阶段进入弃牌堆的牌交给一名其他角色，其获得一个额外回合。",

  ["#fuxiang-choose"] = "付相：令一名角色获得此阶段进入弃牌堆的牌并获得一个额外回合",

  ["$fuxiang1"] = "相父怀托孤之重，朕自当倾国相付。",
  ["$fuxiang2"] = "忠贤明良，朕自当亲而任之。",
}

fuxiang:addEffect(fk.EventPhaseChanging, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fuxiang.name) and player == target and data.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    data.skipped = true
  end,
})

fuxiang:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Discard and
      player:usedEffectTimes(fuxiang.name, Player.HistoryTurn) > 0 and
      not player.dead and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = fuxiang.name,
      prompt = "#fuxiang-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local ids = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(room.discard_pile, info.cardId) then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
    end, Player.HistoryPhase)
    if #ids > 0 then
      room:obtainCard(to, ids, true, fk.ReasonGive, player, fuxiang.name)
    end
    if not to.dead then
      to:gainAnExtraTurn(true, fuxiang.name)
    end
  end,
})

return fuxiang