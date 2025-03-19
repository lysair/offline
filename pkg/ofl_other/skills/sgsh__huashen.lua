local sgsh__huashen = fk.CreateSkill {
  name = "sgsh__huashen"
}

Fk:loadTranslationTable{
  ['sgsh__huashen'] = '化身',
  ['#sgsh__huashen'] = '化身：获得一名其他角色武将牌上的一个技能，直到回合结束',
  ['#sgsh__huashen-choice'] = '化身：选择你要获得的技能',
  ['@sgsh__huashen-turn'] = '化身',
  [':sgsh__huashen'] = '出牌阶段限一次，你可以选择一名其他角色，声明其武将牌上的一个技能，你获得此技能直到回合结束。',
  ['$sgsh__huashen1'] = '幻化之术谨之，为政者自当为国为民。',
  ['$sgsh__huashen2'] = '天之政者，不可逆之，逆之，虽胜必衰矣。',
}

sgsh__huashen:addEffect('active', {
  name = "sgsh__huashen",
  prompt = "#sgsh__huashen",
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(skill.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local skills = Fk.generals[target.general]:getSkillNameList()
    if Fk.generals[target.deputyGeneral] then
      table.insertTableIfNeed(skills, Fk.generals[target.deputyGeneral]:getSkillNameList())
    end
    skills = table.filter(skills, function(skill_name)
      local skill = Fk.skills[skill_name]
      return not player:hasSkill(skill.name, true) and (#skill.attachedKingdom == 0 or table.contains(skill.attachedKingdom, player.kingdom))
    end)
    if #skills > 0 then
      local skill_choice = room:askToChoice(player, {
        choices = skills,
        skill_name = sgsh__huashen.name,
        prompt = "#sgsh__huashen-choice",
        detailed = true
      })
      room:setPlayerMark(player, "@sgsh__huashen-turn", skill_choice)
      room:handleAddLoseSkills(player, skill_choice, nil, true, false)
    end
  end,
})

sgsh__huashen:addEffect(fk.TurnEnd, {
  name = "#sgsh__huashen_delay",
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@sgsh__huashen-turn") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local skill_mark = player:getMark("@sgsh__huashen-turn")
    player.room:handleAddLoseSkills(player, "-"..skill_mark, nil, true, true)
  end,
})

return sgsh__huashen
