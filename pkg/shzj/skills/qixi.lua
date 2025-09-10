local qixi = fk.CreateSkill {
  name = "shzj_yiling__qixi",
}

Fk:loadTranslationTable{
  ["shzj_yiling__qixi"] = "奇袭",
  [":shzj_yiling__qixi"] = "你可以将一张黑色牌当【过河拆桥】使用；你以此法用非基本牌转化的【过河拆桥】不能被响应。",

  ["#shzj_yiling__qixi"] = "奇袭：将一张黑色牌当【过河拆桥】使用，用非基本牌转化的不能被响应",
}

qixi:addEffect("viewas", {
  anim_type = "control",
  pattern = "dismantlement",
  prompt = "#shzj_yiling__qixi",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Black
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("dismantlement")
    c.skillName = qixi.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function (self, player, use)
    if Fk:getCardById(use.card.subcards[1]).type ~= Card.TypeBasic then
      use.disresponsiveList = table.simpleClone(player.room.players)
    end
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

return qixi
