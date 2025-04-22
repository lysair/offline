local paoxi = fk.CreateSkill {
  name = "ofl__paoxi"
}

Fk:loadTranslationTable{
  ['ofl__paoxi'] = '咆袭',
  ['@@ofl__paoxi2-turn'] = '造成伤害+1',
  ['@@ofl__paoxi1-turn'] = '受到伤害+1',
  [':ofl__paoxi'] = '锁定技，每回合各限一次，当你连续成为牌/使用牌指定目标后，你本回合下次受到/造成的伤害+1。',
}

paoxi:addEffect(fk.TargetSpecified, {
  anim_type = "special",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(paoxi.name) and data.firstTarget then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event == nil then return end
      local info = {}
      local events = player.room.logic:getEventsByRule(GameEvent.UseCard, 2, function (e)
        info = {e.data[1].from, e.data[1].tos}
        return true
      end, turn_event.id)
      if #events < 2 or #info == 0 then return end
      event:setCostData(skill, {})
      if player:getMark("ofl__paoxi1-turn") == 0 then
        if table.contains(AimGroup:getAllTargets(data.tos), player.id) and info[2] and
          table.contains(TargetGroup:getRealTargets(info[2]), player.id) then
          table.insert(event:getCostData(skill), 1)
        end
      end
      if player:getMark("ofl__paoxi2-turn") == 0 then
        if target == player and info[1] == player.id and info[2] then
          table.insert(event:getCostData(skill), 2)
        end
      end
      return #event:getCostData(skill) > 0
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for i = 1, 2, 1 do
      if table.contains(event:getCostData(skill), i) then
        room:setPlayerMark(player, "ofl__paoxi"..i.."-turn", 1)
        room:addPlayerMark(player, "@@ofl__paoxi"..i.."-turn", 1)
      end
    end
  end,
})

paoxi:addEffect(fk.DamageCaused, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function (self, event, target, player, data)
    if target == player then
      return player:getMark("@@ofl__paoxi2-turn") > 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(paoxi.name)
    room:notifySkillInvoked(player, paoxi.name, "offensive")
    data.damage = data.damage + player:getMark("@@ofl__paoxi2-turn")
    room:setPlayerMark(player, "@@ofl__paoxi2-turn", 0)
  end,
})

paoxi:addEffect(fk.DamageInflicted, {
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function (self, event, target, player, data)
    if target == player then
      return player:getMark("@@ofl__paoxi1-turn") > 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(paoxi.name)
    room:notifySkillInvoked(player, paoxi.name, "negative")
    data.damage = data.damage + player:getMark("@@ofl__paoxi1-turn")
    room:setPlayerMark(player, "@@ofl__paoxi1-turn", 0)
  end,
})

return paoxi
