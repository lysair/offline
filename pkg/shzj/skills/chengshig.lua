local chengshig = fk.CreateSkill {
  name = "chengshig",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["chengshig"] = "乘势",
  [":chengshig"] = "锁定技，每回合限一次：当你于回合内使用红色【杀】造成伤害后，此【杀】不计入次数限制；当你于回合外使用红色【杀】"..
  "造成伤害后，受伤角色本回合不能使用伤害类牌指定除你以外的角色为目标。",
}

chengshig:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and
      data.card and data.card.trueName == "slash" and data.card.color == Card.Red and
      player:usedSkillTimes(chengshig.name, Player.HistoryTurn) == 0 then
      if player.room.current == player then
        local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
        if use_event ~= nil then
          local use = use_event.data
          return not use.extraUse
        end
      else
        return not data.to.dead
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if player.room.current == player then
      event:setCostData(self, nil)
    else
      event:setCostData(self, {tos = {data.to}})
    end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if room.current == player then
      player:addCardUseHistory(data.card.trueName, -1)
      local use_event = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if use_event ~= nil then
        local use = use_event.data
        use.extraUse = true
      end
    else
      room:addTableMarkIfNeed(data.to, "chengshig-turn", player.id)
    end
  end,
})

chengshig:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return from:getMark("chengshig-turn") ~= 0 and card and card.is_damage_card and from and
      not table.contains(from:getTableMark("chengshig-turn"), to.id)
  end,
})

return chengshig
