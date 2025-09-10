local chanyuan = fk.CreateSkill {
  name = "sgsh__chanyuan",
  tags = { Skill.DeputyPlace },
}

Fk:loadTranslationTable{
  ["sgsh__chanyuan"] = "缠怨",
  [":sgsh__chanyuan"] = "副将技，此武将牌不能被移除。",
}

chanyuan:addEffect("visibility", {})

return chanyuan
