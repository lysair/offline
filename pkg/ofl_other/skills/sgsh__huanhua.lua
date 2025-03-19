local sgsh__huanhua = fk.CreateSkill {
  name = "sgsh__huanhua"
}

Fk:loadTranslationTable{
  ['sgsh__huanhua'] = '幻化',
  [':sgsh__huanhua'] = '锁定技，当一名角色受到1点伤害后，移除其副将，其从未加入游戏的武将牌中随机获得一张作为副将。此技能不会失效。',
}

sgsh__huanhua:addEffect(fk.Damaged, {
  global = false,
  can_trigger = function(self, event, target, player, data)
    return target == player and not player.dead
  end,
  on_trigger = function(self, event, target, player, data)  --假装不是技能
    local room = player.room
    for i = 1, data.damage do
      if player.dead then break end
      local generals = table.filter(room.general_pile, function(name)
        return not table.contains(sgsh__huanhua_blacklist, name)
      end)
      local general = table.random(generals)
      table.removeOne(room.general_pile, general)
      if player.deputyGeneral ~= "" then
        room:returnToGeneralPile({player.deputyGeneral})
      end
      room:changeHero(player, general, false, true, true, false, false)
    end
  end,
})

return sgsh__huanhua
