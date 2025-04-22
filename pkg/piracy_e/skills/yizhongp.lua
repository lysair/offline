local yizhongp = fk.CreateSkill {
  name = "yizhongp",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yizhongp"] = "倚众",
  [":yizhongp"] = "锁定技，当一名角色成为起义军后，其获得1点护甲。",
}

local U = require "packages/offline/pkg/piracy_e/insurrectionary_util"

yizhongp:addEffect(U.JoinInsurrectionary, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yizhongp.name)
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeShield(target, 1)
  end,
})

return yizhongp
