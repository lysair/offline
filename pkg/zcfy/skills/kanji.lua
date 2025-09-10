local kanji = fk.CreateSkill {
  name = "sxfy__kanji"
}

Fk:loadTranslationTable{
  ["sxfy__kanji"] = "勘集",
  [":sxfy__kanji"] = "准备阶段，你可以展示所有手牌，若花色均不相同，你摸两张牌。",
}

kanji:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kanji.name) and player.phase == Player.Start and
      not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local cards = table.simpleClone(player:getCardIds("h"))
    if #cards == 0 then return end
    local yes = not table.find(cards, function (id)
      return table.find(cards, function (id2)
        return id ~= id2 and Fk:getCardById(id):compareSuitWith(Fk:getCardById(id2))
      end) ~= nil
    end)
    player:showCards(cards)
    if player.dead then return end
    if yes then
      player:drawCards(2, kanji.name)
    end
  end,
})

return kanji
