local jinfa = fk.CreateSkill {
  name = "ofl__jinfa",
}

Fk:loadTranslationTable{
  ["ofl__jinfa"] = "矜伐",
  [":ofl__jinfa"] = "出牌阶段限一次，你可以弃置一张牌并选择一名其他角色，令其选择一项：1.你获得其一张牌；2.交给你一张装备牌，若为♠，"..
  "其视为对你使用一张【杀】。",

  ["#ofl__jinfa"] = "矜伐：弃置一张牌，令一名角色选择你获得其一张牌或其交给你一张装备牌",
  ["ofl__jinfa_give"] = "矜伐：交给 %src 一张装备牌，否则其获得你一张牌",

  ["$ofl__jinfa1"] = "居功者，当自矜，为将者，当善伐。",
  ["$ofl__jinfa2"] = "此战伐敌所获，皆我之功。",
}

jinfa:addEffect("active", {
  mute = true,
  prompt = "#ofl__jinfa",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(jinfa.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and not to_select:isNude() and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    player:broadcastSkillInvoke("ld__jinfa")
    room:notifySkillInvoked(player, jinfa.name, "control")
    room:throwCard(effect.cards, jinfa.name, player, player)
    if target.dead then return end
    local card = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      pattern = ".|.|.|.|.|equip",
      prompt = "ofl__jinfa_give:" .. player.id,
      skill_name = jinfa.name,
    })
    if #card == 1 then
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, jinfa.name, nil, true, target)
      if Fk:getCardById(card[1]).suit == Card.Spade and not player.dead and not target.dead then
        room:useVirtualCard("slash", nil, target, player, jinfa.name, true)
      end
    else
      card = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = jinfa.name,
      })
      room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonPrey, jinfa.name, nil, true, player)
    end
  end,
})

return jinfa
