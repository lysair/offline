local imperial_sword_skill = fk.CreateSkill {
  name = "#imperial_sword_skill"
}

Fk:loadTranslationTable{
  ['#imperial_sword_skill'] = '尚方宝剑',
  ['imperial_sword'] = '尚方宝剑',
  ['#imperial_sword_skill-prey'] = '尚方宝剑：是否获得 %dest 一张手牌？',
  ['#imperial_sword_skill-give'] = '尚方宝剑：是否交给 %dest 一张手牌？',
  ['#imperial_sword_skill-invoke'] = '尚方宝剑：交给 %dest 一张手牌，或点“确定”获得 %dest 一张手牌',
  ['#imperial_sword-prey'] = '尚方宝剑：获得 %dest 一张手牌',
}

imperial_sword_skill:addEffect(fk.BeforeCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(imperial_sword_skill.name) then
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).name == "imperial_sword" then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.BeforeCardsMove then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        local move_info = {}
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea ~= Card.PlayerEquip or Fk:getCardById(info.cardId).name ~= "imperial_sword" then
            table.insert(move_info, info)
          end
        end
        move.moveInfo = move_info
      end
    end
  end,
})

imperial_sword_skill:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(imperial_sword_skill.name) then
      return target ~= player and target.kingdom == player.kingdom and data.card.trueName == "slash" and data.firstTarget and
        not (player:isKongcheng() and target:isKongcheng())
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if player:isKongcheng() then
      if room:askToSkillInvoke(player, {
        skill_name = imperial_sword_skill.name,
        prompt = "#imperial_sword_skill-prey::" .. target.id
      }) then
        event:setCostData(skill, {})
        return true
      end
    elseif target:isKongcheng() then
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = imperial_sword_skill.name,
        prompt = "#imperial_sword_skill-give::" .. target.id
      })
      if #card > 0 then
        event:setCostData(skill, card)
        return true
      end
    else
      local success, dat = player.room:askToUseActiveSkill(player, {
        skill_name = "choose_cards_skill",
        prompt = "#imperial_sword_skill-invoke::" .. target.id,
        cancelable = true,
        extra_data = { num = 1, min_num = 0, include_equip = false, pattern = ".", skillName = imperial_sword_skill.name }
      })
      if success then
        event:setCostData(skill, dat.cards or {})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #event:getCostData(skill) == 0 then
      room:doIndicate(player.id, {target.id})
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "h",
        skill_name = imperial_sword_skill.name,
        prompt = "#imperial_sword-prey::" .. target.id
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, imperial_sword_skill.name, nil, false, player.id)
    else
      room:moveCardTo(event:getCostData(skill), Card.PlayerHand, target, fk.ReasonGive, imperial_sword_skill.name, nil, false, player.id)
    end
  end,
})

return imperial_sword_skill
