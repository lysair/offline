local xiongxia = fk.CreateSkill {
  name = "sxfy__xiongxia",
}

Fk:loadTranslationTable{
  ["sxfy__xiongxia"] = "凶侠",
  [":sxfy__xiongxia"] = "出牌阶段，你可以将两张牌当【决斗】对两名其他角色使用，然后此牌结算结束后，若此牌对所有目标角色均造成过伤害，"..
  "此技能本回合失效。",

  ["#sxfy__xiongxia"] = "凶侠：你可以将两张牌当【决斗】对两名其他角色使用",
}

xiongxia:addEffect("active", {
  anim_type = "offensive",
  prompt = "#sxfy__xiongxia",
  card_num = 2,
  target_num = 2,
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    if #selected < 2 then
      local card = Fk:cloneCard("duel")
      card:addSubcards(selected)
      card:addSubcard(to_select)
      return not player:prohibitUse(card)
    end
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected_cards == 2 then
      local card = Fk:cloneCard("duel")
      card:addSubcards(selected_cards)
      card.skillName = xiongxia.name
      return card.skill:canUse(player, card) and not player:prohibitUse(card) and not player:isProhibited(to_select, card)
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:sortByAction(effect.tos)
    local use = room:useVirtualCard("duel", effect.cards, player, effect.tos, xiongxia.name)
    if use and use.damageDealt and use.damageDealt[effect.tos[1]] and use.damageDealt[effect.tos[2]] and not player.dead then
      room:invalidateSkill(player, xiongxia.name, "-turn")
    end
  end,
})

return xiongxia
