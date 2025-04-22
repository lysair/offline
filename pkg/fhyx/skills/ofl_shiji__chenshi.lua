local ofl_shiji__chenshi = fk.CreateSkill {
  name = "ofl_shiji__chenshi"
}

Fk:loadTranslationTable{
  ['ofl_shiji__chenshi'] = '陈势',
  ['#ofl_shiji__chenshi-give'] = '陈势：你可以交给 %src 一张牌，观看牌堆顶三张牌，将其中任意张置入弃牌堆',
  ['#ofl_shijichenshidiscard'] = '陈势：你可以将其中任意张牌置入弃牌堆',
  [':ofl_shiji__chenshi'] = '当其他角色使用<a href=>【兵临城下】</a>指定目标后，或当其他角色成为【兵临城下】的目标后，其可以交给你一张牌，然后其观看牌堆顶三张牌并将其中任意张置入弃牌堆。',
}

ofl_shiji__chenshi:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl_shiji__chenshi.name) and data.card.name == "enemy_at_the_gates" and player ~= target and
      not target:isNude() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      skill_name = ofl_shiji__chenshi.name,
      prompt = "#ofl_shiji__chenshi-give:"..player.id
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, player, fk.ReasonGive, ofl_shiji__chenshi.name, nil, false, target.id)
    if target.dead then return end
    if #room.draw_pile < 3 then
      room:shuffleDrawPile()
      if #room.draw_pile < 3 then
        room:gameOver("")
      end
    end
    local cards = table.slice(room.draw_pile, 1, 4)
    local to_discard = room:askToChooseCards(target, {
      min_num = 0,
      max_num = #cards,
      target = target,
      flag = { card_data = {{"Top", cards}} },
      skill_name = ofl_shiji__chenshi.name,
      prompt = "#ofl_shijichenshidiscard"
    })
    if #to_discard > 0 then
      room:moveCardTo(to_discard, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, ofl_shiji__chenshi.name, nil, true, target.id)
    end
    room:delay(1000)
  end,
})

ofl_shiji__chenshi:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl_shiji__chenshi.name) and data.card.name == "enemy_at_the_gates" and player ~= target and
      not target:isNude() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      skill_name = ofl_shiji__chenshi.name,
      prompt = "#ofl_shiji__chenshi-give:"..player.id
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, player, fk.ReasonGive, ofl_shiji__chenshi.name, nil, false, target.id)
    if target.dead then return end
    if #room.draw_pile < 3 then
      room:shuffleDrawPile()
      if #room.draw_pile < 3 then
        room:gameOver("")
      end
    end
    local cards = table.slice(room.draw_pile, 1, 4)
    local to_discard = room:askToChooseCards(target, {
      min_num = 0,
      max_num = #cards,
      target = target,
      flag = { card_data = {{"Top", cards}} },
      skill_name = ofl_shiji__chenshi.name,
      prompt = "#ofl_shijichenshidiscard"
    })
    if #to_discard > 0 then
      room:moveCardTo(to_discard, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, ofl_shiji__chenshi.name, nil, true, target.id)
    end
    room:delay(1000)
  end,
})

return ofl_shiji__chenshi
