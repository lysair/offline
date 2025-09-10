local kuangcai = fk.CreateSkill {
  name = "sxfy__kuangcai",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__kuangcai"] = "狂才",
  [":sxfy__kuangcai"] = "锁定技，你于出牌阶段使用前两张牌无距离限制，结算后若造成伤害你摸一张牌，否则你弃置一张牌。",
}

kuangcai:addEffect(fk.CardUseFinished, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(kuangcai.name) and
      player.phase == Player.Play then
      local use_events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
        return e.data.from == player
      end, Player.HistoryPhase)
      return table.find(use_events, function (e)
        return e.data == data
      end)
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(kuangcai.name)
    if data.damageDealt then
      room:notifySkillInvoked(player, kuangcai.name, "drawcard")
      player:drawCards(1, kuangcai.name)
    else
      room:notifySkillInvoked(player, kuangcai.name, "negative")
      room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = kuangcai.name,
        cancelable = false,
      })
    end
  end,
})

kuangcai:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(kuangcai.name) and
      player.phase == Player.Play
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addPlayerMark(player, "sxfy__kuangcai-phase", 1)
  end,
})

kuangcai:addEffect("targetmod", {
  bypass_distances = function (self, player, skill, card, to)
    return player:hasSkill(kuangcai.name) and player.phase == Player.Play and card and player:getMark("sxfy__kuangcai-phase") < 2
  end,
})

kuangcai:addAcquireEffect(function (self, player, is_start)
  if player.phase == Player.Play then
    local room = player.room
    room.logic:getEventsOfScope(GameEvent.UseCard, 2, function (e)
      if e.data.from == player then
        room:addPlayerMark(player, "sxfy__kuangcai-phase", 1)
      end
    end, Player.HistoryPhase)
  end
end)

return kuangcai
