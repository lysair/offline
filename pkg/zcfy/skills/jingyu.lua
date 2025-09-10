local jingyu = fk.CreateSkill {
  name = "sxfy__jingyu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__jingyu"] = "静域",
  [":sxfy__jingyu"] = "锁定技，每回合限一次，当一名角色于其回合内发动技能时，其选择一项：1.你摸一张牌；2.弃置一张牌。",

  ["#sxfy__jingyu-discard"] = "静域：弃置一张牌，否则 %src 摸一张牌",
}

jingyu:addEffect(fk.SkillEffect, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jingyu.name) and target and player.room.current == target and
      data.skill:isPlayerSkill(target) and target:hasSkill(data.skill:getSkeleton().name, true, true) and
      player:usedSkillTimes(jingyu.name, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {target}})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #room:askToDiscard(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = jingyu.name,
      cancelable = true,
      prompt = "#sxfy__jingyu-discard:"..player.id,
    }) == 0 then
      player:drawCards(1, jingyu.name)
    end
  end,
})

return jingyu
