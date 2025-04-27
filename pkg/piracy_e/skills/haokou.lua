local haokou = fk.CreateSkill {
  name = "haokou",
  tags = { Skill.AttachedKingdom, Skill.Compulsory },
  attached_kingdom = {"qun"},
}

Fk:loadTranslationTable{
  ["haokou"] = "豪寇",
  [":haokou"] = "群势力技，锁定技，游戏开始时，你获得起义军标记；当你失去起义军标记后，你变更势力至吴。",
}

local U = require "packages/offline/ofl_util"

haokou:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(haokou.name) and not U.isInsurrectionary(player)
  end,
  on_use = function(self, event, target, player, data)
    U.joinInsurrectionary(player, haokou.name)
  end,
})

haokou:addEffect(U.QuitInsurrectionary, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(haokou.name) and player.kingdom ~= "wu"
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeKingdom(player, "wu", true)
  end,
})

return haokou

