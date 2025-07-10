
local chaofeng = fk.CreateSkill{
  name = "sxfy__chaofeng",
}

Fk:loadTranslationTable{
  ["sxfy__chaofeng"] = "朝凤",
  [":sxfy__chaofeng"] = "你可以将一张【闪】当【杀】使用。每阶段限一次，当你于出牌阶段使用【杀】时，你可以交给一名其他角色一张牌，"..
  "然后摸两张牌，若如此做，你弃置其装备区内的一张牌。",

  ["#sxfy__chaofeng"] = "朝凤：你可以将一张【闪】当【杀】使用",
  ["#sxfy__chaofeng-choose"] = "朝凤：你可以交给一名角色一张牌，摸两张牌，弃置其一张装备",
}

chaofeng:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash",
  prompt = "#sxfy__chaofeng",
  handly_pile = true,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "jink"
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = chaofeng.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_response = function (self, player, response)
    return not response
  end,
})

chaofeng:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(chaofeng.name) and
      data.card.trueName == "slash" and player.phase == Player.Play and
      not player:isNude() and #player.room:getOtherPlayers(player, false) > 0 and
      player:usedEffectTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to, cards = room:askToChooseCardsAndPlayers(player, {
      min_card_num = 1,
      max_card_num = 1,
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = chaofeng.name,
      prompt = "#sxfy__chaofeng-choose",
      cancelable = true,
    })
    if #to > 0 and #cards > 0 then
      event:setCostData(self, {tos = to, cards = cards})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, to, fk.ReasonGive, chaofeng.name, nil, false, player)
    if player.dead then return end
    player:drawCards(2, chaofeng.name)
    if player.dead or to.dead or #to:getCardIds("e") == 0 then return end
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "e",
      skill_name = chaofeng.name,
    })
    room:throwCard(card, chaofeng.name, to, player)
  end,
})

return chaofeng
