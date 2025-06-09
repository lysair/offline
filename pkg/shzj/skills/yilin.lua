local yilin = fk.CreateSkill {
  name = "yilin",
}

Fk:loadTranslationTable{
  ["yilin"] = "夷临",
  [":yilin"] = "每回合每名角色限一次，当你获得其他角色的牌后，或当其他角色获得你的牌后，你可以令获得牌的角色选择是否使用其中一张牌。",

  ["#yilin-invoke"] = "夷临：你可以令 %dest 可以使用其中一张牌",
  ["#yilin-use"] = "夷临：你可以使用其中一张牌",
}

yilin:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yilin.name) then
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerHand then
          if move.from == player and move.to ~= player and
            not move.to.dead and not table.contains(player:getTableMark("yilin-turn"), move.to.id) then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                table.contains(move.to:getCardIds("h"), info.cardId) then
                return true
              end
            end
          end
          if move.to == player and move.from and move.from ~= player and
            not table.contains(player:getTableMark("yilin-turn"), player.id) then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
                table.contains(player:getCardIds("h"), info.cardId) then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, move in ipairs(data) do
      if move.toArea == Card.PlayerHand then
        if move.from == player and move.to ~= player and
          not table.contains(player:getTableMark("yilin-turn"), move.to.id) then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(move.to:getCardIds("h"), info.cardId) then
              table.insertIfNeed(targets, move.to)
              break
            end
          end
        end
        if move.to == player and move.from and move.from ~= player and
          not table.contains(player:getTableMark("yilin-turn"), player.id) then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(player:getCardIds("h"), info.cardId) then
              table.insertIfNeed(targets, player)
              break
            end
          end
        end
      end
    end
    room:sortByAction(targets)
    for _, p in ipairs(targets) do
      if not player:hasSkill(yilin.name) then break end
      if not p.dead and not table.contains(player:getTableMark("yilin-turn"), p.id) then
        event:setCostData(self, {tos = {p}})
        self:doCost(event, target, player, data)
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    return room:askToSkillInvoke(player, {
      skill_name = yilin.name,
      prompt = "#yilin-invoke::"..to.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:addTableMark(player, "yilin-turn", to.id)
    local cards = {}
    if target == player then
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerHand and move.to == player and move.from and move.from ~= player then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(player:getCardIds("h"), info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    else
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerHand and move.from == player and move.to == to then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              table.contains(to:getCardIds("h"), info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end
    cards = room.logic:moveCardsHoldingAreaCheck(cards)
    if #cards > 0 then
      room:askToUseRealCard(to, {
        pattern = cards,
        skill_name = yilin.name,
        prompt = "#yilin-use",
        cancelable = true,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
      })
    end
  end,
})

return yilin
