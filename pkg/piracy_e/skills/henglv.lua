local henglv = fk.CreateSkill {
  name = "henglv",
}

Fk:loadTranslationTable{
  ["henglv"] = "衡虑",
  [":henglv"] = "出牌阶段，你可以失去X点体力，弃置任意张手牌，将其中任意张【桃】分配给任意角色，然后摸等量+X张牌（X为你本回合发动此技能次数-1）。",

  ["#henglv"] = "衡虑：失去%arg点体力，弃置任意张手牌并摸等量+%arg张牌",
  ["#henglv-discard"] = "衡虑：你可以弃置任意张手牌并将【桃】分配，然后摸等量+%arg张牌",
  ["#henglv-give"] = "衡虑：你可以将弃置的【桃】任意分配",

  ["$henglv1"] = "",
  ["$henglv2"] = "",
}

henglv:addEffect("active", {
  anim_type = "control",
  prompt = function (self, player)
    return "#henglv:::"..player:usedSkillTimes(henglv.name, Player.HistoryTurn)
  end,
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    if player.hp > 0 then
      return true
    else
      return player:usedSkillTimes(henglv.name, Player.HistoryTurn) == 0
    end
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local n = math.max(player:usedSkillTimes(henglv.name, Player.HistoryTurn) - 1, 0)
    if n > 0 then
      room:loseHp(player, 1, henglv.name)
      if player:isKongcheng() or player.dead then return end
    end
    local cards = room:askToDiscard(player, {
      min_num = 1,
      max_num = 999,
      include_equip = false,
      skill_name = henglv.name,
      prompt = "#henglv-discard:::"..n,
      cancelable = true,
    })
    if #cards > 0 then
      if player.dead then return end
      local peach = table.filter(cards, function (id)
        return Fk:getCardById(id).name == "peach" and table.contains(room.discard_pile, id)
      end)
      if #peach > 0 then
        room:askToYiji(player, {
          cards = peach,
          targets = room.alive_players,
          skill_name = henglv.name,
          min_num = 0,
          max_num = 999,
          prompt = "#henglv-give",
          expand_pile = peach,
        })
        if player.dead then return end
      end
      player:drawCards(#cards + n, henglv.name)
    end
  end,
})

return henglv
