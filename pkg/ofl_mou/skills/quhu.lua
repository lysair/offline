local quhu = fk.CreateSkill({
  name = "ofl_mou__quhu",
})

Fk:loadTranslationTable{
  ["ofl_mou__quhu"] = "驱虎",
  [":ofl_mou__quhu"] = "出牌阶段限一次，若你有牌，你可以与两名有牌的其他角色依次弃置至少一张牌。" ..
  "若有弃置牌数唯一最多的其他角色，其对弃置牌数最少的角色各造成1点伤害，然后获得你弃置的牌；" ..
  "否则这两名角色各摸其弃置牌数的牌。",

  ["#ofl_mou__quhu"] = "驱虎：与两名角色依次弃置牌，弃牌数最多的其他角色造成伤害",
  ["#ofl_mou__quhu-self"] = "驱虎：请弃置至少一张牌",
  ["#ofl_mou__quhu-discard"] = "驱虎：请弃置至少一张牌，若弃置牌数唯一最多则造成伤害",

  ["$ofl_mou__quhu1"] = "令此攻彼，以渔其利。",
  ["$ofl_mou__quhu2"] = "驱虎吞狼，应变知微。",
}

quhu:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_mou__quhu",
  card_num = 0,
  target_num = 2,
  can_use = function(self, player)
    return player:usedSkillTimes(quhu.name, Player.HistoryPhase) == 0 and
      not player:isNude() and #Fk:currentRoom().alive_players > 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected < 2 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    table.insert(targets, player)
    room:sortByAction(targets)
    local result = {}
    for _, p in ipairs(targets) do
      if p.dead then
        table.insert(result, {})
      else
        local cards = room:askToDiscard(p, {
          min_num = 1,
          max_num = 999,
          include_equip = true,
          skill_name = quhu.name,
          prompt = p == player and "#ofl_mou__quhu-self" or "#ofl_mou__quhu-discard",
          cancelable = false,
        })
        table.insert(result, cards)
      end
    end
    local winner
    if #result[2] > #result[1] and #result[2] > #result[3] then
      winner = targets[2]
    elseif #result[3] > #result[1] and #result[3] > #result[2] then
      winner = targets[3]
    end
    if winner then
      if winner == targets[2] then
        if not player.dead and #result[1] <= #result[3] then
          room:damage{
            from = winner,
            to = player,
            damage = 1,
            skillName = quhu.name,
          }
        end
        if not targets[3].dead and #result[3] <= #result[1] then
          room:damage{
            from = winner,
            to = targets[3],
            damage = 1,
            skillName = quhu.name,
          }
        end
      else
        if not player.dead and #result[1] <= #result[2] then
          room:damage{
            from = winner,
            to = player,
            damage = 1,
            skillName = quhu.name,
          }
        end
        if not targets[2].dead and #result[2] <= #result[1] then
          room:damage{
            from = winner,
            to = targets[2],
            damage = 1,
            skillName = quhu.name,
          }
        end
      end
      if not winner.dead then
        local cards = table.filter(result[1], function (id)
          return table.contains(room.discard_pile, id)
        end)
        if #cards > 0 then
          room:moveCardTo(cards, Card.PlayerHand, winner, fk.ReasonJustMove, quhu.name, nil, true, winner)
        end
      end
    else
      if not targets[2].dead and #result[2] > 0 then
        targets[2]:drawCards(#result[2], quhu.name)
      end
      if not targets[3].dead and #result[3] > 0 then
        targets[3]:drawCards(#result[3], quhu.name)
      end
    end
  end,
})

return quhu
