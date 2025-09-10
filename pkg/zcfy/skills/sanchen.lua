local sanchen = fk.CreateSkill {
  name = "sxfy__sanchen",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["sxfy__sanchen"] = "三陈",
  [":sxfy__sanchen"] = "觉醒技，结束阶段，若你装备区内有至少三张装备牌，你加1点体力上限，回复1点体力，然后获得技能〖灭吴〗。",
}

sanchen:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sanchen.name) and player.phase == Player.Finish and
      player:usedSkillTimes(sanchen.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return #player:getCardIds("e") > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, 1)
    if player.dead then return end
    room:recover{
      who = player,
      num = 1,
      skillName = sanchen.name,
    }
    if player.dead then return end
    room:handleAddLoseSkills(player, "sxfy__miewu")
  end,
})

return sanchen
