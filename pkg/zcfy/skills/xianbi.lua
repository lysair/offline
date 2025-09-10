local xianbi = fk.CreateSkill{
  name = "sxfy__xianbi",
}

Fk:loadTranslationTable{
  ["sxfy__xianbi"] = "险诐",
  [":sxfy__xianbi"] = "出牌阶段限一次，你可以将手牌调整至与一名角色装备区里的牌数相同。",

  ["#sxfy__xianbi"] = "险诐：将手牌调整至一名角色装备区牌数",
}

xianbi:addEffect("active", {
  anim_type = "drawcard",
  prompt = "#sxfy__xianbi",
  min_card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xianbi.name, Player.HistoryPhase) == 0
  end,
  card_filter = function (self, player, to_select, selected)
    return table.contains(player:getCardIds("h"), to_select) and not player:prohibitDiscard(to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected == 0 and not table.contains(player:getTableMark("zenrun"), to_select.id) then
      if player:getHandcardNum() > #to_select:getCardIds("e") then
        return #to_select:getCardIds("e") + #selected_cards == player:getHandcardNum()
      elseif player:getHandcardNum() < #to_select:getCardIds("e") then
        return true
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if #effect.cards > 0 then
      room:throwCard(effect.cards, xianbi.name, player, player)
    else
      player:drawCards(#target:getCardIds("e") - player:getHandcardNum(), xianbi.name)
    end
  end,
})

return xianbi
