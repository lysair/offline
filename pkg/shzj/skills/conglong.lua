local conglong = fk.CreateSkill {
  name = "conglong",
}

Fk:loadTranslationTable{
  ["conglong"] = "从龙",
  [":conglong"] = "当一名角色使用红色【杀】时，你可以弃置一张锦囊牌，令此【杀】不能被响应。当红色【杀】对一名角色造成伤害时，你可以弃置一张"..
  "装备牌，令此伤害+1。每回合结束时，若你本回合弃置过至少两张牌，你可以摸一张牌。",

  ["#conglong1-invoke"] = "从龙：你可以弃置一张锦囊牌，令 %dest 使用的%arg不能被响应",
  ["#conglong2-invoke"] = "从龙：你可以弃置一张装备牌，%arg对 %dest 造成的伤害+1",
  ["#conglong3-invoke"] = "从龙：是否摸一张牌？",
}

conglong:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(conglong.name) and
      data.card.trueName == "slash" and data.card.color == Card.Red and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = conglong.name,
      cancelable = true,
      pattern = ".|.|.|.|.|trick",
      prompt = "#conglong1-invoke::" .. target.id,
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {target}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(event:getCostData(self).cards, conglong.name, player, player)
    data.disresponsiveList = table.simpleClone(player.room.players)
  end,
})

conglong:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(conglong.name) and
      data.card and data.card.trueName == "slash" and data.card.color == Card.Red and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = conglong.name,
      cancelable = true,
      pattern = ".|.|.|.|.|equip",
      prompt = "#conglong2-invoke::"..data.to.id..":"..data.card:toLogString(),
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = {data.to}, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(event:getCostData(self).cards, conglong.name, player, player)
    data:changeDamage(1)
  end,
})

conglong:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(conglong.name) then
      local x = 0
      local logic = player.room.logic
      logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player and move.moveReason == fk.ReasonDiscard then
            x = x + #move.moveInfo
            if x > 1 then return true end
          end
        end
      end, Player.HistoryTurn)
      return x > 1
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = conglong.name,
      prompt = "#conglong3-invoke",
    })
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(1, conglong.name)
  end,
})

return conglong
