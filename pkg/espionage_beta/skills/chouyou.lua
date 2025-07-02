local chouyou = fk.CreateSkill {
  name = "chouyou",
}

Fk:loadTranslationTable{
  ["chouyou"] = "仇幽",
  [":chouyou"] = "当你成为其他角色使用【杀】的目标时，你可以令另一名其他角色选择一项：1.代替你成为此【杀】目标；2.发动非锁定技前需经你同意，"..
  "直到其令你回复体力。",

  ["#chouyou-choose"] = "仇幽：你可以令一名其他角色选择：代替你成为%arg目标，或发动技能需经你同意！",
  ["chouyou_slash"] = "此【杀】转移给你",
  ["chouyou_control"] = "发动非锁定技前需经 %src 同意，直到你令其回复体力",
  ["@@chouyou"] = "仇幽",
  ["#chouyou-control"] = "仇幽：是否允许 %dest 发动“%arg”？（“确定”：同意，“取消”：拒绝）",
  ["#chouyou_prohibit"] = "%from 不允许 %to 发动 “%arg”！",
}

chouyou:addEffect(fk.TargetConfirming, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chouyou.name) and
      data.card.trueName == "slash" and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return p ~= data.from
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return p ~= data.from
      end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#chouyou-choose:::" .. data.card:toLogString(),
      skill_name = chouyou.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local choice = room:askToChoice(to, {
      choices = {
        "chouyou_slash",
        "chouyou_control:" .. player.id,
      },
      skill_name = chouyou.name
    })
    if choice == "chouyou_slash" then
      data:cancelTarget(player)
      data:addTarget(to)
    else
      room:addTableMarkIfNeed(to, "@@chouyou", player.id)
    end
  end,
})

chouyou:addEffect(fk.SkillEffect, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target and table.contains(target:getTableMark("@@chouyou"), player.id) and not player.dead and
      not data:isInstanceOf(ViewAsSkill) and not data.skill:hasTag(Skill.Compulsory) and
      table.contains(target:getSkillNameList(), data.skill:getSkeleton().name) and not data.skill.is_delay_effect
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if not room:askToSkillInvoke(player, {
      skill_name = chouyou.name,
      prompt = "#chouyou-control::" .. target.id .. ":" .. data.skill:getSkeleton().name,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:sendLog{
      type = "#chouyou_prohibit",
      from = player.id,
      to = {target.id},
      arg = data.skill:getSkeleton().name,
    }
    data.prevent = true
  end,
})

--[[chouyou:addEffect(fk.AfterSkillEffect, {
  can_refresh = function(self, event, target, player, data)
    return target == player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "chouyou-phase", 0)
  end,
})]]

chouyou:addEffect(fk.HpRecover, {
  can_refresh = function(self, event, target, player, data)
    return target == player and data.recoverBy and table.contains(data.recoverBy:getTableMark("@@chouyou"), player.id)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:removeTableMark(target, "@@chouyou", player.id)
  end,
})

--[[chouyou:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    return from:getMark("chouyou-phase") ~= 0 and from:hasSkill(chouyou.name, true) and from:getMark("chouyou-phase") == skill.name
  end
})]]

return chouyou
