local jiefeng = fk.CreateSkill {
  name = "ofl__jiefeng",
}

Fk:loadTranslationTable{
  ["ofl__jiefeng"] = "借风",
  [":ofl__jiefeng"] = "出牌阶段，你可以弃置两张手牌，然后亮出牌堆顶五张牌，若其中有至少两张红色牌，你视为使用一张【万箭齐发】。",

  ["#ofl__jiefeng"] = "借风：弃置两张手牌，亮出牌堆顶五张牌，若有两张红色则你视为使用【万箭齐发】",
}

jiefeng:addEffect("active", {
  anim_type = "offensive",
  prompt = "#ofl__jiefeng",
  card_num = 2,
  target_num = 0,
  card_filter = function (self, player, to_select, selected)
    return #selected < 2 and table.contains(player:getCardIds("h"), to_select) and not player:prohibitDiscard(to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    room:throwCard(effect.cards, jiefeng.name, player, player)
    local cards = room:getNCards(5)
    local yes = #table.filter(cards, function (id)
      return Fk:getCardById(id).color == Card.Red
    end) > 1
    room:turnOverCardsFromDrawPile(player, cards, jiefeng.name)
    room:delay(2000)
    room:cleanProcessingArea(cards)
    if not yes or player.dead then return end
    local tos = table.filter(room.alive_players, function(p)
      return player:canUseTo(Fk:cloneCard("archery_attack"), p)
    end)
    if #tos > 0 then
      room:sortByAction(tos)
      room:useVirtualCard("archery_attack", nil, player, tos, jiefeng.name)
    end
  end,
})

return jiefeng