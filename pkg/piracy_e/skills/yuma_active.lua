local yuma_active = fk.CreateSkill {
  name = "#yuma_active",
}

Fk:loadTranslationTable{
  ["#yuma_active"] = "御马",
}

yuma_active:addEffect("active", {
  card_num = 1,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(self.expand_pile, to_select)
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected_cards == 1 and to_select:canMoveCardIntoEquip(selected_cards[1], false)
  end,
})

return yuma_active