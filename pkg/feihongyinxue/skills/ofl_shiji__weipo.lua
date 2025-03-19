local ofl_shiji__weipo = fk.CreateSkill {
  name = "ofl_shiji__weipo"
}

Fk:loadTranslationTable{
  ['ofl_shiji__weipo'] = '危迫',
  ['#ofl_shiji__weipo'] = '危迫：你可以选择一名角色，弃置其每个区域各一张牌，然后选择一张【兵临城下】或智囊令其获得',
  ['@$fhyx_extra_pile'] = '额外牌堆',
  ['#ofl_shiji__weipo-give'] = '危迫：选择令 %dest 获得的牌',
  [':ofl_shiji__weipo'] = '出牌阶段限一次，你可以选择一名其他角色，弃置其每个区域各一张牌（无牌则不弃），然后从额外牌堆选择一张<a href=>【兵临城下】</a>或一张<a href=>智囊</a>令其获得。',
}

ofl_shiji__weipo:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#ofl_shiji__weipo",
  can_use = function(self, player)
    return player:usedSkillTimes(ofl_shiji__weipo.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if not target:isAllNude() then
      local disable_ids = {}
      if player == target then
        disable_ids = table.filter(player:getCardIds("he"), function (id)
          return player:prohibitDiscard(id)
        end)
      end
      local cards = room:askToChooseCards(player, {
        target = target,
        flag = "hej",
        skill_name = ofl_shiji__weipo.name,
        expand_pile = disable_ids,
        will_throw = true,
      })
      if #cards > 0 then
        room:throwCard(cards, ofl_shiji__weipo.name, target, player)
      end
      if target.dead then return end
    end
    local names = room:getTag("Zhinang") or {"dismantlement", "nullification", "ex_nihilo"}
    table.insert(names, 1, "enemy_at_the_gates")
    local cards = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
      return table.contains(names, Fk:getCardById(id).trueName)
    end)
    if #cards > 0 then
      local chosen_cards, _, _ = room:askToChooseCardsAndPlayers(player, {
        min_card_num = 1,
        max_card_num = 1,
        targets = {target},
        min_target_num = 0,
        max_target_num = 0,
        pattern = "enemy_at_the_gates|zhinang",
        prompt = "#ofl_shiji__weipo-give::" .. target.id,
        skill_name = ofl_shiji__weipo.name
      })
      room:moveCardTo(chosen_cards, Card.PlayerHand, target, fk.ReasonJustMove, ofl_shiji__weipo.name, nil, true, player.id)
    end
  end,
})

ofl_shiji__weipo:addEffect('refresh', {
  events = {fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if player.seat == 1 then
      for _, move in ipairs(data) do
        for _, info in ipairs(move.moveInfo) do
          if player.room:getBanner("fhyx_extra_pile") and
            table.contains(player.room:getBanner("fhyx_extra_pile"), info.cardId) then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    SetFhyxExtraPileBanner(player.room)
  end,
})

ofl_shiji__weipo:addEffect('acquire', {
  on_acquire = function (self, player, is_start)
    local room = player.room
    PrepareExtraPile(room)
    local cards = room:getBanner("fhyx_extra_pile")
    local id = room:printCard("enemy_at_the_gates", Card.Spade, 7).id
    table.insert(cards, id)
    room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
    room:setBanner("fhyx_extra_pile", cards)
    room:setBanner("@$fhyx_extra_pile", table.simpleClone(cards))
  end,
})

return ofl_shiji__weipo
