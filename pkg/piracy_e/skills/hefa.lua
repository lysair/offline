local hefa = fk.CreateSkill {
  name = "hefa",
}

Fk:loadTranslationTable{
  ["hefa"] = "合伐",
  [":hefa"] = "出牌阶段限一次，你可以将任意张手牌当一张无次数限制、指定等量名角色为目标的【杀】使用，此【杀】伤害后，你将手牌补至手牌上限。",

  ["#hefa"] = "合伐：将任意张手牌当指定等量目标的【杀】使用，造成伤害后摸牌至手牌上限",

  ["$hefa1"] = "放箭！放箭！",
  ["$hefa2"] = "箭支充足，尽管取用！",
}

hefa:addEffect("active", {
  anim_type = "offensive",
  prompt = "#hefa",
  handly_pile = true,
  min_card_num = 1,
  min_target_num = 1,
  can_use = function (self, player)
    return player:usedSkillTimes(hefa.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    if table.contains(player:getHandlyIds(), to_select) then
      local card = Fk:cloneCard("slash")
      card:addSubcards(selected)
      card:addSubcard(to_select)
      card.skillName = hefa.name
      return player:canUse(card, { bypass_times = true })
    end
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    if #selected_cards > 0 then
      local card = Fk:cloneCard("slash")
      card:addSubcards(selected_cards)
      card.skillName = hefa.name
      return #selected < #selected_cards and card.skill:modTargetFilter(player, to_select, selected, card, { bypass_times = true })
    end
  end,
  feasible = function (self, player, selected, selected_cards)
    return #selected == #selected_cards and #selected > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:sortByAction(effect.tos)
    local card = Fk:cloneCard("slash")
    card:addSubcards(effect.cards)
    card.skillName = hefa.name
    local use = {
      from = player,
      tos = effect.tos,
      card = card,
      extraUse = true,
      extra_data = {
        hefa = player,
      },
    }
    room:useCard(use)
  end,
})

hefa:addEffect(fk.Damage, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if not player.dead and player:getHandcardNum() < player:getMaxCards() then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      return use_event and (use_event.data.extra_data or {}).hefa == player
    end
  end,
  on_use = function (self, event, target, player, data)
    player:drawCards(player:getMaxCards() - player:getHandcardNum(), hefa.name)
  end,
})

return hefa
