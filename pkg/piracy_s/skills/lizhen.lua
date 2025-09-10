local lizhen = fk.CreateSkill {
  name = "ofl__lizhen",
}

Fk:loadTranslationTable{
  ["ofl__lizhen"] = "历阵",
  [":ofl__lizhen"] = "你可以将装备区内的牌当【杀】使用或打出。",

  ["#ofl__lizhen"] = "历阵：你可以将装备区内的牌当【杀】使用或打出",
}

lizhen:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#ofl__lizhen",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("e"), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = lizhen.name
    card:addSubcard(cards[1])
    return card
  end,
})

lizhen:addAI(nil, "vs_skill")

return lizhen
