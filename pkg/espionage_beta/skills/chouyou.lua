local chouyou = fk.CreateSkill {
  name = "chouyou"
}

Fk:loadTranslationTable{
  ['chouyou'] = '仇幽',
  ['#chouyou-choose'] = '仇幽：你可以令一名其他角色选择：代替你成为%arg目标，或发动技能需经你同意！',
  ['chouyou_slash'] = '此【杀】转移给你',
  ['chouyou_control'] = '发动非锁定技前需经 %src 同意，直到你令其回复体力',
  ['@@chouyou'] = '仇幽',
  ['#chouyou-control'] = '仇幽：是否允许 %dest 发动“%arg”？',
  ['#chouyou_prohibit'] = '%from 不允许 %to 发动 “%arg”！',
  [':chouyou'] = '当你成为其他角色使用【杀】的目标时，你可以令另一名其他角色选择一项：1.代替你成为此【杀】目标；2.发动非锁定技前需经你同意，直到其令你回复体力。',
}

-- 主技能
chouyou:addEffect(fk.TargetConfirming, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chouyou.name) and data.card.trueName == "slash" and #player.room.alive_players > 2
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    local from = room:getPlayerById(data.from)
    for _, p in ipairs(room.alive_players) do
      if p ~= player and p.id ~= data.from and not from:isProhibited(p, data.card) then
        table.insert(targets, p.id)
      end
    end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#chouyou-choose:::" .. data.card:toLogString(),
      skill_name = chouyou.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    local choice = room:askToChoice(to, {
      choices = {"chouyou_slash", "chouyou_control:" .. player.id},
      skill_name = chouyou.name
    })
    if choice == "chouyou_slash" then
      TargetGroup:removeTarget(data.targetGroup, player.id)
      TargetGroup:pushTargets(data.targetGroup, to.id)
    else
      local mark = to:getMark("@@chouyou")
      if mark == 0 then mark = {} end
      table.insertIfNeed(mark, player.id)
      room:setPlayerMark(to, "@@chouyou", mark)
    end
  end,
})

-- 触发技
chouyou:addEffect(fk.SkillEffect, {
  name = "#chouyou_trigger",
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target and target:getMark("@@chouyou") ~= 0 and table.contains(target:getMark("@@chouyou"), player.id) and not player.dead and
      target:hasSkill(chouyou.name, true) and data:isPlayerSkill(target) and not data.name:startsWith("#") and
      not data:isInstanceOf(ViewAsSkill) and  
      not table.contains({Skill.Limited, Skill.Wake, Skill.Quest}, data.frequency)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not room:askToSkillInvoke(player, {
      skill_name = "chouyou",
      prompt = "#chouyou-control::" .. target.id .. ":" .. data.name
    }) then
      player:broadcastSkillInvoke("chouyou")
      room:notifySkillInvoked(player, "chouyou")
      room:doIndicate(player.id, {target.id})
      local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
      if e then
        room:sendLog{
          type = "#chouyou_prohibit",
          from = player.id,
          to = {target.id},
          arg = data.name
        }
        e:shutdown()
      end
    end
  end,
})

-- 刷新效果
chouyou:addEffect(fk.AfterSkillEffect, {
  can_refresh = function(self, event, target, player, data)
    if target == player then
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "chouyou-phase", 0)
  end,
})

-- 回复体力效果
chouyou:addEffect(fk.HpRecover, {
  can_refresh = function(self, event, target, player, data)
    if target == player then
      return data.recoverBy and data.recoverBy:getMark("@@chouyou") ~= 0 and table.contains(data.recoverBy:getMark("@@chouyou"), player.id)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local mark = target:getMark("@@chouyou")
    table.removeOne(mark, player.id)
    if #mark == 0 then mark = 0 end
    room:setPlayerMark(target, "@@chouyou", mark)
  end,
})

-- 非法性技能
chouyou:addEffect('invalidity', {
  name = "#chouyou_invalidity",
  invalidity_func = function(self, from, skill)
    return from:getMark("chouyou-phase") ~= 0 and from:hasSkill(chouyou.name, true) and from:getMark("chouyou-phase") == skill.name
  end
})

return chouyou
