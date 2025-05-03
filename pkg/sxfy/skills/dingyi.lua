local dingyi = fk.CreateSkill {
  name = "sxfy__dingyi",
}

Fk:loadTranslationTable{
  ["sxfy__dingyi"] = "定仪",
  [":sxfy__dingyi"] = "一名角色结束阶段，若其装备区内没有牌，其可以摸一张牌。",

  ["#sxfy__dingyi-invoke"] = "定仪：是否发动 %src 的“定仪”，摸一张牌？",
}

dingyi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(dingyi.name) and target.phase == Player.Finish and
      not target.dead and #target:getCardIds("e") == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(target, {
      skill_name = dingyi.name,
      prompt = "#sxfy__dingyi-invoke:"..player.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(1, dingyi.name)
  end,
})

return dingyi
