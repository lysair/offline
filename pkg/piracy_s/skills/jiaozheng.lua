local jiaozheng = fk.CreateSkill{
  name = "ofl__jiaozheng",
}

Fk:loadTranslationTable{
  ["ofl__jiaozheng"] = "矫诤",
  [":ofl__jiaozheng"] = "每回合限一次，当你摸牌时，你可以改为令一名角色视为使用一张无距离限制的【杀】。",

  ["#ofl__jiaozheng-choose"] = "矫诤：你可以放弃摸牌，令一名角色视为使用无距离限制的【杀】",
  ["#ofl__jiaozheng-slash"] = "矫诤：请视为使用一张无距离限制的【杀】",
}

jiaozheng:addEffect(fk.BeforeDrawCard, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiaozheng.name) and
      player:usedSkillTimes(jiaozheng.name, Player.HistoryTurn) == 0 and
      table.find(player.room.alive_players, function (p)
        return p:canUse(Fk:cloneCard("slash"), { bypass_distances = true, bypass_times = true })
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p:canUse(Fk:cloneCard("slash"), { bypass_distances = true, bypass_times = true })
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = jiaozheng.name,
      prompt = "#ofl__jiaozheng-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.num = 0
    local to = event:getCostData(self).tos[1]
    room:askToUseVirtualCard(to, {
      name = "slash",
      skill_name = jiaozheng.name,
      prompt = "#ofl__jiaozheng-slash",
      cancelable = false,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
      },
    })
  end,
})

return jiaozheng
