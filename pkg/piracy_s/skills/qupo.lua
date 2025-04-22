local qupo = fk.CreateSkill({
  name = "ofl__qupo",
})

Fk:loadTranslationTable{
  ["ofl__qupo"] = "驱魄",
  [":ofl__qupo"] = "一名角色回合开始时，你可以将一张牌交给另一名其他角色，若此牌为：黑色，当前回合角色使用【杀】不指定该角色为目标时，"..
  "当前回合角色失去1点体力；红色，该角色本回合首次受到伤害时，其失去1点体力。",

  ["#ofl__qupo-invoke"] = "权弈：将一张牌交给一名角色，根据颜色执行效果：<br>"..
  "黑色，%dest 使用【杀】不指定其为目标则失去体力<br>红色，目标首次受到伤害时失去体力",
  ["@ofl__qupo-turn"] = "驱魄",
}

qupo:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(qupo.name) and not player:isNude() and
      table.find(player.room.alive_players, function (p)
        return p ~= player and p ~= target
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p ~= player and p ~= target
    end)
    local to, cards = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = qupo.name,
      prompt = "#ofl__qupo-invoke::"..target.id,
      cancelable = true,
    })
    if #to > 0 and #cards > 0 then
      event:setCostData(self, {tos = to, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = event:getCostData(self).cards[1]
    local color = Fk:getCardById(card):getColorString()
    room:moveCardTo(card, Card.PlayerHand, to, fk.ReasonJustMove, qupo.name, nil, false, player)
    if to.dead then return end
    if color == "black" then
      room:addTableMarkIfNeed(target, "ofl__qupo-turn", to.id)
    elseif color ~= "nocolor" then
      room:addTableMarkIfNeed(to, "@ofl__qupo-turn", color)
    end
  end,
})

qupo:addEffect(fk.TargetSpecifying, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("ofl__qupo-turn") ~= 0 and
      data.card.trueName == "slash" and data.firstTarget and
      player.room.current == player and
      table.find(player:getTableMark("ofl__qupo-turn"), function (id)
        return not table.contains(data.use.tos, player.room:getPlayerById(id))
      end)
  end,
  on_use = function (self, event, target, player, data)
    player.room:loseHp(player, 1, qupo.name)
  end,
})

qupo:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and table.contains(player:getTableMark("@ofl__qupo-turn"), "red") and
      player:usedSkillTimes(self.name, Player.HistoryTurn) == 0
  end,
  on_use = function (self, event, target, player, data)
    player.room:loseHp(player, 1, qupo.name)
  end,
})

return qupo
