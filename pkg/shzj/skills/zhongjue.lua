local zhongjue = fk.CreateSkill{
  name = "zhongjue",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["zhongjue"] = "忠绝",
  [":zhongjue"] = "锁定技，游戏开始时，你令一名其他角色本局游戏使用牌无次数限制，然后其获得武将牌上的一个主公技。",

  ["@@zhongjue"] = "忠绝",
  ["#zhongjue-choose"] = "忠绝：选择一名角色，其使用牌无次数限制并获得武将牌上的主公技",
  ["#zhongjue-choice"] = "忠绝：获得武将牌上的一个主公技",
}

zhongjue:addEffect(fk.GameStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhongjue.name) and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = zhongjue.name,
      prompt = "#zhongjue-choose",
      cancelable = false,
    })[1]
    room:setPlayerMark(to, "@@zhongjue", 1)
    room:setPlayerMark(player, zhongjue.name, to.id)
    local skills = {}
    for _, s in ipairs(Fk.generals[to.general]:getSkillNameList(true)) do
      if Fk.skills[s]:hasTag(Skill.Lord) and not to:hasSkill(s, true) then
        table.insertIfNeed(skills, s)
      end
    end
    if to.deputyGeneral ~= "" then
      for _, s in ipairs(Fk.generals[to.deputyGeneral]:getSkillNameList(true)) do
        if Fk.skills[s]:hasTag(Skill.Lord) and not to:hasSkill(s, true) then
          table.insertIfNeed(skills, s)
        end
      end
    end
    if #skills > 0 then
      local choice = skills[1]
      if #skills > 1 then
        choice = room:askToCustomDialog(to, {
          skill_name = zhongjue.name,
          qml_path = "packages/utility/qml/ChooseSkillBox.qml",
          extra_data = {
            skills, 1, 1, "#zhongjue-choice",
          },
        })[1]
      end
      room:handleAddLoseSkills(to, choice)
    end
  end,
})

zhongjue:addEffect("targetmod", {
  bypass_times = function (self, player, skill, scope, card, to)
    return player:getMark("@@zhongjue") > 0 and card
  end,
})

return zhongjue
