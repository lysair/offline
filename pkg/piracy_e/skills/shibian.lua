local shibian = fk.CreateSkill {
  name = "shibian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["shibian"] = "尸变",
  [":shibian"] = "锁定技，你保留所有技能，阵营和胜利条件变为和贾诩相同。",
}

shibian:addEffect("visibility", {})

return shibian
