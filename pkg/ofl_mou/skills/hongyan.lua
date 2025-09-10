local hongyan = fk.CreateSkill{
  name = "ofl_mou__hongyan",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_mou__hongyan"] = "红颜",
  [":ofl_mou__hongyan"] = "锁定技，你的♠牌或你的♠判定牌视为<font color='red'>♥</font>。当你每回合首次失去<font color='red'>♥</font>牌后，"..
  "你摸一张牌。",
}

hongyan:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(hongyan.name) and player:usedSkillTimes(hongyan.name, Player.HistoryTurn) == 0 then
      for _, move in ipairs(data) do
        if move.from == player and move.extra_data and move.extra_data.ofl_mou__hongyan then
          return true
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, hongyan.name)
  end,
})

hongyan:addEffect(fk.BeforeCardsMove, {
  can_refresh = function (self, event, target, player, data)
    if player:hasSkill(hongyan.name, true) then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
            Fk:getCardById(info.cardId, false).suit == Card.Heart then
            move.extra_data = move.extra_data or {}
            move.extra_data.ofl_mou__hongyan = true
          end
        end
      end
    end
  end,
})

hongyan:addEffect("filter", {
  mute = true,
  card_filter = function(self, card, player, isJudgeEvent)
    return player:hasSkill(hongyan.name) and card.suit == Card.Spade and
      (table.contains(player:getCardIds("he"), card.id) or isJudgeEvent)
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard(card.name, Card.Heart, card.number)
  end,
})

return hongyan
