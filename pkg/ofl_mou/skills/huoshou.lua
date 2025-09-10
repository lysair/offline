local huoshou = fk.CreateSkill {
  name = "ofl_mou__huoshou",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_mou__huoshou"] = "祸首",
  [":ofl_mou__huoshou"] = "锁定技，【南蛮入侵】对你无效；当其他角色使用【南蛮入侵】指定第一个目标后，你代替其成为伤害来源；" ..
  "出牌阶段结束时，你弃置所有手牌，视为使用一张【南蛮入侵】。",

  ["$ofl_mou__huoshou1"] = "蛮人世居两川之地，岂会屈居汉人之下！",
  ["$ofl_mou__huoshou2"] = "吾等，定要守护这南中乐土！",
}

huoshou:addEffect(fk.PreCardEffect, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(huoshou.name) and data.card.trueName == "savage_assault" and data.to == player
  end,
  on_use = function (self, event, target, player, data)
    data.nullified = true
  end,
})

huoshou:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(huoshou.name) and data.card.trueName == "savage_assault" and data.firstTarget
  end,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.huoshou = player.id
  end,
})

huoshou:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huoshou.name) and player.phase == Player.Play and
      player:canUse(Fk:cloneCard("savage_assault"))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:isKongcheng() then
      player:throwAllCards("h", huoshou.name)
      if player.dead then return end
    end
    local card = Fk:cloneCard("savage_assault")
    card.skillName = huoshou.name
    local targets = card:getDefaultTarget(player)
    if #targets > 0 then
      room:useVirtualCard("savage_assault", nil, player, targets, huoshou.name)
    end
  end,
})

huoshou:addEffect(fk.PreDamage, {
  can_refresh = function(self, event, target, player, data)
    if data.card and data.card.trueName == "savage_assault" then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data
        return use.extra_data and use.extra_data.huoshou
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if e then
      local use = e.data
      local from = room:getPlayerById(use.extra_data.huoshou)
      data.from = not from.dead and from or nil
    end
  end,
})

return huoshou
