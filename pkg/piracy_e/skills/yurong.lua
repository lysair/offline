local yurong = fk.CreateSkill {
  name = "yurong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yurong"] = "御戎",
  [":yurong"] = "锁定技，当你每轮首次成为一种牌名的伤害牌的目标时，取消之。",

  ["@$yurong-round"] = "御戎",
}

yurong:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(yurong.name) and data.card.is_damage_card and
      not table.contains(player:getTableMark("@$yurong-round"), data.card.trueName) then
      local room = player.room
      local use_events = room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data
        if use.card.trueName == data.card.trueName and table.contains(use.tos, player) then
          room:addTableMark(player, "@$yurong-round", data.card.trueName)
          return true
        end
      end, Player.HistoryRound)
      return #use_events == 1 and use_events[1].id == room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true).id
    end
  end,
  on_use = function(self, event, target, player, data)
    data:cancelTarget(player)
  end,
})

return yurong
