local mujun = fk.CreateSkill {
  name = "ofl__mujun",
  tags = { Skill.Lord, Skill.Limited },
}

Fk:loadTranslationTable{
  ["ofl__mujun"] = "募军",
  [":ofl__mujun"] = "主公技，限定技，出牌阶段，你可以令一名群势力角色获得〖义从〗。",

  ["#ofl__mujun"] = "募军：你可以令一名群势力角色获得“义从”！",
}

mujun:addEffect("active", {
  anim_type = "support",
  prompt = "#ofl__mujun",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(mujun.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select.kingdom == "qun" and not to_select:hasSkill("yicong", true)
  end,
  on_use = function(self, room, effect)
    room:handleAddLoseSkills(effect.tos[1], "yicong")
  end,
})

return mujun
