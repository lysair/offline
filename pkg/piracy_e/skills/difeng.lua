local difeng = fk.CreateSkill {
  name = "ofl__difeng",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__difeng"] = "地锋",
  [":ofl__difeng"] = "锁定技，当一名角色将牌置于武将牌后，你与其各摸一张牌；你造成或受到伤害时，伤害来源可以弃置你武将牌上一张牌，令此伤害+1。",

  ["#ofl__difeng1-invoke"] = "地锋：是否移去武将牌上一张牌，令你对 %dest 造成的伤害+1？",
  ["#ofl__difeng2-invoke"] = "地锋：是否移去 %src 武将牌上一张牌，令你对其造成的伤害+1？",
}

difeng:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(difeng.name) then
      local targets = {}
      for _, move in ipairs(data) do
        if move.toArea == Card.PlayerSpecial and move.proposer then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea ~= Card.PlayerSpecial then
              table.insertIfNeed(targets, move.proposer)
            end
          end
        end
      end
      if #targets > 0 then
        event:setCostData(self, {extra_data = targets})
        return true
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local tos = table.simpleClone(event:getCostData(self).extra_data)
    player.room:sortByAction(tos)
    for _, p in ipairs(tos) do
      if not player:hasSkill(difeng.name) then return end
      event:setCostData(self, {tos = {p}})
      self:doCost(event, target, player, data)
    end
  end,
  on_use = function (self, event, target, player, data)
    local to = event:getCostData(self).tos[1]
    player:drawCards(1, difeng.name)
    if not to.dead then
      to:drawCards(1, difeng.name)
    end
  end,
})

difeng:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(difeng.name) then
      for _, ids in pairs(player.special_cards) do
        if #ids > 0 then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, ids in pairs(player.special_cards) do
      table.insertTableIfNeed(cards, ids)
    end
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = difeng.name,
      cancelable = true,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#ofl__difeng1-invoke::"..data.to.id,
      expand_pile = cards,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {data.to}, cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(1)
    local card = event:getCostData(self).cards
    player.room:moveCardTo(card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, difeng.name, nil, true, player)
  end,
})

difeng:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(difeng.name) and data.from and not data.from.dead then
      for _, ids in pairs(player.special_cards) do
        if #ids > 0 then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
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
      prompt = "#ofl__difeng2-invoke:"..player.id,
      expand_pile = cards,
    })
    if #card > 0 then
      room:doIndicate(data.from, {player})
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(1)
    local card = event:getCostData(self).cards
    player.room:moveCardTo(card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, difeng.name, nil, true, data.from)
  end,
})

return difeng
