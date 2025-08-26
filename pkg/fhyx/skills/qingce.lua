local qingce = fk.CreateSkill {
  name = "fhyx__qingce",
}

Fk:loadTranslationTable{
  ["fhyx__qingce"] = "清侧",
  [":fhyx__qingce"] = "出牌阶段，你可以移去一张“荣”，然后弃置场上的一张牌。",

  ["#fhyx__qingce"] = "清侧：你可以移去一张“荣”，弃置场上的一张牌",

  ["$fhyx__qingce1"] = "奸臣当道，誓以死清君侧！",
  ["$fhyx__qingce2"] = "案师之罪，宜加大辟，以彰奸慝！",
}

qingce:addEffect("active", {
  anim_type = "control",
  prompt = "#fhyx__qingce",
  target_num = 1,
  card_num = 1,
  expand_pile = "$fhyx__glory",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getPile("$fhyx__glory"), to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #to_select:getCardIds("ej") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:moveCardTo(effect.cards, Card.DiscardPile, player, fk.ReasonPutIntoDiscardPile, qingce.name, nil, true, player)
    if player.dead or target.dead or #target:getCardIds("ej") == 0 then return end
    local card = room:askToChooseCard(player, {
      target = target,
      flag = "ej",
      skill_name = qingce.name,
    })
    room:throwCard(card, qingce.name, target, player)
  end,
})

return qingce
