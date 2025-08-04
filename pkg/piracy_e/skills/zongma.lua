local zongma = fk.CreateSkill {
  name = "ofl__zongma",
}

Fk:loadTranslationTable{
  ["ofl__zongma"] = "纵马",
  [":ofl__zongma"] = "出牌阶段开始时，你可以将一张牌当防御/进攻坐骑置入一名角色的装备区内，其受到/造成的伤害+1，"..
  "当其受到/造成伤害后将此牌置入弃牌堆。",

  ["#ofl__zongma-invoke"] = "纵马：你可以将一张牌当防御/进攻坐骑置入一名角色装备区，其受到/造成的伤害+1",
}

zongma:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zongma.name) and player.phase == Player.Play and
      not player:isNude() and table.find(player.room.alive_players, function (p)
        return p:hasEmptyEquipSlot(Card.SubtypeDefensiveRide) or p:hasEmptyEquipSlot(Card.SubtypeOffensiveRide)
      end)
    end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "#ofl__zongma_active",
      prompt = "#ofl__zongma-invoke",
    })
    if success and dat then
      event:setCostData(self, {cards = dat.cards, tos = dat.targets, choice = dat.interaction})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local cards = event:getCostData(self).cards or {}
    local card = Fk:getCardById(cards[1], true)
    local choice = event:getCostData(self).choice
    room:setCardMark(card, zongma.name, choice == "type_offensive_horse" and "dayuan" or "jueying")
    room:moveCards({
      ids = cards,
      from = player,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      proposer = player,
      skillName = zongma.name,
    })
    if not to.dead and
      ((choice == "type_offensive_horse" and to:hasEmptyEquipSlot(Card.SubtypeOffensiveRide)) or
      (choice == "type_defensive_horse" and to:hasEmptyEquipSlot(Card.SubtypeDefensiveRide))) then
      room:moveCards({
        ids = cards,
        to = to,
        toArea = Card.PlayerEquip,
        moveReason = fk.ReasonPut,
        proposer = player,
        skillName = zongma.name,
      })
    else
      room:cleanProcessingArea(cards)
    end
  end,
})

zongma:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.toArea ~= Card.PlayerEquip and move.skillName ~= zongma.name then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId, true):getMark(zongma.name) ~= 0 then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.toArea ~= Card.PlayerEquip and move.skillName ~= zongma.name then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            player.room:setCardMark(Fk:getCardById(info.cardId, true), zongma.name, 0)
          end
        end
      end
    end
  end,
})

zongma:addEffect("filter", {
  card_filter = function(self, to_select, player, isJudgeEvent)
    return to_select:getMark(zongma.name) ~= 0
    end,
  view_as = function(self, player, to_select)
    return Fk:cloneCard(to_select:getMark(zongma.name), to_select.suit, to_select.number)
  end,
})

zongma:addEffect(fk.DamageInflicted, {
  can_refresh = function (self, event, target, player, data)
    return target == player and
      table.find(player:getCardIds("e"), function (id)
        return Fk:getCardById(id, true):getMark(zongma.name) == "jueying"
      end)
  end,
  on_refresh = function (self, event, target, player, data)
    data:changeDamage(#table.filter(player:getCardIds("e"), function (id)
      return Fk:getCardById(id, true):getMark(zongma.name) == "jueying"
    end))
  end,
})

zongma:addEffect(fk.DamageCaused, {
  can_refresh = function (self, event, target, player, data)
    return target == player and
      table.find(player:getCardIds("e"), function (id)
        return Fk:getCardById(id, true):getMark(zongma.name) == "dayuan"
      end)
  end,
  on_refresh = function (self, event, target, player, data)
    data:changeDamage(#table.filter(player:getCardIds("e"), function (id)
      return Fk:getCardById(id, true):getMark(zongma.name) == "dayuan"
    end))
  end,
})

zongma:addEffect(fk.Damaged, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and
      table.find(player:getCardIds("e"), function (id)
        return Fk:getCardById(id, true):getMark(zongma.name) == "jueying"
      end)
  end,
  on_use = function (self, event, target, player, data)
    local cards = table.filter(player:getCardIds("e"), function (id)
      return Fk:getCardById(id, true):getMark(zongma.name) == "jueying"
    end)
    player.room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
  end,
})

zongma:addEffect(fk.Damage, {
  anim_type = "offensive",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and
      table.find(player:getCardIds("e"), function (id)
        return Fk:getCardById(id, true):getMark(zongma.name) == "dayuan"
      end)
  end,
  on_use = function (self, event, target, player, data)
    local cards = table.filter(player:getCardIds("e"), function (id)
      return Fk:getCardById(id, true):getMark(zongma.name) == "dayuan"
    end)
    player.room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
  end,
})

return zongma
