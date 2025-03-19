local ofl__sangu_show = fk.CreateSkill {
  name = "ofl__sangu_show"
}

Fk:loadTranslationTable{
  ['ofl__sangu_show'] = '三顾',
}

ofl__sangu_show:addEffect('active', {
  min_card_num = 1,
  target_num = 0,
  card_filter = function(self, player, to_select, selected)
    local ids = player:getMark("ofl__sangu_cards")
    return ids ~= 0 and table.contains(ids, to_select) and
      table.every(selected, function(id) return Fk:getCardById(to_select).trueName ~= Fk:getCardById(id).trueName end)
  end,
})

return ofl__sangu_show
