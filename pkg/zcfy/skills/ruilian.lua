local ruilian = fk.CreateSkill {
  name = "sxfy__ruilian",
}

Fk:loadTranslationTable{
  ["sxfy__ruilian"] = "睿敛",
  [":sxfy__ruilian"] = "每轮限一次，一名角色的弃牌阶段结束时，若其此阶段弃置过至少两张类别相同的牌，你可以令你与其各获得其中一张牌。",

  ["#sxfy__ruilian-invoke"] = "睿敛：你可以与 %dest 各获得一张弃置的牌",
  ["#sxfy__ruilian-prey"] = "睿敛：获得一张弃置的牌",
}

ruilian:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(ruilian.name) and target.phase == Player.Discard and
      player:usedSkillTimes(ruilian.name, Player.HistoryRound) == 0 then
      local ids, dat = {}, {}
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.from == target and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              local type = Fk:getCardById(info.cardId).type
              dat[type] = dat[type] or {}
              table.insertIfNeed(dat[type], info.cardId)
              if table.contains(player.room.discard_pile, info.cardId) then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          end
        end
      end, Player.HistoryPhase)
      if #ids > 0 then
        event:setCostData(self, {cards = ids})
        for _, info in pairs(dat) do
          if #info > 1 then
            return true
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = ruilian.name,
      prompt = "#sxfy__ruilian-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}, cards = event:getCostData(self).cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local card = room:askToChooseCard(player, {
      target = player,
      flag = { card_data = {{ "pile_discard", cards }} },
      skill_name = ruilian.name,
      prompt = "#sxfy__ruilian-prey",
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, ruilian.name, nil, true, player)
    if target.dead then return end
    cards = table.filter(cards, function (id)
      return table.contains(room.discard_pile, id)
    end)
    if #cards == 0 then return end
    card = room:askToChooseCard(target, {
      target = target,
      flag = { card_data = {{ "pile_discard", cards }} },
      skill_name = ruilian.name,
      prompt = "#sxfy__ruilian-prey",
    })
    room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonJustMove, ruilian.name, nil, true, target)
  end,
})

return ruilian
