local lizhong_active = fk.CreateSkill {
  name = "lizhong_active"
}

Fk:loadTranslationTable {
  ["lizhong_active"] = "厉众",
}

lizhong_active:addEffect("active", {
  card_num = 1,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 1 and
      to_select:hasEmptyEquipSlot(Fk:getCardById(selected_cards[1]).sub_type)
  end,
})

return lizhong_active
