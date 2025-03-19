local nitian = fk.CreateSkill {
  name = "ofl__nitian"
}

Fk:loadTranslationTable{
  ['ofl__nitian'] = '逆天',
  ['#ofl__nitian'] = '逆天：令你本回合使用牌不能被抵消，若本回合未杀死角色则死亡！',
  ['#ofl__nitian_delay'] = '逆天',
  [':ofl__nitian'] = '限定技，出牌阶段，令你本回合使用牌不能被抵消；结束阶段，若你本回合未杀死角色，你死亡。',
}

nitian:addEffect('active', {
  name = "ofl__nitian",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  prompt = "#ofl__nitian",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(nitian.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
})

nitian:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:usedSkillTimes(nitian.name, Player.HistoryTurn) > 0 then
      return data.card.trueName == "slash" or data.card:isCommonTrick()
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(nitian.name)
    room:notifySkillInvoked(player, nitian.name, "offensive")
    data.unoffsetableList = table.map(room.alive_players, Util.IdMapper)
  end,
})

nitian:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:usedSkillTimes(nitian.name, Player.HistoryTurn) > 0 then
      return player.phase == Player.Finish and
        #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function (e)
          local death = e.data[1]
          return death.damage and death.damage.from == player
        end, Player.HistoryTurn) == 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(nitian.name)
    room:notifySkillInvoked(player, nitian.name, "negative")
    room:killPlayer({who = player.id})
  end,
})

return nitian
