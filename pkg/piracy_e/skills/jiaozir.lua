local jiaozir = fk.CreateSkill {
  name = "ofl__jiaozir",
}

Fk:loadTranslationTable{
  ["ofl__jiaozir"] = "缴资",
  [":ofl__jiaozir"] = "当你使用伤害牌结算结束后，你可以将此牌交给一名其他角色。",

  ["#ofl__jiaozir-choose"] = "缴资：你可以将%arg交给一名其他角色",
}

jiaozir:addEffect(fk.CardUseFinished, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiaozir.name) and
      data.card.is_damage_card and player.room:getCardArea(data.card) == Card.Processing and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      skill_name = jiaozir.name,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      prompt = "#ofl__jiaozir-choose:::"..data.card:toLogString(),
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(event:getCostData(self).tos[1], data.card, true, fk.ReasonGive, player)
  end,
})

return jiaozir
