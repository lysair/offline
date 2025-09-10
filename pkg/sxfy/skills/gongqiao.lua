local gongqiao = fk.CreateSkill {
  name = "sxfy__gongqiao",
}

Fk:loadTranslationTable{
  ["sxfy__gongqiao"] = "工巧",
  [":sxfy__gongqiao"] = "出牌阶段限一次，你可以选择一名角色，连续亮出牌堆顶牌直到亮出装备牌，然后该角色使用此装备牌，"..
  "用所有手牌交换其余亮出的牌。",

  ["#sxfy__gongqiao"] = "工巧：选择一名角色，亮出牌直到亮出装备，然后其使用装备并用手牌交换其余亮出牌",
  ["#sxfy__gongqiao-use"] = "工巧：请使用%arg",
}

gongqiao:addEffect("active", {
  anim_type = "support",
  prompt = "#sxfy__gongqiao",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(gongqiao.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cards, id = {}, 0
    while true do
      local card = room:getNCards(1)
      room:turnOverCardsFromDrawPile(player, card, gongqiao.name)
      room:delay(500)
      if Fk:getCardById(card[1]).type == Card.TypeEquip then
        id = card[1]
        break
      end
      table.insertTable(cards, card)
    end
    local card = Fk:getCardById(id)
    if target:canUse(card) then
      if target:canUseTo(card, target) then
        room:useCard({
          from = target,
          tos = {target},
          card = card,
        })
      else
        room:askToUseRealCard(target, {
          pattern = {id},
          skill_name = gongqiao.name,
          prompt = "#sxfy__gongqiao-use:::"..card:toLogString(),
          cancelable = false,
        })
      end
    end
    if target.dead then
      room:cleanProcessingArea(cards)
      return
    end
    local moves = {}
    if not target:isKongcheng() then
      table.insert(moves, {
        ids = target:getCardIds("h"),
        from = target,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonJustMove,
        skillName = gongqiao.name,
        proposer = target,
      })
    end
    if #cards > 0 then
      table.insert(moves, {
        ids = cards,
        to = target,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        skillName = gongqiao.name,
        proposer = target,
      })
    end
    if #moves > 0 then
      room:moveCards(table.unpack(moves))
      return
    end
    room:cleanProcessingArea(cards)
  end,
})

return gongqiao
