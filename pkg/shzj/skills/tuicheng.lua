local tuicheng = fk.CreateSkill {
  name = "shzj_juedai__tuicheng",
}

Fk:loadTranslationTable{
  ["shzj_juedai__tuicheng"] = "推诚",
  [":shzj_juedai__tuicheng"] = "出牌阶段限一次，你可以将一张伤害牌当无次数限制的基本牌对两名角色使用，然后令其中一名角色获得此牌。",

  ["#shzj_juedai__tuicheng"] = "推诚：将一张伤害牌当基本牌对两名角色使用，然后令其中一名角色获得此牌",
  ["#shzj_juedai__tuicheng-choose"] = "推诚：令一名目标获得%arg",
}

tuicheng:addEffect("active", {
  anim_type = "control",
  prompt = "#shzj_juedai__tuicheng",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("b")
    local names = player:getViewAsCardNames(tuicheng.name, all_names, {}, {}, { bypass_times = true })
    if #names == 0 then return end
    return UI.CardNameBox {choices = names, all_choices = all_names}
  end,
  can_use = function (self, player)
    return player:usedSkillTimes(tuicheng.name, Player.HistoryPhase) == 0
  end,
  handly_pile = true,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).is_damage_card
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if not self.interaction.data or #selected_cards ~= 1 then return end
    if #selected < 2 then
      local card = Fk:cloneCard(self.interaction.data)
      card.skillName = tuicheng.name
      card:addSubcards(selected_cards)
      return card.skill:modTargetFilter(player, to_select, selected, card, {bypass_distances = true, bypass_times = true})
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    return self.interaction.data and #selected_cards == 1 and #selected == 2
  end,
  on_use = function (self, room, effect)
    local player = effect.from
    local targets = effect.tos
    room:sortByAction(targets)
    room:useVirtualCard(self.interaction.data, effect.cards, player, targets, tuicheng.name, true)
    if not player.dead and table.contains(room.discard_pile, effect.cards[1]) then
      targets = table.filter(targets, function (p)
        return not p.dead
      end)
      if #targets > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = tuicheng.name,
          prompt = "#shzj_juedai__tuicheng-choose:::"..Fk:getCardById(effect.cards[1]):toLogString(),
          cancelable = false,
        })[1]
        room:moveCardTo(effect.cards[1], Card.PlayerHand, to, fk.ReasonJustMove, tuicheng.name, nil, true, player)
      end
    end
  end,
})

return tuicheng
