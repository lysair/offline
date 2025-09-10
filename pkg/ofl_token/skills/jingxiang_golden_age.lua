local skill = fk.CreateSkill {
  name = "jingxiang_golden_age_skill",
}

Fk:loadTranslationTable{
  ["jingxiang_golden_age_skill"] = "荆襄盛世",
  ["#jingxiang_golden_age_skill"] = "指定%arg名其他角色，亮出牌堆顶存活角色数的牌，目标角色依次获得其中一张牌，你获得其余的牌",
}

skill:addEffect("cardskill", {
  target_num = function (self, player)
    local kingdoms = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    return #kingdoms
  end,
  mod_target_filter = function(self, player, to_select, selected, card)
    return to_select ~= player
  end,
  target_filter = Util.CardTargetFilter,
  prompt = function (self, player, selected_cards, selected_targets)
    local kingdoms = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    return "#jingxiang_golden_age_skill:::"..#kingdoms
  end,
  on_action = function(self, room, use, finished)
    if not finished then
      local toDisplay = room:getNCards(#room.alive_players)
      room:moveCards({
        ids = toDisplay,
        toArea = Card.Processing,
        moveReason = fk.ReasonPut,
        proposer = use.from,
      })

      table.forEach(room.players, function(p)
        room:fillAG(p, toDisplay)
      end)

      use.extra_data = use.extra_data or {}
      use.extra_data.jingxiangGoldenAgeFilled = toDisplay
      use.extra_data.jingxiangGoldenAgeResult = {}
    else
      if use.extra_data and use.extra_data.jingxiangGoldenAgeFilled then
        table.forEach(room.players, function(p)
          room:closeAG(p)
        end)

        local toDiscard = table.filter(use.extra_data.jingxiangGoldenAgeFilled, function(id)
          return room:getCardArea(id) == Card.Processing
        end)

        if #toDiscard > 0 then
          local from = use.from
          if not from.dead then
            room:moveCardTo(toDiscard, Card.PlayerHand, from, fk.ReasonPrey, skill.name, nil, true, from)
          else
            room:moveCards({
              ids = toDiscard,
              toArea = Card.DiscardPile,
              moveReason = fk.ReasonPutIntoDiscardPile,
            })
          end
        end
      end

      use.extra_data.jingxiangGoldenAgeFilled = nil
    end
  end,
  on_effect = function(self, room, effect)
    if not (effect.extra_data and effect.extra_data.jingxiangGoldenAgeFilled) then
      return
    end

    local chosen = room:askToAG(effect.to, {
      id_list = effect.extra_data.jingxiangGoldenAgeFilled,
      cancelable = false,
      skill_name = skill.name,
    })
    room:takeAG(effect.to, chosen, room.players)
    table.insert(effect.extra_data.jingxiangGoldenAgeResult, {effect.to.id, chosen})
    room:moveCardTo(chosen, Card.PlayerHand, effect.to, fk.ReasonPrey, skill.name, nil, true, effect.to)
    table.removeOne(effect.extra_data.jingxiangGoldenAgeFilled, chosen)
  end,
})

return skill
