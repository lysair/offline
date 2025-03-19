local sgsh__qiaoyan = fk.CreateSkill {
  name = "sgsh__qiaoyan"
}

Fk:loadTranslationTable{
  ['sgsh__qiaoyan'] = '巧言',
  ['sgsh__kuizhul'] = '馈珠',
  [':sgsh__qiaoyan'] = '一名角色结束阶段，若你本回合发动过〖馈珠〗，你可以回复1点体力。',
  ['$sgsh__qiaoyan1'] = '金银渐欲迷人眼，利字当前诱汝行！',
  ['$sgsh__qiaoyan2'] = '以利驱虎，无往不利！',
}

sgsh__qiaoyan:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(sgsh__qiaoyan) and player:usedSkillTimes("sgsh__kuizhul", Player.HistoryTurn) > 0 and player:isWounded()
  end,
  on_use = function(self, event, target, player)
    player.room:recover({
      who = player,
      num = 1,
      recoverBy = player,
      skill_name = sgsh__qiaoyan.name,
    })
  end,
})

return sgsh__qiaoyan
