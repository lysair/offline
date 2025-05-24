local zhiti = fk.CreateSkill {
  name = "ofl__zhiti",
}

Fk:loadTranslationTable{
  ["ofl__zhiti"] = "止啼",
  [":ofl__zhiti"] = "回合结束时，若你的手牌数小于2，你可以观看牌堆顶四张牌，获得其中任意张相同花色的牌。",

  ["#ofl__zhiti-prey"] = "止啼：你可以获得其中任意张相同花色的牌",
}

Fk:addPoxiMethod{
  name = "ofl__zhiti",
  prompt = "#ofl__zhiti-prey",
  card_filter = function(to_select, selected, data)
    if #selected == 0 then
      return Fk:getCardById(to_select).suit ~= Card.NoSuit
    else
      return Fk:getCardById(to_select):compareSuitWith(Fk:getCardById(selected[1]))
    end
  end,
  feasible = function(selected)
    return #selected > 0
  end,
}

zhiti:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhiti.name) and
      player:getHandcardNum() < 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local result = room:askToPoxi(player, {
      poxi_type = zhiti.name,
      data = { { "Top", room:getNCards(4) } },
      cancelable = true,
    })
    if #result > 0 then
      room:moveCardTo(result, Card.PlayerHand, player, fk.ReasonJustMove, zhiti.name, nil, false, player)
    end
  end,
})

return zhiti
