local yure = fk.CreateSkill {
  name = "ofl__yure"
}

Fk:loadTranslationTable{
  ['ofl__yure'] = '余热',
  ['#ofl__yure-give'] = '余热：你可以将弃置的牌分配给其他角色',
  [':ofl__yure'] = '限定技，当你弃置牌后，你可以将所有弃置的牌交给任意名其他角色。',
}

yure:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(yure.name) or player.room:getOtherPlayers(player, false) == 0 or
      player:usedSkillTimes(yure.name, Player.HistoryGame) > 0 then return end
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    cards = table.filter(cards, function(id) return player.room:getCardArea(id) == Card.DiscardPile end)
    cards = U.moveCardsHoldingAreaCheck(player.room, cards)
    if #cards > 0 then
      event:setCostData(skill, {cards = cards})
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(skill).cards
    local move = room:askToYiji(player, {
      cards = cards,
      targets = room:getOtherPlayers(player, false),
      skill_name = yure.name,
      min_num = 0,
      max_num = #cards,
      prompt = "#ofl__yure-give",
      expand_pile = cards,
      skip = true
    })
    local check
    for _, cds in pairs(move) do
      if #cds > 0 then
        check = true
        break
      end
    end
    if check then
      event:setCostData(skill, move)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doYiji(event:getCostData(skill), player.id, yure.name)
  end,
})

return yure
