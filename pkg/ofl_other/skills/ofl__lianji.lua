local ofl__lianji = fk.CreateSkill {
  name = "ofl__lianji"
}

Fk:loadTranslationTable{
  ['ofl__lianji'] = '连计',
  ['#ofl__lianji1-invoke'] = '连计：你可以令一名角色摸一张牌',
  ['#ofl__lianji2-invoke'] = '连计：你可以回复1点体力',
  ['#ofl__lianji3-invoke'] = '连计：你可以令一名其他角色代替你执行本回合剩余阶段',
  [':ofl__lianji'] = '出牌阶段结束时，若你本阶段使用牌类别数不小于：1，你可以令一名角色摸一张牌；2.你可以回复1点体力；3.你可以令一名其他角色代替你执行本回合剩余阶段。',
}

ofl__lianji:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player)
    if target == player and player:hasSkill(ofl__lianji.name) and player.phase == Player.Play then
      local types = {}
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        if use.from == player.id then
          table.insertIfNeed(types, use.card.type)
        end
      end, Player.HistoryPhase)
      if #types > 0 then
        event:setCostData(self, #types)
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = table.map(room.alive_players, Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__lianji1-invoke",
      skill_name = ofl__lianji.name
    })
    if #to > 0 then
      room:getPlayerById(to[1]):drawCards(1, ofl__lianji.name)
    end
    local cost_data = event:getCostData(self)
    if player.dead or cost_data < 2 then return end
    if player:isWounded() and room:askToSkillInvoke(player, {
      skill_name = ofl__lianji.name,
      prompt = "#ofl__lianji2-invoke"
    }) then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = ofl__lianji.name,
      })
    end
    if player.dead or cost_data < 3 or #room.alive_players < 2 then return end
    to = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__lianji3-invoke",
      skill_name = ofl__lianji.name
    })
    if #to > 0 then
      room:setPlayerMark(player, "ofl__lianji-turn", to[1])
    end
  end,
})

ofl__lianji:addEffect(fk.EventPhaseChanging, {
  mute = true,

  can_trigger = function (self, event, target, player)
    if target == player and player:getMark("ofl__lianji_skipping") > 0 then
      data.to = player:getMark("ofl__lianji_skipping")
      player.phase = player:getMark("ofl__lianji_skipping")
      player.room:broadcastProperty(player, "phase")
      player.room:setPlayerMark(player, "ofl__lianji_skipping", 0)
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = Util.TrueFunc,

  can_refresh = function (self, event, target, player)
    return target == player and player:getMark("ofl__lianji-turn") ~= 0 and data.to < 8 and data.to > 1 and
      not player.room:getPlayerById(player:getMark("ofl__lianji-turn")).dead
  end,
  on_refresh = function (self, event, target, player)
    local room = player.room
    local to = room:getPlayerById(player:getMark("ofl__lianji-turn"))
    player.phase = Player.PhaseNone
    room:broadcastProperty(player, "phase")
    room:setPlayerMark(player, "ofl__lianji_skipping", data.to)

    local skip = room.logic:trigger(fk.EventPhaseChanging, to, {
      from = to.phase,
      to = data.to,
    })
    to.phase = data.to
    room:broadcastProperty(to, "phase")

    local cancel_skip = true
    if data.to ~= Player.NotActive and (skip) then
      cancel_skip = room.logic:trigger(fk.EventPhaseSkipping, to)
    end

    if (not skip) or (cancel_skip) then
      GameEvent.Phase:create(to, to.phase):exec()
    else
      room:sendLog{
        type = "#PhaseSkipped",
        from = to.id,
        arg = data.to,
      }
    end
  end,
})

return ofl__lianji
