local duyi = fk.CreateSkill {
  name = "duyi"
}

Fk:loadTranslationTable{
  ['duyi'] = '毒医',
  ['#duyi'] = '毒医: 你可以亮出牌堆顶的一张牌并交给一名角色',
  ['#duyi-choose'] = '毒医: 将 %arg 交给一名角色',
  ['@@duyi-turn'] = '毒医',
  [':duyi'] = '出牌阶段限一次，你可以亮出牌堆顶的一张牌并交给一名角色，若此牌为黑色，该角色不能使用或打出其手牌，直到回合结束。',
}

duyi:addEffect('active', {
  anim_type = "control",
  can_use = function(self, player)
    return player:usedSkillTimes(duyi.name, Player.HistoryPhase) == 0
  end,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_num = 0,
  prompt = "#duyi",
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = room:getNCards(1)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = duyi.name,
      proposer = player.id,
    })
    local card = Fk:getCardById(cards[1])
    local isBlack = card.color == Card.Black
    local tos = room:askToChoosePlayers(player, {
      targets = table.map(room.alive_players, Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#duyi-choose:::"..card:toLogString(),
      skill_name = duyi.name,
      cancelable = false
    })
    local to = room:getPlayerById(tos[1])
    room:moveCardTo(cards, Player.Hand, to, fk.ReasonGive, duyi.name, nil, true, player.id)
    if not to.dead and isBlack then
      room:setPlayerMark(to, "@@duyi-turn", 1)
    end
  end,
})

duyi:addEffect('prohibit', {
  name = "#duyi_prohibit",
  prohibit_use = function(self, player, card)
    if player:getMark("@@duyi-turn") > 0 then
      local subcards = Card:getIdList(card)
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@duyi-turn") > 0 then
      local subcards = Card:getIdList(card)
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds(Player.Hand), id)
      end)
    end
  end,
})

return duyi
