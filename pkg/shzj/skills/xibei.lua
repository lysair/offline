local xibei = fk.CreateSkill {
  name = "xibei",
}

Fk:loadTranslationTable{
  ["xibei"] = "袭惫",
  [":xibei"] = "当其他角色从牌堆以外的区域获得牌后，你可以摸一张牌，若此时为你的出牌阶段，你可以展示一张锦囊牌，此牌视为"..
  "<a href=':shzj__burning_camps'>【火烧连营】</a>直到本回合结束或离开你的手牌。",

  ["#xibei-show"] = "袭惫：你可以展示一张锦囊牌，将之视为【火烧连营】直到回合结束",
  ["@@xibei-inhand-turn"] = "袭惫",
}

xibei:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(xibei.name) then
      for _, move in ipairs(data) do
        if move.to and move.to ~= player and move.toArea == Player.Hand then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea ~= Card.DrawPile then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, xibei.name)
    if player.phase == Player.Play and not player.dead and not player:isKongcheng() then
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = xibei.name,
        pattern = ".|.|.|.|.|trick",
        prompt = "#xibei-show",
        cancelable = true,
      })
      if #card > 0 then
        player:showCards(card)
        if not player.dead and table.contains(player:getCardIds("h"), card[1]) then
          room:setCardMark(Fk:getCardById(card[1]), "@@xibei-inhand-turn", 1)
        end
      end
    end
  end,
})

xibei:addEffect("filter", {
  anim_type = "offensive",
  card_filter = function(self, card, player)
    return card:getMark("@@xibei-inhand-turn") > 0 and table.contains(player:getCardIds("h"), card.id)
  end,
  view_as = function(self, player, card)
    return Fk:cloneCard("shzj__burning_camps", card.suit, card.number)
  end,
})

return xibei
