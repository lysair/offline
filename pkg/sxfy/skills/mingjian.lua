local mingjian = fk.CreateSkill {
  name = "sxfy__mingjian",
}

Fk:loadTranslationTable{
  ["sxfy__mingjian"] = "明鉴",
  [":sxfy__mingjian"] = "出牌阶段限一次，你可以展示并交给一名其他角色一张牌，然后其可以使用此牌。",

  ["#sxfy__mingjian"] = "明鉴：你可以展示并交给一名角色一张牌，其可以使用之",
  ["#sxfy__mingjian-use"] = "明鉴：你可以使用这张牌",
}

mingjian:addEffect("active", {
  anim_type = "support",
  prompt = "#sxfy__mingjian",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(mingjian.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local id = effect.cards[1]
    player:showCards(effect.cards)
    if not table.contains(player:getCardIds("he"), id) then return end
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, mingjian.name, nil, true, player)
    if not target.dead and table.contains(target:getCardIds("h"), id) then
      room:askToUseRealCard(target, {
        pattern = {id},
        skill_name = mingjian.name,
        prompt = "#sxfy__mingjian-use",
        extra_data = {
          bypass_times = true,
          extraUse = true,
        }
      })
    end
  end,
})

return mingjian
