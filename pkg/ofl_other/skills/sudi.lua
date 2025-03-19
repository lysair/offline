local sudi = fk.CreateSkill {
  name = "ofl__sudi"
}

Fk:loadTranslationTable{
  ['ofl__sudi'] = '肃敌',
  [':ofl__sudi'] = '锁定技，攻击范围内包含你的角色响应你使用的牌后，你摸一张牌。',
}

sudi:addEffect({fk.CardUseFinished, fk.CardRespondFinished}, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sudi.name) and target:inMyAttackRange(player) and data.responseToEvent and data.responseToEvent.from == player.id
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, sudi.name)
  end,
})

return sudi
