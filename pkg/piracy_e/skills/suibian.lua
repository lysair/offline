local suibian = fk.CreateSkill {
  name = "suibian",
}

Fk:loadTranslationTable{
  ["suibian"] = "随变",
  [":suibian"] = "一名角色使用与“掠”花色相同的牌时，你可以选择一项：1.移去所有此花色的“掠”，对其造成1点伤害；"..
  "2.与其各摸一张牌；3.失去1点体力令此牌无效，然后将此牌交给一名角色并摸一张牌。",

  ["suibian_damage"] = "移去所有%arg“掠”，对%dest造成1点伤害",
  ["suibian_draw"] = "与%dest各摸一张牌",
  ["suibian_card"] = "失去1点体力令%arg无效，将之交给一名角色并摸一张牌",
  ["#suibian-give"] = "随变：将%arg交给一名角色",
}

suibian:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(suibian.name) and
      table.find(player:getPile("silve"), function (id)
        return data.card:compareSuitWith(Fk:getCardById(id))
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local all_choices = {
      "suibian_damage::"..target.id..":"..data.card:getSuitString(true),
      "suibian_draw::"..target.id,
      "suibian_card:::"..data.card:toLogString(),
      "Cancel",
    }
    local choices = table.simpleClone(all_choices)
    if target.dead then
      table.remove(choices, 1)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = suibian.name,
      all_choices = all_choices,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {target}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice:startsWith("suibian_damage") then
      local cards = table.filter(player:getPile("silve"), function (id)
        return data.card:compareSuitWith(Fk:getCardById(id))
      end)
      room:moveCardTo(cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, suibian.name, nil, true, player)
      if not target.dead then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          skillName = suibian.name,
        }
      end
    elseif choice:startsWith("suibian_draw") then
      player:drawCards(1, suibian.name)
      if not target.dead then
        target:drawCards(1, suibian.name)
      end
    elseif choice:startsWith("suibian_card") then
      data.toCard = nil
      data:removeAllTargets()
      room:loseHp(player, 1, suibian.name)
      if player.dead then return end
      if room:getCardArea(data.card) == Card.Processing then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = room.alive_players,
          skill_name = suibian.name,
          prompt = "#suibian-give:::"..data.card:toLogString(),
          cancelable = false,
        })[1]
        room:moveCardTo(data.card, Card.PlayerHand, to, fk.ReasonGive, suibian.name, nil, true, player)
      end
      if not player.dead then
        player:drawCards(1, suibian.name)
      end
    end
  end,
})

return suibian
