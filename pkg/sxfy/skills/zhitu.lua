local zhitu = fk.CreateSkill {
  name = "sxfy__zhitu",
}

Fk:loadTranslationTable{
  ["sxfy__zhitu"] = "制图",
  [":sxfy__zhitu"] = "你可以将至少两张点数之和为13的牌当任意普通锦囊牌使用。",

  ["#sxfy__zhitu"] = "制图：将至少两张点数之和为13的牌当任意普通锦囊牌使用",
}

zhitu:addEffect("viewas", {
  pattern = ".|.|.|.|.|trick",
  prompt = "#sxfy__zhitu",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("t")
    local names = player:getViewAsCardNames(zhitu.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if Fk:getCardById(to_select).number < 13 then
      local num = 0
      for _, id in ipairs(selected) do
        num = num + Fk:getCardById(id).number
      end
      return num + Fk:getCardById(to_select).number <= 13
    end
  end,
  view_as = function (self, player, cards)
    if #cards < 2 or self.interaction.data == nil then return end
    local num = 0
    for _, id in ipairs(cards) do
      num = num + Fk:getCardById(id).number
    end
    if num ~= 13 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = zhitu.name
    return card
  end,
  enabled_at_response = function(self, player, response)
    return not response and #player:getViewAsCardNames(zhitu.name, Fk:getAllCardNames("t")) > 0
  end,
})

return zhitu
