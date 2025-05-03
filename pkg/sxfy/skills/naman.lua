local naman = fk.CreateSkill {
  name = "sxfy__naman",
}

Fk:loadTranslationTable{
  ["sxfy__naman"] = "纳蛮",
  [":sxfy__naman"] = "出牌阶段限一次，你可以将任意张基本牌当指定等量名目标的【南蛮入侵】使用。",

  ["#sxfy__naman"] = "纳蛮：将任意张基本牌当指定等量目标的【南蛮入侵】使用",
}

naman:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sxfy__naman",
  min_card_num = 1,
  min_target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(naman.name, Player.HistoryPhase) == 0
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if Fk:getCardById(to_select).type == Card.TypeBasic then
      local card = Fk:cloneCard("savage_assault")
      card:addSubcards(selected)
      card:addSubcard(to_select)
      return not player:prohibitUse(card)
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    local card = Fk:cloneCard("savage_assault")
    card:addSubcards(selected_cards)
    return to_select ~= player and #selected < #selected_cards and
      not player:prohibitUse(card) and not player:isProhibited(to_select, card)
  end,
  feasible = function (self, player, selected, selected_cards)
    return #selected > 0 and #selected == #selected_cards
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:sortByAction(effect.tos)
    room:useVirtualCard("savage_assault", effect.cards, player, effect.tos, naman.name)
  end,
})

return naman
