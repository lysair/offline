local fangtong_active = fk.CreateSkill {
  name = "ofl__fangtong_active"
}

Fk:loadTranslationTable{
  ["ofl__fangtong_active"] = "方统",
}

fangtong_active:addEffect("active", {
  min_card_num = 1,
  target_num = 1,
  expand_pile = "ofl__godzhangliang_fang",
  card_filter = function (self, player, to_select, selected)
    if table.contains(player:getPile("ofl__godzhangliang_fang"), to_select) then
      local num = 0
      for _, id in ipairs(selected) do
        num = num + Fk:getCardById(id).number
      end
      return num + Fk:getCardById(to_select).number <= self.num
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  feasible = function (self, player, selected, selected_cards)
    if #selected == 1 and #selected_cards > 0 then
      local num = 0
      for _, id in ipairs(selected_cards) do
        num = num + Fk:getCardById(id).number
      end
      return num == self.num
    end
  end,
})

return fangtong_active
