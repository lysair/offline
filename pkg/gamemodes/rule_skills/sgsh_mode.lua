local rule = fk.CreateSkill {
  name = "#sgsh_mode&",
}

Fk:loadTranslationTable{
  ["#sgsh_mode&"] = "幻化",
  ["@&sgsh_deputy"] = "副将",
}

local U = require "packages/offline/ofl_util"

rule:addEffect(fk.Damaged, {
  priority = 0.001,
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead
  end,
  on_trigger = function(self, event, target, player, data)
    U.sgshAcquireDeputy(player)
  end,
})

rule:addEffect(fk.Death, {
  can_refresh = function (self, event, target, player, data)
    return target == player
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    table.insertIfNeed(room.general_pile, player.general)
    table.insertTableIfNeed(room.general_pile, player:getTableMark("@&sgsh_deputy"))
  end,
})

return rule
