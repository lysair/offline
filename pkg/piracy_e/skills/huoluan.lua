local huoluan = fk.CreateSkill {
  name = "huoluan",
  tags = { Skill.AttachedKingdom },
  attached_kingdom = {"qun"},
}

Fk:loadTranslationTable{
  ["huoluan"] = "惑乱",
  [":huoluan"] = "群势力技，你与蜀势力角色互相造成的伤害+1。",
}

huoluan:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(huoluan.name) and target then
      if target == player then
        return data.to.kingdom == "shu"
      elseif data.to == player then
        return target.kingdom == "shu"
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(huoluan.name)
    if target == player then
      room:notifySkillInvoked(player, huoluan.name, "offensive")
    else
      room:notifySkillInvoked(player, huoluan.name, "negative")
    end
    data:changeDamage(1)
  end,
})

return huoluan
