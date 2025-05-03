local jujian = fk.CreateSkill {
  name = "sxfy__jujian",
}

Fk:loadTranslationTable{
  ["sxfy__jujian"] = "举荐",
  [":sxfy__jujian"] = "每回合限一次，当你使用的【无懈可击】结算结束后，你可以将此牌交给一名其他角色。",

  ["#sxfy__jujian-give"] = "举荐：你可以将此%arg交给一名角色",
}

jujian:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jujian.name) and
      data.card.trueName == "nullification" and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      player.room:getCardArea(data.card) == Card.Processing and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = jujian.name,
      prompt = "#sxfy__jujian-give",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:moveCardTo(data.card, Card.PlayerHand, to, fk.ReasonGive, jujian.name, nil, true, player)
  end,
})

return jujian
