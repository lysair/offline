local xiemu_active = fk.CreateSkill {
  name = "sxfy__xiemu&",
}

Fk:loadTranslationTable{
  ["sxfy__xiemu&"] = "协穆",
  [":sxfy__xiemu&"] = "出牌阶段限一次，你可以展示并交给马良一张基本牌，然后本回合你攻击范围+1。",

  ["#sxfy__xiemu&"] = "协穆：交给马良一张基本牌，本回合你攻击范围+1",
}

xiemu_active:addEffect("active", {
  mute = true,
  card_num = 1,
  target_num = 1,
  prompt = "#sxfy__xiemu&",
  can_use = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function (p)
      return p ~= player and p:hasSkill("sxfy__xiemu") and p:usedSkillTimes("sxfy__xiemu", Player.HistoryPhase) == 0
    end)
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).type == Card.TypeBasic
  end,
  target_filter = function (self, player, to_select, selected)
    return #selected == 0 and to_select:hasSkill("sxfy__xiemu") and p:usedSkillTimes("sxfy__xiemu", Player.HistoryPhase) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:notifySkillInvoked(target, "sxfy__xiemu", "support")
    target:broadcastSkillInvoke("sxfy__xiemu")
    target:addSkillUseHistory("sxfy__xiemu", 1)
    player:showCards(effect.cards)
    if target.dead or not table.contains(player:getCardIds("h"), effect.cards[1]) then return end
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, "sxfy__xiemu", nil, true, player)
  end,
})

return xiemu_active
