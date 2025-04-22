local zhengan = fk.CreateSkill {
  name = "ofl__zhengan",
}

Fk:loadTranslationTable{
  ['ofl__zhengan'] = '桢干',
  ['#ofl__zhengan-choose'] = '桢干：你可以令其中至多两名角色依次视为使用一张基本牌',
  ['#ofl__zhengan-use'] = '桢干：你可以视为使用一张基本牌',
  [':ofl__zhengan'] = '每个回合结束时，若本回合有角色交给过其他角色手牌，或计算距离与回合开始时不同，你可以令其中至多两名角色依次可以视为使用一张基本牌。',
}

zhengan:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zhengan.name) then
      local room = player.room
      local targets = {}
      if #room.logic:getEventsOfScope(GameEvent.Death, 1, Util.TrueFunc, Player.HistoryTurn) > 0 then
        targets = table.map(room.alive_players, Util.IdMapper)
      else
        room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
          for _, move in ipairs(e.data) do
            if move.from and move.to and move.toArea == Card.PlayerHand and move.moveReason == fk.ReasonGive and
              not room:getPlayerById(move.from).dead then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand then
                  table.insertIfNeed(targets, move.from)
                end
              end
            end
          end
        end, Player.HistoryTurn)
        if player:getMark("ofl__zhengan-turn") ~= 0 then
          for _, mark in ipairs(player:getMark("ofl__zhengan-turn")) do
            local p = room:getPlayerById(mark[1])
            for _, info in ipairs(mark[2]) do
              local q = room:getPlayerById(info[1])
              if p:distanceTo(q) ~= info[2] then
                table.insertIfNeed(targets, mark[1])
                break
              end
            end
          end
        end
      end
      if #targets > 0 then
        event:setCostData(self, targets)
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = event:getCostData(self),
      min_num = 1,
      max_num = 2,
      skill_name = zhengan.name,
      prompt = "#ofl__zhengan-choose",
    })
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = U.getUniversalCards(room, "b")
    for _, id in ipairs(event:getCostData(self).tos) do
      local p = room:getPlayerById(id)
      if not p.dead then
        local use = room:askToUseRealCard(p, {
          pattern = cards,
          skill_name = zhengan.name,
          prompt = "#ofl__zhengan-use",
          cancelable = true,
          skip = true,
          expand_pile = cards,
          extra_data = {bypass_times = true},
        })
        if use then
          use = {
            card = Fk:cloneCard(use.card.name),
            from = p.id,
            tos = use.tos,
            extraUse = true,
          }
          use.card.skillName = zhengan.name
          room:useCard(use)
        end
      end
    end
  end,

  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(zhengan.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      local info = {}
      for _, q in ipairs(room:getOtherPlayers(p)) do
        table.insert(info, {q.id, p:distanceTo(q)})
      end
      room:addTableMark(player, "ofl__zhengan-turn", {p.id, info})
    end
  end,
})

return zhengan
