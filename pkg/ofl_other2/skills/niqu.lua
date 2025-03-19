local niqu = fk.CreateSkill {
  name = "ofl__niqu"
}

Fk:loadTranslationTable{
  ['ofl__niqu'] = '逆取',
  ['#ofl__niqu-invoke'] = '逆取：是否摸一张牌，视为对 %dest 使用【杀】？',
  [':ofl__niqu'] = '每回合限一次，当一名角色使用或打出【闪】结算后，你可以摸一张牌，然后视为对其使用一张【杀】。',
  ['$ofl__niqu1'] = '离心离德，为吾等所不容！',
  ['$ofl__niqu2'] = '此昏聩之徒，吾羞与为伍。',
}

niqu:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niqu.name) and data.card.trueName == "jink" and player:usedSkillTimes(niqu.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = niqu.name,
      prompt = "#ofl__niqu-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, niqu.name)
    if target ~= player and not target.dead then
      room:useVirtualCard("slash", nil, player, target, niqu.name, true)
    end
  end,
})

niqu:addEffect(fk.CardRespondFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(niqu.name) and data.card.trueName == "jink" and player:usedSkillTimes(niqu.name, Player.HistoryTurn) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = niqu.name,
      prompt = "#ofl__niqu-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, niqu.name)
    if target ~= player and not target.dead then
      room:useVirtualCard("slash", nil, player, target, niqu.name, true)
    end
  end,
})

return niqu
