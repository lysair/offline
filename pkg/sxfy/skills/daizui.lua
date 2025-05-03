local daizui = fk.CreateSkill {
  name = "sxfy__daizui",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__daizui"] = "戴罪",
  [":sxfy__daizui"] = "锁定技，当你受到伤害后，〖盗书〗视为本轮未发动过。",
}

daizui:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(daizui.name) and
      player:usedSkillTimes("sxfy__daoshu", Player.HistoryRound) > 0
  end,
  on_use = function(self, event, target, player, data)
    player:setSkillUseHistory("sxfy__daoshu", 0, Player.HistoryRound)
  end,
})

return daizui
