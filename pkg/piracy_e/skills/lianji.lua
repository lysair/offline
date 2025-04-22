local lianji = fk.CreateSkill {
  name = "ofl__lianji",
}

Fk:loadTranslationTable{
  ["ofl__lianji"] = "连计",
  [":ofl__lianji"] = "出牌阶段结束时，若你本阶段使用牌类别数不小于：1，你可以令一名角色摸一张牌；2.你可以回复1点体力；"..
  "3.你可以令一名其他角色代替你执行本回合剩余阶段。",

  ["#ofl__lianji1-invoke"] = "连计：你可以令一名角色摸一张牌",
  ["#ofl__lianji2-invoke"] = "连计：你可以回复1点体力",
  ["#ofl__lianji3-invoke"] = "连计：你可以令一名其他角色代替你执行本回合剩余阶段",
}

lianji:addEffect(fk.EventPhaseEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(lianji.name) and player.phase == Player.Play then
      local types = {}
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data
        if use.from == player then
          table.insertIfNeed(types, use.card.type)
        end
      end, Player.HistoryPhase)
      if #types > 0 then
        event:setCostData(self, {choice = #types})
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__lianji1-invoke",
      skill_name = lianji.name,
    })
    if #to > 0 then
      to[1]:drawCards(1, lianji.name)
    end
    local n = event:getCostData(self).choice
    if player.dead or n < 2 then return end
    if player:isWounded() and
      room:askToSkillInvoke(player, {
        skill_name = lianji.name,
        prompt = "#ofl__lianji2-invoke"
      }) then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = lianji.name,
      }
    end
    if player.dead or n < 3 or #room:getOtherPlayers(player, false) == 0 or room.current ~= player then return end
    to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__lianji3-invoke",
      skill_name = lianji.name,
    })
    if #to > 0 then
      local phase_table = {}
      local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
      if turn_event then
        local phase_data = nil
        for i = turn_event.data.phase_index + 1, #turn_event.data.phase_table, 1 do
          phase_data = turn_event.data.phase_table[i]
          if not phase_data.skipped then
            table.insert(phase_table, phase_data.phase)
            phase_data.skipped = true
          end
        end
        room:setPlayerMark(to[1], "ofl__lianji-turn", phase_table)
      end
    end
  end,
})

lianji:addEffect(fk.EventPhaseSkipped, {
  can_refresh = function (self, event, target, player, data)
    return player:getMark("ofl__lianji-turn") ~= 0 and
      data.phase <= Player.Finish and data.phase >= Player.Start
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    local mark = player:getMark("ofl__lianji-turn")
    local phase = mark[1]
    table.remove(mark, 1)
    room:setPlayerMark(player, "ofl__lianji-turn", #mark > 0 and mark or 0)
    player:gainAnExtraPhase(phase, "game_rule", false)
  end,
})

return lianji
