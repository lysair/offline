local fuzhao = fk.CreateSkill {
  name = "fuzhao",
}

Fk:loadTranslationTable{
  ["fuzhao"] = "福照",
  [":fuzhao"] = "当一名角色进入濒死状态时，你可以令其进行一次判定，若结果为<font color='red'>♥</font>，其回复1点体力。",

  ["#fuzhao-invoke"] = "福照：是否令 %dest 判定？若为<font color='red'>♥</font>，其回复1点体力",
}

fuzhao:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fuzhao.name) and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = fuzhao.name,
      prompt = "#fuzhao-invoke::" .. target.id
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = target,
      reason = fuzhao.name,
      pattern = ".|.|heart",
    }
    room:judge(judge)
    if judge:matchPattern() and target:isWounded() and not target.dead then
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        skillName = fuzhao.name,
      }
    end
  end,
})

return fuzhao
