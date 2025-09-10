local minsi = fk.CreateSkill {
  name = "sxfy__minsi",
}

Fk:loadTranslationTable{
  ["sxfy__minsi"] = "敏思",
  [":sxfy__minsi"] = "出牌阶段限一次，你可以弃置任意张点数之和为13的牌，然后摸两张牌。",

  ["#sxfy__minsi"] = "敏思：弃置任意张点数之和为13的牌，摸两张牌",
}

minsi:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#sxfy__minsi",
  min_card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(minsi.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
    if not player:prohibitDiscard(to_select) then
      local num = 0
      for _, id in ipairs(selected) do
        num = num + Fk:getCardById(id).number
      end
      return num + Fk:getCardById(to_select).number <= 13
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    local num = 0
    for _, id in ipairs(selected_cards) do
      num = num + Fk:getCardById(id).number
    end
    return num == 13
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, minsi.name, player, player)
    if not player.dead then
      player:drawCards(2, minsi.name)
    end
  end,
})

return minsi
