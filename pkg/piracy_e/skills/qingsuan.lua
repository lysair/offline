local qingsuan = fk.CreateSkill {
  name = "qingsuan",
  tags = { Skill.Lord, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["qingsuan"] = "清算",
  [":qingsuan"] = "主公技，锁定技，你对与你势力不同且本局游戏对你造成过伤害的角色使用牌无距离和次数限制。",
}

qingsuan:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:hasSkill(qingsuan.name) and scope == Player.HistoryPhase and to and
      player.kingdom ~= to.kingdom and table.contains(player:getTableMark("qingsuan_enemy"), to.id)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and player:hasSkill(qingsuan.name) and to and
      player.kingdom ~= to.kingdom and table.contains(player:getTableMark("qingsuan_enemy"), to.id)
  end,
})

qingsuan:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  local enemies = {}
  room.logic:getActualDamageEvents(1, function(e)
    local damage = e.data
    if damage.from and damage.to == player then
      table.insertIfNeed(enemies, damage.from.id)
    end
  end,
    Player.HistoryGame)
  room:setPlayerMark(player, "qingsuan_enemy", enemies)
end)

qingsuan:addEffect(fk.BeforeHpChanged, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(qingsuan.name, true) and
      data.reason == "damage" and data.damageEvent and data.damageEvent.from
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:addTableMarkIfNeed(player, "qingsuan_enemy", data.damageEvent.from.id)
  end,
})

return qingsuan
