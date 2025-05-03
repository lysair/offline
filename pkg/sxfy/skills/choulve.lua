local choulve = fk.CreateSkill {
  name = "sxfy__choulve",
}

Fk:loadTranslationTable{
  ["sxfy__choulve"] = "筹略",
  [":sxfy__choulve"] = "出牌阶段限一次，你可以交给一名其他角色一张手牌，然后其可以交给你一张装备牌。",

  ["#sxfy__choulve"] = "筹略：交给一名角色一张手牌，然后其可以交给你一张装备牌",
  ["#sxfy__choulve-give"] = "筹略：你可以交给 %src 一张装备牌",
}

choulve:addEffect("active", {
  anim_type = "support",
  prompt = "#sxfy__choulve",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(choulve.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, choulve.name, nil, false, player)
    if player.dead or target.dead or target:isNude() then return end
    local card = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = choulve.name,
      pattern = ".|.|.|.|.|equip",
      prompt = "#sxfy__choulve-give:"..player.id,
      cancelable = true,
    })
    if #card > 0 then
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, choulve.name, nil, true, target)
    end
  end,
})

return choulve
