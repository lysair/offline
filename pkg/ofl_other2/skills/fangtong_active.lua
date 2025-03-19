local fangtong = fk.CreateSkill {
  name = "ofl__fangtong"
}

Fk:loadTranslationTable{
  ['ofl__fangtong_active'] = '方统',
  ['ofl__godzhangliang_fang'] = '方',
}

fangtong:addEffect('active', {
  min_card_num = 1,
  target_num = 1,
  expand_pile = "ofl__godzhangliang_fang",
  card_filter = function (skill, player, to_select, selected)
    if table.contains(player:getPile("ofl__godzhangliang_fang"), to_select) then
      local num = 0
      for _, id in ipairs(selected) do
        num = num + Fk:getCardById(id).number
      end
      return num + Fk:getCardById(to_select).number <= player:getMark("ofl__fangtong-tmp")
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player.id
  end,
  feasible = function (skill, player, selected, selected_cards)
    if #selected == 1 and #selected_cards > 0 then
      local num = 0
      for _, id in ipairs(selected_cards) do
        num = num + Fk:getCardById(id).number
      end
      return num == player:getMark("ofl__fangtong-tmp")
    end
  end,
})

return fangtong
