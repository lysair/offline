local quanpan = fk.CreateSkill {
  name = "quanpan",
  tags = { Skill.AttachedKingdom },
  attached_kingdom = {"wu"},
}

Fk:loadTranslationTable{
  ["quanpan"] = "劝叛",
  [":quanpan"] = "吴势力技，当你获得装备牌手牌后，你可以将其中一张展示并交给一名其他角色。",

  ["#quanpan-invoke"] = "劝叛：你可以将其中一张装备牌展示并交给一名其他角色",
}

quanpan:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(quanpan.name) and #player.room:getOtherPlayers(player, false) > 0 then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).type == Card.TypeEquip and
              table.contains(player:getCardIds("h"), info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local ids = {}
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).type == Card.TypeEquip and
            table.contains(player:getCardIds("h"), info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
    local result = room:askToYiji(player, {
      cards = ids,
      targets = room:getOtherPlayers(player, false),
      skill_name = quanpan.name,
      min_num = 0,
      max_num = 1,
      prompt = "#quanpan-invoke",
      skip = true,
    })
    for id, cards in pairs(result) do
      if #cards > 0 then
        event:setCostData(self, {tos = {room:getPlayerById(id)}, cards = cards})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = event:getCostData(self).cards
    player:showCards(cards)
    if to.dead or not table.contains(player:getCardIds("h"), cards[1]) then return end
    room:moveCardTo(cards, Card.PlayerHand, to, fk.ReasonGive, quanpan.name, nil, true, player)
  end,
})

return quanpan
