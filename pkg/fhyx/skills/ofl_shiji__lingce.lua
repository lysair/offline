local ofl_shiji__lingce = fk.CreateSkill {
  name = "ofl_shiji__lingce"
}

Fk:loadTranslationTable{
  ['ofl_shiji__lingce'] = '灵策',
  [':ofl_shiji__lingce'] = '锁定技，其他角色使用的智囊牌对你无效；一名角色使用智囊牌时，你摸一张牌。',
}

ofl_shiji__lingce:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(ofl_shiji__lingce) and data.card:isCommonTrick() and
      player.room:getTag("Zhinang") and table.contains(player.room:getTag("Zhinang"), data.card.name) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.CardUsing then
      player:drawCards(1, ofl_shiji__lingce.name)
    end
  end,
})

ofl_shiji__lingce:addEffect(fk.PreCardEffect, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(ofl_shiji__lingce) and data.card:isCommonTrick() and
      player.room:getTag("Zhinang") and table.contains(player.room:getTag("Zhinang"), data.card.name) then
      return data.from ~= player.id and data.to == player.id
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.PreCardEffect then
      return true
    end
  end,
})

return ofl_shiji__lingce
