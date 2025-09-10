local huituo = fk.CreateSkill {
  name = "sxfy__huituo",
}

Fk:loadTranslationTable{
  ["sxfy__huituo"] = "恢拓",
  [":sxfy__huituo"] = "当你受到伤害后，你可以展示牌堆顶两张牌，用任意张手牌替换等量的牌。",

  ["#sxfy__huituo-exchange"] = "恢拓：你可以用手牌替换其中的牌",
}

huituo:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(2)
    room:showCards(cards)
    if not player:isKongcheng() then
      local result = room:askToArrangeCards(player, {
        skill_name = huituo.name,
        card_map = {
          cards, player:getCardIds("h"),
          "Top", "$Hand"
        },
        prompt = "#sxfy__huituo-exchange",
        free_arrange = false,
      })
      room:swapCardsWithPile(player, result[1], result[2], huituo.name, "Top", true, player)
    end
  end,
})

return huituo
