local xiayong = fk.CreateSkill {
  name = "fhyx_ex__xiayong",
}

Fk:loadTranslationTable{
  ["fhyx_ex__xiayong"] = "狭勇",
  [":fhyx_ex__xiayong"] = "结束阶段，若你本回合使用的【杀】和【决斗】均对目标角色造成了伤害，你可以摸等同于这些伤害值的牌。",
}

xiayong:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(xiayong.name) and player.phase == Player.Finish then
      local yes, n = true, 0
      player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data
        if use.from == player and (use.card.trueName == "slash" or use.card.trueName == "duel") then
          if use.damageDealt then
            local tmp = n
            for _, p in ipairs(use.tos) do
              if use.damageDealt[p] then
                n = n + use.damageDealt[p]
              end
            end
            if n == tmp then
              yes = false
              return true
            end
          else
            yes = false
            return true
          end
        end
      end, Player.HistoryTurn)
      if yes and n > 0 then
        event:setCostData(self, {choice = n})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(event:getCostData(self).choice, xiayong.name)
  end,
})

return xiayong
