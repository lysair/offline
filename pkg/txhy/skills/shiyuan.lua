local shiyuan = fk.CreateSkill {
  name = "ofl_tx__shiyuan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__shiyuan"] = "尸怨",
  [":ofl_tx__shiyuan"] = "锁定技，你造成的伤害+1。当你进入濒死状态时，你死亡。当你杀死一名角色后，其复活为长怨尸兵并改为你的阵营。",
}

shiyuan:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(shiyuan.name)
  end,
  on_use = function (self, event, target, player, data)
    data:changeDamage(1)
  end,
})

shiyuan:addEffect(fk.EnterDying, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(shiyuan.name)
  end,
  on_use = function (self, event, target, player, data)
    player.room:killPlayer({ who = player })
  end,
})

shiyuan:addEffect(fk.Deathed, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(shiyuan.name) and
      data.killer == player and target.dead
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
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
    local role = player.role
    if player.role == "lord" then
      role = "loyalist"
    end
    target.role = role
    room:setPlayerProperty(target, "role_shown", player.role_shown)
    room:setPlayerProperty(target, "role", role)
    local skills = table.map(target:getSkillNameList(), function (s)
      return "-"..s
    end)
    table.insert(skills, shiyuan.name)
    room:handleAddLoseSkills(target, table.concat(skills, "|"), nil, false)
    room.logic:trigger(fk.AfterPlayerRevived, target, {
      who = target,
      reason = shiyuan.name,
    })
  end,
})

return shiyuan
