local shuyong = fk.CreateSkill {
  name = "sxfy__shuyong",
}

Fk:loadTranslationTable{
  ["sxfy__shuyong"] = "姝勇",
  [":sxfy__shuyong"] = "当其他角色于其回合内连续使用两张同名牌时，你可以摸一张牌。",
}

shuyong:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(shuyong.name) and player.room.current == target then
      local use_events = player.room.logic:getEventsByRule(GameEvent.UseCard, 1, function(e)
        if e.id < player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard, true).id then
          local use = e.data
          if use.from == target then
            return true
          end
        end
      end, nil, Player.HistoryTurn)
      return #use_events == 1 and use_events[1].data.card.trueName == data.card.trueName
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, shuyong.name)
  end,
})

return shuyong
