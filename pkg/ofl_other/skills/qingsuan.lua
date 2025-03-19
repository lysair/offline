local qingsuan = fk.CreateSkill {
  name = "qingsuan$"
}

Fk:loadTranslationTable{ }

qingsuan:addEffect('targetmod', {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:hasSkill(qingsuan.name) and scope == Player.HistoryPhase and to and
      player.kingdom ~= to.kingdom and table.contains(player:getTableMark("qingsuan_enemy"), to.id)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and player:hasSkill(qingsuan.name) and to and
      player.kingdom ~= to.kingdom and table.contains(player:getTableMark("qingsuan_enemy"), to.id)
  end,

  on_acquire = function (skill, player, is_start)
    local room = player.room
    local enemies = {}
    room.logic:getActualDamageEvents(1, function(e)
      local damage = e.data[1]
      if damage.from and damage.to == player then
        table.insertIfNeed(enemies, damage.from.id)
      end
    end,
      Player.HistoryGame)
    room:setPlayerMark(player, "qingsuan_enemy", enemies)
  end,
})

qingsuan:addEffect('refresh', {
  event = fk.BeforeHpChanged,
  can_refresh = function (skill, player, target, data)
    return target == player and player:hasSkill(qingsuan.name, true) and
      data.reason == "damage" and data.damageEvent and data.damageEvent.from
  end,
  on_refresh = function (skill, player, target, data)
    local enemies = player:getTableMark("qingsuan_enemy")
    table.insertIfNeed(enemies, data.damageEvent.from.id)
    player.room:setPlayerMark(player, "qingsuan_enemy", enemies)
  end,
})

return qingsuan
