local qibu = fk.CreateSkill {
  name = "qibu",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["qibu"] = "七步",
  [":qibu"] = "限定技，当你进入濒死状态时，你可以亮出牌堆顶七张牌，每有一张<font color='red'>♥</font>牌，你回复1点体力，然后获得其中的♣牌。",
}

qibu:addEffect(fk.EnterDying, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qibu.name) and
      player:usedSkillTimes(qibu.name, Player.HistoryGame) == 0 and
      player.dying
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(7)
    room:turnOverCardsFromDrawPile(player, cards, qibu.name)
    local n = #table.filter(cards, function (id)
      return Fk:getCardById(id).suit == Card.Heart
    end)
    if n > 0 then
      room:recover{
        who = player,
        num = n,
        recoverBy = player,
        skillName = qibu.name,
      }
    end
    if not player.dead then
      cards = table.filter(cards, function (id)
        return Fk:getCardById(id).suit == Card.Club and room:getCardArea(id) == Card.Processing
      end)
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, qibu.name, nil, true, player)
      end
    end
    room:cleanProcessingArea(cards)
  end,
})

return qibu
