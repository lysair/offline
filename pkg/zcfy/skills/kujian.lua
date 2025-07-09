local kujian = fk.CreateSkill{
  name = "sxfy__kujian",
}

Fk:loadTranslationTable{
  ["sxfy__kujian"] = "苦谏",
  [":sxfy__kujian"] = "出牌阶段限一次，你可以将一张手牌交给一名其他角色，其可以使用此牌令你与其各摸一张牌，否则你与其各弃置一张牌。",

  ["#sxfy__kujian"] = "远略：交给一名角色一张手牌，其使用此牌令你与其各摸一张牌，否则各弃一张牌",
  ["#sxfy__kujian-use"] = "远略：使用这张牌令 %src 与你各摸一张牌，否则各弃一张牌",
}

kujian:addEffect("active", {
  anim_type = "support",
  prompt = "#sxfy__kujian",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(kujian.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:moveCardTo(effect.cards, Card.PlayerHand, target, fk.ReasonGive, kujian.name, nil, false, player)
    if not target.dead and table.contains(target:getCardIds("h"), effect.cards[1]) then
      if room:askToUseRealCard(target, {
        pattern = effect.cards,
        skill_name = kujian.name,
        prompt = "#sxfy__kujian-use:"..player.id,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        }
      }) then
        if not player.dead then
          player:drawCards(1, kujian.name)
        end
        if not target.dead then
          target:drawCards(1, kujian.name)
        end
      else
        if not player.dead then
          room:askToDiscard(player, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = kujian.name,
            cancelable = false,
          })
        end
        if not target.dead then
          room:askToDiscard(target, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = kujian.name,
            cancelable = false,
          })
        end
      end
    end
  end,
})

return kujian
