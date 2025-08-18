
local juebing_viewas = fk.CreateSkill {
  name = "juebing&",
}

Fk:loadTranslationTable{
  ["juebing&"] = "谲兵",
  [":juebing&"] = "“谲兵”【杀】只能将一张非【闪】手牌当【闪】使用来响应。",

  ["#juebing&"] = "只能用一张非【闪】手牌当【闪】使用来响应“谲兵”【杀】",
}

juebing_viewas:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "jink",
  prompt = "#juebing&",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getHandlyIds(), to_select) and
      Fk:getCardById(to_select).trueName ~= "jink"
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("jink")
    c.skillName = juebing_viewas.name
    c:addSubcards(cards)
    return c
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

juebing_viewas:addAI(nil, "vs_skill")

return juebing_viewas
