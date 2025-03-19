local mujun = fk.CreateSkill {
  name = "ofl__mujun$"
}

Fk:loadTranslationTable{
  ['#ofl__mujun'] = '募军：你可以令一名群势力角色获得“义从”！',
}

mujun:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl__mujun",
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(mujun.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and target.kingdom == "qun" and not target:hasSkill(mujun.name, true)
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    room:handleAddLoseSkills(target, "yicong", nil, true, false)

    -- 重构askForUseActiveSkill
    room:askToUseActiveSkill(player, {
      skill_name = mujun.name,
      prompt = "#ofl__mujun",
    })
  end,
})

return mujun
