local quanyi = fk.CreateSkill({
  name = "ofl__quanyi",
})

Fk:loadTranslationTable{
  ["ofl__quanyi"] = "权弈",
  [":ofl__quanyi"] = "出牌阶段限一次，你可以与一名角色拼点，赢的角色根据双方拼点牌的花色执行效果：<br>"..
  "<font color='red'>♥</font>，获得没赢的角色区域里的一张牌；<br>"..
  "<font color='red'>♦</font>，对没赢的角色造成1点伤害；<br>♣，弃置两张牌；<br>♠，失去1点体力。<br>"..
  "当你拼点时，你可以改为用牌堆顶牌进行拼点。",

  ["#ofl__quanyi"] = "权弈：与一名角色拼点，赢者根据双方拼点牌花色执行效果",
  ["#ofl__quanyi-prey"] = "权弈：获得 %dest 区域内一张牌",
  ["#ofl__quanyi-invoke"] = "权弈：是否用牌堆顶牌拼点？",
}

quanyi:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl__quanyi",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:canPindian(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local pindian = player:pindian({target}, quanyi.name)
    local winner, loser = pindian.results[target].winner, nil
    if winner == nil then return end
    if pindian.results[target].winner == player then
      winner, loser = player, target
    else
      winner, loser = target, player
    end
    local suits = {}
    if pindian.fromCard then
      table.insert(suits, pindian.fromCard.suit)
    end
    if pindian.results[target].toCard then
      table.insert(suits, pindian.results[target].toCard.suit)
    end
    for _, suit in ipairs(suits) do
      if suit == Card.Heart then
        if not winner.dead and not loser.dead and not loser:isAllNude() then
          local card = room:askToChooseCard(winner, {
            target = loser,
            flag = "hej",
            skill_name = quanyi.name,
            prompt = "#ofl__quanyi-prey::"..loser.id,
          })
          room:moveCardTo(card, Card.PlayerHand, winner, fk.ReasonPrey, quanyi.name, nil, false, winner)
        end
      elseif suit == Card.Diamond then
        if not loser.dead then
          room:damage{
            from = winner,
            to = loser,
            damage = 1,
            skillName = quanyi.name,
          }
        end
      elseif suit == Card.Club then
        if not winner.dead then
          room:askToDiscard(winner, {
            min_num = 2,
            max_num = 2,
            include_equip = true,
            skill_name = quanyi.name,
            cancelable = false,
          })
        end
      elseif suit == Card.Spade then
        if not winner.dead then
          room:loseHp(winner, 1, quanyi.name)
        end
      end
    end
  end,
})

quanyi:addEffect(fk.StartPindian, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(quanyi.name) and (player == data.from or table.contains(data.tos, player))
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = quanyi.name,
      prompt = "#ofl__quanyi-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    if player == data.from then
      data.fromCard = Fk:getCardById(player.room.draw_pile[1])
    else
      data.results[player] = data.results[player] or {}
      data.results[player].toCard = Fk:getCardById(player.room.draw_pile[1])
    end
  end,
})

return quanyi
