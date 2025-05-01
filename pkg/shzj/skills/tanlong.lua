local tanlong = fk.CreateSkill({
  name = "tanlong",
})

Fk:loadTranslationTable{
  ["tanlong"] = "探龙",
  [":tanlong"] = "出牌阶段限X次，你可以与一名角色拼点，赢的角色可以获得没赢角色的拼点牌，然后其视为对自己使用【铁索连环】（X为横置角色数+1）。",

  ["#tanlong"] = "探龙：与一名角色拼点，赢者可以获得对方的拼点牌并视为对自己使用【铁索连环】",
  ["#tanlong-prey"] = "探龙：是否获得对方的拼点牌？",
}

tanlong:addEffect("active", {
  anim_type = "control",
  prompt = "#tanlong",
  card_num = 0,
  target_num = 1,
  times = function(self, player)
    return player.phase == Player.Play and
    #table.filter(Fk:currentRoom().alive_players, function (p)
      return p.chained
    end) + 1 - player:usedSkillTimes(tanlong.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(tanlong.name, Player.HistoryPhase) <=
      #table.filter(Fk:currentRoom().alive_players, function (p)
        return p.chained
      end)
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, tanlong.name)
    local winner, card = nil, nil
    if pindian.results[target].winner == player then
      winner = player
      card = pindian.results[target].toCard
    elseif pindian.results[target].winner == target then
      winner = target
      card = pindian.fromCard
    end
    if winner and not winner.dead then
      if card and room:getCardArea(card) == Card.DiscardPile and
      room:askToSkillInvoke(winner, {
        skill_name = tanlong.name,
        prompt = "#tanlong-prey",
      }) then
        room:moveCardTo(card, Card.PlayerHand, winner, fk.ReasonJustMove, tanlong.name, nil, true, winner)
      end
      if not winner.dead then
        room:useVirtualCard("iron_chain", nil, winner, winner, tanlong.name)
      end
    end
  end,
})

return tanlong
