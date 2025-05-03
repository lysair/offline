local jinjian = fk.CreateSkill {
  name = "sxfy__jinjian",
}

Fk:loadTranslationTable{
  ["sxfy__jinjian"] = "进谏",
  [":sxfy__jinjian"] = "每回合各限一次，当你受到/造成伤害时，你可以防止此伤害，然后你本回合下次受到/造成的伤害+1。",

  ["#sxfy__jinjian1-invoke"] = "进谏：是否防止你对 %dest 造成的伤害，本回合你下次造成伤害+1？",
  ["#sxfy__jinjian2-invoke"] = "进谏：是否防止你受到的伤害，本回合你下次受到伤害+1？",
  ["@@sxfy__jinjian1-turn"] = "造成伤害+1",
  ["@@sxfy__jinjian2-turn"] = "受到伤害+1",
}

jinjian:addEffect(fk.DamageCaused, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jinjian.name) and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = jinjian.name,
      prompt = "#sxfy__jinjian1-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-1)
    player.room:setPlayerMark(player, "@@sxfy__jinjian1-turn", 1)
    data.extra_data = data.extra_data or {}
    data.extra_data.sxfy__jinjian1 = player
  end,
})

jinjian:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@@sxfy__jinjian1-turn") > 0 and
      not (data.extra_data and data.extra_data.sxfy__jinjian1 == player)
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
    player.room:setPlayerMark(player, "@@sxfy__jinjian1-turn", 0)
  end,
})

jinjian:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(jinjian.name) and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jinjian.name,
      prompt = "#sxfy__jinjian2-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-1)
    player.room:setPlayerMark(player, "@@sxfy__jinjian2-turn", 1)
    data.extra_data = data.extra_data or {}
    data.extra_data.sxfy__jinjian2 = player
  end,
})

jinjian:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@@sxfy__jinjian2-turn") > 0 and
      not (data.extra_data and data.extra_data.sxfy__jinjian2 == player)
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
    player.room:setPlayerMark(player, "@@sxfy__jinjian2-turn", 0)
  end,
})

return jinjian
