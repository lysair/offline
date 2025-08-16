
local zhengjing = fk.CreateSkill {
  name = "sxfy__zhengjing",
}

Fk:loadTranslationTable{
  ["sxfy__zhengjing"] = "整经",
  [":sxfy__zhengjing"] = "摸牌阶段开始时，你可以展示所有手牌并亮出牌堆顶等量的牌（至多三张），你将其中一种花色的牌交给一名其他角色，"..
  "你获得其余的牌。",

  ["#sxfy__zhengjing-invoke"] = "整经：展示所有手牌并亮出牌堆顶等量的牌，将一种花色交给一名其他角色，你获得其余牌",
  ["#sxfy__zhengjing-choose"] = "整经：令一名角色获得其中一种花色的牌",
  ["#sxfy__zhengjing-choice"] = "整经：选择令 %dest 获得牌的花色",
}

zhengjing:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhengjing.name) and player.phase == Player.Draw and
      not player:isKongcheng()
  end,
  on_cost = function (self,event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhengjing.name,
      prompt = "#sxfy__zhengjing-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = table.simpleClone(player:getCardIds("h"))
    player:showCards(cards)
    if player.dead or player:isKongcheng() then return end
    local cards2 = room:getNCards(math.min(3, #cards))
    room:turnOverCardsFromDrawPile(player, cards2, zhengjing.name)
    if player.dead or #room:getOtherPlayers(player, false) == 0 then
      room:cleanProcessingArea(cards2)
      return
    end
    local suits, mapper1, mapper2 = {}, {}, {}
    for _, id in ipairs(cards) do
      local suit = Fk:getCardById(id):getSuitString(true)
      table.insertIfNeed(suits, suit)
      mapper1[suit] = mapper1[suit] or {}
      table.insert(mapper1[suit], id)
    end
    for _, id in ipairs(cards2) do
      local suit = Fk:getCardById(id):getSuitString(true)
      table.insertIfNeed(suits, suit)
      mapper2[suit] = mapper2[suit] or {}
      table.insert(mapper2[suit], id)
    end
    table.removeOne(suits, "log_nosuit")
    if #suits == 0 then
      room:cleanProcessingArea(cards2)
      return
    end
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = zhengjing.name,
      prompt = "#sxfy__zhengjing-choose",
      cancelable = false,
    })[1]
    local choice = room:askToChoice(player, {
      choices = suits,
      skill_name = zhengjing.name,
      prompt = "#sxfy__zhengjing-choice::"..to.id,
    })
    local moves = {}
    if mapper1[choice] and #mapper1[choice] > 0 then
      table.insert(moves, {
        ids = mapper1[choice],
        from = player,
        to = to,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonGive,
        skillName = zhengjing.name,
        proposer = player,
        moveVisible = true,
      })
    end
    if mapper2[choice] and #mapper2[choice] > 0 then
      table.insert(moves, {
        ids = mapper2[choice],
        to = to,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonGive,
        skillName = zhengjing.name,
        proposer = player,
        moveVisible = true,
      })
    end
    room:moveCards(table.unpack(moves))
    if not player.dead then
      cards2 = table.filter(cards2, function (id)
        return room:getCardArea(id) == Card.Processing
      end)
      if #cards2 > 0 then
        room:moveCardTo(cards2, Card.PlayerHand, player, fk.ReasonJustMove, zhengjing.name, nil, true, player)
        return
      end
    end
    room:cleanProcessingArea(cards2)
  end,
})

return zhengjing
