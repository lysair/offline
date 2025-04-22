local jizhong = fk.CreateSkill {
  name = "ofl__jizhong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__jizhong"] = "集众",
  [":ofl__jizhong"] = "锁定技，起义军摸牌阶段额外摸一张牌，计算与除其以外的角色距离-1。",
}

local U = require "packages/offline/pkg/piracy_e/insurrectionary_util"

jizhong:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jizhong.name) and U.isInsurrectionary(target)
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})

jizhong:addEffect("distance", {
  correct_func = function(self, from, to)
    if U.isInsurrectionary(from) then
      return -#table.filter(Fk:currentRoom().alive_players, function (p)
        return p:hasSkill(jizhong.name)
      end)
    end
  end,
})

return jizhong
