local zhuhun = fk.CreateSkill({
  name = "ofl_tx__zhuhun",
})

Fk:loadTranslationTable{
  ["ofl_tx__zhuhun"] = "注魂",
  [":ofl_tx__zhuhun"] = "出牌阶段限一次，你可以令一名已死亡友方角色复活为长怨尸兵。",

  ["#ofl_tx__zhuhun"] = "注魂：令一名已死亡友方角色复活为长怨尸兵！",
  ["ofl_tx__zhuhun_seat"] = "%arg（%arg2号位）",
}

zhuhun:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl_tx__zhuhun",
  card_num = 0,
  target_num = 0,
  interaction = function (self, player)
    local choices = {}
    for _, p in ipairs(Fk:currentRoom().players) do
      if p.dead and p:isFriend(player) then
        table.insert(choices, "ofl_tx__zhuhun_seat:::"..p.general..":"..p.seat)
      end
    end
    return UI.ComboBox{ choices = choices }
  end,
  can_use = function (self, player)
    return player:usedSkillTimes(zhuhun.name, Player.HistoryPhase) == 0 and
      table.find(Fk:currentRoom().players, function (p)
        return p.dead and p:isFriend(player)
      end)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local seat = string.split(self.interaction.data, ":")[5]
    local target = room:getPlayerBySeat(tonumber(seat))
    room:doIndicate(player, {target})
    room:setPlayerProperty(target, "general", "ofl_tx__zombie")
    room:setPlayerProperty(target, "deputyGeneral", "")
    room:setPlayerProperty(target, "kingdom", "qun")
    room:setPlayerProperty(target, "dead", false)
    target._splayer:setDied(false)
    room:setPlayerProperty(target, "dying", false)
    room:setPlayerProperty(target, "maxHp", 3)
    room:setPlayerProperty(target, "hp", 3)
    table.insertIfNeed(room.alive_players, target)
    room:sendLog {
      type = "#Revive",
      from = target.id,
    }
    local skills = table.map(target:getSkillNameList(), function (s)
      return "-"..s
    end)
    table.insert(skills, "ofl_tx__shiyuan")
    room:handleAddLoseSkills(target, table.concat(skills, "|"), nil, false)
    room.logic:trigger(fk.AfterPlayerRevived, target, {
      who = target,
      reason = zhuhun.name,
    })
  end,
})

return zhuhun
