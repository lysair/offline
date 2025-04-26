local skill = fk.CreateSkill {
  name = "#caning_whip_skill",
  tags = { Skill.Compulsory },
  attached_equip = "caning_whip",
}

Fk:loadTranslationTable{
  ["#caning_whip_skill"] = "刑鞭",
  ["#caning_whip-choose"] = "刑鞭：为 %src 指定一名角色，若其未对指定角色使用【杀】或造成伤害，本回合结束阶段其对自己造成1点伤害",
  ["@@caning_whip-turn"] = "刑鞭",
}

skill:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return (player.general == "tianchuan" or player.deputyGeneral == "tianchuan") and
      target:hasSkill(skill.name) and target.phase == Player.Play and
      #player.room:getOtherPlayers(target, false) > 0
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(target, false),
      min_num = 1,
      max_num = 1,
      prompt = "#caning_whip-choose:"..target.id,
      skill_name = skill.name,
      cancelable = false,
    })[1]
    room:setPlayerMark(to, "@@caning_whip-turn", 1)
    room:addTableMark(target, "caning_whip-turn", to.id)
  end,
})

skill:addEffect(fk.EventPhaseEnd, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if target == player and player.phase == Player.Finish and player:getMark("caning_whip-turn") ~= 0 then
      local room = player.room
      local n = 0
      for _, id in ipairs(player:getMark("caning_whip-turn")) do
        local yes = false
        local p = room:getPlayerById(id)
        if #room.logic:getActualDamageEvents(1, function(e)
          local damage = e.data
          return damage.from == player and damage.to == p
        end, Player.HistoryTurn) == 0 then
          yes = true
        end
        if not yes and #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
          local use = e.data
          return use.card.trueName == "slash" and use.from == player and table.contains(use.tos, p)
        end, Player.HistoryTurn) == 0 then
          yes = true
        end
        if yes then
          n = n + 1
        end
      end
      if n > 0 then
        event:setCostData(self, {choice = n})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = player,
      damage = event:getCostData(self).choice,
      skillName = skill.name,
    }
  end,
})

skill:addEffect("atkrange", {
  correct_func = function (self, from)
    if from:hasSkill(skill.name) then
      return #table.filter(from:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
    end
  end,
})

return skill
