local duyi = fk.CreateSkill {
  name = "duyi",
}

Fk:loadTranslationTable{
  ["duyi"] = "毒医",
  [":duyi"] = "出牌阶段限一次，你可以亮出牌堆顶的一张牌并交给一名角色，若此牌为黑色，该角色不能使用或打出手牌直到回合结束。",

  ["#duyi"] = "毒医：亮出牌堆顶牌并交给一名角色，若为黑色，其本回合不能使用打出手牌",
  ["#duyi-choose"] = "毒医：将 %arg 交给一名角色",
  ["@@duyi-turn"] = "毒医",
}

duyi:addEffect("active", {
  anim_type = "control",
  prompt = "#duyi",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(duyi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local cards = room:getNCards(1)
    room:turnOverCardsFromDrawPile(player, cards, duyi.name)
    local card = Fk:getCardById(cards[1])
    local isBlack = card.color == Card.Black
    local to = room:askToChoosePlayers(player, {
      targets = room.alive_players, Util.IdMapper,
      min_num = 1,
      max_num = 1,
      prompt = "#duyi-choose:::"..card:toLogString(),
      skill_name = duyi.name,
      cancelable = false,
    })[1]
    room:moveCardTo(cards, Player.Hand, to, fk.ReasonGive, duyi.name, nil, true, player)
    if not to.dead and isBlack then
      room:setPlayerMark(to, "@@duyi-turn", 1)
    end
  end,
})

duyi:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    if player:getMark("@@duyi-turn") > 0 then
      local subcards = Card:getIdList(card)
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
  prohibit_response = function(self, player, card)
    if player:getMark("@@duyi-turn") > 0 then
      local subcards = Card:getIdList(card)
      return #subcards > 0 and table.every(subcards, function(id)
        return table.contains(player:getCardIds("h"), id)
      end)
    end
  end,
})

return duyi
