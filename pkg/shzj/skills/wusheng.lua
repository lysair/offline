
local wusheng = fk.CreateSkill {
  name = "shzj_yiling__wusheng",
}

Fk:loadTranslationTable{
  ["shzj_yiling__wusheng"] = "武圣",
  [":shzj_yiling__wusheng"] = "你可以将一张红色牌当【杀】使用或打出，你以此法使用的【杀】只能被花色相同的【闪】抵消。",

  ["#shzj_yiling__wusheng"] = "武圣：将一张红色牌当【杀】使用或打出，此【杀】只能被相同花色【闪】抵消",
}

wusheng:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#shzj_yiling__wusheng",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = wusheng.name
    c:addSubcards(cards)
    return c
  end,
})

wusheng:addEffect(fk.HandleAskForPlayCard, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(wusheng.name) and data.eventData and data.eventData.from == player and
      table.contains(data.eventData.card.skillNames, wusheng.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if not data.afterRequest then
      room:setBanner(wusheng.name, data.eventData.card.suit)
    else
      room:setBanner(wusheng.name, 0)
    end
  end,
})

wusheng:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    local suit = Fk:currentRoom():getBanner(wusheng.name)
    if card and suit then
      return card.suit ~= suit or card.suit == Card.NoSuit
    end
  end,
})

return wusheng
