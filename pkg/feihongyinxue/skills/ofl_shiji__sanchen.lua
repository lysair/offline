local ofl_shiji__sanchen = fk.CreateSkill{
  name = "ofl_shiji__sanchen"
}

Fk:loadTranslationTable{
  ['ofl_shiji__sanchen'] = '三陈',
  ['ofl_shiji__miewu'] = '灭吴',
  [':ofl_shiji__sanchen'] = '觉醒技，准备阶段或结束阶段，若你的“武库”标记为3，你加1点体力上限，回复1点体力，获得〖灭吴〗。',
  ['$ofl_shiji__sanchen1'] = '今便可荡平吴都，陛下何舍而不取？',
  ['$ofl_shiji__sanchen2'] = '天下思定已久，陛下当成四海之愿。',
}

ofl_shiji__sanchen:addEffect(fk.EventPhaseStart, {
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ofl_shiji__sanchen.name) and
      (player.phase == Player.Start or player.phase == Player.Finish) and
      player:usedSkillTimes(ofl_shiji__sanchen.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return player:getMark("@wuku") == 3
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player:isWounded() and not player.dead then
      room:recover{
        who = player,
        num = 1,
        skillName = ofl_shiji__sanchen.name,
      }
    end
    room:handleAddLoseSkills(player, "ofl_shiji__miewu", nil, true, false)
  end,
})

return ofl_shiji__sanchen
