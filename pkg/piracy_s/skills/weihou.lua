local weihou = fk.CreateSkill{
  name = "ofl__weihou",
}

Fk:loadTranslationTable{
  ["ofl__weihou"] = "威侯",
  [":ofl__weihou"] = "当你进行判定时，你可以展示牌堆顶两张牌，将其中一张置入弃牌堆，另一张作为你的判定牌。",

  ["#ofl__weihou-choose"] = "威侯：将其中一张牌置入弃牌堆，另一张作为你的判定牌",
}

weihou:addEffect(fk.StartJudge, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(weihou.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(2)
    room:showCards(cards)
    local id = room:askToChooseCard(player, {
      target = player,
      flag = { card_data = {{ "Top", cards }} },
      skill_name = weihou.name,
      prompt = "#ofl__weihou-choose",
    })
    data.card = Fk:getCardById(id == cards[1] and cards[2] or cards[1])
    room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, weihou.name, nil, true, player)
  end,
})

return weihou
