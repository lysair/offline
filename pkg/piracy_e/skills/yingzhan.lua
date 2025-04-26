local yingzhan = fk.CreateSkill {
  name = "ofl__yingzhan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__yingzhan"] = "营战",
  [":ofl__yingzhan"] = "锁定技，你造成或受到的属性伤害+1。",
}

local spec = {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yingzhan.name) and data.damageType ~= fk.NormalDamage
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
}

yingzhan:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = spec.can_trigger,
  on_use = spec.on_use,
})

yingzhan:addEffect(fk.DamageInflicted, {
  anim_type = "negative",
  can_trigger = spec.can_trigger,
  on_use = spec.on_use,
})

return yingzhan
