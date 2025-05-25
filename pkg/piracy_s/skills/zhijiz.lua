local zhijiz = fk.CreateSkill {
  name = "ofl__zhijiz",
}

Fk:loadTranslationTable{
  ["ofl__zhijiz"] = "智激",
  [":ofl__zhijiz"] = "出牌阶段限一次，你可以弃置两张手牌并选择两名势力不同的角色，这两名角色依次视为对对方使用一张【杀】。",

  ["#ofl__zhijiz"] = "智激：弃置两张手牌，选择两名势力不同的角色，这些角色视为对对方使用【杀】",
}

zhijiz:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__zhijiz",
  card_num = 2,
  target_num = 2,
  can_use = function(self, player)
    return player:usedSkillTimes(zhijiz.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected < 2 and table.contains(player:getCardIds("h"), to_select) and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      return true
    elseif #selected == 1 then
      return to_select.kingdom ~= selected[1].kingdom
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, zhijiz.name, player, player)
    room:sortByAction(effect.tos)
    if effect.tos[1].dead or effect.tos[2].dead then return end
    room:useVirtualCard("slash", nil, effect.tos[1], effect.tos[2], zhijiz.name, true)
    if effect.tos[1].dead or effect.tos[2].dead then return end
    room:useVirtualCard("slash", nil, effect.tos[2], effect.tos[1], zhijiz.name, true)
  end,
})

return zhijiz