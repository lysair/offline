local jimeng = fk.CreateSkill {
  name = "sxfy__jimeng",
}

Fk:loadTranslationTable{
  ["sxfy__jimeng"] = "急盟",
  [":sxfy__jimeng"] = "准备阶段，你可以交给一名角色至少一张牌，然后其交给你至少一张牌。",

  ["#sxfy__jimeng-invoke"] = "急盟：交给一名角色至少一张牌，然后其交给你至少一张牌",
  ["#sxfy__jimeng-give"] = "急盟：请交给 %dest 至少一张牌",
}

jimeng:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jimeng.name) and player.phase == Player.Start and
      not player:isNude() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to, cards = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 999,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = jimeng.name,
      prompt = "#sxfy__jimeng-invoke",
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
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, to, fk.ReasonGive, jimeng.name, nil, false, player)
    if not player.dead and not to.dead and not to:isNude() then
      local cards = room:askToCards(to, {
        min_num = 1,
        max_num = 999,
        include_equip = true,
        skill_name = jimeng.name,
        prompt = "#sxfy__jimeng-give::"..player.id,
        cancelable = false,
      })
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, jimeng.name, nil, false, to)
    end
  end,
})

return jimeng
