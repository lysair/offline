local skill = fk.CreateSkill {
  name = "#baibi_dagger_skill",
  tags = { Skill.Compulsory },
  attached_equip = "baibi_dagger",
}

Fk:loadTranslationTable{
  ["#baibi_dagger_skill"] = "百辟双匕",
}

skill:addEffect(fk.TargetSpecified, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.trueName == "slash" and
      player:isKongcheng() and player:compareGenderWith(data.to, true)
  end,
  on_use = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + 1
  end,
})

return skill
