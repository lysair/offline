local lianrong = fk.CreateSkill {
  name = "lianrong",
}

Fk:loadTranslationTable{
  ["lianrong"] = "怜容",
  [":lianrong"] = "当其他角色的<font color='red'>♥</font>牌因弃置进入弃牌堆后，你可以获得之。",

  ["#lianrong-choose"] = "怜容：选择要获得的牌",
  ["get_all"] = "全部获得",
}

lianrong:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(lianrong.name) then
      local ids = {}
      for _, move in ipairs(data) do
        if move.from and move.from ~= player and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).suit == Card.Heart then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
      ids = table.filter(ids, function (id)
        return table.contains(player.room.discard_pile, id)
      end)
      ids = player.room.logic:moveCardsHoldingAreaCheck(ids)
      if #ids > 0 then
        event:setCostData(self, {cards = ids})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(event:getCostData(self).cards)
    if #ids > 1 then
      local cards, _ = room:askToChooseCardsAndChoice(player, {
        cards = ids,
        choices = {"OK"},
        skill_name = lianrong.name,
        prompt = "#lianrong-choose",
        cancel_choices = {"get_all"},
        min_num = 1,
        max_num = #ids
      })
      if #cards > 0 then
        ids = cards
      end
    end
    room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, lianrong.name, nil, true, player)
  end,
})

return lianrong