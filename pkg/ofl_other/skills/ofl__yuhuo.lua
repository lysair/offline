local ofl__yuhuo = fk.CreateSkill {
  name = "ofl__yuhuo"
}

Fk:loadTranslationTable{
  ['ofl__yuhuo'] = '驭火',
  [':ofl__yuhuo'] = '锁定技，防止你受到的火焰伤害；你手牌中的【火攻】和火【杀】不计入手牌上限。',
}

ofl__yuhuo:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, _, target, player, data)
    return target == player and player:hasSkill(ofl__yuhuo.name) and data.damageType == fk.FireDamage
  end,
  on_use = Util.TrueFunc,
})

ofl__yuhuo:addEffect('maxcards', {
  main_skill = ofl__yuhuo,
  exclude_from = function(self, player, card)
    return player:hasSkill(ofl__yuhuo.name) and (card.name == "fire__slash" or card.trueName == "fire_attack")
  end,
})

return ofl__yuhuo
