local lengjian = fk.CreateSkill {
  name = "lengjian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lengjian"] = "冷箭",
  [":lengjian"] = "锁定技，你每回合使用的第一张【杀】对攻击范围内的角色造成伤害+1，对攻击范围外的角色无距离限制且不能被响应。",
}

lengjian:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(lengjian.name) and
      data.card and data.card.trueName == "slash" and
      player:inMyAttackRange(data.to) and player.room.logic:damageByCardEffect() then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event then
        local use_events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          local use = e.data
          return use.from == player and use.card.trueName == "slash"
        end, Player.HistoryTurn)
        return #use_events == 1 and use_events[1] == use_event
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(1)
  end,
})

lengjian:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(lengjian.name) and
      data.card and data.card.trueName == "slash" and
      table.find(data.tos, function (p)
        return not player:inMyAttackRange(p)
      end) then
      local use_event = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data
        return use.from == player and use.card.trueName == "slash"
      end, Player.HistoryTurn)
      return #use_event == 1 and use_event[1].data == data
    end
  end,
  on_use = function (self, event, target, player, data)
    data.disresponsiveList = data.disresponsiveList or {}
    for _, p in ipairs(player.room.alive_players) do
      if not player:inMyAttackRange(p) then
        table.insertIfNeed(data.disresponsiveList, p)
      end
    end
  end,
})

lengjian:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(lengjian.name) and skill.trueName == "slash_skill" and player:getMark("lengjian-turn") == 0
  end,
})

lengjian:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(lengjian.name, true) and data.card.trueName == "slash"
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "lengjian-turn", 1)
  end,
})

lengjian:addAcquireEffect(function (self, player, is_start)
  if not is_start then
    local room = player.room
    if #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      return use.from == player and use.card.trueName == "slash"
    end, Player.HistoryTurn) > 0 then
      room:addPlayerMark(player, "lengjian-turn", 1)
    end
  end
end)

return lengjian
