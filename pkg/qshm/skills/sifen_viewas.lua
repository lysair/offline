local sifen_viewas = fk.CreateSkill {
  name = "sifen_viewas",
}

Fk:loadTranslationTable{
  ["sifen_viewas"] = "俟奋",
}

sifen_viewas:addEffect("viewas", {
  handly_pile = true,
  card_filter = Util.TrueFunc,
  view_as = function(self, player, cards)
    if #cards == 0 then return end
    local card = Fk:cloneCard("duel")
    card.skillName = "sifen"
    card:addSubcards(cards)
    return card
  end,
})

return sifen_viewas
