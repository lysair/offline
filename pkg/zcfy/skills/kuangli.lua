local kuangli = fk.CreateSkill {
  name = "sxfy__kuangli",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["sxfy__kuangli"] = "狂戾",
  [":sxfy__kuangli"] = "锁定技，每阶段限一次，当你于出牌阶段内使用牌指定一名其他角色为目标后，你获得其一张牌。",
}

kuangli:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(kuangli.name) and player.phase == Player.Play and
      data.to ~= player and not data.to:isNude() and
      player:usedEffectTimes(kuangli.name, Player.HistoryPhase) == 0
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.to}})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = data.to,
      flag = "he",
      skill_name = kuangli.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, kuangli.name, nil, false, player)
  end,
})

return kuangli
