
local lirang = fk.CreateSkill {
  name = "sxfy__lirang",
}

Fk:loadTranslationTable{
  ["sxfy__lirang"] = "礼让",
  [":sxfy__lirang"] = "一名角色弃牌阶段结束时，你可以交给其一张牌，然后获得此阶段进入弃牌堆的红色牌。",

  ["#sxfy__lirang-invoke"] = "礼让：交给 %dest 一张牌，获得此阶段进入弃牌堆的红色牌",
}

lirang:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(lirang.name) and target.phase == Player.Discard and not target.dead then
      if target == player then
        return #player:getCardIds("e") > 0
      else
        return not player:isNude()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = lirang.name,
      pattern = target == player and ".|.|.|equip" or ".",
      prompt = "#sxfy__lirang-invoke::"..target.id,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, target, fk.ReasonGive, lirang.name, nil, false, player)
    if player.dead then return end
    local cards = {}
    room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(room.discard_pile, info.cardId) and
              Fk:getCardById(info.cardId).color == Card.Red then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, nil, Player.HistoryPhase)
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, lirang.name, nil, true, player)
    end
  end,
})

return lirang
