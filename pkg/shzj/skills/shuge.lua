local shuge = fk.CreateSkill {
  name = "shuge",
}

Fk:loadTranslationTable{
  ["shuge"] = "戍阁",
  [":shuge"] = "每个回合结束时，你可以令至多X名蜀势力角色各摸一张牌（X为本回合你发动〖翊赞〗的次数）。",

  ["#shuge-choose"] = "戍阁：你可以令至多%arg名蜀势力角色各摸一张牌",

  ["$shuge1"] = "",
  ["$shuge2"] = "",
}

shuge:addEffect(fk.TurnEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shuge.name) and
      player:usedSkillTimes("shzj_juedai__yizan", Player.HistoryTurn) > 0 and
      table.find(player.room.alive_players, function(p)
        return p.kingdom == "shu"
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = player:usedSkillTimes("shzj_juedai__yizan", Player.HistoryTurn)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = n,
      targets = table.filter(room.alive_players, function(p)
        return p.kingdom == "shu"
      end),
      skill_name = shuge.name,
      prompt = "#shuge-choose:::"..n,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    for _, p in ipairs(event:getCostData(self).tos) do
      if not p.dead then
        p:drawCards(1, shuge.name)
      end
    end
  end,
})

return shuge
