local hengwu = fk.CreateSkill {
  name = "ofl__hengwu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__hengwu"] = "横骛",
  [":ofl__hengwu"] = "锁定技，有“骏”/“骊”的角色获得“骏”/“骊”后，你摸X张牌（X为其拥有该标记的数量）。",

  ["$ofl__hengwu1"] = "此身独傲，天下无不可敌之人，无不可去之地！",
  ["$ofl__hengwu2"] = "神威天降，世间无不可驭之雷，无不可降之马！",
}

local U = require "packages/offline/ofl_util"

hengwu:addEffect(U.OflShouliMarkChanged, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(hengwu.name)
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(data.n, hengwu.name)
  end,
})

return hengwu
