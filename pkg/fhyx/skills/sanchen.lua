local sanchen = fk.CreateSkill{
  name = "ofl_shiji__sanchen",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["ofl_shiji__sanchen"] = "三陈",
  [":ofl_shiji__sanchen"] = "觉醒技，准备阶段或结束阶段，若你的“武库”标记为3，你加1点体力上限，回复1点体力，获得〖灭吴〗。",

  ["$ofl_shiji__sanchen1"] = "今便可荡平吴都，陛下何舍而不取？",
  ["$ofl_shiji__sanchen2"] = "天下思定已久，陛下当成四海之愿。",
}

sanchen:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sanchen.name) and
      (player.phase == Player.Start or player.phase == Player.Finish) and
      player:usedSkillTimes(sanchen.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("@wuku") == 3
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player.dead then return end
    if player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        skillName = sanchen.name,
      }
      if player.dead then return end
    end
    room:handleAddLoseSkills(player, "ofl_shiji__miewu")
  end,
})

return sanchen
