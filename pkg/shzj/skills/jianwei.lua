local jianwei = fk.CreateSkill {
  name = "shzj_juedai__jianwei",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shzj_juedai__jianwei"] = "坚卫",
  [":shzj_juedai__jianwei"] = "锁定技，若你没有防具，视为你装备【白银狮子】。",
}

jianwei:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jianwei.name) and
      data.damage > 1 and not player:isFakeSkill(self) and
      not player:getEquipment(Card.SubtypeArmor) and
      Fk.skills["#silver_lion_skill"] ~= nil and Fk.skills["#silver_lion_skill"]:isEffectable(player)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:broadcastPlaySound("./packages/maneuvering/audio/card/silver_lion")
    room:setEmotion(player, "./packages/maneuvering/image/anim/silver_lion")
    data:changeDamage(1 - data.damage)
  end,
})

return jianwei
