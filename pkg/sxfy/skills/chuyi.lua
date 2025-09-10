local chuyi = fk.CreateSkill {
  name = "sxfy__chuyi",
}

Fk:loadTranslationTable{
  ["sxfy__chuyi"] = "除异",
  [":sxfy__chuyi"] = "每轮限一次，当一名其他角色对你攻击范围内一名角色造成伤害时，你可以令此伤害+1。",

  ["#sxfy__chuyi-invoke"] = "除异：是否令 %dest 受到的伤害+1？",
}

chuyi:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target and target ~= player and player:hasSkill(chuyi.name) and
      player:inMyAttackRange(data.to) and
      player:usedSkillTimes(chuyi.name, Player.HistoryRound) == 0
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#sxfy__chuyi-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

return chuyi
