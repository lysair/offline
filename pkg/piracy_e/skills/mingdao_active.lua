local mingdao_active = fk.CreateSkill {
  name = "ofl__mingdao_active",
}

Fk:loadTranslationTable{
  ["ofl__mingdao_active"] = "瞑道",
}

local mapper = {"weapon", "armor", "defensive_horse", "offensive_horse"}

mingdao_active:addEffect("active", {
  card_num = 1,
  target_num = 0,
  expand_pile = function (self, player)
    return table.filter(Fk:currentRoom():getBanner("ofl__mingdao"), function (id)
      return not table.find(player:getCardIds("e"), function (id2)
        return Fk:getCardById(id2).trueName == "populace" and Fk:getCardById(id2).suit == Fk:getCardById(id).suit
      end)
    end)
  end,
  interaction = function(self, player)
    local choices = {}
    for _, sub_type in ipairs({3, 4, 5, 6}) do
      if player:hasEmptyEquipSlot(sub_type) then
        for _ = 1, #player:getAvailableEquipSlots(sub_type) - #player:getEquipments(sub_type), 1 do
          table.insert(choices, "type_"..mapper[sub_type - 2])
        end
      end
    end
    return UI.ComboBox { choices = choices }
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom():getBanner("ofl__mingdao"), to_select)
  end,
})

return mingdao_active
