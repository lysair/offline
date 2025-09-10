local zhiheng = fk.CreateSkill {
  name = "ofl_mou__zhiheng",
}

Fk:loadTranslationTable{
  ["ofl_mou__zhiheng"] = "制衡",
  [":ofl_mou__zhiheng"] = "出牌阶段限一次，你可以弃置至少一张牌，然后摸等量的牌，若你以此法弃置了装备区里的牌，则你多摸一张牌。",

  ["#ofl_mou__zhiheng"] = "制衡：弃置任意牌并摸等量牌，若弃置装备区的牌则多摸一张",

  ["$ofl_mou__zhiheng1"] = "权者万变，非制衡不可取之。",
  ["$ofl_mou__zhiheng2"] = "内制朝臣乱政，外衡天下时局。",
}

zhiheng:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#ofl_mou__zhiheng",
  min_card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(zhiheng.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return not player:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local n = #effect.cards
    if table.find(player:getCardIds("e"), function(id)
      return table.contains(effect.cards, id)
    end) then
      n = n + 1
    end
    room:throwCard(effect.cards, zhiheng.name, player, player)
    if not player.dead then
      player:drawCards(n, zhiheng.name)
    end
  end,
})

return zhiheng
