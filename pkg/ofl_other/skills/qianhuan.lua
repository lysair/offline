local qianhuan = fk.CreateSkill{
  name = "sgsh__qianhuan",
}

Fk:loadTranslationTable{
  ["sgsh__qianhuan"] = "千幻",
  [":sgsh__qianhuan"] = "当你受到伤害后，你可以将一张与你武将牌上花色均不同的牌置于你的武将牌上（称为“幻”）。"..
  "当你成为基本牌或锦囊牌的唯一目标时，你可以将一张“幻”置入弃牌堆，令此牌对你无效。",

  ["#sgsh__qianhuan-invoke"] = "千幻：你可以将一张与“幻”花色均不同的牌置为“幻”",
  ["#sgsh__qianhuan-nullify"] = "千幻：你可以将一张“幻”置入弃牌堆，令%arg对你无效",
  ["yuji_sorcery"] = "幻",
}

qianhuan:addEffect(fk.Damaged, {
  anim_type = "masochism",
  derived_piles = "yuji_sorcery",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qianhuan.name) and
      not player:isNude() and #player:getPile("yuji_sorcery") < 4
  end,
  on_cost = function(self, event, target, player, data)
    local card = {}
    local room = player.room
    local suits = {}
    for _, id in ipairs(player:getPile("yuji_sorcery")) do
      table.insert(suits, Fk:getCardById(id):getSuitString())
    end
    card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = qianhuan.name,
      pattern = ".|.|^(" .. table.concat(suits, ",") .. ")",
      prompt = "#sgsh__qianhuan-invoke",
      cancelable = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("yuji_sorcery", event:getCostData(self).cards, true, qianhuan.name)
  end,
})

qianhuan:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(qianhuan.name) and #player:getPile("yuji_sorcery") > 0 and
      (data.card.type == Card.TypeBasic or data.card.type == Card.TypeTrick) and data:isOnlyTarget(player)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = qianhuan.name,
      pattern = ".|.|.|yuji_sorcery",
      prompt = "#sgsh__qianhuan-nullify:::"..data.card:toLogString(),
      cancelable = true,
      expand_pile = "yuji_sorcery",
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, qianhuan.name, nil, true, player)
    data.nullified = true
  end
})

return qianhuan
