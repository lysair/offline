local fuluan = fk.CreateSkill {
  name = "fuluan"
}

Fk:loadTranslationTable{
  ['fuluan'] = '扶乱',
  ['#fuluan'] = '扶乱：弃置三张相同花色的牌，令攻击范围内一名角色翻面',
  ['@@fuluan-turn'] = '扶乱',
  [':fuluan'] = '出牌阶段限一次，若你未于本阶段使用过【杀】，你可以弃置三张相同花色的牌并选择攻击范围内的一名角色：若如此做，该角色将武将牌翻面，你不能使用【杀】直到回合结束。 ',
}

fuluan:addEffect('active', {
  anim_type = "control",
  prompt = "#fuluan",
  can_use = function(self, player)
    return player:usedSkillTimes(fuluan.name, Player.HistoryPhase) == 0 and player:getMark("fuluan-phase") == 0
  end,
  card_num = 3,
  card_filter = function(self, player, to_select, selected)
    if #selected < 3 and not player:prohibitDiscard(Fk:getCardById(to_select)) then
      return table.every(selected, function (id)
        return Fk:getCardById(id).suit == Fk:getCardById(to_select).suit
      end)
    end
  end,
  target_num = 1,
  target_filter = function(self, player, to_select, selected, cards)
    return #cards == 3 and #selected == 0 and player:inMyAttackRange(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local to = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(player, "@@fuluan-turn", 1)
    room:throwCard(effect.cards, fuluan.name, player, player)
    if not to.dead then
      to:turnOver()
    end
  end,
})

fuluan:addEffect('refresh', {
  events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:hasSkill(fuluan.name) and data.card.trueName == "slash"
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "fuluan-phase", 1)
  end,
})

fuluan:addEffect('prohibit', {
  prohibit_use = function(self, player, card)
    return player:getMark("@@fuluan-turn") > 0 and card and card.trueName == "slash"
  end,
})

return fuluan
