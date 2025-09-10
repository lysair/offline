local anchao = fk.CreateSkill {
  name = "anchao",
}

Fk:loadTranslationTable{
  ["anchao"] = "安朝",
  [":anchao"] = "每个回合结束时，本回合每有一名角色使用过虚拟牌或转化牌，你可以摸一张牌并令〖定西〗可发动次数+1。",
}

anchao:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(anchao.name) and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        return e.data.card:isVirtual()
      end, Player.HistoryTurn) > 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local players = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
      local use = e.data
      if use.card:isVirtual() then
        table.insertIfNeed(players, use.from)
      end
    end, Player.HistoryTurn)
    if player:hasSkill("ofl__dingxi", true) then
      room:addPlayerMark(player, "ofl__dingxi", #players)
    end
    player:drawCards(#players, anchao.name)
  end,
})

return anchao
