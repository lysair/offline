
local shezuo_viewas = fk.CreateSkill {
  name = "shezuo_viewas",
}

Fk:loadTranslationTable{
  ["shezuo_viewas"] = "设座",
}

shezuo_viewas:addEffect("viewas", {
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("t")
    local names = player:getViewAsCardNames("shezuo", all_names, player:getCardIds("h"))
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(player:getCardIds("h"))
    card.skillName = "shezuo"
    return card
  end,
})

return shezuo_viewas
