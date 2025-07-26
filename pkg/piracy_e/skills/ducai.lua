local ducai = fk.CreateSkill {
  name = "ofl__ducai",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["ofl__ducai"] = "独裁",
  [":ofl__ducai"] = "持恒技，你的回合内，你使用牌无距离次数限制，其他角色不能使用牌且所有技能失效。",
}

ducai:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(ducai.name)
  end,
  on_use = function (self, event, target, player, data)
    player.room:setBanner("ofl__ducai-turn", 1)
  end,
})

ducai:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(ducai.name) and Fk:currentRoom().current == player and card and
      Fk:currentRoom():getBanner("ofl__ducai-turn")
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(ducai.name) and Fk:currentRoom().current == player and card and
      Fk:currentRoom():getBanner("ofl__ducai-turn")
  end,
})

ducai:addEffect("prohibit", {
  prohibit_use = function (self, player, card)
    return Fk:currentRoom().current and Fk:currentRoom().current:hasSkill(ducai.name) and
      Fk:currentRoom().current ~= player and card and
      Fk:currentRoom():getBanner("ofl__ducai-turn")
  end,
})

ducai:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    return Fk:currentRoom().current and Fk:currentRoom().current:hasSkill(ducai.name) and
      Fk:currentRoom().current ~= from and skill:isPlayerSkill(from) and
      Fk:currentRoom():getBanner("ofl__ducai-turn")
  end,
})

return ducai
