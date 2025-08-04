local qingjin = fk.CreateSkill({
  name = "ofl__qingjin",
})

Fk:loadTranslationTable{
  ["ofl__qingjin"] = "黥金",
  [":ofl__qingjin"] = "一名角色摸牌阶段结束时，若其此阶段摸牌数大于两张，你可以视为对其使用一张【杀】，若此【杀】未造成伤害，你失去1点体力。",

  ["#ofl__qingjin-invoke"] = "黥金：你可以视为对 %dest 使用【杀】，若未造成伤害你失去体力",
}

qingjin:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player and player:hasSkill(qingjin.name) and target.phase == Player.Draw and
      not target.dead and player:canUseTo(Fk:cloneCard("slash"), target, { bypass_distances = true, bypass_times = true }) then
      local n = 0
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
        for _, move in ipairs(e.data) do
          if move.to == target and move.moveReason == fk.ReasonDraw then
            n = n + #move.moveInfo
          end
        end
      end, Player.HistoryPhase)
      return n > 2
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qingjin.name,
      prompt = "#ofl__qingjin-invoke::"..target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local use = room:useVirtualCard("slash", nil, player, target, qingjin.name, true)
    if not (use and use.damageDealt) and not player.dead then
      room:loseHp(player, 1, qingjin.name)
    end
  end,
})

return qingjin
