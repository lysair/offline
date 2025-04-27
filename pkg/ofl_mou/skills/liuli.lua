local liuli = fk.CreateSkill{
  name = "ofl_mou__liuli",
}

Fk:loadTranslationTable{
  ["ofl_mou__liuli"] = "流离",
  [":ofl_mou__liuli"] = "当你成为【杀】的目标时，你可以弃置一张牌，将目标转移给你攻击范围内除使用者以外的一名角色，令其获得“流离”标记"..
  "（若场上已有则转移给其）。有“流离”标记的角色回合开始时，移去“流离”标记并执行一个额外的出牌阶段。",

  ["#ofl_mou__liuli-choose"] = "流离：你可以弃置一张牌，将此%arg转移给一名其他角色",
  ["@@liuli_dangxian"] = "流离",

  ["$ofl_mou__liuli1"] = "战火频仍，坐困此间。",
  ["$ofl_mou__liuli2"] = "飘零复一载，何处是归程。",
}

liuli:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liuli.name) and data.card.trueName == "slash" and
      table.find(player.room.alive_players, function (p)
        return player:inMyAttackRange(p) and p ~= data.from and not data.from:isProhibited(p, data.card)
      end) and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return player:inMyAttackRange(p) and p ~= data.from and not data.from:isProhibited(p, data.card)
    end)
    local tos, cards = room:askToChooseCardsAndPlayers(player, {
      min_num = 1,
      max_num = 1,
      min_card_num = 1,
      max_card_num = 1,
      targets = targets,
      skill_name = liuli.name,
      prompt = "#ofl_mou__liuli-choose",
      cancelable = true,
      will_throw = true,
    })
    if #tos > 0 and #cards > 0 then
      event:setCostData(self, {tos = tos, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:throwCard(event:getCostData(self).cards, liuli.name, player, player)
    data:cancelTarget(player)
    data:addTarget(to)
    if not to.dead then
      for _, p in ipairs(room.alive_players) do
        room:setPlayerMark(p, "@@liuli_dangxian", 0)
      end
      room:setPlayerMark(to, "@@liuli_dangxian", 1)
    end
  end,
})

liuli:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@liuli_dangxian") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@liuli_dangxian", 0)
    player:gainAnExtraPhase(Player.Play, liuli.name)
  end,
})

return liuli
