local zhuying = fk.CreateSkill {
  name = "ofl__zhuying"
}

Fk:loadTranslationTable{
  ["ofl__zhuying"] = "驻营",
  [":ofl__zhuying"] = "每名角色的结束阶段，若你本回合未成为过其使用牌的目标，你获得一枚“驻”标记。",

  ["@ofl__zhuying"] = "驻",
}

zhuying:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhuying.name) and target.phase == Player.Finish and
      #player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data
        return use.from == target and table.contains(use.tos, player)
      end, Player.HistoryTurn) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@ofl__zhuying", 1)
  end,
})

zhuying:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if not table.find(room.alive_players, function (p)
    return p:hasSkill(zhuying.name, true) or p:hasSkill("ofl__chiyuan", true)
  end) then
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "@ofl__zhuying", 0)
    end
  end
end)

return zhuying
