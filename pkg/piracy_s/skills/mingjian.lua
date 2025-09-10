local mingjian = fk.CreateSkill {
  name = "ofl__mingjian",
}

Fk:loadTranslationTable{
  ["ofl__mingjian"] = "明鉴",
  [":ofl__mingjian"] = "其他角色出牌阶段开始时，你可以展示手牌并将其中一种花色的所有牌交给该角色，然后其本回合使用的下一张牌额外结算一次。",

  ["#ofl__mingjian-invoke"] = "明鉴：你可以交给 %dest 一种花色的手牌，其本回合使用的下一张牌额外结算一次",
  ["@@ofl__mingjian-turn"] = "明鉴",
}

local U = require "packages/utility/utility"

mingjian:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(mingjian.name) and target.phase == Player.Play and not target.dead and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local listNames = {"log_spade", "log_club", "log_heart", "log_diamond"}
    local listCards = {{}, {}, {}, {}}
    for _, id in ipairs(player:getCardIds("h")) do
      local suit = Fk:getCardById(id).suit
      if suit ~= Card.NoSuit then
        table.insertIfNeed(listCards[suit], id)
      end
    end
    local choice = U.askForChooseCardList(room, player, listNames, listCards, 1, 1, mingjian.name, "#ofl__mingjian-invoke::"..target.id)
    if #choice == 1 then
      event:setCostData(self, {tos = {target}, cards = listCards[U.ConvertSuit(choice[1], "sym", "int")]})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:showCards(player:getCardIds("h"))
    if target.dead then return end
    room:addPlayerMark(target, "@@ofl__mingjian-turn", 1)
    local cards = table.filter(event:getCostData(self).cards, function (id)
      return table.contains(player:getCardIds("h"), id)
    end)
    if #cards > 0 then
      room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonGive, mingjian.name, nil, true, player)
    end
  end,
})

mingjian:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@ofl__mingjian-turn") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local n = player:getMark("@@ofl__mingjian-turn")
    player.room:setPlayerMark(player, "@@ofl__mingjian-turn", 0)
    if (data.card.type == Card.TypeBasic or data.card:isCommonTrick()) and #data.tos > 0 then
      data.additionalEffect = (data.additionalEffect or 0) + n
    end
  end,
})

return mingjian
