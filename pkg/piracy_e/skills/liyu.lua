local liyu = fk.CreateSkill {
  name = "ofl2__liyu",
}

Fk:loadTranslationTable{
  ["ofl2__liyu"] = "利驭",
  [":ofl2__liyu"] = "出牌阶段限两次，你可以获得一名其他角色的一张牌，若如此做，本回合你使用【杀】或【决斗】造成的伤害+1，"..
  "然后其视为对你使用一张【决斗】。",

  ["#ofl2__liyu"] = "利驭：获得一名角色一张牌，本回合你使用【杀】和【决斗】伤害+1，其视为对你使用【决斗】",
}

liyu:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl2__liyu",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(liyu.name, Player.HistoryPhase) < 2
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cards = room:askToChooseCard(player, {
      target = target,
      flag = "he",
      skill_name = liyu.name,
    })
    room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonPrey, liyu.name, nil, false, player)
    if player.dead or target.dead then return end
    room:useVirtualCard("duel", nil, target, player, liyu.name)
  end,
})

liyu:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(liyu.name, Player.HistoryTurn) > 0 and
      (data.card.trueName == "slash" or data.card.name == "duel")
  end,
  on_refresh = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + player:usedSkillTimes(liyu.name, Player.HistoryTurn)
  end,
})

return liyu
