local xingwei = fk.CreateSkill {
  name = "xingwei",
}

Fk:loadTranslationTable{
  ["xingwei"] = "兴威",
  [":xingwei"] = "当你获得红色牌后，你可以展示之并摸一张牌；准备阶段或当你受到伤害后，你可以获得弃牌堆中的一张红色牌。",

  ["#xingwei-show"] = "兴威：是否展示获得的红色牌并摸一张牌？",
  ["#xingwei-invoke"] = "兴威：你可以获得弃牌堆中的一张红色牌",
  ["#xingwei-prey"] = "兴威：获得弃牌堆中的一张红色牌",
}

xingwei:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xingwei.name) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            if Fk:getCardById(info.cardId).color == Card.Red and
              table.contains(player:getCardIds("h"), info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xingwei.name,
      prompt = "#xingwei-show",
    })
  end,
  on_use = function (self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          if Fk:getCardById(info.cardId).color == Card.Red and
            table.contains(player:getCardIds("h"), info.cardId) then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
    player:showCards(ids)
    if not player.dead then
      player:drawCards(1, xingwei.name)
    end
  end,
})

local spec = {
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xingwei.name,
      prompt = "#xingwei-invoke",
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(room.discard_pile, function (id)
      return Fk:getCardById(id).color == Card.Red
    end)
    local card = room:askToChooseCard(player, {
      target = player,
      flag = { card_data = {{ "discard_pile", cards }} },
      skill_name = xingwei.name,
      prompt = "#xingwei-prey",
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, xingwei.name, nil, true, player)
  end,
}

xingwei:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(xingwei.name) and player.phase == Player.Start and
      table.find(player.room.discard_pile, function (id)
        return Fk:getCardById(id).color == Card.Red
      end)
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

xingwei:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(xingwei.name) and
      table.find(player.room.discard_pile, function (id)
        return Fk:getCardById(id).color == Card.Red
      end)
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

return xingwei
