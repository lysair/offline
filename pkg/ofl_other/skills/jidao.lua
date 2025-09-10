local jidao = fk.CreateSkill {
  name = "sgsh__jidao",
  tags = { Skill.MainPlace },
}

Fk:loadTranslationTable{
  ["sgsh__jidao"] = "祭祷",
  [":sgsh__jidao"] = "主将技，当一名角色的副将被移除时，你可以摸一张牌。",

  ["$sgsh__jidao"] = "含气求道，祸福难料，且与阁下共参之。",
}

local U = require "packages/offline/ofl_util"

jidao:addEffect(U.SgshLoseDeputy, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jidao.name) and player.general == "sgsh__nanhualaoxian"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, jidao.name)
  end
})

return jidao
