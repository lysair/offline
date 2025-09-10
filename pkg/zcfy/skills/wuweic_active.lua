local wuweic_active = fk.CreateSkill {
  name = "#wuweic_active"
}

Fk:loadTranslationTable {
  ["#wuweic_active"] = "无为",
}

wuweic_active:addEffect("active", {
  card_num = 1,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 1 and
      to_select:canMoveCardIntoEquip(selected_cards[1], false)
  end,
})

return wuweic_active
