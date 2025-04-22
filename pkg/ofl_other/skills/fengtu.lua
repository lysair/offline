local fengtu = fk.CreateSkill {
  name = "fengtu",
}

Fk:loadTranslationTable{
  ["fengtu"] = "封土",
  [":fengtu"] = "当其他角色死亡后，若其未处于休整状态，你可以令一名未以此法扣减过体力上限的角色减1点体力上限，" ..
  "然后其获得死亡角色座次每轮的额定回合。",

  ["@fengtu"] = "封土",
  ["#fengtu-choose"] = "封土：你可以令一名角色减1体力上限，获得%arg号位的额定回合",
}

fengtu:addEffect(fk.Deathed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fengtu.name) and target.rest == 0 and
      table.find(player.room.alive_players, function(p)
        return p:getMark("fengtu_lost") == 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p:getMark("fengtu_lost") == 0
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = fengtu.name,
      prompt = "#fengtu-choose:::"..target.seat,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    if room:changeMaxHp(to, -1) then
      if to.dead then return end
      room:setPlayerMark(to, "fengtu_lost", 1)
    end
    room:addTableMarkIfNeed(to, "@fengtu", target.seat)
  end,
})

fengtu:addEffect(fk.EventTurnChanging, {
  can_refresh = function (self, event, target, player, data)
    return table.contains(player:getTableMark("@fengtu"), data.to.seat)
  end,
  on_refresh = function (self, event, target, player, data)
    player:gainAnExtraTurn(false, "game_rule")
  end,
})

return fengtu
