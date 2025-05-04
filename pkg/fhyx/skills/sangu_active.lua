local sangu_active = fk.CreateSkill {
  name = "ofl__sangu_active",
}

Fk:loadTranslationTable{
  ["ofl__sangu_active"] = "三顾",
}

sangu_active:addEffect("active", {
  target_num = 0,
  expand_pile = function (self, player)
    return self.ofl__sangu
  end,
  card_filter = function(self, player, to_select, selected)
    return table.contains(self.ofl__sangu, to_select) and
      (Fk:getCardById(to_select).type == Card.TypeBasic or Fk:getCardById(to_select):isCommonTrick()) and
      table.every(selected, function(id)
        return Fk:getCardById(to_select).trueName ~= Fk:getCardById(id).trueName
      end)
  end,
})

return sangu_active
