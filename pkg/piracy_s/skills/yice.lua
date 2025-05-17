local yice = fk.CreateSkill {
  name = "ofl__yice",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__yice"] = "遗策",
  [":ofl__yice"] = "锁定技，当你使用、打出或弃置的牌进入弃牌堆后，将这些牌依次置于你的武将牌上，若其中有点数相同的牌，你获得介于这两张牌"..
  "之间的牌，然后将这两张牌分别置于牌堆顶和牌堆底，并对一名角色造成1点伤害。",

  ["#ofl__yice-choose"] = "遗策：对一名角色造成1点伤害",
}

yice:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  derived_piles = yice.name,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yice.name) then
      local cards = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          elseif move.from == nil and
            table.contains({fk.ReasonUse, fk.ReasonResponse}, move.moveReason) then
            local parent_event = player.room.logic:getCurrentEvent().parent
            if parent_event ~= nil then
              local card_ids = {}
              if parent_event.event == GameEvent.UseCard or parent_event.event == GameEvent.RespondCard then
                local use = parent_event.data
                if use.from == player then
                  parent_event:searchEvents(GameEvent.MoveCards, 1, function(e2)
                    if e2.parent and e2.parent.id == parent_event.id then
                      for _, move2 in ipairs(e2.data) do
                        if (move2.moveReason == fk.ReasonUse or move2.moveReason == fk.ReasonResponse) then
                          for _, info in ipairs(move2.moveInfo) do
                            table.insertIfNeed(card_ids, info.cardId)
                          end
                        end
                      end
                    end
                  end)
                end
              end
              if #card_ids > 0 then
                for _, info in ipairs(move.moveInfo) do
                  if table.contains(card_ids, info.cardId) and info.fromArea == Card.Processing then
                    table.insertIfNeed(cards, info.cardId)
                  end
                end
              end
            end
          end
        end
      end
      cards = table.filter(cards, function (id)
        return table.contains(player.room.discard_pile, id)
      end)
      cards = player.room.logic:moveCardsHoldingAreaCheck(cards)
      if #cards > 0 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(event:getCostData(self).cards)
    player:addToPile(yice.name, cards, true, yice.name, player)
    if player.dead or #player:getPile(yice.name) < 2 then return end

    local index1, index2
    for i = 1, #player:getPile(yice.name) - 1, 1 do
      for j = #player:getPile(yice.name), i + 1, -1 do
        if Fk:getCardById(player:getPile(yice.name)[i]).number == Fk:getCardById(player:getPile(yice.name)[j]).number then
          index1, index2 = i, j
        end
      end
    end
    if index1 == nil or index2 == nil then
      return
    end
    local id1, id2 = player:getPile(yice.name)[index1], player:getPile(yice.name)[index2]
    if index2 - index1 > 1 then
      cards = table.slice(player:getPile(yice.name), index1 + 1, index2)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, yice.name, nil, true, player)
      if player.dead then return end
    end

    local moves = {}
    if table.contains(player:getPile(yice.name), id1) then
      table.insert(moves, {
      ids = {id1},
      from = player,
      fromArea = Card.PlayerSpecial,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonPut,
      skillName = yice.name,
      moveVisible = true,
      drawPilePosition = 1,
    })
    end
    if table.contains(player:getPile(yice.name), id2) then
      table.insert(moves, {
      ids = {id2},
      from = player,
      fromArea = Card.PlayerSpecial,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonPut,
      skillName = yice.name,
      moveVisible = true,
      drawPilePosition = -1,
    })
    end
    if #moves > 0 then
      room:moveCards(table.unpack(moves))
      if player.dead then return end
    end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = yice.name,
      prompt = "#ofl__yice-choose",
      cancelable = false,
    })[1]
    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = yice.name,
    }
  end,
})

return yice
