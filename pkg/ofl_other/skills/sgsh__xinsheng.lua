local sgsh__xinsheng = fk.CreateSkill {
  name = "sgsh__xinsheng"
}

Fk:loadTranslationTable{
  ['sgsh__xinsheng'] = '新生',
  ['sgsh__zuoci'] = '幻左慈',
  [':sgsh__xinsheng'] = '主将技，准备阶段，你可以移除副将，然后随机获得一张未加入游戏的武将牌作为副将。',
  ['$sgsh__xinsheng1'] = '傍日月，携宇宙，游乎尘垢之外。',
  ['$sgsh__xinsheng2'] = '吾多与天地精神之往来，生即死，死又复生。',
}

sgsh__xinsheng:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Start and
      player.general == "sgsh__zuoci" and player.deputyGeneral ~= ""
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    room:returnToGeneralPile({player.deputyGeneral})
    room:changeHero(player, "", false, true, true, false, false)
    if player.dead then return end
    local generals = table.filter(room.general_pile, function(name)
      return not table.contains(sgsh__huanhua_blacklist, name)
    end)
    local general = table.random(generals)
    table.removeOne(room.general_pile, general)
    room:changeHero(player, general, false, true, true, false, false)
  end,
})

return sgsh__xinsheng
