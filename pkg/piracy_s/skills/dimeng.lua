local dimeng = fk.CreateSkill{
  name = "ofl__dimeng",
}

Fk:loadTranslationTable{
  ["ofl__dimeng"] = "缔盟",
  [":ofl__dimeng"] = "当两名角色的拼点牌亮出后，你可以交换双方的拼点牌。",

  ["#ofl__dimeng-invoke"] = "缔盟：是否交换 %src 和 %dest 的拼点牌？",
}

dimeng:addEffect(fk.PindianCardsDisplayed, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(dimeng.name) and
      data.fromCard and #data.tos == 1 and data.results[data.tos[1]].toCard
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = dimeng.name,
      prompt = "#ofl__dimeng-invoke:"..data.from.id..":"..data.tos[1].id,
    }) then
      event:setCostData(self, {tos = {data.from, data.tos[1]}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.fromCard, data.results[data.tos[1]].toCard = data.results[data.tos[1]].toCard, data.fromCard
  end,
})

return dimeng
