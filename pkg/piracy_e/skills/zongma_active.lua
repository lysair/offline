local zongma_active = fk.CreateSkill {
  name = "#ofl__zongma_active",
}

Fk:loadTranslationTable {
  ["#ofl__zongma_active"] = "纵马",
}

zongma_active:addEffect("active", {
  card_num = 1,
  target_num = 1,
  interaction = function(self, player)
    return UI.ComboBox { choices = { "type_offensive_horse", "type_defensive_horse" } }
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    if #selected == 0 then
      if self.interaction.data == "type_offensive_horse" then
        return to_select:hasEmptyEquipSlot(Card.SubtypeOffensiveRide)
      elseif self.interaction.data == "type_defensive_horse" then
        return to_select:hasEmptyEquipSlot(Card.SubtypeDefensiveRide)
      end
    end
  end,
})

return zongma_active
