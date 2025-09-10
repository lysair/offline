local skill = fk.CreateSkill {
  name = "#imperial_sword_skill",
  attached_equip = "imperial_sword",
}

Fk:loadTranslationTable{
  ["#imperial_sword_skill"] = "尚方宝剑",
  ["#imperial_sword_skill-prey"] = "尚方宝剑：是否获得 %dest 一张手牌？",
  ["#imperial_sword_skill-give"] = "尚方宝剑：是否交给 %dest 一张手牌？",
  ["#imperial_sword_skill-invoke"] = "尚方宝剑：交给 %dest 一张手牌，或直接点“确定”获得 %dest 一张手牌",
  ["#imperial_sword-prey"] = "尚方宝剑：获得 %dest 一张手牌",
}

skill:addEffect(fk.BeforeCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(skill.name) then
      for _, move in ipairs(data) do
        if move.from == player and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).name == "imperial_sword" then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip and Fk:getCardById(info.cardId).name == "imperial_sword" then
            table.insertIfNeed(ids, info.cardId)
          end
        end
      end
    end
    player.room:cancelMove(data, ids)
  end,
})

skill:addEffect(fk.TargetSpecified, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skill.name) and target ~= player and
      target.kingdom == player.kingdom and data.card.trueName == "slash" and data.firstTarget and
      not (player:isKongcheng() and target:isKongcheng())
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if player:isKongcheng() then
      if room:askToSkillInvoke(player, {
        skill_name = skill.name,
        prompt = "#imperial_sword_skill-prey::" .. target.id,
      }) then
        event:setCostData(self, {tos = {target}, cards = {}})
        return true
      end
    elseif target:isKongcheng() then
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = skill.name,
        prompt = "#imperial_sword_skill-give::" .. target.id,
        cancelable = true,
      })
      if #card > 0 then
        event:setCostData(self, {tos = {target}, cards = card})
        return true
      end
    else
      local success, dat = player.room:askToUseActiveSkill(player, {
        skill_name = "choose_cards_skill",
        prompt = "#imperial_sword_skill-invoke::" .. target.id,
        cancelable = true,
        extra_data = {
          num = 1,
          min_num = 0,
          include_equip = false,
          pattern = ".",
          skillName = skill.name,
        }
      })
      if success and dat then
        event:setCostData(self, {tos = {target}, cards = dat.cards})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #event:getCostData(self).cards == 0 then
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "h",
        skill_name = skill.name,
        prompt = "#imperial_sword-prey::" .. target.id,
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, skill.name, nil, false, player)
    else
      room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, target, fk.ReasonGive, skill.name, nil, false, player)
    end
  end,
})

return skill
