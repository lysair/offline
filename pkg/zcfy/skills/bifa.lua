local bifa = fk.CreateSkill {
  name = "sxfy__bifa",
}

Fk:loadTranslationTable{
  ["sxfy__bifa"] = "笔伐",
  [":sxfy__bifa"] = "结束阶段，你可以展示并将一张手牌交给一名其他角色，其需选择一项："..
  "1.展示并交给你一张类别相同的其他手牌；2.失去1点体力。",

  ["#sxfy__bifa-choose"] = "笔伐：将一张手牌交给一名角色，其选择交给你类别相同的另一张手牌或失去1点体力",
  ["#sxfy__bifa-ask"] = "笔伐：交给 %src 一张%arg手牌，或点“取消”失去1点体力",
}

bifa:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bifa.name) and player.phase == Player.Finish and
      not player:isKongcheng() and #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos, card = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      pattern = ".|.|.|hand",
      prompt = "#sxfy__bifa-choose",
      skill_name = bifa.name,
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1] ---@type ServerPlayer
    local id1 = event:getCostData(self).cards[1]
    player:showCards(id1)
    if player.dead or to.dead or not table.contains(player:getCardIds("h"), id1) then return end
    room:moveCardTo(id1, Card.PlayerHand, to, fk.ReasonGive, bifa.name, nil, true, player)
    if to.dead then return end
    if player.dead then
      room:loseHp(to, 1, bifa.name)
    else
      local type = Fk:getCardById(id1):getTypeString()
      local card = room:askToCards(to, {
        min_num = 1,
        max_num = 1,
        pattern = ".|.|.|hand|.|"..type.."|^"..id1,
        prompt = "#sxfy__bifa-ask:"..player.id.."::"..type,
        skill_name = bifa.name,
      })
      if #card > 0 then
        to:showCards(card)
        if not player.dead and not to.dead and table.contains(to:getCardIds("h"), card[1]) then
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, bifa.name, nil, true, to)
        end
      else
        room:loseHp(to, 1, bifa.name)
      end
    end
  end,
})

return bifa
