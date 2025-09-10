local fenxun = fk.CreateSkill {
  name = "sxfy__fenxun",
}

Fk:loadTranslationTable{
  ["sxfy__fenxun"] = "奋迅",
  [":sxfy__fenxun"] = "出牌阶段限一次，你可以弃置一张防具牌并选择一名其他角色，其本回合视为在你的攻击范围内。",

  ["#sxfy__fenxun"] = "奋迅：弃置一张防具牌，令一名角色本回合视为在你的攻击范围内",
}

fenxun:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sxfy__fenxun",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(fenxun.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).sub_type == Card.SubtypeArmor and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:throwCard(effect.cards, fenxun.name, player, player)
    if player.dead or target.dead then return end
    room:addTableMarkIfNeed(player, "sxfy__fenxun-turn", target.id)
  end,
})

fenxun:addEffect("atkrange", {
  within_func = function (self, from, to)
    return table.contains(from:getTableMark("sxfy__fenxun-turn"), to.id)
  end,
})

return fenxun
