local yingzhan = fk.CreateSkill {
  name = "ofl__yingzhan"
}

Fk:loadTranslationTable{
  ['ofl__yingzhan'] = '营战',
  [':ofl__yingzhan'] = '锁定技，你造成或受到的属性伤害+1。',
}

yingzhan:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yingzhan.name) and data.damageType ~= fk.NormalDamage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(yingzhan.name)
    room:notifySkillInvoked(player, yingzhan.name, "offensive")
    data.damage = data.damage + 1
  end,
})

yingzhan:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yingzhan.name) and data.damageType ~= fk.NormalDamage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(yingzhan.name)
    room:notifySkillInvoked(player, yingzhan.name, "negative")
    data.damage = data.damage + 1
  end,
})

return yingzhan
