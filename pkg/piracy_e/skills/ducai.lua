local ducai = fk.CreateSkill {
  name = "ofl__ducai",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["ofl__ducai"] = "独裁",
  [":ofl__ducai"] = "持恒技，你的回合内，你使用牌无距离次数限制，其他角色不能使用牌且所有技能失效。",

  ["$ofl__ducai"] = "Please give me a piece of pie.",
}

-- audio
ducai:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(ducai.name)
  end,
  on_refresh = function(_, _, _, player)
    local room = player.room
    player:broadcastSkillInvoke(ducai.name)
    room:notifySkillInvoked(player, ducai.name, "offensive", room:getOtherPlayers(player))
    room:doIndicate(player, room:getOtherPlayers(player))
  end,
})

ducai:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return player:hasSkill(ducai.name) and Fk:currentRoom():getCurrent() == player and card
  end,
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(ducai.name) and Fk:currentRoom():getCurrent() == player and card
  end,
})

ducai:addEffect("prohibit", {
  prohibit_use = function (self, player, card)
    return Fk:currentRoom():getCurrent() and Fk:currentRoom():getCurrent():hasSkill(ducai.name) and
      Fk:currentRoom().current ~= player and card
  end,
})

ducai:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    return Fk:currentRoom():getCurrent() and Fk:currentRoom():getCurrent():hasSkill(ducai.name) and
      Fk:currentRoom():getCurrent() ~= from and skill:isPlayerSkill(from)
  end,
})

return ducai
