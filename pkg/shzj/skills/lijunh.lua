local lijunh = fk.CreateSkill{
  name = "shzj_juedai__lijunh",
}

Fk:loadTranslationTable{
  ["shzj_juedai__lijunh"] = "励军",
  [":shzj_juedai__lijunh"] = "准备阶段，你可以令任意名已受伤角色各摸一张牌；结束阶段，若你本回合未弃置过牌，你回复1点体力。",

  ["#shzj_juedai__lijunh-choose"] = "励战：你可以令任意名已受伤角色各摸一张牌",
}

lijunh:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(lijunh.name) then
      if player.phase == Player.Start then
        return table.find(player.room.alive_players, function(p)
          return p:isWounded()
        end)
      elseif player.phase == Player.Finish and player:isWounded() then
        return #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
          for _, move in ipairs(e.data) do
            if move.from == player and move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  return true
                end
              end
            end
          end
        end, Player.HistoryTurn) == 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if player.phase == Player.Start then
      local room = player.room
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 9,
        targets = table.filter(room.alive_players, function(p)
          return p:isWounded()
        end),
        skill_name = lijunh.name,
        prompt = "#shzj_juedai__lijunh-choose",
        cancelable = true,
      })
      if #tos > 0 then
        room:sortByAction(tos)
        event:setCostData(self, {tos = tos})
        return true
      end
    elseif player.phase == Player.Finish then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if player.phase == Player.Start then
      for _, p in ipairs(event:getCostData(self).tos) do
        if not p.dead then
          p:drawCards(1, lijunh.name)
        end
      end
    elseif player.phase == Player.Finish then
      player.room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = lijunh.name,
      }
    end
  end,
})

return lijunh
