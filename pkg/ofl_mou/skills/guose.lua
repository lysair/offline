local guose = fk.CreateSkill {
  name = "ofl_mou__guose",
}

Fk:loadTranslationTable{
  ["ofl_mou__guose"] = "国色",
  [":ofl_mou__guose"] = "出牌阶段限一次，你可以将一张<font color='red'>♦</font>牌当【乐不思蜀】使用，或移动场上一张【乐不思蜀】。",

  ["ofl_mou__guose_use"] = "使用【乐不思蜀】",
  ["ofl_mou__guose_move"] = "移动【乐不思蜀】",
  ["#ofl_mou__guose_use"] = "国色：将一张<font color='red'>♦</font>牌当【乐不思蜀】使用",
  ["#ofl_mou__guose_move"] = "国色：移动场上一张【乐不思蜀】",

  ["$ofl_mou__guose1"] = "逢郎欲语含羞笑，还走香囊投君怀。",
  ["$ofl_mou__guose2"] = "凝眸望君浅笑，换君片刻停留。",
}

guose:addEffect("active", {
  anim_type = "control",
  min_card_num = 0,
  max_card_num = 1,
  min_target_num = 1,
  max_target_num = 1,
  prompt = function (self)
    return "#"..self.interaction.data
  end,
  interaction = UI.ComboBox {choices = { "ofl_mou__guose_use", "ofl_mou__guose_move"} },
  can_use = function(self, player)
    return player:usedSkillTimes(guose.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    if self.interaction.data == "ofl_mou__guose_use" then
      if #selected > 0 or Fk:getCardById(to_select).suit ~= Card.Diamond then return end
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(to_select)
      return player:canUse(card) and not player:prohibitUse(card)
    else
      return false
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if self.interaction.data == "ofl_mou__guose_use" and #selected_cards == 1 then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(selected_cards[1])
      return to_select ~= player and not player:isProhibited(to_select, card)
    elseif self.interaction.data == "ofl_mou__guose_move" then
      if #selected == 0 then
        return to_select:hasDelayedTrick("indulgence")
      elseif #selected == 1 then
        for _, id in ipairs(selected[1]:getCardIds("j")) do
          local card = selected[1]:getVirualEquip(id)
          if not card then card = Fk:getCardById(id) end
          if card.name == "indulgence" and selected[1]:canMoveCardInBoardTo(to_select, id) then
            return true
          end
        end
      end
    end
  end,
  feasible = function (self, player, selected, selected_cards)
    if self.interaction.data == "ofl_mou__guose_use" then
      return #selected == 1 and #selected_cards == 1
    else
      if #selected == 2 and #selected_cards == 0 then
        for _, id in ipairs(selected[1]:getCardIds("j")) do
          local card = selected[1]:getVirualEquip(id)
          if not card then card = Fk:getCardById(id) end
          if card.name == "indulgence" and selected[1]:canMoveCardInBoardTo(selected[2], id) then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    if self.interaction.data == "ofl_mou__guose_use" then
      local target = effect.tos[1]
      room:useVirtualCard("indulgence", effect.cards, player, target, guose.name)
    elseif self.interaction.data == "ofl_mou__guose_move" then
      local targets = effect.tos
      local excludeIds = {}
      for _, id in ipairs(targets[1]:getCardIds("j")) do
        local card = targets[1]:getVirualEquip(id)
        if not card then card = Fk:getCardById(id) end
        if card.name == "indulgence" and targets[1]:canMoveCardInBoardTo(targets[2], id) and
          not targets[2]:isProhibited(targets[2], card) then
        else
          table.insert(excludeIds, id)
        end
      end
      room:askToMoveCardInBoard(player, {
        target_one = targets[1],
        target_two = targets[2],
        skill_name = guose.name,
        flag = "j",
        move_from = targets[1],
        exclude_ids = excludeIds,
      })
    end
  end,
})

return guose
