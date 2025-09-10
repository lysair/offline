local zuoyu = fk.CreateSkill {
  name = "zuoyu",
}

Fk:loadTranslationTable{
  ["zuoyu"] = "佐愈",
  [":zuoyu"] = "每回合限一次，当一名其他角色于其回合外：回复体力后，你可以加1点体力上限；失去体力后，你可以对其发动一次〖毒医〗。",

  ["#zuoyu-max"] = "佐愈：你可以加1点体力上限",
  ["#zuoyu-lose"] = "佐愈：你可以对 %dest 发动一次“毒医”",
}

zuoyu:addEffect(fk.HpRecover, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zuoyu.name) and target ~= player and player.room.current ~= target and
      player:usedSkillTimes(zuoyu.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zuoyu.name,
      prompt = "#zuoyu-max",
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeMaxHp(player, 1)
  end,
})

zuoyu:addEffect(fk.HpLost, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zuoyu.name) and target ~= player and player.room.current ~= target and
      player:usedSkillTimes(zuoyu.name, Player.HistoryTurn) == 0 and
      not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "shzj_guansuo__duyi",
      prompt = "#zuoyu-lose::"..target.id,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
        exclusive_targets = {target.id},
      },
      cancelable = true,
      skip = true,
    })
    if success and dat then
      event:setCostData(self, {extra_data = dat})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dat = event:getCostData(self).extra_data
    room:useVirtualCard(dat.interaction, dat.cards, player, dat.targets, zuoyu.name, true)
  end,
})

return zuoyu
