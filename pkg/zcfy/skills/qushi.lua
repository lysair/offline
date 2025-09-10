local qushi = fk.CreateSkill{
  name = "sxfy__qushi",
}

Fk:loadTranslationTable{
  ["sxfy__qushi"] = "趋势",
  [":sxfy__qushi"] = "出牌阶段限一次，你可以弃置一张牌并选择一名其他角色，结束阶段，若其本回合使用过牌，你摸两张牌。",

  ["#sxfy__qushi"] = "趋势：弃一张牌选择一名角色，结束阶段若其本回合使用过牌，你摸两张牌",
}

qushi:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__qushi",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(qushi.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:addTableMark(player, "sxfy__qushi-turn", effect.tos[1].id)
    room:throwCard(effect.cards, qushi.name, player, player)
  end,
})

qushi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player.phase == Player.Finish and
      table.find(player:getTableMark("sxfy__qushi-turn"), function (id)
        return #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          return e.data.from.id == id
        end, Player.HistoryTurn) > 0
      end)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = #table.filter(player:getTableMark("sxfy__qushi-turn"), function (id)
      return #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        return e.data.from.id == id
      end, Player.HistoryTurn) > 0
    end)
    player:drawCards(n * 2, qushi.name)
  end,
})

return qushi
