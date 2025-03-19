local zhaoluan = fk.CreateSkill { name = "zhaoluan" }

Fk:loadTranslationTable {
  ['zhaoluan'] = '兆乱',
  ['#zhaoluan-damage'] = '兆乱：你可以令 %dest 减1点体力上限，其对你指定的一名角色造成1点伤害！',
  ['#zhaoluan_trigger'] = '兆乱',
  ['#zhaoluan-invoke'] = '兆乱：%dest 即将死亡，你可以令其复活并操纵其进行攻击！',
  [':zhaoluan'] = '限定技，一名角色濒死结算后，若其仍处于濒死状态，你可以令其加3点体力上限并失去所有非锁定技，回复体力至3并摸四张牌。出牌阶段对每名角色限一次，你可以令该角色减1点体力上限，其对一名你选择的角色造成1点伤害。',
  ['$zhaoluan1'] = '杀汝，活汝，吾一念之间。',
  ['$zhaoluan2'] = '故山千岫，折得清香。故人，还不醒转？',
  ['$zhaoluan3'] = '汝之形名，悉吾所赐，须奉骨报偿！',
  ['$zhaoluan4'] = '心在柙中，不知窍数，取出与吾把示。',
}

zhaoluan:addEffect('active', {
  mute = true,
  frequency = Skill.Limited,
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
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:addTableMark(player, "zhaoluan_target-phase", target.id)
    local src = room:getPlayerById(player:getMark(zhaoluan.name))
    player:broadcastSkillInvoke(zhaoluan.name, math.random(3, 4))
    room:notifySkillInvoked(player, zhaoluan.name, "offensive")
    room:doIndicate(player.id, {src.id})
    room:doIndicate(src.id, {target.id})
    room:changeMaxHp(src, -1)
    room:damage{
      from = src,
      to = target,
      damage = 1,
      skillName = zhaoluan.name,
    }
  end
})

zhaoluan:addEffect(fk.AskForPeachesDone, {
  anim_type = "special",
  frequency = Skill.Limited,
  mute = true,
  can_trigger = function(self, event, target, player)
    return player:hasSkill(zhaoluan) and not target.dead and target.hp < 1 and player:getMark("zhaoluan") == 0
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, { skill_name = "zhaoluan", prompt = "#zhaoluan-invoke::" .. target.id })
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:setPlayerMark(player, "zhaoluan", target.id) --FIXME: 谨防刷新限定技
    player:broadcastSkillInvoke("zhaoluan", math.random(1, 2))
    room:notifySkillInvoked(player, "zhaoluan", "big")
    room:changeMaxHp(target, 3)
    local skills = {}
    for _, s in ipairs(target.player_skills) do
      if s:isPlayerSkill(target) and s.frequency ~= Skill.Compulsory and s.frequency ~= Skill.Wake then
        table.insertIfNeed(skills, s.name)
      end
    end
    if room.settings.gameMode == "m_1v2_mode" and target.role == "lord" then
      table.removeOne(skills, "m_feiyang")
      table.removeOne(skills, "m_bahu")
    end
    if #skills > 0 then
      room:handleAddLoseSkills(target, "-" .. table.concat(skills, "|-"), nil, true, false)
    end
    if not target.dead and target.hp < 3 and target:isWounded() then
      room:recover({
        who = target,
        num = math.min(3, target.maxHp) - target.hp,
        recoverBy = player,
        skillName = zhaoluan.name,
      })
    end
    if not target.dead then
      target:drawCards(4, zhaoluan.name)
    end
  end
})

return zhaoluan
