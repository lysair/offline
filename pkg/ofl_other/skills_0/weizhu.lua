local weizhu = fk.CreateSkill { name = "ofl__weizhu" }

Fk:loadTranslationTable {
  ['ofl__weizhu'] = '围铸',
  ['#ofl__weizhu'] = '围铸：重铸任意张手牌，获得弃牌堆中等量装备牌，然后分配等量的手牌',
  ['#ofl__weizhu-prey'] = '围铸：获得其中%arg张牌',
  ['#ofl__weizhu-give'] = '围铸：请分配给%arg名角色各一张牌，这些角色本轮计算距离-1',
  ['@ofl__weizhu-round'] = '围铸',
  [':ofl__weizhu'] = '出牌阶段限一次，你可以重铸任意张手牌，获得弃牌堆中等量张装备牌，然后你交给等量名其他角色各一张牌，以此法获得牌的角色本轮计算与除其以外的角色距离-1。',
}

weizhu:addEffect('active', {
  name = "ofl__weizhu",
  anim_type = "support",
  min_card_num = 1,
  target_num = 0,
  prompt = "#ofl__weizhu",
  can_use = function(self, player)
    return player:usedSkillTimes(weizhu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local n = #effect.cards
    room:recastCard(effect.cards, player, weizhu.name)
    if player.dead then return end
    local cards = table.filter(room.discard_pile, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
    if #cards > 0 then
      if #cards > n then
        cards = room:askToChooseCardsAndPlayers(player, {
          min_card_num = n,
          max_card_num = n,
          pattern = ".|.|equip",
          prompt = "#ofl__weizhu-prey:::" .. n,
          skill_name = weizhu.name,
          targets = { player.id },
        })
      end
      room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, weizhu.name, nil, true, player.id)
      if player.dead then return end
    end
    n = math.min(n, #room:getOtherPlayers(player, false), #player:getCardIds("he"))
    if n == 0 then return end
    local result = room:askToYiji(player, {
      cards = player:getCardIds("he"),
      min_num = n,
      max_num = n,
      prompt = "#ofl__weizhu-give:::" .. n,
      skill_name = weizhu.name,
      targets = room:getOtherPlayers(player, false),
      single_max = 1,
    })
    for id, ids in pairs(result) do
      if #ids > 0 then
        local p = room:getPlayerById(id)
        if not p.dead then
          room:addPlayerMark(p, "@ofl__weizhu-round", 1)
        end
      end
    end
  end,
})

weizhu:addEffect('distance', {
  name = "#ofl__weizhu_distance",
  correct_func = function(self, from, to)
    return -from:getMark("@ofl__weizhu-round")
  end,
})

return weizhu
