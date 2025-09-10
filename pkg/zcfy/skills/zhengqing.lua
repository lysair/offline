local zhengqing = fk.CreateSkill {
  name = "sxfy__zhengqing",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__zhengqing"] = "争擎",
  [":sxfy__zhengqing"] = "锁定技，当【杀】或【决斗】造成伤害时，伤害来源将之置于武将牌上，称为“擎”。每轮结束时，你移去场上所有“擎”，"..
  "被移去数最多的角色摸X张牌（X为其移去的“擎”数，至多为3）。",
}

zhengqing:addEffect(fk.DamageCaused, {
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(zhengqing.name) and target and
      data.card and table.contains({"slash", "duel"}, data.card.trueName) and
      not target.dead and player.room:getCardArea(data.card) == Card.Processing
  end,
  on_use = function (self, event, target, player, data)
    target:addToPile(zhengqing.name, data.card, true, zhengqing.name, target)
  end,
})

zhengqing:addEffect(fk.RoundEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhengqing.name) and
      table.find(player.room.alive_players, function (p)
        return #p:getPile(zhengqing.name) > 0
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mapper, max = {}, 0
    for _, p in ipairs(room:getAlivePlayers()) do
      local cards = p:getPile(zhengqing.name)
      if #cards > 0 then
        mapper[p] = #cards
        max = math.max(max, #cards)
        room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, zhengqing.name, nil, true, player)
      end
    end
    local targets = {}
    for p, n in pairs(mapper) do
      if n == max then
        table.insert(targets, p)
      end
    end
    room:sortByAction(targets)
    max = math.min(max, 3)
    for _, p in ipairs(targets) do
      if not p.dead then
        p:drawCards(max, zhengqing.name)
      end
    end
  end,
})

zhengqing:addLoseEffect(function (self, player, is_death)
  local room = player.room
  for _, p in ipairs(room:getAlivePlayers()) do
    room:moveCardTo(p:getPile(zhengqing.name), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile)
  end
end)

return zhengqing
