local sgsh__jidao = fk.CreateSkill {
  name = "sgsh__jidao"
}

Fk:loadTranslationTable{
  ['sgsh__jidao'] = '祭祷',
  ['sgsh__nanhualaoxian'] = '幻南华老仙',
  [':sgsh__jidao'] = '主将技，当一名角色的副将被移除时，你可以摸一张牌。',
  ['$sgsh__jidao'] = '含气求道，祸福难料，且与阁下共参之。',
}

sgsh__jidao:addEffect(fk.PropertyChange, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgsh__jidao.name) and player.general == "sgsh__nanhualaoxian" and data.deputyGeneral and target.deputyGeneral ~= ""
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, sgsh__jidao.name)
  end
})

return sgsh__jidao
