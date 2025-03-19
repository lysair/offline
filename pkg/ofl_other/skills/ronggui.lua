local ronggui = fk.CreateSkill {
  name = "ronggui"
}

Fk:loadTranslationTable{
  ['ronggui'] = '荣归',
  ['#ronggui-invoke'] = '荣归：你可以弃置一张基本牌，为 %src 使用的%arg增加一个目标',
  [':ronggui'] = '吴势力技，当一名吴势力角色使用【决斗】或红色【杀】指定目标时，你可以弃置一张基本牌，为此牌增加一个目标。',
}

ronggui:addEffect(fk.TargetSpecifying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ronggui.name) and target.kingdom == "wu" and
      (data.card.trueName == "duel" or (data.card.trueName == "slash" and data.card.color == Card.Red)) and
      #player.room:getUseExtraTargets(data, false, true) > 0 and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = table.filter(player:getCardIds("he"), function(id)
      local card = Fk:getCardById(id)
      return card.type == Card.TypeBasic and not player:prohibitDiscard(card)
    end)

    local to, card = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      targets = room:getUseExtraTargets(data, false, true),
      min_target_num = 1,
      max_target_num = 1,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#ronggui-invoke:"..target.id.."::"..data.card:toLogString(),
      skill_name = ronggui.name
    })

    if #to == 1 and card then
      event:setCostData(skill, {tos = to, cards = {card}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    AimGroup:addTargets(room, data, event:getCostData(skill).tos)
    room:throwCard(event:getCostData(skill).cards, ronggui.name, player, player)
  end,
})

return ronggui
