local wanlan = fk.CreateSkill {
  name = "sxfy__wanlan",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["sxfy__wanlan"] = "挽澜",
  [":sxfy__wanlan"] = "限定技，当一名其他角色进入濒死状态时，你可以将所有手牌交给其，该角色回复至1点体力。",

  ["#sxfy__wanlan-invoke"] = "挽澜：你可以将所有手牌交给 %dest，令其回复至1点体力",
}

wanlan:addEffect(fk.EnterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wanlan.name) and
      not player:isKongcheng() and target ~= player and
      player:usedSkillTimes(wanlan.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = wanlan.name,
      prompt = "#sxfy__wanlan-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:obtainCard(target, player:getCardIds("h"), false, fk.ReasonGive, player, wanlan.name)
    if not target.dead and target.hp < 1 then
      room:recover{
        who = target,
        num = 1 - target.hp,
        recoverBy = player,
        skillName = wanlan.name,
      }
    end
  end,
})

return wanlan
