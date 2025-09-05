local jiufa = fk.CreateSkill {
  name = "sxfy__jiufa",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["sxfy__jiufa"] = "九伐",
  [":sxfy__jiufa"] = "限定技，准备阶段，若你的体力上限大于9，你可以减9点体力上限，然后亮出牌堆顶九张牌，依次使用之"..
  "（不能使用则置入手牌）。",

  ["#sxfy__jiufa-use"] = "九伐：请使用%arg",
}

jiufa:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiufa.name) and player.phase == Player.Start and
      player.maxHp > 9 and player:usedSkillTimes(jiufa.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -9)
    if player.dead then return end
    local all_cards = room:getNCards(9)
    local cards = table.simpleClone(all_cards)
    room:turnOverCardsFromDrawPile(player, cards, jiufa.name)
    for i = 1, #all_cards do
      local id = all_cards[i]
      local use = room:askToUseRealCard(player, {
        pattern = {id},
        skill_name = jiufa.name,
        prompt = "#sxfy__jiufa-use:::"..Fk:getCardById(id):toLogString(),
        extra_data = {
          bypass_times = true,
          extraUse = true,
          expand_pile = cards,
        },
        cancelable = false,
      })
      if not use then
        room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonJustMove, jiufa.name, nil, true, player)
      end
      cards = table.filter(all_cards, function (c)
        return room:getCardArea(c) == Card.Processing
      end)
      if player.dead or #cards == 0 then break end
    end
    room:cleanProcessingArea(cards)
  end,
})

return jiufa
