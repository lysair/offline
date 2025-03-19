local zhue = fk.CreateSkill {
  name = "zhue"
}

Fk:loadTranslationTable{
  ['zhue'] = '诛恶',
  ['#zhue-invoke'] = '诛恶：是否令 %src 摸一张牌且其使用的%arg不能被响应？若此牌造成伤害，你变更势力为蜀',
  ['#zhue_delay'] = '诛恶',
  [':zhue'] = '群势力技，每回合限一次，当一名群势力角色使用非装备牌时，你可以令其摸一张牌，令此牌不能被响应；此牌结算后，若此牌造成过伤害，你变更势力至蜀。',
}

zhue:addEffect(fk.CardUsing, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhue.name) and target.kingdom == "qun" and data.card.type ~= Card.TypeEquip and
      player:usedSkillTimes(zhue.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhue.name,
      prompt = "#zhue-invoke:"..target.id.."::"..data.card:toLogString()
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    data.extra_data = data.extra_data or {}
    data.extra_data.zhue = player.id
    data.disresponsiveList = table.map(room.alive_players, Util.IdMapper)
    target:drawCards(1, zhue.name)
  end,
})

zhue:addEffect(fk.CardUseFinished, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return data.extra_data and data.extra_data.zhue == player.id and data.damageDealt and player.kingdom ~= "shu"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:changeKingdom(player, "shu", true)
  end,
})

return zhue
