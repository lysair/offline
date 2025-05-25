local fuluan = fk.CreateSkill {
  name = "fuluan",
}

Fk:loadTranslationTable{
  ["fuluan"] = "扶乱",
  [":fuluan"] = "出牌阶段限一次，若你未于本阶段使用过【杀】，你可以弃置三张相同花色的牌并选择攻击范围内的一名角色，若如此做，"..
  "该角色将武将牌翻面，你不能使用【杀】直到回合结束。",

  ["#fuluan"] = "扶乱：弃置三张相同花色的牌，令攻击范围内一名角色翻面",
  ["@@fuluan-turn"] = "扶乱",
}

fuluan:addEffect("active", {
  anim_type = "control",
  prompt = "#fuluan",
  can_use = function(self, player)
    return player:usedSkillTimes(fuluan.name, Player.HistoryPhase) == 0 and player:getMark("fuluan-phase") == 0
  end,
  card_num = 3,
  target_num = 1,
  card_filter = function(self, player, to_select, selected)
    return #selected < 3 and not player:prohibitDiscard(to_select) and
      table.every(selected, function (id)
        return Fk:getCardById(id):compareSuitWith(Fk:getCardById(to_select))
      end)
  end,
  target_filter = function(self, player, to_select, selected, cards)
    return #cards == 3 and #selected == 0 and player:inMyAttackRange(to_select, nil, cards)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    room:setPlayerMark(player, "@@fuluan-turn", 1)
    room:throwCard(effect.cards, fuluan.name, player, player)
    if not to.dead then
      to:turnOver()
    end
  end,
})

fuluan:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and
      player:hasSkill(fuluan.name, true) and data.card.trueName == "slash"
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "fuluan-phase", 1)
  end,
})

fuluan:addAcquireEffect(function (self, player, is_start)
  if player.room.current == player then
    player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      if use.from == player and use.card.trueName == "slash" then
        player.room:setPlayerMark(player, "fuluan-phase", 1)
        return true
      end
    end, Player.HistoryTurn)
  end
end)

fuluan:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return player:getMark("@@fuluan-turn") > 0 and card and card.trueName == "slash"
  end,
})

return fuluan
