
local juesui = fk.CreateSkill {
  name = "juesui&",
}

Fk:loadTranslationTable{
  ["juesui&"] = "玦碎",
  [":juesui&"] = "你可以将黑色非基本牌当无次数限制的【杀】使用或打出。",

  ["#juesui&"] = "玦碎：将黑色非基本牌当无次数限制的【杀】使用或打出",
}

juesui:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#juesui&",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      local card = Fk:getCardById(to_select)
      return card.color == Card.Black and card.type ~= Card.TypeBasic
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard("slash")
    card.skillName = juesui.name
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function (self, player, use)
    use.extraUse = true
  end,
})

juesui:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return card and table.contains(card.skillNames, juesui.name)
  end,
})

return juesui
