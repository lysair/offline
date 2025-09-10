local weizhen = fk.CreateSkill {
  name = "ofl__weizhen",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__weizhen"] = "威震",
  [":ofl__weizhen"] = "锁定技，手牌数大于你的角色对你造成的伤害至多为1。",
}

weizhen:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(weizhen.name) and
      data.damage > 1 and data.from and data.from:getHandcardNum() > player:getHandcardNum()
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1 - data.damage)
  end,
})

return weizhen
