
local lizhong = fk.CreateSkill {
  name = "lizhong&",
}

Fk:loadTranslationTable{
  ["lizhong&"] = "厉众",
  [":lizhong&"] = "你本轮内可以将装备区里的牌当【无懈可击】使用。",

  ["#lizhong&"] = "厉众：将装备区里的牌当【无懈可击】使用",
}

lizhong:addEffect("viewas", {
  anim_type = "control",
  pattern = "nullification",
  prompt = "#lizhong&",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("e"), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("nullification")
    card.skillName = lizhong.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

return lizhong
