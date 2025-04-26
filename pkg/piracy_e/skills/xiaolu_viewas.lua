local xiaolu_viewas = fk.CreateSkill {
  name = "ofl__xiaolu_viewas",
}

Fk:loadTranslationTable{
  ["ofl__xiaolu_viewas"] = "宵赂",
}

xiaolu_viewas:addEffect("active", {
  card_num = 1,
  min_target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom():getBanner("ofl__xiaolu"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected_cards == 1 then
      local card = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
      card.skillName = "ofl__xiaolu"
      if #selected == 0 then
        return card.skill:modTargetFilter(player, to_select, {}, card)
      elseif #selected == 1 then
        if card.skill:modTargetFilter(player, selected[1], {}, card) then
          return card.skill:getMinTargetNum(player) > 1 and card.skill:targetFilter(player, to_select, selected, {}, c)
        end
      end
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    if #selected > 0 and #selected_cards == 1 then
      local card = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
      card.skillName = "ofl__xiaolu"
      return card.skill:feasible(player, selected, {}, card)
    end
  end,
})

return xiaolu_viewas
