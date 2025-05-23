
local chouyou = fk.CreateTriggerSkill{
  name = "chouyou",
  anim_type = "control",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash" and #player.room.alive_players > 2
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
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#chouyou-choose:::"..data.card:toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local choice = room:askForChoice(to, {"chouyou_slash", "chouyou_control:"..player.id}, self.name)
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
}
local chouyou_trigger = fk.CreateTriggerSkill{
  name = "#chouyou_trigger",
  mute = true,
  events = {fk.SkillEffect},
  can_trigger = function(self, event, target, player, data)
    return target and target:getMark("@@chouyou") ~= 0 and table.contains(target:getMark("@@chouyou"), player.id) and not player.dead and
      target:hasSkill(data, true) and data:isPlayerSkill(target) and not data.name:startsWith("#") and
      not data:isInstanceOf(ViewAsSkill) and  --FIXME: 转化技！
      not table.contains({Skill.Limited, Skill.Wake, Skill.Quest}, data.frequency)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not room:askForSkillInvoke(player, "chouyou", nil, "#chouyou-control::"..target.id..":"..data.name) then
      player:broadcastSkillInvoke("chouyou")
      room:notifySkillInvoked(player, "chouyou")
      room:doIndicate(player.id, {target.id})
      --room:setPlayerMark(target, "chouyou-phase", data.name)
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

  refresh_events = {fk.AfterSkillEffect, fk.HpRecover},
  can_refresh = function(self, event, target, player, data)
    if target == player then
      if event == fk.AfterSkillEffect then
        --return player:getMark("@@chouyou") ~= 0 and player:getMark("chouyou-phase") ~= 0
      else
        return data.recoverBy and data.recoverBy:getMark("@@chouyou") ~= 0 and table.contains(data.recoverBy:getMark("@@chouyou"), player.id)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterSkillEffect then
      room:setPlayerMark(player, "chouyou-phase", 0)
    else
      local mark = target:getMark("@@chouyou")
      table.removeOne(mark, player.id)
      if #mark == 0 then mark = 0 end
      room:setPlayerMark(target, "@@chouyou", mark)
    end
  end,
}
--[[local chouyou_invalidity = fk.CreateInvaliditySkill {--FIXME: 想实现防止空发好像有点难
  name = "#chouyou_invalidity",
  invalidity_func = function(self, from, skill)
    return from:getMark("chouyou-phase") ~= 0 and from:hasSkill(skill, true) and from:getMark("chouyou-phase") == skill.name
  end
}]]
Fk:loadTranslationTable{
  ["chouyou"] = "仇幽",
  [":chouyou"] = "当你成为其他角色使用【杀】的目标时，你可以令另一名其他角色选择一项：1.代替你成为此【杀】目标；2.发动非锁定技前需经你同意，"..
  "直到其令你回复体力。",
  ["#chouyou-choose"] = "仇幽：你可以令一名其他角色选择：代替你成为%arg目标，或发动技能需经你同意！",
  ["chouyou_slash"] = "此【杀】转移给你",
  ["chouyou_control"] = "发动非锁定技前需经 %src 同意，直到你令其回复体力",
  ["@@chouyou"] = "仇幽",
  ["#chouyou-control"] = "仇幽：是否允许 %dest 发动“%arg”？",
  ["#chouyou_prohibit"] = "%from 不允许 %to 发动 “%arg”！",
}

--local liru = General(extension, "es__liru", "qun", 3)
local dumou = fk.CreateFilterSkill{
  name = "dumou",
  frequency = Skill.Compulsory,
  card_filter = function(self, to_select, player)
    if player:hasSkill(self) and player.phase ~= Player.NotActive and table.contains(player:getCardIds("h"), to_select.id) then
      return to_select.trueName == "poison"
    end
    if table.find(Fk:currentRoom().alive_players, function(p)
      return p.phase ~= Player.NotActive and p:hasSkill(self) and p ~= player and table.contains(p.player_skills, self)
    end) and table.contains(player:getCardIds("h"), to_select.id) then
      return to_select.color == Card.Black
    end
  end,
  view_as = function(self, to_select)
    local card
    if Self.phase == Player.NotActive then
      card = Fk:cloneCard("es__poison", to_select.suit, to_select.number)
    else
      card = Fk:cloneCard("dismantlement", to_select.suit, to_select.number)
    end
    card.skillName = self.name
    return card
  end,
}
Fk:loadTranslationTable{
  ["dumou"] = "毒谋",
  [":dumou"] = "锁定技，你的回合内，其他角色的黑色手牌均视为【毒】，你的【毒】均视为【过河拆桥】。",
}
