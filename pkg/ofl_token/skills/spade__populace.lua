local skill = fk.CreateSkill {
  name = "#spade__populace_skill",
  tags = { Skill.Compulsory },
  attached_equip = "spade__populace",
}

Fk:loadTranslationTable{
  ["#spade__populace_skill"] = "众",
}

skill:addEffect(fk.DamageCaused, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.damageType == fk.ThunderDamage
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

skill:addEffect(fk.DamageInflicted, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.damageType == fk.ThunderDamage
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(-1)
  end,
})

return skill
