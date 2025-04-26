local tuonan = fk.CreateSkill {
  name = "tuonan",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["tuonan"] = "脱难",
  [":tuonan"] = "限定技，当你进入濒死状态时，你可以回复1点体力，然后失去一个有技能标签的技能。",

  ["#tuonan-choice"] = "脱难：失去一个带有标签的技能",
}

tuonan:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tuonan.name) and
      player:usedSkillTimes(tuonan.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover{
      who = player,
      num = 1,
      recoverBy = player,
      skillName = tuonan.name,
    }
    if not player.dead then
      local skills = table.filter(player:getSkillNameList(), function (s)
        return #Fk.skill_skels[s].tags > 0
      end)
      if #skills > 0 then
        local req = Request:new(player, "CustomDialog")
        req:setData(player, {
          path = "/packages/utility/qml/ChooseSkillBox.qml",
          data = { skills, 1, 1, "#tuonan-choice" },
        })
        req:setDefaultReply(player, table.random(skills, 1))
        req.focus_text = tuonan.name
        req:ask()
        skills = req:getResult(player)
        room:handleAddLoseSkills(player, "-"..skills[1])
      end
    end
  end,
})

return tuonan
