local xiaolu = fk.CreateSkill {
  name = "xiaolu"
}

Fk:loadTranslationTable{
  ['ofl__xiaolu_viewas'] = '宵赂',
  ['ofl__xiaolu'] = '宵赂',
}

xiaolu:addEffect('active', {
  card_num = 1,
  min_target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom():getBanner("ofl__xiaolu"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards, card, extra_data)
    if #selected_cards == 1 then
      local c = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
      c.skillName = "ofl__xiaolu"
      if #selected == 0 then
        return c.skill:modTargetFilter(to_select, {}, player, c, false)
      elseif #selected == 1 then
        if c.skill:modTargetFilter(selected[1], {}, player, c, false) then
          return c.skill:getMinTargetNum() > 1 and c.skill:targetFilter(to_select, selected, {}, c, extra_data, player)
        end
      end
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    if #selected > 0 and #selected_cards == 1 then
      local card = Fk:cloneCard(Fk:getCardById(selected_cards[1]).name)
      card.skillName = "ofl__xiaolu"
      return card.skill:feasible(selected, {}, player, card)
    end
  end,
})

return xiaolu
