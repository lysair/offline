local zhuan = fk.CreateSkill {
  name = "zhuan",
}

Fk:loadTranslationTable{
  ["zhuan"] = "驻岸",
  [":zhuan"] = "出牌阶段，你可以弃置一张【杀】并获得一名其他角色装备区内一张牌。一名角色使用装备牌后，你可以摸一张牌。",

  ["#zhuan"] = "驻岸：你可以弃一张【杀】，获得一名其他角色装备区一张牌",
  ["#zhuan-prey"] = "驻岸：获得 %dest 装备区一张牌",
  ["#zhuan-draw"] = "驻岸：你可以摸一张牌",
}

zhuan:addEffect("active", {
  anim_type = "control",
  prompt = "#zhuan",
  card_num = 1,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash" and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and #to_select:getCardIds("e") > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:throwCard(effect.cards, zhuan.name, player, player)
    if player.dead or target.dead or #target:getCardIds("e") == 0 then return end
    local card = room:askToChooseCard(player, {
      target = target,
      flag = "e",
      skill_name = zhuan.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, zhuan.name, nil, true, player)
  end,
})

zhuan:addEffect(fk.CardUseFinished, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhuan.name) and data.card.type == Card.TypeEquip
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhuan.name,
      prompt = "#zhuan-draw",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, zhuan.name)
  end,
})

return zhuan
