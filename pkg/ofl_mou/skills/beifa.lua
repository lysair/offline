local beifa = fk.CreateSkill {
  name = "ofl_mou__beifa",
}

Fk:loadTranslationTable{
  ["ofl_mou__beifa"] = "北伐",
  [":ofl_mou__beifa"] = "出牌阶段，你可以弃置任意张手牌，令一名角色展示等量手牌，你可以依次将展示牌中你本次弃置过的牌名的牌"..
  "当无次数限制的【杀】使用。",

  ["#ofl_mou__beifa"] = "北伐：弃置任意手牌并令一名角色展示等量手牌，你可以将展示牌中与你弃置的同名牌当【杀】使用",
  ["#ofl_mou__beifa-show"] = "北伐：请展示%arg张手牌，%src 可以将其中与其弃置的同名牌当【杀】使用",
  ["#ofl_mou__beifa-use"] = "北伐；你可以将其中一张牌当无次数限制的【杀】使用",

  ["$ofl_mou__beifa1"] = "",
  ["$ofl_mou__beifa2"] = "",
}

beifa:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl_mou__beifa",
  min_card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(beifa.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select) and not player:prohibitDiscard(to_select)
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0 and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local n = #effect.cards
    local names = table.map(effect.cards, function(id)
      return Fk:getCardById(id).trueName
    end)
    room:throwCard(effect.cards, beifa.name, player, player)
    if target.dead or target:isKongcheng() then return end
    local cards = target:getCardIds("h")
    if #cards > n then
      cards = room:askToCards(target, {
        min_num = n,
        max_num = n,
        include_equip = false,
        skill_name = beifa.name,
        prompt = "#ofl_mou__beifa-show:"..player.id.."::"..n,
        cancelable = false,
      })
    end
    target:showCards(cards)
    cards = table.filter(cards, function(id)
      return table.contains(target:getCardIds("h"), id) and table.contains(names, Fk:getCardById(id).trueName)
    end)
    while not player.dead and #cards > 0 do
      local use = room:askToUseVirtualCard(player, {
        name = "slash",
        skill_name = beifa.name,
        prompt = "#ofl_mou__beifa-use",
        cancelable = true,
        extra_data = {
          bypass_times = true,
          expand_pile = cards,
        },
        card_filter = {
          n = 1,
          cards = cards,
        },
        skip = true,
      })
      if use then
        table.removeOne(cards, use.card.id)
        room:useCard(use)
      else
        return
      end
      cards = table.filter(cards, function(id)
        return table.contains(target:getCardIds("h"), id)
      end)
    end
  end,
})

return beifa
