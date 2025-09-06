
local duanyuan = fk.CreateSkill{
  name = "ofl_tx__duanyuan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__duanyuan"] = "断援",
  [":ofl_tx__duanyuan"] = "锁定技，当你获得牌后，你将这些牌置入弃牌堆。",
}

duanyuan:addEffect(fk.AfterCardsMove, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(duanyuan.name) and player:usedSkillTimes(duanyuan.name, Player.HistoryTurn) < 20 and
      not player:isNude() then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerHand then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getCardIds("h"), info.cardId) then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, duanyuan.name, nil, true, player)
  end,
})

return duanyuan
