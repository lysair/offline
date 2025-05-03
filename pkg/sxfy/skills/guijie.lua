local guijie = fk.CreateSkill{
  name = "sxfy__guijie",
}

Fk:loadTranslationTable{
  ["sxfy__guijie"] = "瑰杰",
  [":sxfy__guijie"] = "你可以弃置两张红色牌，然后摸一张牌，视为使用或打出一张【闪】。",

  ["#sxfy__guijie"] = "锦织：弃置两张红色牌，然后摸一张牌，视为使用或打出一张【闪】",
}

guijie:addEffect("viewas", {
  anim_type = "defensive",
  pattern = "jink",
  prompt = "#sxfy__guijie",
  card_filter = function (self, player, to_select, selected)
    return #selected < 2 and Fk:getCardById(to_select).color == Card.Red and not player:prohibitDiscard(to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 2 then return end
    local card = Fk:cloneCard("jink")
    card.skillName = guijie.name
    self.cost_data = cards
    return card
  end,
  before_use = function(self, player)
    player.room:throwCard(self.cost_data, guijie.name, player, player)
    if not player.dead then
      player:drawCards(1, guijie.name)
    end
  end,
})

return guijie
