local kaishi = fk.CreateSkill {
  name = "ofl_tx__kaishi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__kaishi"] = "慨逝",
  [":ofl_tx__kaishi"] = "锁定技，当你受到伤害后，你令伤害来源获得一枚“慨”标记。有“慨”标记的角色手牌上限-X（X为其“慨”标记数）；"..
  "其弃牌阶段结束时，若其此阶段弃置了牌，你摸等量的牌，然后移去其所有“慨”标记。",

  ["@ofl_tx__kaishi"] = "慨",
}

kaishi:addEffect(fk.Damaged, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kaishi.name) and
      data.from and not data.from.dead
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.from}})
    return true
  end,
  on_use = function (self, event, target, player, data)
    player.room:addPlayerMark(data.from, "@ofl_tx__kaishi", 1)
  end,
})

kaishi:addEffect("maxcards", {
  correct_func = function(self, player)
    return -player:getMark("@ofl_tx__kaishi")
  end,
})

kaishi:addEffect(fk.EventPhaseEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(kaishi.name) and target:getMark("@ofl_tx__kaishi") > 0 and target.phase == Player.Discard and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          return move.from == target and move.moveReason == fk.ReasonDiscard
        end
      end, Player.HistoryPhase) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.from == target and move.moveReason == fk.ReasonDiscard then
          n = n + #move.moveInfo
        end
      end
    end, Player.HistoryPhase)
    room:setPlayerMark(target, "@ofl_tx__kaishi", 0)
    player:drawCards(n, kaishi.name)
  end,
})

kaishi:addLoseEffect(function (self, player, is_death)
  local room = player.room
  for _, p in ipairs(room.alive_players) do
    room:setPlayerMark(p, "@ofl_tx__kaishi", 0)
  end
end)

return kaishi
