local mingfa = fk.CreateSkill {
  name = "ofl_shiji__mingfa",
}

Fk:loadTranslationTable{
  ["ofl_shiji__mingfa"] = "明伐",
  [":ofl_shiji__mingfa"] = "你的拼点牌点数+2。出牌阶段开始时，你可以展示一张手牌，用此牌与一名其他角色拼点，若你：赢，你获得其一张牌，"..
  "然后你摸一张牌；没赢，本回合你不能对其他角色使用牌。",

  ["#ofl_shiji__mingfa-choose"] = "明伐：你可以展示一张手牌，用此牌与一名角色拼点，若赢，获得其一张牌并摸一张牌",
  ["@@ofl_shiji__mingfa-turn"] = "明伐失败",

  ["$ofl_shiji__mingfa1"] = "我军素以德信著称，断不会行谲诈之策。",
  ["$ofl_shiji__mingfa2"] = "吾等不妨克日而战，以行君子之争。",
}

mingfa:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(mingfa.name) and player.phase == Player.Play and not player:isKongcheng() and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return player:canPindian(p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player, false), function (p)
      return player:canPindian(p)
    end)
    local to, card = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      min_num = 1,
      max_num = 1,
      targets = targets,
      pattern = ".|.|.|hand",
      prompt = "#ofl_shiji__mingfa-choose",
      skill_name = mingfa.name,
      cancelable = true
    })
    if #to > 0 and card then
      event:setCostData(self, {tos = to, cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local id = event:getCostData(self).cards[1]
    player:showCards(id)
    if player.dead or to.dead or not table.contains(player:getCardIds("h"), id) or not player:canPindian(to) then return end
    local pindian = player:pindian({to}, mingfa.name, Fk:getCardById(id))
    if player.dead then return end
    if pindian.results[to].winner == player then
      if not to.dead and not to:isNude() then
        local card = room:askToChooseCard(player, {
          target = to,
          flag = "he",
          skill_name = mingfa.name
        })
        room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, mingfa.name, nil, false, player)
      end
      if not player.dead then
        player:drawCards(1, mingfa.name)
      end
    else
      room:setPlayerMark(player, "@@ofl_shiji__mingfa-turn", 1)
    end
  end,
})

mingfa:addEffect(fk.PindianCardsDisplayed, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(mingfa.name) then
      if player == data.from then
        return data.fromCard
      elseif data.results[player] then
        return data.results[player].toCard
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:changePindianNumber(data, player, 2, mingfa.name)
  end,
})

mingfa:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    return from and from:getMark("@@ofl_shiji__mingfa-turn") > 0 and card and from ~= to
  end,
})

return mingfa
