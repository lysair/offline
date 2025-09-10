local quedi = fk.CreateSkill {
  name = "sxfy__quedi",
}

Fk:loadTranslationTable{
  ["sxfy__quedi"] = "却敌",
  [":sxfy__quedi"] = "你可以将【杀】当【决斗】使用。",

  ["#sxfy__quedi"] = "却敌：你可以将【杀】当【决斗】使用",
}

quedi:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "duel",
  prompt = "#sxfy__quedi",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash"
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("duel")
    card.skillName = quedi.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
})

return quedi
