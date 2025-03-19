local jizun = fk.CreateSkill {
  name = "jizun"
}

Fk:loadTranslationTable{
  ['jizun'] = '极尊',
  ['qingsuan'] = '清算',
  [':jizun'] = '觉醒技，当你脱离濒死状态时，你获得技能〖清算〗；若你已拥有〖清算〗，则改为回复体力至体力上限。',
  ['$jizun1'] = '立事立功，开国称孤；朱轮朱毂，拥旄万里。',
  ['$jizun2'] = '龙潜出震，握符御极；鞭笞四海，率土兴仁。',
}

jizun:addEffect(fk.AfterDying, {
  anim_type = "support",
  frequency = Skill.Wake,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(skill.name) and player:usedSkillTimes(jizun.name, Player.HistoryGame) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player)
    local room = player.room
    if not player:hasSkill("qingsuan", true) then
      room:handleAddLoseSkills(player, "qingsuan", nil, true, false)
    elseif player:isWounded() then
      room:recover({
        who = player,
        num = player:getLostHp(),
        recoverBy = player,
        skillName = jizun.name,
      })
    end
  end,
})

return jizun
