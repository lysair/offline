local juhun = fk.CreateSkill {
  name = "ofl_tx__juhun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__juhun"] = "拘魂",
  [":ofl_tx__juhun"] = "锁定技，准备阶段，你令一名于你上个结束阶段后阵亡的友方角色复活，其回复体力至3点并摸三张牌。",

  ["#ofl_tx__juhun-choice"] = "拘魂：选择你要复活的友方角色",
}

juhun:addEffect(fk.EventPhaseStart, {
  anim_type = "big",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(juhun.name) and player.phase == Player.Start then
      local phase_event = player.room.logic:getEventsByRule(GameEvent.Phase, 1, function (e)
        return e.data.who == player and e.data.phase == Player.Finish
      end, -1)
      if #phase_event > 0 then
        return #player.room.logic:getEventsByRule(GameEvent.Death, 1, function (e)
          return e.data.who:isFriend(player) and e.data.who.dead and e.data.who.maxHp > 0
        end, phase_event[1].id) > 0
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    local phase_event = room.logic:getEventsByRule(GameEvent.Phase, 1, function (e)
      return e.data.who == player and e.data.phase == Player.Finish
    end, -1)
    if phase_event then
      room.logic:getEventsByRule(GameEvent.Death, 1, function (e)
        if e.data.who:isFriend(player) and e.data.who.dead and e.data.who.maxHp > 0 then
          table.insertIfNeed(targets, e.data.who)
        end
      end, phase_event[1].id)
    end
    if #targets == 0 then return end
    local to = targets[1]
    if #targets > 1 then
      local tos = table.map(targets, function(p)
        return "seat#" .. tostring(p.seat)
      end)
      local choice = room:askToChoice(player, {
        choices = tos,
        skill_name = juhun.name,
        prompt = "#ofl_tx__juhun-choice",
      })
      to = room:getPlayerBySeat(tonumber(string.sub(choice, 6)))
    end
    room:doIndicate(player, {to})
    room:setPlayerProperty(to, "dead", false)
    to._splayer:setDied(false)
    room:setPlayerProperty(to, "dying", false)
    room:setPlayerProperty(to, "hp", math.min(to.maxHp, 3))
    table.insertIfNeed(room.alive_players, to)
    room:updateAllLimitSkillUI(to)
    room:sendLog {
      type = "#Revive",
      from = to.id,
    }
    room.logic:trigger(fk.AfterPlayerRevived, to, data)
    if not to.dead then
      to:drawCards(3, juhun.name)
    end
  end,
})

return juhun
