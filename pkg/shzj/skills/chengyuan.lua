local chengyuan = fk.CreateSkill {
  name = "chengyuan",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["chengyuan"] = "承缘",
  [":chengyuan"] = "限定技，当你或女性角色进入濒死状态时，你可以令其回复体力至体力上限。",

  ["#chengyuan-invoke"] = "承缘：是否令 %dest 回复体力至体力上限？",
}

chengyuan:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chengyuan.name) and
      player:usedSkillTimes(chengyuan.name, Player.HistoryGame) == 0 and
      (target == player or target:isFemale()) and target.dying
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = chengyuan.name,
      prompt = "#chengyuan-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover {
      who = target,
      num = target.maxHp - target.hp,
      recoverBy = player,
      skillName = chengyuan.name,
    }
  end,
})

return chengyuan
