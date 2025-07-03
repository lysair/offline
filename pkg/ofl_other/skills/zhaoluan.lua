local zhaoluan = fk.CreateSkill {
  name = "zhaoluan",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable {
  ["zhaoluan"] = "兆乱",
  [":zhaoluan"] = "限定技，一名角色濒死结算后，若其仍处于濒死状态，你可以令其加3点体力上限并失去所有非锁定技，回复体力至3并摸四张牌。"..
  "出牌阶段对每名角色限一次，你可以令该角色减1点体力上限，其对一名你选择的角色造成1点伤害。",

  ["#zhaoluan-invoke"] = "兆乱：%dest 即将死亡，你可以令其复活并操纵其进行攻击！",
  ["#zhaoluan-damage"] = "兆乱：你可以令 %dest 减1点体力上限，其对你指定的一名角色造成1点伤害！",

  ["$zhaoluan1"] = "杀汝，活汝，吾一念之间。",
  ["$zhaoluan2"] = "故山千岫，折得清香。故人，还不醒转？",
  ["$zhaoluan3"] = "汝之形名，悉吾所赐，须奉骨报偿！",
  ["$zhaoluan4"] = "心在柙中，不知窍数，取出与吾把示。",
}

zhaoluan:addEffect("active", {
  mute = true,
  card_num = 0,
  target_num = 1,
  prompt = function(self, player)
    return "#zhaoluan-damage::" .. player:getMark(zhaoluan.name)
  end,
  can_use = function(self, player)
    return player:getMark(zhaoluan.name) ~= 0 and not Fk:currentRoom():getPlayerById(player:getMark(zhaoluan.name)).dead
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and not table.contains(player:getTableMark("zhaoluan_target-phase"), to_select.id)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:addTableMark(player, "zhaoluan_target-phase", target.id)
    local src = room:getPlayerById(player:getMark(zhaoluan.name))
    player:broadcastSkillInvoke(zhaoluan.name, math.random(3, 4))
    room:notifySkillInvoked(player, zhaoluan.name, "offensive")
    room:doIndicate(player, {src})
    room:doIndicate(src, {target})
    room:changeMaxHp(src, -1)
    if not target.dead then
      room:damage{
        from = src,
        to = target,
        damage = 1,
        skillName = zhaoluan.name,
      }
    end
  end
})

zhaoluan:addEffect(fk.AskForPeachesDone, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhaoluan.name) and not target.dead and target.hp < 1 and
      player:usedEffectTimes(self.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = zhaoluan.name,
      prompt = "#zhaoluan-invoke::" .. target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, zhaoluan.name, target.id)
    player:broadcastSkillInvoke(zhaoluan.name, math.random(1, 2))
    room:notifySkillInvoked(player, zhaoluan.name, "big")
    room:changeMaxHp(target, 3)
    local skills = table.filter(target:getSkillNameList(), function (s)
      local skill = Fk.skills[s]
      return not skill:hasTag(Skill.Compulsory) and skill:isPlayerSkill(player)
    end)
    if #skills > 0 then
      room:handleAddLoseSkills(target, "-" .. table.concat(skills, "|-"))
    end
    if not target.dead and target.hp < 3 and target:isWounded() then
      room:recover{
        who = target,
        num = 3 - target.hp,
        recoverBy = player,
        skillName = zhaoluan.name,
      }
    end
    if not target.dead then
      target:drawCards(4, zhaoluan.name)
    end
  end
})

return zhaoluan
