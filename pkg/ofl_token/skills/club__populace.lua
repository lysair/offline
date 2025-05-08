local skill = fk.CreateSkill {
  name = "#club__populace_skill",
  tags = { Skill.Compulsory },
  attached_equip = "club__populace",
}

Fk:loadTranslationTable{
  ["#club__populace_skill"] = "众",
}

skill:addEffect(fk.DrawNCards, {
  on_use = function(self, event, target, player, data)
    data.n = data.n + 1
  end,
})

skill:addEffect("maxcards", {
  correct_func = function (self, player)
    if player:hasSkill(skill.name) then
      return 1
    end
  end,
})

return skill
