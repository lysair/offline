local kongcheng = fk.CreateSkill({
  name = "ofl_mou__kongcheng",
  tags = { Skill.Compulsory },
})

Fk:loadTranslationTable{
  ["ofl_mou__kongcheng"] = "空城",
  [":ofl_mou__kongcheng"] = "锁定技，当你受到伤害时，若你的武将牌上：有“星”，你判定，若结果点数小于“星”数，则此伤害-1；没有“星”，此伤害+1。",

  ["$ofl_mou__kongcheng1"] = "急中行空城险计，功成流千载英声！",
  ["$ofl_mou__kongcheng2"] = "兵临城下心犹静，指端雄兵退万军！",
}

kongcheng:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kongcheng.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(kongcheng.name)
    if #player:getPile("ofl_mou__guanxing_star") > 0 then
      room:notifySkillInvoked(player, kongcheng.name, "defensive")
      local pattern = ".|1~"..#player:getPile("ofl_mou__guanxing_star")
      if #player:getPile("ofl_mou__guanxing_star") < 2 then
        pattern = "false"
      end
      local judge = {
        who = player,
        reason = kongcheng.name,
        pattern = pattern,
      }
      room:judge(judge)
      if judge.card.number < #player:getPile("ofl_mou__guanxing_star") then
        data:changeDamage(-1)
      end
    else
      room:notifySkillInvoked(player, kongcheng.name, "negative")
      data:changeDamage(1)
    end
  end,
})

return kongcheng
