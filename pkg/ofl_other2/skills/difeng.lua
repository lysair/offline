local difeng = fk.CreateSkill {
  name = "ofl__difeng"
}

Fk:loadTranslationTable{
  ['ofl__difeng'] = '地锋',
  ['#ofl__difeng-invoke'] = '地锋：是否移去 %src 武将牌上一张牌，令你对 %dest 造成的伤害+1？',
  [':ofl__difeng'] = '锁定技，当一名角色将牌置于武将牌后，你与其各摸一张牌；你造成或受到伤害时，伤害来源可以弃置你武将牌上一张牌，令此伤害+1。',
}

difeng:addEffect(fk.AfterCardsMove, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(difeng.name) then
      local targets = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerSpecial and move.proposer then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea ~= Card.PlayerSpecial then
              table.insert(targets, move.proposer)
            end
          end
        end
      end
      if #targets > 0 then
        event:setCostData(skill, targets)
        return true
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local cost_data = event:getCostData(skill)
    for _, id in ipairs(cost_data) do
      if not player:hasSkill(difeng.name) then return end
      skill:doCost(event, player.room:getPlayerById(id), player, data)
    end
  end,
  on_use = function (skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(skill.name)
    room:notifySkillInvoked(player, skill.name, "drawcard")
    player:drawCards(1, difeng.name)
    if not target.dead then
      target:drawCards(1, difeng.name)
    end
  end,
})

difeng:addEffect(fk.DamageCaused, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player and data.from and not data.from.dead then
      for _, ids in pairs(player.special_cards) do
        if #ids > 0 then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    skill:doCost(event, target, player, data)
  end,
  on_use = function (skill, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, ids in pairs(player.special_cards) do
      table.insertTableIfNeed(cards, ids)
    end
    local card = room:askToCards(data.from, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = difeng.name,
      cancelable = true,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#ofl__difeng-invoke:"..player.id..":"..data.to.id,
      expand_pile = cards
    })
    if #card > 0 then
      room:notifySkillInvoked(player, skill.name, "offensive")
      data.damage = data.damage + 1
      room:moveCardTo(card[1], Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, difeng.name, nil, true, data.from.id)
    end
  end,
})

difeng:addEffect(fk.DamageInflicted, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player and data.from and not data.from.dead then
      for _, ids in pairs(player.special_cards) do
        if #ids > 0 then
          return true
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    skill:doCost(event, target, player, data)
  end,
  on_use = function (skill, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, ids in pairs(player.special_cards) do
      table.insertTableIfNeed(cards, ids)
    end
    local card = room:askToCards(data.from, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = difeng.name,
      cancelable = true,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#ofl__difeng-invoke:"..player.id..":"..data.to.id,
      expand_pile = cards
    })
    if #card > 0 then
      room:notifySkillInvoked(player, skill.name, "negative")
      data.damage = data.damage + 1
      room:moveCardTo(card[1], Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, difeng.name, nil, true, data.from.id)
    end
  end,
})

return difeng
