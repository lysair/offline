local fujij = fk.CreateSkill {
  name = "fujij",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["fujij"] = "扶稷",
  [":fujij"] = "限定技，结束阶段，若一号位本局于其回合内弃置过牌，你可以于本回合结束后执行一个额外回合；"..
  "当你于额外回合内杀死角色后，你摸三张牌，回复体力至体力上限，令此技能视为未发动过。",

  ["$fujij1"] = "",
  ["$fujij2"] = "",
}

fujij:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fujij.name) and player.phase == Player.Finish and
      player:getMark(fujij.name) > 0 and player:usedSkillTimes(fujij.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraTurn(true, fujij.name)
  end,
})

fujij:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if player:getMark(fujij.name) == 0 and
      player.room:getCurrent() and player.room:getCurrent().seat == 1 then
      for _, move in ipairs(data) do
        if move.from and move.from.seat == 1 and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, fujij.name, 1)
  end,
})

fujij:addEffect(fk.Deathed, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fujij.name) and
      data.killer == player and player:insideExtraTurn()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(fujij.name)
    room:notifySkillInvoked(player, self.name, "drawcard")
    player:drawCards(3, fujij.name)
    if player.dead then return end
    if player:isWounded() then
      room:recover{
        who = player,
        num = player.maxHp - player.hp,
        recoverBy = player,
        skillName = fujij.name,
      }
      if player.dead then return end
    end
    player:setSkillUseHistory(fujij.name, 0, Player.HistoryGame)
  end,
})

fujij:addAcquireEffect(function (self, player, is_start)
  if not is_start and player:getMark(fujij.name) == 0 then
    local room = player.room
    local lord = room:getPlayerBySeat(1)
    local turn_events = room.logic:getEventsOfScope(GameEvent.Turn, 999, function (e)
      return e.data.who == lord
    end, Player.HistoryGame)
    if #turn_events > 0 then
      if table.find(turn_events, function (e)
        return #e:searchEvents(GameEvent.MoveCards, 1, function (e2)
          for _, move in ipairs(e2.data) do
            if move.from == lord and move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                  return true
                end
              end
            end
          end
        end) > 0
      end) then
        room:setPlayerMark(player, fujij.name, 1)
      end
    end
  end
end)

return fujij
