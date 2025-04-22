local sgsh__feisheng = fk.CreateSkill {
  name = "sgsh__feisheng"
}

Fk:loadTranslationTable{
  ['sgsh__feisheng'] = '飞升',
  ['sgsh__nanhualaoxian'] = '幻南华老仙',
  [':sgsh__feisheng'] = '副将技，当此武将牌被移除时，你可以回复1点体力或摸两张牌。',
  ['$sgsh__feisheng'] = '蕴气修德，其理易现，容吾为君讲解一二。',
}

sgsh__feisheng:addEffect(fk.PropertyChange, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sgsh__feisheng.name) and player.deputyGeneral == "sgsh__nanhualaoxian" and
      data.deputyGeneral
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = sgsh__feisheng.name
    })
    if choice == "draw2" then
      player:drawCards(2, sgsh__feisheng.name)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = sgsh__feisheng.name
      })
    end
  end,
})

return sgsh__feisheng
