local qianjing = fk.CreateSkill {
  name = "qianjing"
}

Fk:loadTranslationTable{
  ['qianjing'] = '潜荆',
}

qianjing:addEffect('active', {
  card_num = 1,
  target_num = 1,
  interaction = function ()
    return UI.ComboBox {choices = {"WeaponSlot", "ArmorSlot", "OffensiveRideSlot", "DefensiveRideSlot", "TreasureSlot"}}
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).name == "caning_whip" and
      Fk:currentRoom():getCardArea(to_select) == Card.PlayerHand
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and #selected_cards == 1 and skill.interaction.data and
      Fk:currentRoom():getPlayerById(to_select):hasEmptyEquipSlot(Util.convertSubtypeAndEquipSlot(skill.interaction.data))
  end,
})

return qianjing
