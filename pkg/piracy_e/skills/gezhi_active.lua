local gezhi_active = fk.CreateSkill{
  name = "ofl__gezhi_active",
}

Fk:loadTranslationTable{
  ["ofl__gezhi_active"] = "革制",
}

gezhi_active:addEffect("active", {
  card_num = 3,
  target_num = 0,
  card_filter = function(self, player, to_select, selected)
    return table.every(selected, function(id)
      return Fk:getCardById(to_select).type ~= Fk:getCardById(id).type
    end)
  end,
})

return gezhi_active
