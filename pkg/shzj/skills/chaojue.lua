local chaojue = fk.CreateSkill {
  name = "chaojue",
}

Fk:loadTranslationTable{
  ["chaojue"] = "超绝",
  [":chaojue"] = "准备阶段，你可以弃置一张手牌，令所有其他角色本回合不能使用或打出与此牌花色相同的牌，"..
  "然后这些角色依次选择一项：1.展示并交给你一张相同花色的手牌；2.其本回合所有非锁定技失效。",

  ["#chaojue-invoke"] = "超绝：是否弃置一张手牌，令所有其他角色本回合不能使用打出此花色的牌？",
  ["#chaojue-give"] = "超绝：交给 %src 一张%arg手牌，否则本回合非锁定技失效",
  ["@@chaojue-turn"] ="非锁定技失效",
  ["@chaojue-turn"] = "超绝",
}

chaojue:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chaojue.name) and player.phase == Player.Start and
      not player:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = chaojue.name,
      cancelable = true,
      prompt = "#chaojue-invoke",
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {tos = room:getOtherPlayers(player, false), cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(event:getCostData(self).cards[1])
    room:throwCard(card, chaojue.name, player, player)
    if player.dead then return end
    if card.suit ~= Card.NoSuit then
      for _, p in ipairs(room:getOtherPlayers(player, false)) do
        room:addTableMarkIfNeed(p, "@chaojue-turn", card:getSuitString(true))
      end
    end
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if player.dead then return end
      if not p.dead then
        local cards = {}
        if card.suit ~= Card.NoSuit and not p:isKongcheng() then
          cards = room:askToCards(p, {
            min_num = 1,
            max_num = 1,
            include_equip = false,
            skill_name = chaojue.name,
            pattern = ".|.|"..card:getSuitString(),
            prompt = "#chaojue-give:"..player.id.."::"..card:getSuitString(true),
            cancelable = true,
          })
        end
        if #cards > 0 then
          room:obtainCard(player, cards, true, fk.ReasonGive, p, chaojue.name)
        else
          room:addPlayerMark(p, "@@chaojue-turn")
          room:addPlayerMark(p, MarkEnum.UncompulsoryInvalidity .. "-turn")
        end
      end
    end
  end,
})

chaojue:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    return card and table.contains(player:getTableMark("@chaojue-turn"), card:getSuitString(true))
  end,
  prohibit_response = function(self, player, card)
    return card and table.contains(player:getTableMark("@chaojue-turn"), card:getSuitString(true))
  end,
})

return chaojue
