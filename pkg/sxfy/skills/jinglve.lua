
local jinglve = fk.CreateSkill {
  name = "sxfy__jinglve",
}

Fk:loadTranslationTable{
  ["sxfy__jinglve"] = "景略",
  [":sxfy__jinglve"] = "其他角色弃牌阶段开始时，你可以展示并交给其两张牌，令其本阶段不能弃置这些牌，然后你可以于本阶段结束时获得本阶段弃置的"..
  "一张牌。",

  ["#sxfy__jinglve-invoke"] = "景略：交给 %dest 两张牌，其本阶段不能弃置这些牌，本阶段结束时你可以获得一张弃置牌",
  ["@@sxfy__jinglve-phase"] = "景略",
  ["#sxfy__jinglve-prey"] = "景略：你可以获得其中一张牌",
}

jinglve:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(jinglve.name) and target.phase == Player.Discard and not target.dead and
      #player:getCardIds("he") > 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 2,
      max_num = 2,
      include_equip = true,
      skill_name = jinglve.name,
      prompt = "#sxfy__jinglve-invoke::"..target.id,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {tos = {target}, cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(event:getCostData(self).cards)
    player:showCards(cards)
    cards = table.filter(cards, function (id)
      return table.contains(player:getCardIds("he"), id)
    end)
    if #cards == 0 or target.dead then return end
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, jinglve.name, nil, true, player, "@@sxfy__jinglve-phase")
  end,
})

jinglve:addEffect(fk.EventPhaseEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Discard and player:usedSkillTimes(jinglve.name, Player.HistoryPhase) > 0 and
      not player.dead
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    room.logic:getEventsByRule(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(room.discard_pile, info.cardId) then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end, nil, Player.HistoryPhase)
    if #cards > 0 then
      local card = room:askToChooseCards(player, {
        target = player,
        min = 0,
        max = 1,
        flag = { card_data = {{ "discard_pile", cards }} },
        skill_name = jinglve.name,
        prompt = "#sxfy__jinglve-prey",
      })
      if #card > 0 then
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonJustMove, jinglve.name, nil, true, player)
      end
    end
  end,
})

jinglve:addEffect("prohibit", {
  prohibit_discard = function(self, player, card)
    return card and card:getMark("@@sxfy__jinglve-phase") > 0 and player.phase == Player.Discard
  end,
})

return jinglve
