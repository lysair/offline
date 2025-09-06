local mozun = fk.CreateSkill {
  name = "ofl_tx__mozun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__mozun"] = "魔尊",
  [":ofl_tx__mozun"] = "锁定技，准备阶段，你从额外牌堆、弃牌堆、所有角色的区域各随机获得一张牌并展示之；"..
  "结束阶段，你将以此法获得的牌置入弃牌堆。",

  ["@@ofl_tx__mozun-turn"] = "魔尊",
}

mozun:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(mozun.name) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    event:setCostData(self, {tos = player.room:getAlivePlayers()})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = {}
    if #room.draw_pile > 0 then
      table.insert(cards, table.random(room.draw_pile))
    end
    if #room.discard_pile > 0 then
      table.insert(cards, table.random(room.discard_pile))
    end
    if #player:getCardIds("ej") > 0 then
      table.insert(cards, table.random(player:getCardIds("ej")))
    end
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p:isAllNude() then
        table.insert(cards, table.random(p:getCardIds("hej")))
      end
    end
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, mozun.name, nil, false, player, "@@ofl_tx__mozun-turn")
    end
  end,
})

mozun:addEffect(fk.EventPhaseStart, {
  anim_type = "negative",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(mozun.name) and player.phase == Player.Finish
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("he"), function (id)
      return Fk:getCardById(id):getMark("@@ofl_tx__mozun-turn") > 0
    end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, mozun.name, nil, true, player)
    end
  end,
})

return mozun
