local yibing = fk.CreateSkill {
  name = "yibing",
}

Fk:loadTranslationTable{
  ["yibing"] = "义兵",
  [":yibing"] = "当你于摸牌阶段外获得牌后，你可以将这些牌当无距离次数限制的【杀】使用，此【杀】结算结束前，你不能发动〖义兵〗。",

  ["#yibing-slash"] = "义兵：你可以将这些牌当无距离次数限制的【杀】使用（直接选择【杀】的目标）",
}

yibing:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(yibing.name) and player:getMark(yibing.name) == 0 then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand and player.phase ~= Player.Draw then
          for _, info in ipairs(move.moveInfo) do
            if table.contains(player:getCardIds("h"), info.cardId) then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local cards = {}
    for _, move in ipairs(data) do
      if move.to == player and move.toArea == Player.Hand then
        for _, info in ipairs(move.moveInfo) do
          if table.contains(player:getCardIds("h"), info.cardId) then
            table.insertIfNeed(cards, info.cardId)
          end
        end
      end
    end
    event:setCostData(self, {cards = cards})
    self:doCost(event, nil, player, data)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = yibing.name,
      prompt = "#yibing-slash",
      cancelable = true,
      skip = true,
      subcards = cards,
      extra_data = {
        bypass_distances = true,
        bypass_times = true,
        extraUse = true,
      }
    })
    if use then
      event:setCostData(self, {extra_data = use})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, yibing.name, 1)
    room:useCard(event:getCostData(self).extra_data)
    room:setPlayerMark(player, yibing.name, 0)
  end,
})

return yibing
