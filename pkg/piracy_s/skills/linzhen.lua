local linzhen = fk.CreateSkill {
  name = "ofl__linzhen",
  tags = { Skill.Lord, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__linzhen"] = "临阵",
  [":ofl__linzhen"] = "主公技，锁定技，你视为在其他群势力角色的攻击范围内。",
}

linzhen:addEffect("atkrange", {
  within_func = function(self, from, to)
    return to:hasSkill(linzhen.name) and from.kingdom == "qun" and from ~= to
  end,
})

return linzhen
