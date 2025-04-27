local paiyi = fk.CreateSkill{
  name = "ofl__paiyi",
}

Fk:loadTranslationTable{
  ["ofl__paiyi"] = "排异",
  [":ofl__paiyi"] = "出牌阶段限一次，你可以将一张“权”置入弃牌堆，令一名角色摸X张牌（X为“权”数，至多为7），然后若其手牌数大于你，你对其造成1点伤害。",

  ["#ofl__paiyi"] = "排异：移去一张“权”，令一名角色摸%arg张牌，然后若其手牌数大于你，对其造成1点伤害",
}

paiyi:addEffect("active", {
  anim_type = "control",
  prompt = function (self, player, selected_cards, selected_targets)
    return "#ofl__paiyi:::"..(math.min(#player:getPile("zhonghui_quan") - 1, 7))
  end,
  card_num = 1,
  target_num = 1,
  expand_pile = "zhonghui_quan",
  can_use = function(self, player)
    return #player:getPile("zhonghui_quan") > 0 and player:usedSkillTimes(paiyi.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getPile("zhonghui_quan"), to_select)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
  local player = effect.from
  local target = effect.tos[1]
  room:moveCardTo(effect.cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, paiyi.name, nil, true, player)
  if target.dead or #player:getPile("zhonghui_quan") == 0 then return end
  target:drawCards(math.min(#player:getPile("zhonghui_quan"), 7), paiyi.name)
  if not target.dead and target:getHandcardNum() > player:getHandcardNum() then
    room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = paiyi.name,
      }
    end
  end,
})

return paiyi
