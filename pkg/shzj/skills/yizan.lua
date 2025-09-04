local yizan = fk.CreateSkill {
  name = "shzj_juedai__yizan",
}

Fk:loadTranslationTable{
  ["shzj_juedai__yizan"] = "翊赞",
  [":shzj_juedai__yizan"] = "你可以将两张牌当任意一张基本牌使用或打出。",

  ["#shzj_juedai__yizan"] = "翊赞：你可以将两张牌当任意基本牌使用或打出",

  ["$shzj_juedai__yizan1"] = "我们兄弟齐心合力，也能和父亲一样！",
  ["$shzj_juedai__yizan2"] = "这一切，都是为了护佑大汉！",
}

yizan:addEffect("viewas", {
  pattern = ".|.|.|.|.|basic",
  filter_pattern = function (self, player, card_name, selected)
    return {
      min_num = 2,
      max_num = 2,
      pattern = ".",
    }
  end,
  prompt = "#shzj_juedai__yizan",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(yizan.name, all_names)
    if #names == 0 then return end
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  handly_pile = true,
  view_as = function(self, player, cards)
    if not self.interaction.data or #cards ~= 2 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(cards)
    card.skillName = yizan.name
    return card
  end,
})

return yizan
