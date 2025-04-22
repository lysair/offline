local caningWhipSkill = fk.CreateSkill {
  name = "#caning_whip_skill"
}

Fk:loadTranslationTable{
  ['#caning_whip_skill'] = '刑鞭',
  ['caning_whip'] = '刑鞭',
  ['#caning_whip-choose'] = '刑鞭：为 %src 指定一名角色，若其未对指定角色使用【杀】或造成伤害，本回合结束阶段其对自己造成1点伤害',
  ['@@caning_whip-turn'] = '刑鞭',
}

caningWhipSkill:addEffect(fk.EventPhaseStart, {
  attached_equip = "caning_whip",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if player:hasSkill(caningWhipSkill) and player.phase == Player.Play and #player.room.alive_players > 1 then
        return table.find(player.room.alive_players, function (p)
          return (p.general == "tianchuan" or p.deputyGeneral == "tianchuan")
        end)
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local tos = {}
      for _, p in ipairs(room:getAllPlayers()) do
        if (p.general == "tianchuan" or p.deputyGeneral == "tianchuan") and not p.dead then
          local to = room:askToChoosePlayers(p, {
            targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper),
            min_num = 1,
            max_num = 1,
            prompt = "#caning_whip-choose:"..player.id,
            skill_name = "caning_whip",
          })
          room:notifySkillInvoked(p, caningWhipSkill.name, "control")
          table.insertIfNeed(tos, to[1])
          room:setPlayerMark(room:getPlayerById(to[1]), "@@caning_whip-turn", 1)
        end
      end
      room:setPlayerMark(player, "caning_whip-turn", tos)
    end
  end,
})

caningWhipSkill:addEffect(fk.EventPhaseEnd, {
  attached_equip = "caning_whip",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if player.phase == Player.Finish and player:getMark("caning_whip-turn") ~= 0 then
        local room = player.room
        local n = 0
        for _, id in ipairs(player:getMark("caning_whip-turn")) do
          local yes = false
          local p = room:getPlayerById(id)
          if #room.logic:getActualDamageEvents(1, function(e)
            local damage = e.data[1]
            return damage.from == player and damage.to == p
          end, Player.HistoryTurn) == 0 then
            yes = true
          end
          if not yes and #room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
            local use = e.data[1]
            return use.card.trueName == "slash" and use.from == player.id and TargetGroup:includeRealTargets(use.tos, p.id)
          end, Player.HistoryTurn) == 0 then
            yes = true
          end
          if yes then
            n = n + 1
          end
        end
        if n > 0 then
          event:setCostData(skill, n)
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseEnd then
      room:notifySkillInvoked(player, caningWhipSkill.name, "negative")
      room:damage{
        from = player,
        to = player,
        damage = event:getCostData(skill),
        skillName = caningWhipSkill.name,
      }
    end
  end,
})

caningWhipSkill:addEffect('atkrange', {
  frequency = Skill.Compulsory,
  correct_func = function (self, from)
    if from:hasSkill(caningWhipSkill) then
      return #table.filter(from:getCardIds("e"), function (id)
        return Fk:getCardById(id).name == "caning_whip"
      end)
    end
  end,
})

return caningWhipSkill
