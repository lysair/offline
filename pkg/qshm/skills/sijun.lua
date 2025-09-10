local sijun = fk.CreateSkill {
  name = "qshm__sijun",
}

Fk:loadTranslationTable{
  ["qshm__sijun"] = "肆军",
  [":qshm__sijun"] = "准备阶段，若“黄”标记数大于牌堆的牌数，你可以移去所有“黄”标记，然后重复亮出并获得牌堆顶的一张牌，"..
  "直到获得牌的点数之和不小于36，然后洗牌。",

  ["$qshm__sijun1"] = "苍天已被吾泪没，且看黄天昭太平！",
  ["$qshm__sijun2"] = "黄巾覆首，联方数万，此击可撼百年之炎汉。",
}

sijun:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sijun.name) and player.phase == Player.Start and
      player:getMark("@zhangjiao_huang") > #player.room.draw_pile
  end,
  on_use = function(self, event, tar, player)
    local room = player.room
    room:setPlayerMark(player, "@zhangjiao_huang", 0)
    local n = 0
    while n < 36 and not player.dead do
      local cards = room:getNCards(1)
      n = n + Fk:getCardById(cards[1]).number
      room:turnOverCardsFromDrawPile(player, cards, sijun.name)
      room:delay(500)
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, sijun.name, nil, false, player)
    end
    room:shuffleDrawPile()
  end,
})

return sijun
