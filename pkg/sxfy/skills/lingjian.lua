local lingjian = fk.CreateSkill {
  name = "sxfy__lingjian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__lingjian"] = "令荐",
  [":sxfy__lingjian"] = "锁定技，当你每回合首次使用【杀】结算结束后，若未造成伤害，〖明识〗视为未发动过。",
}

lingjian:addEffect(fk.CardUseFinished, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(lingjian.name) and
      data.card.trueName == "slash" and not data.damageDealt and
      player:usedSkillTimes("sxfy__mingship", Player.HistoryGame) > 0 then
      local use_events = player.room.logic:getEventsOfScope(GameEvent.UseCard, 1, function (e)
        local use = e.data
        return use.card.trueName == "slash" and use.from == player
      end, Player.HistoryTurn)
      return #use_events == 1 and use_events[1].data == data
    end
  end,
  on_use = function(self, event, target, player, data)
    player:setSkillUseHistory("sxfy__mingship", 0, Player.HistoryGame)
  end,
})

return lingjian
