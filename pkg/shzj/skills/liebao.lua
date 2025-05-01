local liebao = fk.CreateSkill {
  name = "liebao",
}

Fk:loadTranslationTable{
  ["liebao"] = "烈报",
  [":liebao"] = "一名角色成为【杀】的目标后，若其手牌数最少，你可以摸一张牌，代替其成为目标，若此【杀】未对你造成伤害，其回复1点体力。",

  ["#liebao-self"] = "烈报：你可以摸一张牌，若此【杀】未对你造成伤害，你回复1点体力",
  ["#liebao-invoke"] = "烈报：你可以摸一张牌，代替 %dest 成为此【杀】目标，若未对你造成伤害其回复1点体力",
}

liebao:addEffect(fk.TargetConfirmed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(liebao.name) and data.card.trueName == "slash" and
      data.from ~= player and
      table.every(player.room.alive_players, function (p)
      return p:getHandcardNum() >= target:getHandcardNum()
    end)
  end,
  on_cost = function (self, event, target, player, data)
    local prompt = (target == player) and "#liebao-self" or "#liebao-invoke::"..target.id
    if player.room:askToSkillInvoke(player, {
      skill_name = liebao.name,
      prompt = prompt,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    data:cancelTarget(target)
    data.extra_data = data.extra_data or {}
    data.extra_data.liebao = {player, target}
    if not data.from:isProhibited(player, data.card) then
      table.insert(data.tos[AimData.Done], player)
      table.insert(data.use.tos, player)
    end
    player:drawCards(1, liebao.name)
  end,
})

liebao:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.card.trueName == "slash" and
      data.extra_data and data.extra_data.liebao and data.extra_data.liebao[1] == player and
      not (data.damageDealt and data.damageDealt[player]) and
      data.extra_data.liebao[2]:isWounded() and not data.extra_data.liebao[2].dead
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.extra_data.liebao[2]}})
    return true
  end,
  on_use = function (self, event, target, player, data)
    player.room:recover({
      who = data.extra_data.liebao[2],
      num = 1,
      recoverBy = player,
      skillName = liebao.name,
    })
  end,
})

return liebao
