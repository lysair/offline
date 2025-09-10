local taoluanh = fk.CreateSkill {
  name = "sxfy__taoluanh",
}

Fk:loadTranslationTable {
  ["sxfy__taoluanh"] = "讨乱",
  [":sxfy__taoluanh"] = "其他角色的结束阶段，你可以交给其一张牌，其展示所有手牌，然后弃置所有的【闪】。",

  ["#sxfy__taoluanh-invoke"] = "讨乱：交给 %dest 一张牌，其展示手牌并弃置所有【闪】",
}

taoluanh:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(taoluanh.name) and target.phase == Player.Finish and
      not target.dead and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = taoluanh.name,
      prompt = "#sxfy__taoluanh-invoke::"..target.id,
      cancelable = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, target, fk.ReasonGive, taoluanh.name, nil, false, player)
    if target.dead or target:isKongcheng() then return end
    target:showCards(target:getCardIds("h"))
    if target.dead or target:isKongcheng() then return end
    local cards = table.filter(target:getCardIds("h"), function(id)
      return Fk:getCardById(id).trueName == "jink" and not target:prohibitDiscard(id)
    end)
    if #cards > 0 then
      room:throwCard(cards, taoluanh.name, target, target)
    end
  end,
})

return taoluanh
