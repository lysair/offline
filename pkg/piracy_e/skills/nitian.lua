local nitian = fk.CreateSkill {
  name = "ofl__nitian",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl__nitian"] = "逆天",
  [":ofl__nitian"] = "限定技，出牌阶段，令你本回合使用牌不能被抵消；结束阶段，若你本回合未杀死角色，你死亡。",

  ["#ofl__nitian"] = "逆天：令你本回合使用牌不能被抵消，若本回合未杀死角色则死亡！",
}

nitian:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__nitian",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(nitian.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
})

nitian:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(nitian.name, Player.HistoryTurn) > 0 and
      (data.card.trueName == "slash" or data.card:isCommonTrick())
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(nitian.name)
    player.room:notifySkillInvoked(player, self.name, "offensive")
    data.unoffsetableList = player.room:getAllPlayers(false)
  end,
})

nitian:addEffect(fk.EventPhaseStart, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(nitian.name, Player.HistoryTurn) > 0 and
      player.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function (e)
        return e.data.killer == player
      end, Player.HistoryTurn) == 0
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke(nitian.name)
    player.room:notifySkillInvoked(player, self.name, "negative")
    player.room:killPlayer({who = player})
  end,
})

return nitian
