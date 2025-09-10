local chengshi = fk.CreateSkill {
  name = "sxfy__chengshi",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["sxfy__chengshi"] = "承事",
  [":sxfy__chengshi"] = "限定技，当一名其他角色死亡时，你可以与其交换座次与装备区内的牌。",

  ["#sxfy__chengshi-invoke"] = "承事：是否与 %dest 交换座次并交换装备区内的牌？",
}

chengshi:addEffect(fk.Death, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(chengshi.name) and player:usedSkillTimes(chengshi.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = chengshi.name,
      prompt = "#sxfy__chengshi-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:swapSeat(player, target)
    room:swapAllCards(player, {player, target}, chengshi.name, "e")
  end,
})

return chengshi
