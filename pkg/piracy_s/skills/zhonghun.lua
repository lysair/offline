local zhonghun = fk.CreateSkill{
  name = "ofl__zhonghun",
}

Fk:loadTranslationTable{
  ["ofl__zhonghun"] = "忠魂",
  [":ofl__zhonghun"] = "当你使用或打出一张红色牌时，你可以展示牌堆顶一张牌，若为红色，你获得之。",
}

local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhonghun.name) and data.card.color == Card.Red
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(1)
    room:showCards(cards)
    if Fk:getCardById(cards[1]).color == Card.Red then
      room:obtainCard(player, cards, true, fk.ReasonJustMove, player, zhonghun.name)
    end
  end,
}
zhonghun:addEffect(fk.CardUsing, spec)
zhonghun:addEffect(fk.CardResponding, spec)

return zhonghun
