local jiuchi = fk.CreateSkill{
  name = "ofl_tx__jiuchi",
}

Fk:loadTranslationTable{
  ["ofl_tx__jiuchi"] = "酒池",
  [":ofl_tx__jiuchi"] = "你可以将黑色牌当【酒】使用。你使用【酒】无次数限制。",

  ["#ofl_tx__jiuchi"] = "酒池：你可以将黑色牌当【酒】使用",
}

jiuchi:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "analeptic",
  prompt = "#ofl_tx__jiuchi",
  handly_pile = true,
  filter_pattern = {
    min_num = 1,
    max_num = 1,
    pattern = ".|.|black",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("analeptic")
    c.skillName = jiuchi.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

jiuchi:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card)
    return player:hasSkill(jiuchi.name) and card and card.name == "analeptic" and scope == Player.HistoryTurn
  end,
})

return jiuchi