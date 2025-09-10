local qingcheng = fk.CreateSkill {
  name = "sxfy__qingcheng",
}

Fk:loadTranslationTable{
  ["sxfy__qingcheng"] = "倾城",
  [":sxfy__qingcheng"] = "出牌阶段限一次，你可以将两张红色非锦囊牌当两张【乐不思蜀】分别对你和一名其他角色使用。",

  ["#sxfy__qingcheng"] = "倾城：选择两张红色非锦囊牌，当【乐不思蜀】分别对自己和一名其他角色使用",
}

qingcheng:addEffect("active", {
  anim_type = "control",
  prompt = "#sxfy__qingcheng",
  card_num = 2,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(qingcheng.name, Player.HistoryPhase) == 0 and
      not player:hasDelayedTrick("indulgence") and not table.contains(player.sealedSlots, Player.JudgeSlot)
  end,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected < 2 and Fk:getCardById(to_select).color == Card.Red and Fk:getCardById(to_select).type ~= Card.TypeTrick then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(to_select)
      if #selected == 0 then
        return not player:prohibitUse(card) and not player:isProhibited(player, card)
      elseif #selected == 1 then
        return not player:prohibitUse(card)
      end
    end
  end,
  target_filter = function (self, player, to_select, selected, selected_cards)
    if #selected_cards == 2 and #selected == 0 and to_select ~= player then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(selected_cards[2])
      return not player:prohibitUse(card) and not player:isProhibited(to_select, card)
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:useVirtualCard("indulgence", {effect.cards[1]}, player, player, qingcheng.name)
    if player.dead or target.dead then return end
    local id = effect.cards[2]
    if table.contains(table.connect(player:getCardIds("he"), player:getHandlyIds()), id) then
      local card = Fk:cloneCard("indulgence")
      card:addSubcard(id)
      if not player:prohibitUse(card) and not player:isProhibited(target, card) then
        room:useVirtualCard("indulgence", {id}, player, target, qingcheng.name)
      end
    end
  end,
})

return qingcheng
