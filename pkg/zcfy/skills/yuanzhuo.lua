local yuanzhuo = fk.CreateSkill{
  name = "yuanzhuo",
}

Fk:loadTranslationTable{
  ["yuanzhuo"] = "怨灼",
  [":yuanzhuo"] = "出牌阶段限一次，你可以弃置一名其他角色的一张牌，然后其视为对你使用一张【火攻】。",

  ["#yuanzhuo"] = "怨灼：弃置一名其他角色一张牌，其视为对你使用【火攻】",
}

yuanzhuo:addEffect("active", {
  anim_type = "control",
  prompt = "#yuanzhuo",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(yuanzhuo.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "he",
      skill_name = yuanzhuo.name,
    })
    room:throwCard(id, yuanzhuo.name, target, player)
    if player.dead or target.dead then return end
    room:useVirtualCard("fire_attack", nil, target, player, yuanzhuo.name)
  end,
})

return yuanzhuo
