local jilis = fk.CreateSkill{
  name = "sxfy__jilis",
}

Fk:loadTranslationTable{
  ["sxfy__jilis"] = "蒺藜",
  [":sxfy__jilis"] = "每阶段限一次，你的出牌阶段内，当你本回合内使用或打出第X张牌时，你可以摸X张牌（X为你的攻击范围）。",
}

local spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(jilis.name) and
      player.phase == Player.Play and player:usedSkillTimes(jilis.name, Player.HistoryPhase) == 0 then
      local x, y = player:getAttackRange(), player:getMark("jilis_times-turn")
      if x >= y then
        local room = player.room
        y = #room.logic:getEventsByRule(GameEvent.UseCard, x + 1, function (e)
          return e.data.from == player
        end, nil, Player.HistoryTurn) +
        #room.logic:getEventsByRule(GameEvent.RespondCard, x + 1, function (e)
          return e.data.from == player
        end, nil, Player.HistoryTurn)
        room:setPlayerMark(player, "jilis_times-turn", y)
        return x == y
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getAttackRange(), jilis.name)
  end,
}
jilis:addEffect(fk.CardUsing, spec)
jilis:addEffect(fk.CardResponding, spec)

return jilis
