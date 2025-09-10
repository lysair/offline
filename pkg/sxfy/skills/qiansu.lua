local qiansu = fk.CreateSkill {
  name = "sxfy__qiansu",
}

Fk:loadTranslationTable{
  ["sxfy__qiansu"] = "谦素",
  [":sxfy__qiansu"] = "当你成为锦囊牌的目标后，若你的装备区内没有牌，你可以摸一张牌。",
}

qiansu:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qiansu.name) and
      data.card.type == Card.TypeTrick and #player:getCardIds("e") == 0
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, qiansu.name)
  end,
})

return qiansu
