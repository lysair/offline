local yimou = fk.CreateSkill{
  name = "sxfy__yimou",
}

Fk:loadTranslationTable{
  ["sxfy__yimou"] = "毅谋",
  [":sxfy__yimou"] = "当你受到伤害后，你可以将一张牌交给一名其他角色。",

  ["#sxfy__yimou-give"] = "毅谋：你可以将一张牌交给一名其他角色",
}

yimou:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yimou.name) and
      not player:isNude() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to, cards = room:askToChooseCardsAndPlayers(target, {
      min_card_num = 1,
      max_card_num = 1,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(target, false),
      skill_name = yimou.name,
      prompt = "#sxfy__yimou-give",
      cancelable = true,
    })
    if #to > 0 and #cards > 0 then
      event:setCostData(self, {tos = to, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = event:getCostData(self).cards
    room:moveCardTo(cards, Player.Hand, to, fk.ReasonGive, yimou.name, nil, false, player)
  end,
})

return yimou
