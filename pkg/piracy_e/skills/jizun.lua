local jizun = fk.CreateSkill {
  name = "jizun",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["jizun"] = "极尊",
  [":jizun"] = "觉醒技，当你脱离濒死状态时，你获得技能〖清算〗；若你已拥有〖清算〗，则改为回复体力至体力上限。",

  ["$jizun1"] = "立事立功，开国称孤；朱轮朱毂，拥旄万里。",
  ["$jizun2"] = "龙潜出震，握符御极；鞭笞四海，率土兴仁。",
}

jizun:addEffect(fk.AfterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jizun.name) and player:usedSkillTimes(jizun.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not player:hasSkill("qingsuan", true) then
      room:handleAddLoseSkills(player, "qingsuan")
    elseif player:isWounded() then
      room:recover({
        who = player,
        num = player.maxHp - player.hp,
        recoverBy = player,
        skillName = jizun.name,
      })
    end
  end,
})

return jizun
