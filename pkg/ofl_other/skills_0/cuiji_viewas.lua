local cuiji = fk.CreateSkill {
  name = "ofl__cuiji"
}

Fk:loadTranslationTable{
  ['ofl__cuiji_viewas'] = '摧击',
  ['ofl__cuiji'] = '摧击',
}

cuiji:addEffect('viewas', {
  card_filter = function(self, player, to_select, selected)
    return table.contains(player:getHandlyIds(), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards == 0 then return end
    local card = Fk:cloneCard("thunder__slash")
    card.skillName = "ofl__cuiji"
    card:addSubcards(cards)
    return card
  end,
})

return cuiji
