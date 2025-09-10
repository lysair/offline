local moucheng = fk.CreateSkill{
  name = "ofl2__moucheng",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["ofl2__moucheng"] = "谋逞",
  [":ofl2__moucheng"] = "觉醒技，当一名角色造成伤害后，若本局游戏因〖连计〗造成过至少3点伤害，你加1点体力上限并失去〖连计〗，然后回复1点体力"..
  "并获得〖矜功〗。",
}

moucheng:addEffect(fk.Damage, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(moucheng.name) and target and
      player:usedSkillTimes(moucheng.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    local n = 0
    player.room.logic:getActualDamageEvents(1, function (e)
      local damage = e.data
      if damage.card and table.contains(damage.card.skillNames, "ofl2__lianji") then
        n = n + damage.damage
      end
      return n > 2
    end, Player.HistoryGame)
    return n > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player.dead then return end
    player.room:handleAddLoseSkills(player, "-ofl2__lianji")
    if player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = moucheng.name,
      }
      if player.dead then return end
    end
    player.room:handleAddLoseSkills(player, "ofl2__jingong")
  end,
})

return moucheng
