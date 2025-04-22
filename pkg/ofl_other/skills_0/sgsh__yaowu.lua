local sgsh__yaowu = fk.CreateSkill {
  name = "sgsh__yaowu"
}

Fk:loadTranslationTable{
  ['sgsh__yaowu'] = '耀武',
  [':sgsh__yaowu'] = '锁定技，当一名角色对你使用【杀】造成伤害时，或当你使用【杀】造成伤害时，你摸一张牌。',
  ['$sgsh__yaowu1'] = '来将通名，吾刀下不斩无名之辈！',
  ['$sgsh__yaowu2'] = '且看汝比那祖茂潘凤如何？',
}

sgsh__yaowu:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sgsh__yaowu.name) and data.card and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, sgsh__yaowu.name)
  end,
})

sgsh__yaowu:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sgsh__yaowu.name) and data.card and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, sgsh__yaowu.name)
  end,
})

return sgsh__yaowu
