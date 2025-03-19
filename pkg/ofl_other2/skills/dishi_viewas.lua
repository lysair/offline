local dishi = fk.CreateSkill {
  name = "ofl__dishi"
}

Fk:loadTranslationTable{
  ['ofl__dishi_viewas'] = '地逝',
  ['ofl__dishi'] = '地逝',
}

dishi:addEffect('viewas', {
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("slash")
    card:addSubcards(player:getCardIds("h"))
    card.skillName = "ofl__dishi"
    return card
  end,
})

return dishi
