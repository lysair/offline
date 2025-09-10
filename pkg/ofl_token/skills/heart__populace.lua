local sk = fk.CreateSkill {
  name = "#heart__populace_skill",
  tags = { Skill.Compulsory },
  attached_equip = "heart__populace",
}

Fk:loadTranslationTable{
  ["#heart__populace_skill"] = "众",
}

sk:addEffect("targetmod", {
  residue_func = function (self, player, skill, scope, card, to)
    if player:hasSkill(sk.name) and skill.trueName == "slash_skill" and scope == Player.HistoryPhase then
      return 1
    end
  end,
  bypass_distances = function (self, player, skill, card, to)
    if player:hasSkill(sk.name) and skill.trueName == "slash_skill" then
      return true
    end
  end,
})

return sk
