local huashen = fk.CreateSkill {
  name = "sgsh__huashen",
}

Fk:loadTranslationTable{
  ["sgsh__huashen"] = "化身",
  [":sgsh__huashen"] = "出牌阶段限一次，你可以选择一名其他角色，声明其武将牌上的一个技能，你获得此技能直到回合结束。",

  ["#sgsh__huashen"] = "化身：获得一名角色武将牌上的一个技能直到回合结束",
  ["#sgsh__huashen-choice"] = "化身：选择你要获得的技能",
  ["@sgsh__huashen-turn"] = "化身",

  ["$sgsh__huashen1"] = "幻化之术谨之，为政者自当为国为民。",
  ["$sgsh__huashen2"] = "天之政者，不可逆之，逆之，虽胜必衰矣。",
}

huashen:addEffect("active", {
  name = "sgsh__huashen",
  prompt = "#sgsh__huashen",
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(huashen.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local skills = Fk.generals[target.general]:getSkillNameList()
    if Fk.generals[target.deputyGeneral] then
      table.insertTableIfNeed(skills, Fk.generals[target.deputyGeneral]:getSkillNameList())
    end
    if #target:getTableMark("@&sgsh_deputy") > 0 then
      for _, deputy in ipairs(target:getTableMark("@&sgsh_deputy")) do
        table.insertTableIfNeed(skills, Fk.generals[deputy]:getSkillNameList())
      end
    end
    skills = table.filter(skills, function(skill_name)
      local skill = Fk.skills[skill_name]
      if not player:hasSkill(skill.name, true) then
        if skill:hasTag(Skill.Lord) and player.role ~= "lord" then
          return false
        end
        if skill:hasTag(Skill.MainPlace) or skill:hasTag(Skill.DeputyPlace) then
          return false
        end
        if skill:hasTag(Skill.AttachedKingdom) and not table.contains(skill:getSkeleton().attached_kingdom, player.kingdom) then
          return false
        end
        return true
      end
    end)
    if #skills > 0 then
      local skill = room:askToChoice(player, {
        choices = skills,
        skill_name = huashen.name,
        prompt = "#sgsh__huashen-choice",
        detailed = true,
      })
      room:setPlayerMark(player, "@sgsh__huashen-turn", skill)
      room:handleAddLoseSkills(player, skill)
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        room:handleAddLoseSkills(player, "-"..skill)
      end)
    end
  end,
})

return huashen
