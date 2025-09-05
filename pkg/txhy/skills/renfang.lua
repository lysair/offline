local renfang = fk.CreateSkill {
  name = "ofl_tx__renfang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__renfang"] = "人方",
  [":ofl_tx__renfang"] = "锁定技，当你使用或打出的一张牌进入弃牌堆后，你获得一枚“人方”标记。"..
  "每有一枚“人方”，你的手牌上限+1；每有五枚“人方”，你出牌阶段使用【杀】次数+1。",

  ["@ofl_tx__renfang"] = "人方",

  ["$ofl_tx__renfang1"] = "集民力万千，亦可为军！",
  ["$ofl_tx__renfang2"] = "集万千义军，定天下大局！",
}

renfang:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(renfang.name) then
      for _, move in ipairs(data) do
        if move.from == nil and (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResponse) then
          local move_event = player.room.logic:getCurrentEvent()
          local use_event = move_event.parent
          if use_event ~= nil and (use_event.event == GameEvent.UseCard or use_event.event == GameEvent.RespondCard) then
            local use = use_event.data
            if use.from == player then
              for _, info in ipairs(move.moveInfo) do
                if table.contains(Card:getIdList(use.card), info.cardId) and
                  table.contains(player.room.discard_pile, info.cardId) then
                  return true
                end
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, move in ipairs(data) do
      if move.from == nil and (move.moveReason == fk.ReasonUse or move.moveReason == fk.ReasonResponse) then
        local move_event = room.logic:getCurrentEvent():findParent(GameEvent.MoveCards)
        if move_event then
          local use_event = move_event.parent
          if use_event ~= nil and (use_event.event == GameEvent.UseCard or use_event.event == GameEvent.RespondCard) then
            local use = use_event.data
            if use.from == player then
              for _, info in ipairs(move.moveInfo) do
                if table.contains(Card:getIdList(use.card), info.cardId) and
                  table.contains(room.discard_pile, info.cardId) then
                  n = n + 1
                end
              end
            end
          end
        end
      end
    end
    room:addPlayerMark(player, "@ofl_tx__renfang", n)
  end,
})

renfang:addEffect("maxcards", {
  correct_func = function(self, player)
    return player:hasSkill(renfang.name) and player:getMark("@ofl_tx__renfang") or 0
  end,
})

renfang:addEffect("targetmod", {
  residue_func = function (self, player, skill, scope, card, to)
    if player:hasSkill(renfang.name) and player:getMark("@ofl_tx__renfang") > 4 and
      card and card.trueName == "slash" and scope == Player.HistoryPhase then
      return player:getMark("@ofl_tx__renfang") // 5
    end
  end,
})

renfang:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@ofl_tx__renfang", 0)
end)

return renfang
