local hanwei = fk.CreateSkill {
  name = "ofl__hanwei"
}

Fk:loadTranslationTable{
  ['ofl__hanwei'] = '扞卫',
  ['#ofl__hanwei'] = '扞卫：交给距离1一名角色任意张非伤害牌，摸等量牌，其可以使用交给其的牌',
  ['#ofl__hanwei-use'] = '扞卫：你可以使用这些牌',
  [':ofl__hanwei'] = '出牌阶段限一次，你可以展示并交给距离为1的一名其他角色任意张非伤害类牌并摸等量的牌，然后其可以使用你交给其的任意张牌。',
}

hanwei:addEffect('active', {
  anim_type = "support",
  min_card_num = 1,
  target_num = 1,
  prompt = "#ofl__hanwei",
  can_use = function(self, player)
    return player:usedSkillTimes(hanwei.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return not Fk:getCardById(to_select).is_damage_card
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return player:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == 1
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:showCards(effect.cards)
    local cards = table.filter(effect.cards, function (id)
      return table.contains(player:getCardIds("he"), id)
    end)
    if #cards > 0 and not target.dead then
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, hanwei.name, nil, true, player.id)
    end
    if not player.dead then
      player:drawCards(#effect.cards, hanwei.name)
    end
    cards = table.filter(cards, function (id)
      return table.contains(target:getCardIds("h"), id)
    end)
    while #cards > 0 and not target.dead do
      local use = room:askToUseRealCard(target, {
        pattern = cards,
        skill_name = hanwei.name,
        prompt = "#ofl__hanwei-use",
        cancelable = true,
        skip = true,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        }
      })
      if use then
        table.removeOne(cards, use.card.id)
      else
        return
      end
    end
  end,
})

return hanwei
