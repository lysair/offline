local qianjing_active = fk.CreateSkill {
  name = "qianjing_active",
}

Fk:loadTranslationTable{
  ["qianjing_active"] = "潜荆",
}

qianjing_active:addEffect("active", {
  card_num = 1,
  target_num = 1,
  interaction = UI.ComboBox {choices = {"WeaponSlot", "ArmorSlot", "OffensiveRideSlot", "DefensiveRideSlot", "TreasureSlot"}},
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).name == "caning_whip" and
      table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 1 and self.interaction.data and
      to_select:hasEmptyEquipSlot(Util.convertSubtypeAndEquipSlot(self.interaction.data))
  end,
})

return qianjing_active
