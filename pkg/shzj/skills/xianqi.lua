local xianqi = fk.CreateSkill {
  name = "xianqi",
  attached_skill_name = "xianqi&",
}

Fk:loadTranslationTable{
  ["xianqi"] = "献气",
  [":xianqi"] = "其他角色出牌阶段限一次，其可以对其造成1点伤害或弃置两张手牌，然后你受到1点无来源伤害。",
}

xianqi:addEffect("visibility", {})

return xianqi
