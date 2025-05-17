local xinsheng = fk.CreateSkill {
  name = "sgsh__xinsheng",
  tags = { Skill.MainPlace },
}

Fk:loadTranslationTable{
  ["sgsh__xinsheng"] = "新生",
  [":sgsh__xinsheng"] = "主将技，准备阶段，你可以移除副将，然后随机获得一张未加入游戏的武将牌作为副将。",

  ["$sgsh__xinsheng1"] = "傍日月，携宇宙，游乎尘垢之外。",
  ["$sgsh__xinsheng2"] = "吾多与天地精神之往来，生即死，死又复生。",
}

local U = require "packages/offline/ofl_util"

xinsheng:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xinsheng.name) and player.phase == Player.Start and
      player.general == "sgsh__zuoci" and #player:getTableMark("@&sgsh_deputy") > 0
  end,
  on_use = function(self, event, target, player, data)
    U.sgshLoseDeputy(player)
    if not player.dead then
      U.sgshAcquireDeputy(player)
    end
  end,
})

return xinsheng
