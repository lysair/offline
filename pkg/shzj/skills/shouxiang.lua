local shouxiang = fk.CreateSkill {
  name = "shouxiang",
}

Fk:loadTranslationTable{
  ["shouxiang"] = "守襄",
  [":shouxiang"] = "摸牌阶段，你可以多摸X张牌，然后跳过你的出牌阶段。若如此做，此回合的弃牌阶段开始时，你可以交给至多X名角色各一张手牌"..
  "（X为攻击范围内含有你的角色数且至多为3）。",

  ["#shouxiang-invoke"] = "守襄：多摸%arg张牌并跳过出牌阶段，弃牌阶段可以将牌交给其他角色",
  ["#shouxiang-give"] = "守襄：你可以交给%arg名角色各一张手牌",
}

shouxiang:addEffect(fk.DrawNCards, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(shouxiang.name) and
      table.find(player.room.alive_players, function(p)
        return p:inMyAttackRange(player)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function(p)
      return p:inMyAttackRange(player)
    end)
    n = math.min(n, 3)
    if room:askToSkillInvoke(player, {
      skill_name = shouxiang.name,
      prompt = "#shouxiang-invoke:::"..n,
    }) then
      event:setCostData(self, {choice = n})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + event:getCostData(self).choice
    player:skip(Player.Play)
  end,
})

shouxiang:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Discard and
      player:usedSkillTimes(shouxiang.name, Player.HistoryTurn) > 0 and
      not player:isKongcheng() and
      table.find(player.room.alive_players, function(p)
        return p:inMyAttackRange(player)
      end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = #table.filter(player.room.alive_players, function(p)
      return p:inMyAttackRange(player)
    end)
    n = math.min(n, 3)
    local result = room:askToYiji(player, {
      cards = player:getCardIds("h"),
      targets = room:getOtherPlayers(player, false),
      skill_name = shouxiang.name,
      min_num = 0,
      max_num = n,
      prompt = "#shouxiang-give:::"..n,
      cancelable = true,
      skip = true,
      single_max = 1,
    })
    for _, ids in pairs(result) do
      if #ids > 0 then
        event:setCostData(self, {extra_data = result})
        return true
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:doYiji(event:getCostData(self).extra_data, player, shouxiang.name)
  end,
})

return shouxiang
