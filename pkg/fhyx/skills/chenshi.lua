local chenshi = fk.CreateSkill {
  name = "ofl_shiji__chenshi",
}

Fk:loadTranslationTable{
  ["ofl_shiji__chenshi"] = "陈势",
  [":ofl_shiji__chenshi"] = "当其他角色使用<a href=':enemy_at_the_gates'>【兵临城下】</a>指定目标后，或当其他角色成为【兵临城下】的目标后，"..
  "其可以交给你一张牌，然后其观看牌堆顶三张牌并将其中任意张置入弃牌堆。",

  ["#ofl_shiji__chenshi-give"] = "陈势：你可以交给 %src 一张牌，观看牌堆顶三张牌，将其中任意张置入弃牌堆",
  ["#ofl_shiji__chenshi-discard"] = "陈势：你可以将其中任意张牌置入弃牌堆",

  ["$ofl_shiji__chenshi1"] = "博闻多智，可祛战事诸多之不利也。",
  ["$ofl_shiji__chenshi2"] = "此时不和于军，主公万不可出阵！",
}

local spec = {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chenshi.name) and data.card.trueName == "enemy_at_the_gates" and
      player ~= target and not target:isNude() and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      skill_name = chenshi.name,
      prompt = "#ofl_shiji__chenshi-give:"..player.id,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, player, fk.ReasonGive, chenshi.name, nil, false, target)
    if target.dead then return end
    local cards = room:askToChooseCards(target, {
      target = target,
      min = 0,
      max = 3,
      flag = { card_data = {{ "Top", room:getNCards(3) }} },
      skill_name = chenshi.name,
      prompt = "#ofl_shiji__chenshi-discard",
    })
    if #cards > 0 then
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, chenshi.name, nil, true, target)
    end
  end,
}

chenshi:addEffect(fk.TargetSpecified, spec)
chenshi:addEffect(fk.TargetConfirmed, spec)

return chenshi
