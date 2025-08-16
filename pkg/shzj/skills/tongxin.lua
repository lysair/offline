local tongxin = fk.CreateSkill{
  name = "tongxin",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["tongxin"] = "同心",
  [":tongxin"] = "锁定技，当你或“结衣”角色摸牌阶段结束时，对方摸等同于此阶段摸牌数的牌。",
}

tongxin:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(tongxin.name) and target.phase == Player.Draw then
      if target == player then
        if player:getMark("@jieyi-round") == 0 or player:getMark("@jieyi-round").dead then
          return
        end
      elseif target ~= player:getMark("@jieyi-round") then
        return
      end
      return #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.to == target and move.moveReason == fk.ReasonDraw then
            return true
          end
        end
      end, Player.HistoryPhase) > 0
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.to == target and move.moveReason == fk.ReasonDraw then
          n = n + #move.moveInfo
        end
      end
    end, Player.HistoryPhase)
    if target == player then
      player:getMark("@jieyi-round"):drawCards(n, tongxin.name)
    elseif target == player:getMark("@jieyi-round") then
      player:drawCards(n, tongxin.name)
    end
  end,
})

return tongxin
