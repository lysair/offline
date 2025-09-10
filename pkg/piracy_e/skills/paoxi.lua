local paoxi = fk.CreateSkill {
  name = "ofl__paoxi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__paoxi"] = "咆袭",
  [":ofl__paoxi"] = "锁定技，每回合各限一次，当你连续成为牌/使用牌指定目标后，你本回合下次受到/造成的伤害+1。",

  ["@@ofl__paoxi1-turn"] = "受到伤害+1",
  ["@@ofl__paoxi2-turn"] = "造成伤害+1",
}

paoxi:addEffect(fk.TargetConfirmed, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(paoxi.name) and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 then
      local info = {}
      local use_events = player.room.logic:getEventsByRule(GameEvent.UseCard, 2, function (e)
        info = {e.data.from, e.data.tos}
        return true
      end, nil, Player.HistoryTurn)
      if #use_events < 2 or #info == 0 then return end
      return table.contains(info[2], player)
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@@ofl__paoxi1-turn", 1)
  end,
})

paoxi:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(paoxi.name) and data.firstTarget and
      player:usedEffectTimes(self.name, Player.HistoryTurn) == 0 then
      local info = {}
      local events = player.room.logic:getEventsByRule(GameEvent.UseCard, 2, function (e)
        info = {e.data.from, e.data.tos}
        return true
      end, nil, Player.HistoryTurn)
      if #events < 2 or #info == 0 then return end
      return info[1] == player and #info[2] > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@@ofl__paoxi2-turn", 1)
  end,
})

paoxi:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@@ofl__paoxi1-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(player:getMark("@@ofl__paoxi1-turn"))
    player.room:setPlayerMark(player, "@@ofl__paoxi1-turn", 0)
  end,
})

paoxi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("@@ofl__paoxi2-turn") > 0
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(player:getMark("@@ofl__paoxi2-turn"))
    player.room:setPlayerMark(player, "@@ofl__paoxi2-turn", 0)
  end,
})

return paoxi
