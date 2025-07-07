local suirenq = fk.CreateSkill {
  name = "sxfy__suirenq",
}

Fk:loadTranslationTable{
  ["sxfy__suirenq"] = "随认",
  [":sxfy__suirenq"] = "你死亡时，你可以将所有手牌交给一名其他角色。",

  ["#sxfy__suirenq-choose"] = "随认：你可以将所有手牌交给一名其他角色",
}

suirenq:addEffect(fk.Death, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(suirenq.name, false, true) and
      not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#sxfy__suirenq-choose",
      skill_name = suirenq.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:moveCardTo(player:getCardIds("h"), Card.PlayerHand, to, fk.ReasonGive, suirenq.name, nil, false, player)
  end,
})

return suirenq
