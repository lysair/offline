local sgsh__jinghe = fk.CreateSkill {
  name = "sgsh__jinghe"
}

Fk:loadTranslationTable{
  ['sgsh__jinghe'] = '经合',
  ['#sgsh__jinghe-invoke'] = '经合：%dest 即将获得随机副将，是否改为其观看两张并选择一张作为副将？',
  [':sgsh__jinghe'] = '当一名其他角色获得副将武将牌前，你可以令其改为观看两张未加入游戏的武将牌并选择一张作为副将。',
  ['$sgsh__jinghe1'] = '此经所书晦涩难明，吾偶有所悟，愿为君陈之。',
  ['$sgsh__jinghe2'] = '大音希声，大象无形，天理难明，以经合之。',
}

sgsh__jinghe:addEffect(fk.BeforePropertyChange, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(sgsh__jinghe.name) and data.deputyGeneral and data.deputyGeneral ~= "" and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = sgsh__jinghe.name,
      prompt = "#sgsh__jinghe-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local generals = room:getNGenerals(2)
    local general = room:askToChooseGeneral(target, {
      generals = generals,
      n = 1,
      no_convert = true
    })
    if general == nil then
      general = table.random(generals)
    end
    table.removeOne(generals, general)
    room:returnToGeneralPile(generals)
    data.deputyGeneral = general
  end,
})

return sgsh__jinghe
