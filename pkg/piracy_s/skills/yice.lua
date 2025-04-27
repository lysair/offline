local yice = fk.CreateSkill {
  name = "ofl__yice",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__yice"] = "遗策",
  [":ofl__yice"] = "锁定技，当你使用、打出或弃置的牌进入弃牌堆后，将这些牌依次置于你的武将牌上，若其中有点数相同的牌，你获得介于这两张牌"..
  "之间的牌，然后将这两张牌分别置于牌堆顶和牌堆底，并对一名角色造成1点伤害。",
}

yice:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yice.name) and target ~= player and target.chained
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(yice.name)
    if data.damageType == fk.NormalDamage then
      room:notifySkillInvoked(player, yice.name, "defensive", {target})
      data:changeDamage(-1)
    else
      room:notifySkillInvoked(player, yice.name, "offensive", {target})
      data:changeDamage(1)
    end
  end,
})

return yice