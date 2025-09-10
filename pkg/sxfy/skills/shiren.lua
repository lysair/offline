local shiren = fk.CreateSkill {
  name = "sxfy__shiren",
}

Fk:loadTranslationTable{
  ["sxfy__shiren"] = "施仁",
  [":sxfy__shiren"] = "每回合限一次，当你成为其他角色使用【杀】的目标后，你可以摸两张牌，然后交给该角色一张牌。",

  ["#sxfy__shiren-invoke"] = "施仁：你可以摸两张牌，交给 %dest 一张牌",
  ["#sxfy__shiren-give"] = "施仁：请交给 %dest 一张牌",
}

shiren:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(shiren.name) and data.card.trueName == "slash" and
      player ~= data.from and player:usedSkillTimes(shiren.name, Player.HistoryTurn) == 0
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#sxfy__shiren-invoke::"..data.from.id,
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player:drawCards(2, shiren.name)
    if player.dead or data.from.dead or player:isNude() then return end
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = shiren.name,
      prompt = "#sxfy__shiren-give::"..data.from.id,
      cancelable = false,
    })
    room:moveCardTo(card, Card.PlayerHand, data.from, fk.ReasonGive, shiren.name, nil, false, player)
  end,
})

return shiren
