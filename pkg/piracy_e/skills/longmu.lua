local longmu = fk.CreateSkill {
  name = "longmu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["longmu"] = "籠墓",
  [":longmu"] = "锁定技，你的回合内其他角色不能回复体力。当你成为锦囊牌的目标时，取消之。当一名角色死亡后，若你对其发动过此武将牌上的技能"..
  "且其不为丧尸，用丧尸代替该角色加入游戏。",
}

longmu:addEffect(fk.PreHpRecover, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(longmu.name) and player.room:getCurrent() == player and target ~= player
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke("wansha")
    data.prevented = true
  end,
})

longmu:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(longmu.name) and data.card.type == Card.TypeTrick
  end,
  on_use = function (self, event, target, player, data)
    player:broadcastSkillInvoke("weimu")
    data.nullified = true
  end,
})

longmu:addEffect(fk.Deathed, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(longmu.name) and table.contains(player:getTableMark(longmu.name), target.id) and
      target.general ~= "ofl__zombie" and target.dead and target.rest < 1 and
      target.role ~= "lord"
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerProperty(target, "general", "ofl__zombie")
    room:setPlayerProperty(target, "deputyGeneral", "")
    room:setPlayerProperty(target, "kingdom", "qun")
    room:setPlayerProperty(target, "dead", false)
    target._splayer:setDied(false)
    room:setPlayerProperty(target, "dying", false)
    room:setPlayerProperty(target, "maxHp", 4)
    room:setPlayerProperty(target, "hp", 2)
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
    room:setPlayerMark(target, "longmu_jiaxu", player.id)
    room:handleAddLoseSkills(target, "shibian|ganran", nil, false)
    room.logic:trigger(fk.AfterPlayerRevived, target, {
      who = target,
      reason = longmu.name,
    })
  end,
})

return longmu
