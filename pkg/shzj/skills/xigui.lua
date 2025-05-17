local xigui = fk.CreateSkill {
  name = "xigui",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable {
  ["xigui"] = "西归",
  [":xigui"] = "限定技，当你进入濒死状态时或一轮结束时，你可以回复体力至体力上限，若如此做，本轮结束时你失去〖诈亡〗，获得〖当先〗。",

  ["$xigui1"] = "",
  ["$xigui2"] = "",
}

local spec = {
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover({
      who = player,
      num = player.maxHp - player.hp,
      recoverBy = player,
      skillName = xigui.name,
    })
    if target ~= player then
      room.logic:getCurrentEvent():findParent(GameEvent.Round):addCleaner(function()
        room:handleAddLoseSkills(player, "-xigui|ty_ex__dangxian")
      end)
    end
  end,
}

xigui:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xigui.name) and player.dying and
      player:usedSkillTimes(xigui.name, Player.HistoryGame) == 0
  end,
  on_use = spec.on_use,
})

xigui:addEffect(fk.RoundEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xigui.name) and player:isWounded() and
      player:usedSkillTimes(xigui.name, Player.HistoryGame) == 0
  end,
  on_use = spec.on_use,
})

return xigui
