local ofl_shiji__mingfa = fk.CreateSkill {
  name = "ofl_shiji__mingfa"
}

Fk:loadTranslationTable{
  ['ofl_shiji__mingfa'] = '明伐',
  ['#ofl_shiji__mingfa-choose'] = '明伐：你可以展示一张手牌，用此牌与一名角色拼点，若赢，获得其一张牌并摸一张牌',
  ['@@ofl_shiji__mingfa-turn'] = '明伐失败',
  [':ofl_shiji__mingfa'] = '你的拼点牌点数+2。出牌阶段开始时，你可以展示一张手牌，用此牌与一名其他角色拼点，若你：赢，你获得其一张牌，然后你摸一张牌；没赢，本回合你不能对其他角色使用牌。',
  ['$ofl_shiji__mingfa1'] = '我军素以德信著称，断不会行谲诈之策。',
  ['$ofl_shiji__mingfa2'] = '吾等不妨克日而战，以行君子之争。',
}

ofl_shiji__mingfa:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl_shiji__mingfa.name) and
      target == player and player.phase == Player.Play and not player:isKongcheng() and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return player:canPindian(p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return player:canPindian(p)
    end)
    local tos, card =  room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      targets = table.map(targets, Util.IdMapper),
      pattern = ".|.|.|hand",
      prompt = "#ofl_shiji__mingfa-choose",
      skill_name = ofl_shiji__mingfa.name,
      cancelable = true
    })
    if #tos > 0 and card then
      event:setCostData(skill, {tos = tos, cards = {card}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local data = event:getCostData(skill)
    local to = room:getPlayerById(data.tos[1])
    player:showCards(data.cards)
    if player.dead or to.dead or not table.contains(player:getCardIds("h"), data.cards[1]) or
      not player:canPindian(to) then return end
    local pindian = player:pindian({to}, ofl_shiji__mingfa.name, Fk:getCardById(data.cards[1]))
    if player.dead then return end
    if pindian.results[to.id].winner == player then
      if not to.dead and not to:isNude() then
        local id = room:askToChooseCard(player, {
          target = to,
          flag = "he",
          skill_name = ofl_shiji__mingfa.name
        })
        room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonPrey, ofl_shiji__mingfa.name, nil, false, player.id)
      end
      if not player.dead then
        player:drawCards(1, ofl_shiji__mingfa.name)
      end
    else
      room:setPlayerMark(player, "@@ofl_shiji__mingfa-turn", 1)
    end
  end,
})

ofl_shiji__mingfa:addEffect(fk.PindianCardsDisplayed, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(ofl_shiji__mingfa.name) and (player == data.from or data.results[player.id])
  end,
  on_use = function(self, event, target, player, data)
    if player == data.from then
      data.fromCard.number = math.min(13, data.fromCard.number + 2)
    elseif data.results[player.id] then
      data.results[player.id].toCard.number = math.min(13, data.results[player.id].toCard.number + 2)
    end
  end,
})

ofl_shiji__mingfa:addEffect('prohibit', {
  is_prohibited = function(self, from, to, card)
    return from:getMark("@@ofl_shiji__mingfa-turn") > 0 and card and from ~= to
  end,
})

return ofl_shiji__mingfa
