local shameng = fk.CreateSkill {
  name = "ofl_shiji__shameng"
}

Fk:loadTranslationTable{
  ['ofl_shiji__shameng'] = '歃盟',
  ['#ofl_shiji__shameng'] = '歃盟：你可以展示至多两张手牌，令一名角色展示至多两张手牌，你可以弃置这些牌令双方摸牌',
  ['#ofl_shiji__shameng-show'] = '歃盟：请展示一至两张手牌，%src 可以弃置这些牌令双方摸牌',
  ['#ofl_shiji__shameng-discard'] = '歃盟：是否弃置这些牌令双方摸牌？你摸%arg张，%dest摸%arg2张',
  [':ofl_shiji__shameng'] = '出牌阶段限一次，你可以展示一至两张手牌，然后令一名其他角色展示一至两张手牌，若如此做，你可以弃置这些牌，你摸等同于其中花色数的牌，令该角色摸等同于其中类别数的牌。',
}

shameng:addEffect('active', {
  anim_type = "drawcard",
  min_card_num = 1,
  max_card_num = 2,
  target_num = 1,
  prompt = "#ofl_shiji__shameng",
  can_use = function(self, player)
    return player:usedSkillTimes(shameng.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local suits = {}
    local types = {}
    for _, id in ipairs(effect.cards) do
      local card = Fk:getCardById(id)
      if card.suit ~= Card.NoSuit then
        table.insertIfNeed(suits, card.suit)
      end
      table.insertIfNeed(types, card.type)
    end
    player:showCards(effect.cards)
    if player.dead or target.dead or target:isKongcheng() then return end
    local cards = room:askToCards(target, {
      min_num = 1,
      max_num = 2,
      prompt = "#ofl_shiji__shameng-show:" .. player.id,
      skill_name = shameng.name
    })
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id)
      if card.suit ~= Card.NoSuit then
        table.insertIfNeed(suits, card.suit)
      end
      table.insertIfNeed(types, card.type)
    end
    target:showCards(cards)
    if player.dead then return end
    if room:askToSkillInvoke(player, {
      skill_name = shameng.name,
      prompt = "#ofl_shiji__shameng-discard::" .. target.id .. ":" .. #suits .. ":" .. #types
    }) then
      local move1 = {
        ids = table.filter(effect.cards, function(id)
          return room:getCardOwner(id) == player and table.contains(player:getCardIds("h"), id) and not player:prohibitDiscard(id)
        end),
        from = player.id,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player.id,
        skillName = shameng.name,
      }
      local move2 = {
        ids = table.filter(cards, function(id)
          return room:getCardOwner(id) == target and table.contains(target:getCardIds("h"), id)
        end),
        from = target.id,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonDiscard,
        proposer = player.id,
        skillName = shameng.name,
      }
      room:moveCards(move1, move2)
      if not player.dead then
        player:drawCards(#suits, shameng.name)
      end
      if not target.dead then
        target:drawCards(#types, shameng.name)
      end
    end
  end,
})

return shameng
