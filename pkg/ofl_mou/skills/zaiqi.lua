local zaiqi = fk.CreateSkill {
  name = "ofl_mou__zaiqi",
}

Fk:loadTranslationTable{
  ["ofl_mou__zaiqi"] = "再起",
  [":ofl_mou__zaiqi"] = "弃牌阶段结束时，你可以令至多X名角色依次选择一项（X为你本回合弃置过的牌数）：" ..
  "1.令你摸一张牌；2.弃置一张牌，你回复1点体力。",

  ["#ofl_mou__zaiqi-choose"] = "再起：令至多%arg名角色选择：你摸一张牌，或弃置一张牌令你回复体力",
  ["#ofl_mou__zaiqi-discard"] = "再起：弃置一张牌令 %src 回复1点体力，或点“取消”其摸一张牌",

  ["$ofl_mou__zaiqi1"] = "山辟路窄，误遭汝手，如何肯服？",
  ["$ofl_mou__zaiqi2"] = "待我重整兵马，来日一决雌雄！",
}

zaiqi:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zaiqi.name) and player.phase == Player.Discard and
      #player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.moveReason == fk.ReasonDiscard and move.proposer == player then
            return true
          end
        end
      end, Player.HistoryTurn) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
      for _, move in ipairs(e.data) do
        if move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard and move.proposer == player then
          n = n + #move.moveInfo
        end
      end
    end, Player.HistoryTurn)
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = n,
      targets = room.alive_players,
      skill_name = zaiqi.name,
      prompt = "#ofl_mou__zaiqi-choose:::"..n,
      cancelable = true,
    })
    if #tos > 0 then
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(event:getCostData(self).tos) do
      if player.dead then return end
      if not p.dead then
        if not p:isNude() and
          #room:askToDiscard(p, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = zaiqi.name,
            prompt = "#ofl_mou__zaiqi-discard:" .. player.id,
            cancelable = true,
          }) > 0 then
          if player:isWounded() and not player.dead then
            room:recover{
              who = player,
              num = 1,
              recoverBy = p,
              skillName = zaiqi.name
            }
          end
        else
          player:drawCards(1, zaiqi.name)
        end
      end
    end
  end,
})

return zaiqi
