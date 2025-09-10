local chunlao = fk.CreateSkill {
  name = "sxfy__chunlao",
}

Fk:loadTranslationTable{
  ["sxfy__chunlao"] = "醇醪",
  [":sxfy__chunlao"] = "弃牌阶段结束时，你可以用弃牌堆中你本阶段弃置的所有牌（至少两张）交换一名其他角色的所有手牌，然后其可以令你回复1点体力。",

  ["#sxfy__chunlao-choose"] = "醇醪：是否用你弃置的牌和一名角色的手牌交换？",
  ["#sxfy__chunlao-recover"] = "醇醪：是否令 %src 回复1点体力？",
}

chunlao:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(chunlao.name) and player.phase == Player.Discard and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isKongcheng()
      end) then
      local cards = {}
      player.room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.from == player and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if table.contains(player.room.discard_pile, info.cardId) then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          end
        end
      end, Player.HistoryPhase)
      if #cards > 1 then
        event:setCostData(self, {cards = cards})
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return not p:isKongcheng()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = chunlao.name,
      prompt = "#sxfy__chunlao-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to, cards = event:getCostData(self).cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:swapCardsWithPile(to, to:getCardIds("h"), event:getCostData(self).cards, chunlao.name, "discardPile", true, to)
    if not to.dead and not player.dead and player:isWounded() and
      room:askToSkillInvoke(to, {
        skill_name = chunlao.name,
        prompt = "#sxfy__chunlao-recover:"..player.id,
      }) then
      room:recover{
        who = player,
        num = 1,
        recoverBy = to,
        skillName = chunlao.name,
      }
    end
  end,
})

return chunlao
