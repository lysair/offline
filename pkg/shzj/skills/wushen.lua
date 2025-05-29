local wushen = fk.CreateSkill{
  name = "shzj_yiling__wushen",
}

Fk:loadTranslationTable {
  ["shzj_yiling__wushen"] = "武神",
  [":shzj_yiling__wushen"] = "你可以将<font color='red'>♥</font>牌当【杀】使用或打出，你以此法使用【杀】无距离次数限制且不能被响应。",

  ["#shzj_yiling__wushen"] = "武神：将<font color='red'>♥</font>牌当【杀】使用或打出（无距离次数限制、不能被响应）",
}

wushen:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#shzj_yiling__wushen",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Heart
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = wushen.name
    c:addSubcards(cards)
    return c
  end,
  before_use = function (self, player, use)
    use.extraUse = true
    use.disresponsiveList = table.simpleClone(player.room.players)
  end,
})

wushen:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and table.contains(card.skillNames, wushen.name)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and table.contains(card.skillNames, wushen.name)
  end,
})

return wushen
