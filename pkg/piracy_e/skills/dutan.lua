local dutan = fk.CreateSkill {
  name = "dutan",
}

Fk:loadTranslationTable{
  ["dutan"] = "独探",
  [":dutan"] = "出牌阶段限一次，你可以视为使用一张指定任意名角色为目标的【决斗】。",

  ["#dutan"] = "独探：视为使用一张指定任意名角色为目标的【决斗】",
}

dutan:addEffect("active", {
  anim_type = "offensive",
  prompt = "#dutan",
  card_num = 0,
  min_target_num = 1,
  max_target_num = 9,
  can_use = function(self, player)
    return player:usedSkillTimes(dutan.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    local card = Fk:cloneCard("duel")
    card.skillName = dutan.name
    return card.skill:modTargetFilter(player, to_select, selected, card)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = table.simpleClone(effect.tos)
    room:sortByAction(targets)
    room:useVirtualCard("duel", nil, player, targets, dutan.name)
  end,
})

return dutan
