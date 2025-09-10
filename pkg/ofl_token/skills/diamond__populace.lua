local skill = fk.CreateSkill {
  name = "#diamond__populace_skill",
  tags = { Skill.Compulsory },
  attached_equip = "diamond__populace",
}

Fk:loadTranslationTable{
  ["#diamond__populace_skill"] = "众",
}

skill:addEffect(fk.Damaged, {
  on_use = function(self, event, target, player, data)
    player:drawCards(2, "populace")
  end,
})

return skill
