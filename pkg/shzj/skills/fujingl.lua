local fujingl = fk.CreateSkill {
  name = "fujingl",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fujingl"] = "蝜荆",
  [":fujingl"] = "锁定技，第一轮开始时，你翻面并摸三张牌，然后令一名其他角色获得<a href='fujingl_href'>“伏”标记</a>。",

  ["fujingl_href"] = "拥有“伏”标记的角色拥有以下技能：<br>当你每回合首次造成或受到伤害后，令你获得此标记的角色可以选择一项："..
  "1.摸一张牌；2.获得1点护甲；背水：其失去1点体力并对你发动一次〖攻心〗。",

  ["#fujingl-choose"] = "蝜荆：令一名其他角色获得“伏”标记，其每回合首次造成或受到伤害后你可以执行效果",
  ["@@fujingl"] = "伏",
  ["fujingl_shield"] = "获得1点护甲",
  ["fujingl_beishui"] = "背水：失去1点体力，对%dest发动“攻心”",
}

fujingl:addEffect(fk.RoundStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fujingl.name) and player.room:getBanner("RoundCount") == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:turnOver()
    if player.dead then return end
    player:drawCards(3, fujingl.name)
    if player.dead or #player.room:getOtherPlayers(player, false) == 0 then return end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = fujingl.name,
      prompt = "#fujingl-choose",
      cancelable = false,
    })[1]
    room:addTableMark(to, "@@fujingl", player.id)
  end,
})

local spec = {
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"draw1", "fujingl_shield", "fujingl_beishui::"..target.id, "Cancel"},
      skill_name = fujingl.name,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice ~= "fujingl_shield" then
      player:drawCards(1, fujingl.name)
      if player.dead then return end
    end
    if choice ~= "draw1" then
      room:changeShield(player, 1)
    end
    if choice:startsWith("fujingl_beishui") then
      room:loseHp(player, 1, fujingl.name)
      if player.dead or target.dead or target:isKongcheng() then return end
      local skill = Fk.skills["gongxin"]
      skill:onUse(room, {
        from = player,
        tos = {target},
      })
    end
  end,
}

fujingl:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target and table.contains(target:getTableMark("@@fujingl"), player.id) then
      local damage_events = player.room.logic:getActualDamageEvents(1, function (e)
        return e.data.from == target
      end, Player.HistoryTurn)
      return #damage_events > 0 and damage_events[1].data == data
    end
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})
fujingl:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    if table.contains(target:getTableMark("@@fujingl"), player.id) then
      local damage_events = player.room.logic:getActualDamageEvents(1, function (e)
        return e.data.to == target
      end, Player.HistoryTurn)
      return #damage_events > 0 and damage_events[1].data == data
    end
  end,
  on_cost = spec.on_cost,
  on_use = spec.on_use,
})

fujingl:addLoseEffect(function (self, player, is_death)
  if is_death then
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:removeTableMark(p, "@@fujingl", player.id)
    end
  end
end)

return fujingl
