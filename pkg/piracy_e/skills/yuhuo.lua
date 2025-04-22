local yuhuo = fk.CreateSkill {
  name = "ofl__yuhuo",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__yuhuo"] = "驭火",
  [":ofl__yuhuo"] = "锁定技，防止你受到的火焰伤害；你手牌中的【火攻】和火【杀】不计入手牌上限。",
}

yuhuo:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yuhuo.name) and data.damageType == fk.FireDamage
  end,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
  end,
})

yuhuo:addEffect("maxcards", {
  exclude_from = function(self, player, card)
    return player:hasSkill(yuhuo.name) and (card.name == "fire__slash" or card.trueName == "fire_attack")
  end,
})

return yuhuo
