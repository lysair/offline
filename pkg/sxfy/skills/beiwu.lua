local beiwu = fk.CreateSkill {
  name = "sxfy__beiwu",
}

Fk:loadTranslationTable{
  ["sxfy__beiwu"] = "备武",
  [":sxfy__beiwu"] = "你可以将装备区内一张不为本回合置入的牌当【无中生有】或【决斗】使用。",

  ["#sxfy__beiwu"] = "备武：将一张不是本回合进入装备区的牌当【无中生有】或【决斗】使用",
}

beiwu:addEffect("viewas", {
  anim_type = "special",
  pattern = "ex_nihilo,duel",
  prompt = "#sxfy__beiwu",
  interaction = function(self, player)
    local all_names = {"ex_nihilo", "duel"}
    local names = player:getViewAsCardNames(beiwu.name, all_names)
    return UI.CardNameBox { choices = names, all_choices = all_names }
  end,
  card_filter = function (self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getCardIds("e"), to_select) and
      not table.contains(player:getTableMark("sxfy__beiwu-turn"), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or self.interaction.data == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = beiwu.name
    card:addSubcards(cards)
    return card
  end,
  enabled_at_response = function (self, player, response)
    return not response and
      table.find(player:getCardIds("e"), function (id)
        return not table.contains(player:getTableMark("sxfy__beiwu-turn"), id) and
          #player:getViewAsCardNames(beiwu.name, {"ex_nihilo", "duel"}, {id}) > 0
      end)
  end,
})

beiwu:addEffect(fk.AfterCardsMove, {
  can_refresh = function (self, event, target, player, data)
    if player:hasSkill(beiwu.name, true) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerEquip then
          return true
        end
      end
    end
  end,
  on_refresh = function (self, event, target, player, data)
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Card.PlayerEquip then
        for _, info in ipairs(move.moveInfo) do
          player.room:addTableMarkIfNeed(player, "sxfy__beiwu-turn", info.cardId)
        end
      end
    end
  end,
})

beiwu:addAcquireEffect(function (self, player, is_start)
  if not is_start then
    local room = player.room
    local cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      for _, move in ipairs(e.data) do
        if move.to == player and move.toArea == Card.PlayerEquip then
          for _, info in ipairs(move.moveInfo) do
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end, Player.HistoryTurn)
    room:setPlayerMark(player, "sxfy__beiwu-turn", cards)
  end
end)

return beiwu
