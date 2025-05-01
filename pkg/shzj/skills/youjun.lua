local youjun = fk.CreateSkill {
  name = "youjun",
}

Fk:loadTranslationTable{
  ["youjun"] = "诱军",
  [":youjun"] = "出牌阶段限一次，你可以获得一名其他角色一张牌，然后其可以令其所有手牌视为【杀】直到回合结束，并视为对你使用【决斗】。",

  ["#youjun"] = "诱军：获得一名角色一张牌，其可以令其手牌视为【杀】并视为对你使用【决斗】",
  ["#youjun-duel"] = "诱军：是否令手牌视为【杀】直到回合结束，并视为对 %src 使用【决斗】？",
  ["@@youjun-turn"] = "诱军",
}

youjun:addEffect("active", {
  anim_type = "control",
  prompt = "#youjun",
  card_num = 0,
  target_num = 1,
  can_use = function (self, player)
    return player:usedSkillTimes(youjun.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card = room:askToChooseCard(player, {
      target = target,
      flag = "he",
      skill_name = youjun.name,
    })
    room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, youjun.name, nil, true, player)
    if player.dead or target.dead then return end
    if room:askToSkillInvoke(target, {
      skill_name = youjun.name,
      prompt = "#youjun-duel:"..player.id,
    }) then
      room:setPlayerMark(target, "@@youjun-turn", 1)
      room:useVirtualCard("duel", nil, target, player, youjun.name)
    end
  end,
})

youjun:addEffect("filter", {
  mute = true,
  card_filter = function(self, card, player)
    return player:getMark("@@youjun-turn") > 0 and table.contains(player:getCardIds("h"), card.id)
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard("slash", card.suit, card.number)
  end,
})

return youjun
