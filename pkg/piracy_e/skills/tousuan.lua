local tousuan = fk.CreateSkill {
  name = "tousuan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["tousuan"] = "偷算",
  [":tousuan"] = "锁定技，你或“暗谋”目标首次对对方造成伤害时，此伤害+1并摸三张牌，然后你失去此技能。",
}

tousuan:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(tousuan.name) and target then
      if target == player then
        return player:getMark("anmou") == data.to.id
      elseif data.to == player then
        return player:getMark("anmou") == target.id
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(tousuan.name)
    if target == player then
      room:notifySkillInvoked(player, tousuan.name, "offensive")
    else
      room:notifySkillInvoked(player, tousuan.name, "negative")
    end
    data:changeDamage(1)
    target:drawCards(3, tousuan.name)
    if not player.dead then
      room:handleAddLoseSkills(player, "-tousuan")
    end
  end,
})

return tousuan
