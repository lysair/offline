local zhenlue = fk.CreateSkill {
  name = "ofl__zhenlue"
}

Fk:loadTranslationTable{
  ["ofl__zhenlue"] = "缜略",
  [":ofl__zhenlue"] = "当一名角色使用【无懈可击】时，你可以弃置一张牌，令此【无懈可击】无效并获得之。",

  ["#ofl__zhenlue-invoke"] = "缜略：你可以弃置一张牌，令 %dest 使用的【无懈可击】无效并获得之",
}

zhenlue:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhenlue.name) and
      data.card.trueName == "nullification" and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = zhenlue.name,
      prompt = "#ofl__zhenlue-invoke::"..target.id,
      cancelable = true,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.toCard = nil
    room:throwCard(event:getCostData(self).cards, zhenlue.name, player, player)
    if not player.dead and room:getCardArea(data.card) == Card.Processing then
      room:moveCardTo(data.card, Card.PlayerHand, player, fk.ReasonJustMove, zhenlue.name, nil, true, player)
    end
  end,
})

return zhenlue
