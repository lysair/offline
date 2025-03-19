local qingce = fk.CreateSkill {
  name = "fhyx__qingce"
}

Fk:loadTranslationTable{
  ['fhyx__qingce'] = '清侧',
  ['#fhyx__qingce'] = '清侧：你可以移去一张“荣”，弃置场上的一张牌',
  ['$fhyx__glory'] = '荣',
  [':fhyx__qingce'] = '出牌阶段，你可以移去一张“荣”，然后弃置场上的一张牌。',
}

qingce:addEffect('active', {
  anim_type = "control",
  target_num = 1,
  card_num = 1,
  prompt = "#fhyx__qingce",
  expand_pile = "$fhyx__glory",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:getPileNameOfId(to_select) == "$fhyx__glory"
  end,
  target_filter = function(self, player, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #target:getCardIds("ej") > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardTo(effect.cards, Card.DiscardPile, player, fk.ReasonPutIntoDiscardPile, skill.name, "$fhyx__glory")
    if player.dead or target.dead or #target:getCardIds("ej") == 0 then return end
    local card = room:askToChooseCard(player, {
      target = target,
      flag = "ej",
      skill_name = skill.name
    })
    room:throwCard(card, skill.name, target, player)
  end,
})

return qingce
