local bazhan = fk.CreateSkill {
  name = "sxfy__bazhan",
}

Fk:loadTranslationTable{
  ["sxfy__bazhan"] = "把盏",
  [":sxfy__bazhan"] = "出牌阶段限两次，你可以将一张手牌展示并交给一名男性角色，然后其可将一张类别不同的手牌展示并交给你。",

  ["#sxfy__bazhan"] = "把盏：将一张手牌交给一名角色，其可以交给你一张类别不同的手牌",
  ["#sxfy__bazhan-give"] = "把盏：你可以交给 %src 一张非%arg",
}

bazhan:addEffect("active", {
  anim_type = "support",
  prompt = "#sxfy__bazhan",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(bazhan.name, Player.HistoryPhase) < 2
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and to_select:isMale()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local type = Fk:getCardById(effect.cards[1]):getTypeString()
    player:showCards(effect.cards)
    if player.dead or target.dead or not table.contains(player:getCardIds("h"), effect.cards[1]) then return end
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, bazhan.name, nil, true, player)
    if player.dead or target.dead or target:isKongcheng() then return end
    local card = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = bazhan.name,
      pattern = ".|.|.|.|.|^"..type,
      prompt = "#sxfy__bazhan-give:"..player.id.."::"..type,
      cancelable = true,
    })
    if #card > 0 then
      target:showCards(card)
      if player.dead or target.dead or not table.contains(target:getCardIds("h"), card[1]) then return end
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, bazhan.name, nil, true, target)
    end
  end,
})

return bazhan
