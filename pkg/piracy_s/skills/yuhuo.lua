local yuhuo = fk.CreateSkill {
  name = "ofl__yuhuop",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__yuhuop"] = "浴火",
  [":ofl__yuhuop"] = "锁定技，处于连环状态的其他角色受到的属性伤害+1，非属性伤害-1。",
}

yuhuo:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yuhuo.name) and target ~= player and target.chained
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(yuhuo.name)
    if data.damageType == fk.NormalDamage then
      room:notifySkillInvoked(player, yuhuo.name, "defensive", {target})
      data:changeDamage(-1)
    else
      room:notifySkillInvoked(player, yuhuo.name, "offensive", {target})
      data:changeDamage(1)
    end
  end,
})

return yuhuo