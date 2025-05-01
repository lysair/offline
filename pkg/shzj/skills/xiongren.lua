local xiongren = fk.CreateSkill {
  name = "xiongren",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["xiongren"] = "凶刃",
  [":xiongren"] = "锁定技，你对与你距离大于1的角色使用【杀】造成伤害+1；你对与你距离不大于1的角色使用【杀】无距离次数限制。",
}

xiongren:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiongren.name) and
      data.to:distanceTo(player) > 1 and data.card and data.card.trueName == "slash" and
      player.room.logic:damageByCardEffect()
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

xiongren:addEffect(fk.PreCardUse, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(xiongren.name) and
      data.card.trueName == "slash" and
      table.find(data.tos, function (p)
        return p:distanceTo(player) > 1
      end)
  end,
  on_refresh = function (self, event, target, player, data)
    data.extraUse = true
  end,
})

xiongren:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(xiongren.name) and skill.trueName == "slash_skill" and scope == Player.HistoryPhase and
      to:distanceTo(player) <= 1
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(xiongren.name) and skill.trueName == "slash_skill" and
      to:distanceTo(player) <= 1
  end,
})

return xiongren
