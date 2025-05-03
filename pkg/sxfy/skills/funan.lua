local funan = fk.CreateSkill {
  name = "sxfy__funan",
}

Fk:loadTranslationTable{
  ["sxfy__funan"] = "复难",
  [":sxfy__funan"] = "每回合限一次，其他角色使用的牌被你抵消时，你可以获得之。",
}

funan:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(funan.name) and
      player:usedSkillTimes(funan.name, Player.HistoryTurn) == 0 and
      data.responseToEvent and data.responseToEvent.from ~= player and
      player.room:getCardArea(data.responseToEvent.card) == Card.Processing
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(data.responseToEvent.card, Card.PlayerHand, player, fk.ReasonJustMove, funan.name, nil, true, player)
  end,
})

return funan
